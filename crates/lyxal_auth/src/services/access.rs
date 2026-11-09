//! Connexion, sessions et parcours : orchestration des fonctions SurrealQL du lot 3 par l'hôte.
//!
//! Ce service tourne sur la **session système** de l'hôte. Il ne fait que ce qui relève du
//! système : vérification et hachage des mots de passe, génération des jetons, codes et liens,
//! empreintes, scellement, signature des jetons d'accès. Les règles (états, unicité, tentatives,
//! verrouillage, actions imposées, droits) restent dans les fonctions `fn::auth_*`.

use lyxal_crypto::{
    blake3_hex, sign_hmac_sha256_hex, CryptoEngine, KeyResolver, SecretBytes, SecretContext,
    SecretString,
};
use lyxal_surreal::ToSql;
use rand_core::{OsRng, RngCore};
use std::sync::Arc;
use zeroize::Zeroizing;

use crate::error::{AuthError, AuthResult};
use crate::models::{
    AddressChangeConfirmParams, AddressChangeRequestParams, AddressVerifyParams,
    ApiKeySessionParams, AssuranceCheckParams, ClientInfo, CodeIssueParams, CodeVerifyParams, Flow,
    FlowGetParams, FlowStartParams, FlowSubmitParams, IdentityGetParams, LoginFailureParams,
    LoginFailureResetParams, LoginRequirements, LoginRequirementsParams, MfaFailureKeyParams,
    MfaFailureParams, PasswordCredentialParams, PasswordSetParams, PolicyGetParams,
    RegistrationCompleteParams, RegistrationStartParams, RegistrationStarted,
    RequiredActionCompleteParams, ServiceSessionParams, SessionCaller, SessionCreateParams,
    SessionReauthenticateParams, SessionRefreshParams, SessionRevokeAllParams, SessionRevokeParams,
    SessionSwitchParams, SetupStartParams,
};
use crate::services::keys::SigningKeyService;
use crate::services::mfa::{MfaActor, MfaService, PasskeyChallenge, PasskeyConfig};
use crate::services::password::{PasswordCheck, PasswordPolicy, PasswordService};
use crate::services::tokens::{
    access_token, opaque_token, token_hash, token_slot, verify_access_token, IssuedTokens,
    OpaqueToken,
};
use crate::store::AuthStore;

/// Configuration du service.
#[derive(Debug, Clone)]
pub struct AccessConfig {
    /// Espace de noms SurrealDB (claim `ns`).
    pub namespace: String,
    /// Base SurrealDB (claim `db`).
    pub database: String,
    /// Adresse publique de l'interface (`https://…`), pour les liens des messages ; son origine
    /// est celle des passkeys.
    pub public_url: String,
    /// Nom affiché par les applications d'authentification et les appareils (passkeys).
    pub issuer: String,
    /// Identifiant de partie de confiance des passkeys (domaine) ; défaut : hôte de `public_url`.
    pub passkey_rp_id: Option<String>,
}

/// Demande de connexion.
pub struct LoginRequest {
    /// Identifiant (e-mail).
    pub identifier: String,
    /// Mot de passe.
    pub password: SecretString,
    /// Organisation active demandée (texte `auth_organization:<clé>`).
    pub organization: Option<String>,
    /// Appareil.
    pub client: ClientInfo,
}

/// Issue d'une connexion.
#[derive(Debug)]
pub enum LoginOutcome {
    /// Session ouverte.
    Authenticated(Box<IssuedTokens>),
    /// Actions à faire avant toute session (dans le parcours `flow`).
    ActionRequired {
        /// Parcours de connexion.
        flow: String,
        /// Actions restantes.
        actions: Vec<String>,
    },
    /// Second facteur à présenter avant toute session (dans le parcours `flow`).
    MfaRequired {
        /// Parcours de connexion.
        flow: String,
        /// Seconds facteurs utilisables (`totp`, `passkey`, `recovery_code`).
        methods: Vec<String>,
    },
}

/// Second facteur présenté.
pub enum MfaProof {
    /// Code de l'application d'authentification.
    Totp(SecretString),
    /// Code de secours.
    RecoveryCode(SecretString),
    /// Réponse au défi passkey gardé dans le parcours `flow`.
    Passkey {
        /// Parcours qui garde le défi.
        flow: String,
        /// Réponse WebAuthn du navigateur (JSON).
        response: serde_json::Value,
    },
}

impl MfaProof {
    /// Méthode (`totp`, `recovery_code`, `passkey`).
    pub fn method(&self) -> &'static str {
        match self {
            Self::Totp(_) => "totp",
            Self::RecoveryCode(_) => "recovery_code",
            Self::Passkey { .. } => "passkey",
        }
    }
}

/// Preuve d'une réauthentification.
pub enum ReauthProof {
    /// Mot de passe (identité sans second facteur).
    Password(SecretString),
    /// Second facteur.
    Mfa(MfaProof),
}

/// Réponses aux actions imposées d'un parcours de connexion.
#[derive(Default)]
pub struct LoginActions {
    /// Nouveau mot de passe (`update_password`).
    pub new_password: Option<SecretString>,
    /// Conditions acceptées (`accept_terms`).
    pub accept_terms: bool,
}

/// Code ou lien présenté pour un parcours.
pub enum CodeProof {
    /// Code à 6 chiffres reçu par message, avec son parcours.
    Code {
        /// Parcours.
        flow: String,
        /// Code.
        code: SecretString,
    },
    /// Jeton du lien reçu par message.
    Link(SecretString),
}

/// Service de connexion et de sessions.
pub struct AccessService<R: KeyResolver> {
    store: AuthStore,
    crypto: Arc<CryptoEngine<R>>,
    keys: Arc<SigningKeyService<R>>,
    passwords: PasswordService<R>,
    mfa: MfaService<R>,
    config: AccessConfig,
}

impl<R: KeyResolver + 'static> AccessService<R> {
    /// Service sur la session système de l'hôte, son trousseau et ses clés.
    pub fn new(
        store: AuthStore,
        crypto: Arc<CryptoEngine<R>>,
        keys: Arc<SigningKeyService<R>>,
        config: AccessConfig,
    ) -> AuthResult<Self> {
        if !(config.public_url.starts_with("https://") || config.public_url.starts_with("http://"))
            || config.public_url.contains(['?', '#', '"', '\\', ' '])
        {
            return Err(AuthError::InvalidParameter("public_url"));
        }
        let origin = webauthn_rs::prelude::Url::parse(&config.public_url)
            .map_err(|_| AuthError::InvalidParameter("public_url"))?;
        let host = origin
            .host_str()
            .ok_or(AuthError::InvalidParameter("public_url"))?
            .to_string();
        let mfa = MfaService::new(
            store.clone(),
            crypto.clone(),
            keys.clone(),
            config.issuer.clone(),
            Some(PasskeyConfig {
                rp_id: config.passkey_rp_id.clone().unwrap_or(host),
                origin: origin.origin().ascii_serialization(),
                rp_name: config.issuer.clone(),
            }),
        )?;
        Ok(Self {
            passwords: PasswordService::new(crypto.clone()),
            mfa,
            store,
            crypto,
            keys,
            config,
        })
    }

    /// Store de la session système.
    pub fn store(&self) -> &AuthStore {
        &self.store
    }

    /// Service des seconds facteurs (enrôlement, liste, codes de secours).
    pub fn mfa(&self) -> &MfaService<R> {
        &self.mfa
    }

    /// Acteur d'une session interactive (gestion de ses facteurs).
    pub fn session_actor(caller: &SessionCaller) -> AuthResult<MfaActor> {
        let identity = caller
            .identity
            .as_ref()
            .map(|id| id.to_sql())
            .ok_or(AuthError::Rejected("AUTH_PERMISSION_DENIED"))?;
        if caller.kind != "interactive" {
            return Err(AuthError::Rejected("AUTH_PERMISSION_DENIED"));
        }
        Ok(MfaActor {
            identity,
            session: Some(caller.session.to_sql()),
            flow: None,
        })
    }

    /// Acteur d'un parcours de connexion en attente d'actions (`configure_mfa`) ; la base
    /// revérifie que le double facteur est bien à configurer.
    pub async fn login_actor(&self, flow: &str) -> AuthResult<MfaActor> {
        Ok(MfaActor {
            identity: self.login_flow_identity(flow).await?,
            session: None,
            flow: Some(flow.to_string()),
        })
    }

    /// Exigence d'une action sensible : AAL la plus haute disponible et authentification récente.
    pub async fn require_fresh(&self, session: &str) -> AuthResult<()> {
        self.store
            .assurance_check(AssuranceCheckParams {
                session: Some(session.to_string()),
                min_aal: "highest_available".to_string(),
                fresh: true,
            })
            .await?;
        Ok(())
    }

    // ------------------------------------------------------------------------------------------
    // Connexion et sessions
    // ------------------------------------------------------------------------------------------

    /// Identifie l'appelant d'un jeton d'accès : signature et validité vérifiées avec la clé de
    /// son emplacement, puis session contrôlée par la base (`fn::auth_session_check` : révocation,
    /// expiration, sujet, version des droits).
    pub async fn authenticate(
        &self,
        token: &SecretString,
    ) -> AuthResult<crate::models::SessionCaller> {
        let slot = token_slot(token)?;
        let key = self.keys.verification_key(&slot).await?;
        let claims =
            verify_access_token(&key, token, &self.config.namespace, &self.config.database)?;
        Ok(self
            .store
            .session_check(crate::models::SessionCheckParams {
                session: claims.session,
                pv: claims.pv,
            })
            .await?)
    }

    /// Connexion par mot de passe : verrouillage contrôlé, échec compté (identifiant inconnu
    /// compris), message unique `AUTH_CREDENTIALS_INVALID`, actions imposées avant toute session.
    pub async fn login(&self, request: LoginRequest) -> AuthResult<LoginOutcome> {
        let credential = self
            .store
            .password_credential_get(PasswordCredentialParams {
                identifier: request.identifier.clone(),
            })
            .await
            .map_err(|_| AuthError::Rejected("AUTH_CREDENTIALS_INVALID"))?;
        let failure = LoginFailureParams {
            identifier_hash: blake3_hex(credential.identifier.as_bytes()),
            ip_hash: request
                .client
                .ip
                .as_deref()
                .map(|ip| blake3_hex(ip.as_bytes())),
            identity: credential.identity.as_ref().map(|id| id.to_sql()),
        };
        if self
            .store
            .login_failure_check(failure.clone())
            .await?
            .locked
        {
            return Err(AuthError::Rejected("AUTH_TOO_MANY_ATTEMPTS"));
        }
        let identity = credential.identity.as_ref().map(|id| id.to_sql());
        let check = self
            .passwords
            .verify(
                &request.password,
                identity.as_deref(),
                credential.secret.as_deref(),
            )
            .await?;
        let (Some(identity), PasswordCheck::Valid { needs_rehash }) = (identity, check) else {
            let status = self.store.login_failure_record(failure).await?;
            return Err(AuthError::Rejected(if status.locked {
                "AUTH_TOO_MANY_ATTEMPTS"
            } else {
                "AUTH_CREDENTIALS_INVALID"
            }));
        };
        // Mot de passe juste : l'état du compte peut être dit
        match credential.state.as_deref() {
            Some("active") => {}
            Some("locked") => return Err(AuthError::Rejected("AUTH_IDENTITY_LOCKED")),
            _ => return Err(AuthError::Rejected("AUTH_IDENTITY_INACTIVE")),
        }
        self.store
            .login_failure_reset(LoginFailureResetParams {
                identifier_hash: failure.identifier_hash.clone(),
            })
            .await?;
        if needs_rehash {
            let policy = self.password_policy().await?;
            let sealed = self
                .passwords
                .seal_new(
                    &identity,
                    &request.password,
                    PasswordPolicy {
                        history: 0,
                        ..policy
                    },
                    None,
                )
                .await?;
            self.store
                .password_set(PasswordSetParams {
                    identity: identity.clone(),
                    secret: sealed,
                    revoke_sessions: false,
                    except_session: None,
                })
                .await?;
        }
        self.next_step(
            &identity,
            request.organization,
            vec!["password".into()],
            None,
            request.client,
        )
        .await
    }

    /// Second facteur d'une connexion (parcours `mfa_required`) : vérifié, puis actions imposées
    /// s'il en reste, sinon session AAL2.
    pub async fn complete_login_mfa(
        &self,
        flow: &str,
        proof: MfaProof,
        client: ClientInfo,
    ) -> AuthResult<LoginOutcome> {
        let current = self.flow(flow).await?;
        if current.flow_type != "login" || current.state != "mfa_required" {
            return Err(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"));
        }
        let identity = current
            .identity
            .as_ref()
            .map(|id| id.to_sql())
            .ok_or(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"))?;
        let method = proof.method();
        if !current.methods.iter().any(|m| m == method) {
            return Err(AuthError::Rejected("AUTH_MFA_METHOD_DISABLED"));
        }
        if let MfaProof::Passkey {
            flow: challenge, ..
        } = &proof
        {
            if challenge != flow {
                return Err(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"));
            }
        }
        let organization = current.organization.as_ref().map(|id| id.to_sql());
        self.verify_second_factor(&identity, organization.clone(), Some(flow), "login", proof)
            .await?;
        self.next_step(
            &identity,
            organization,
            vec!["password".into(), method.into()],
            Some(flow.to_string()),
            client,
        )
        .await
    }

    /// Défi passkey d'un parcours de connexion `mfa_required`.
    pub async fn login_passkey_options(&self, flow: &str) -> AuthResult<serde_json::Value> {
        let current = self.flow(flow).await?;
        if current.flow_type != "login"
            || current.state != "mfa_required"
            || !current.methods.iter().any(|m| m == "passkey")
        {
            return Err(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"));
        }
        let identity = current
            .identity
            .as_ref()
            .map(|id| id.to_sql())
            .ok_or(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"))?;
        self.mfa.passkey_challenge(&identity, flow).await
    }

    /// Défi de connexion sans mot de passe (passkey découvrable).
    pub async fn passkey_login_options(&self) -> AuthResult<PasskeyChallenge> {
        self.mfa.passkey_login_options().await
    }

    /// Connexion sans mot de passe : passkey vérifiée (vérification de l'utilisateur), puis
    /// actions imposées éventuelles, puis session AAL2.
    pub async fn passkey_login(
        &self,
        flow: &str,
        response: serde_json::Value,
        client: ClientInfo,
    ) -> AuthResult<LoginOutcome> {
        let login = self.mfa.passkey_login(flow, response).await?;
        // Passkeys désactivées par la politique : la clé, même valide, n'authentifie pas
        if !self
            .requirements(&login.identity, None)
            .await?
            .methods
            .iter()
            .any(|m| m == "passkey")
        {
            return Err(AuthError::Rejected("AUTH_MFA_METHOD_DISABLED"));
        }
        self.next_step(&login.identity, None, vec!["passkey".into()], None, client)
            .await
    }

    /// Défi passkey d'une réauthentification de la session de l'appelant.
    pub async fn reauthenticate_options(
        &self,
        caller: &SessionCaller,
    ) -> AuthResult<PasskeyChallenge> {
        let actor = Self::session_actor(caller)?;
        let flow = self
            .store
            .flow_start(FlowStartParams {
                flow_type: "reauthentication".to_string(),
                identity: Some(actor.identity.clone()),
                session: actor.session.clone(),
                methods: vec!["passkey".to_string()],
                ..FlowStartParams::default()
            })
            .await?
            .id
            .to_sql();
        let options = self.mfa.passkey_challenge(&actor.identity, &flow).await?;
        Ok(PasskeyChallenge { flow, options })
    }

    /// Réauthentifie la session de l'appelant (mot de passe si l'identité n'a pas de second
    /// facteur, second facteur sinon) ; nouveau jeton d'accès, AAL2 par un second facteur.
    pub async fn reauthenticate(
        &self,
        caller: &SessionCaller,
        proof: ReauthProof,
    ) -> AuthResult<IssuedTokens> {
        let actor = Self::session_actor(caller)?;
        let session = caller.session.to_sql();
        let method = match proof {
            ReauthProof::Password(password) => {
                self.verify_password_counted(&actor.identity, &password)
                    .await?;
                "password"
            }
            ReauthProof::Mfa(proof) => {
                let challenge = match &proof {
                    MfaProof::Passkey { flow, .. } => Some(flow.clone()),
                    _ => None,
                };
                let method = self
                    .verify_second_factor(
                        &actor.identity,
                        caller.organization.as_ref().map(|id| id.to_sql()),
                        challenge.as_deref(),
                        "reauthentication",
                        proof,
                    )
                    .await?;
                if let Some(flow) = challenge {
                    self.store
                        .flow_submit(FlowSubmitParams {
                            flow,
                            from: vec!["started".into()],
                            state: "completed".into(),
                            ..FlowSubmitParams::default()
                        })
                        .await?;
                }
                method
            }
        };
        let key = self.keys.signing_key().await?;
        let issued = self
            .store
            .session_reauthenticate(SessionReauthenticateParams {
                session,
                method: method.to_string(),
                access_slot: key.slot.clone(),
            })
            .await?;
        self.tokens(issued, None).await
    }

    /// Envoie le code de vérification d'adresse depuis un parcours de connexion qui attend
    /// `verify_email` (mot de passe déjà vérifié, aucune session encore). Le code se présente
    /// ensuite à `complete_verification`, puis le parcours de connexion reprend par
    /// `complete_login_actions`.
    pub async fn start_login_verification(
        &self,
        flow: &str,
        client: ClientInfo,
    ) -> AuthResult<String> {
        let identity = self.login_flow_identity(flow).await?;
        let organization = self.flow(flow).await?.organization.map(|id| id.to_sql());
        if !self
            .requirements(&identity, organization)
            .await?
            .required_actions
            .iter()
            .any(|a| a == "verify_email")
        {
            return Err(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"));
        }
        self.start_verification(&identity, client).await
    }

    /// Termine les actions imposées d'un parcours de connexion (`update_password`,
    /// `accept_terms`) ; `verify_email` se fait par le parcours de vérification
    /// (`start_login_verification`). Session ouverte quand plus rien n'est requis.
    pub async fn complete_login_actions(
        &self,
        flow: &str,
        actions: LoginActions,
        client: ClientInfo,
    ) -> AuthResult<LoginOutcome> {
        let current = self.flow(flow).await?;
        let identity = self.login_flow_identity(flow).await?;
        let organization = current.organization.as_ref().map(|id| id.to_sql());
        // Actions relues : une action levée ailleurs (adresse vérifiée, second facteur configuré)
        // ne bloque plus, une action ajoutée depuis est exigée.
        let pending = self
            .requirements(&identity, organization.clone())
            .await?
            .required_actions;
        if pending.iter().any(|a| a == "update_password") {
            if let Some(password) = &actions.new_password {
                self.set_password(&identity, password, true, None).await?;
            }
        }
        if actions.accept_terms && pending.iter().any(|a| a == "accept_terms") {
            self.store
                .required_action_complete(RequiredActionCompleteParams {
                    identity: identity.clone(),
                    action: "accept_terms".to_string(),
                })
                .await?;
        }
        // Méthodes déjà prouvées dans ce parcours (mot de passe ou passkey, facteur enrôlé)
        let proven = if current.methods.is_empty() {
            vec!["password".to_string()]
        } else {
            current.methods.clone()
        };
        self.next_step(
            &identity,
            organization,
            proven,
            Some(flow.to_string()),
            client,
        )
        .await
    }

    /// Échange un jeton de renouvellement (usage unique ; réutilisation → session révoquée).
    pub async fn refresh(&self, refresh_token: &SecretString) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        let next = opaque_token("lyxr_")?;
        let issued = self
            .store
            .session_refresh(SessionRefreshParams {
                token_hash: token_hash(refresh_token),
                new_token_hash: next.hash.clone(),
                access_slot: key.slot.clone(),
            })
            .await?;
        self.tokens(issued, Some(next)).await
    }

    /// Révoque une session (déconnexion, ou révocation demandée par son titulaire ou un
    /// gestionnaire autorisé par `fn::auth_session_list`).
    pub async fn revoke(&self, session: &str, reason: &str) -> AuthResult<bool> {
        Ok(self
            .store
            .session_revoke(SessionRevokeParams {
                session: session.to_string(),
                reason: reason.to_string(),
            })
            .await?
            .revoked)
    }

    /// Change l'organisation active (nouvelle session, même expiration absolue).
    pub async fn switch_organization(
        &self,
        session: &str,
        organization: Option<String>,
    ) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        let refresh = opaque_token("lyxr_")?;
        let issued = self
            .store
            .session_switch_organization(SessionSwitchParams {
                session: session.to_string(),
                organization,
                access_slot: key.slot.clone(),
                refresh_token_hash: refresh.hash.clone(),
            })
            .await?;
        self.tokens(issued, Some(refresh)).await
    }

    /// Change le mot de passe d'une identité connectée (mot de passe actuel exigé) ; les autres
    /// sessions sont révoquées.
    pub async fn change_password(
        &self,
        identity: &str,
        session: &str,
        current: &SecretString,
        new_password: &SecretString,
    ) -> AuthResult<()> {
        self.require_fresh(session).await?;
        self.verify_password_counted(identity, current).await?;
        self.set_password(identity, new_password, true, Some(session.to_string()))
            .await
    }

    /// Session d'un compte de service (`client_credentials`), sans jeton de renouvellement.
    pub async fn service_token(
        &self,
        client_id: &str,
        client_secret: &SecretString,
        client: ClientInfo,
    ) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        let issued = self
            .store
            .service_session_create(ServiceSessionParams {
                client_id: client_id.to_string(),
                secret_hash: token_hash(client_secret),
                client,
                access_slot: key.slot.clone(),
            })
            .await?;
        self.tokens(issued, None).await
    }

    /// Jeton d'un compte de service interne à l'hôte (application machine désignée par son
    /// `client_id`), sans secret : l'hôte agit déjà comme session système. Aucun jeton de
    /// renouvellement : un jeton frais est demandé pour chaque usage.
    pub async fn internal_service_token(&self, client_id: &str) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        let issued = self
            .store
            .service_session_open(crate::models::ServiceSessionOpenParams {
                client_id: client_id.to_string(),
                client: ClientInfo {
                    ip: None,
                    user_agent: Some("lyxal-server".to_string()),
                },
                access_slot: key.slot.clone(),
            })
            .await?;
        self.tokens(issued, None).await
    }

    /// Échange une clé d'API contre un jeton d'accès (permissions de la clé).
    pub async fn api_key_token(
        &self,
        api_key: &SecretString,
        client: ClientInfo,
    ) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        let issued = self
            .store
            .api_key_session_create(ApiKeySessionParams {
                key_hash: token_hash(api_key),
                client,
                access_slot: key.slot.clone(),
            })
            .await?;
        self.tokens(issued, None).await
    }

    // ------------------------------------------------------------------------------------------
    // Récupération, vérification, changement d'adresse
    // ------------------------------------------------------------------------------------------

    /// Démarre une récupération de compte. Réponse identique que l'adresse existe ou non : un
    /// parcours est toujours créé, le message n'est envoyé qu'à une identité active.
    pub async fn start_recovery(&self, email: &str, client: ClientInfo) -> AuthResult<String> {
        let credential = self
            .store
            .password_credential_get(PasswordCredentialParams {
                identifier: email.to_string(),
            })
            .await?;
        let active = credential.state.as_deref() == Some("active");
        let flow = self
            .store
            .flow_start(FlowStartParams {
                flow_type: "recovery".to_string(),
                identity: if active {
                    credential.identity.as_ref().map(|id| id.to_sql())
                } else {
                    None
                },
                address: Some(credential.identifier.clone()),
                client,
                ..FlowStartParams::default()
            })
            .await?;
        // Adresse inconnue ou compte inactif : code factice (même travail, même plafond d'envoi,
        // aucun message) pour que la réponse ne révèle pas l'existence du compte
        let identity = credential
            .identity
            .as_ref()
            .filter(|_| active)
            .map(|id| id.to_sql());
        self.send_code(
            &flow,
            "recovery",
            &credential.identifier,
            identity.as_deref(),
            "recovery",
            identity.is_some(),
        )
        .await?;
        Ok(flow.id.to_sql())
    }

    /// Termine une récupération : code ou lien vérifié (une seule fois, l'étape est conservée),
    /// nouveau mot de passe, **toutes les sessions révoquées**.
    pub async fn complete_recovery(
        &self,
        proof: CodeProof,
        new_password: &SecretString,
    ) -> AuthResult<()> {
        // Politique contrôlée avant de consommer la preuve : un mot de passe refusé laisse le
        // code ou le lien utilisable pour un nouvel essai.
        self.password_policy().await?.check(new_password)?;
        let flow = self.verify_proof(proof, "recovery").await?;
        let identity = flow
            .identity
            .as_ref()
            .map(|id| id.to_sql())
            .ok_or(AuthError::Rejected("AUTH_CODE_INVALID"))?;
        self.set_password(&identity, new_password, true, None)
            .await?;
        self.store
            .flow_submit(FlowSubmitParams {
                flow: flow.id.to_sql(),
                from: vec!["code_verified".into()],
                state: "completed".into(),
                required_actions: None,
                methods: None,
                identity: None,
            })
            .await?;
        Ok(())
    }

    /// Envoie un code de vérification à l'adresse principale d'une identité.
    pub async fn start_verification(
        &self,
        identity: &str,
        client: ClientInfo,
    ) -> AuthResult<String> {
        let address = self.identity_email(identity).await?;
        let flow = self
            .store
            .flow_start(FlowStartParams {
                flow_type: "verification".to_string(),
                identity: Some(identity.to_string()),
                address: Some(address.clone()),
                client,
                ..FlowStartParams::default()
            })
            .await?;
        self.send_code(
            &flow,
            "verification",
            &address,
            Some(identity),
            "verify",
            true,
        )
        .await?;
        Ok(flow.id.to_sql())
    }

    /// Vérifie une adresse par code ou lien (action `verify_email` levée, rattachement par domaine).
    pub async fn complete_verification(&self, proof: CodeProof) -> AuthResult<()> {
        let verified = self.verify_code(proof, "verification").await?;
        let identity = verified
            .identity
            .as_ref()
            .map(|id| id.to_sql())
            .ok_or(AuthError::Rejected("AUTH_CODE_INVALID"))?;
        self.store
            .address_verify(AddressVerifyParams {
                identity,
                address: verified.address.clone(),
            })
            .await?;
        self.store
            .flow_submit(FlowSubmitParams {
                flow: verified.flow.to_sql(),
                from: vec!["code_sent".into()],
                state: "completed".into(),
                required_actions: None,
                methods: None,
                identity: None,
            })
            .await?;
        Ok(())
    }

    /// Demande un changement d'adresse (mot de passe actuel exigé) : code envoyé à la nouvelle
    /// adresse.
    pub async fn start_address_change(
        &self,
        identity: &str,
        session: &str,
        current: &SecretString,
        new_address: &str,
        client: ClientInfo,
    ) -> AuthResult<String> {
        self.require_fresh(session).await?;
        self.verify_password_counted(identity, current).await?;
        let requested = self
            .store
            .address_change_request(AddressChangeRequestParams {
                identity: identity.to_string(),
                new_address: new_address.to_string(),
                client,
            })
            .await?;
        let flow = self.flow(&requested.flow.to_sql()).await?;
        self.send_code(
            &flow,
            "address_change",
            &requested.address,
            Some(identity),
            "address-change",
            true,
        )
        .await?;
        Ok(flow.id.to_sql())
    }

    /// Confirme un changement d'adresse par le code reçu à la nouvelle adresse.
    pub async fn complete_address_change(&self, proof: CodeProof) -> AuthResult<String> {
        let flow = self.verify_proof(proof, "address_change").await?;
        Ok(self
            .store
            .address_change_confirm(AddressChangeConfirmParams {
                flow: flow.id.to_sql(),
            })
            .await?
            .address)
    }

    // ------------------------------------------------------------------------------------------
    // Inscription et premier administrateur
    // ------------------------------------------------------------------------------------------

    /// Démarre une inscription par le jeton d'une invitation ou d'un lien d'installation.
    pub async fn start_registration(
        &self,
        token: &SecretString,
        setup: bool,
    ) -> AuthResult<RegistrationStarted> {
        let hash = token_hash(token);
        Ok(self
            .store
            .registration_start(RegistrationStartParams {
                invitation_token_hash: if setup { None } else { Some(hash.clone()) },
                setup_link_hash: if setup { Some(hash) } else { None },
            })
            .await?)
    }

    /// Termine une inscription : identité créée (adresse de l'invitation ou du lien), mot de
    /// passe enregistré, session ouverte dans l'organisation de l'invitation.
    pub async fn complete_registration(
        &self,
        flow: &str,
        traits: lyxal_surreal::Value,
        password: &SecretString,
        client: ClientInfo,
    ) -> AuthResult<LoginOutcome> {
        let policy = self.password_policy().await?;
        // Politique contrôlée avant la création de l'identité
        policy.check(password)?;
        let completed = self
            .store
            .registration_complete(RegistrationCompleteParams {
                flow: flow.to_string(),
                traits,
            })
            .await?;
        let identity = completed.identity.to_sql();
        self.set_password(&identity, password, false, None).await?;
        // Double facteur exigé (premier administrateur, organisation) : configure_mfa avant la session
        self.next_step(
            &identity,
            completed.organization.as_ref().map(|id| id.to_sql()),
            vec!["password".into()],
            None,
            client,
        )
        .await
    }

    /// Prépare le lien d'installation du premier administrateur (valable 1 h, à afficher une
    /// seule fois par la commande de l'hôte).
    pub async fn setup_link(&self, email: &str) -> AuthResult<SecretString> {
        let link = opaque_token("lyxs_")?;
        self.store
            .setup_start(SetupStartParams {
                email: email.to_string(),
                link_hash: link.hash.clone(),
            })
            .await?;
        Ok(SecretString::new(format!(
            "{}/setup?token={}",
            self.config.public_url,
            link.value.expose_secret()
        ))?)
    }

    /// Révoque toutes les sessions d'une identité (sauf `except`).
    pub async fn revoke_all(
        &self,
        identity: &str,
        except: Option<String>,
        reason: &str,
    ) -> AuthResult<()> {
        self.store
            .session_revoke_all(SessionRevokeAllParams {
                identity: identity.to_string(),
                except_session: except,
                reason: reason.to_string(),
            })
            .await?;
        Ok(())
    }

    // ------------------------------------------------------------------------------------------
    // Interne
    // ------------------------------------------------------------------------------------------

    async fn open_session(
        &self,
        identity: &str,
        organization: Option<String>,
        amr: Vec<String>,
        client: ClientInfo,
    ) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        let refresh = opaque_token("lyxr_")?;
        let issued = self
            .store
            .session_create(SessionCreateParams {
                identity: identity.to_string(),
                organization,
                amr,
                client,
                access_slot: key.slot.clone(),
                refresh_token_hash: refresh.hash.clone(),
            })
            .await?;
        self.tokens(issued, Some(refresh)).await
    }

    async fn tokens(
        &self,
        issued: crate::models::SessionIssued,
        refresh: Option<OpaqueToken>,
    ) -> AuthResult<IssuedTokens> {
        let key = self.keys.signing_key().await?;
        Ok(IssuedTokens {
            access_token: access_token(
                &key,
                &self.config.namespace,
                &self.config.database,
                &issued,
            )?,
            refresh_token: refresh.map(|token| token.value),
            expires_in: issued.access_seconds,
            session: issued,
        })
    }

    async fn password_policy(&self) -> AuthResult<PasswordPolicy> {
        let policy = self.store.policy_get(PolicyGetParams::default()).await?;
        Ok(PasswordPolicy::from_policy(&policy.into_json_value()))
    }

    async fn set_password(
        &self,
        identity: &str,
        password: &SecretString,
        revoke_sessions: bool,
        except_session: Option<String>,
    ) -> AuthResult<()> {
        let policy = self.password_policy().await?;
        let email = self.identity_email(identity).await?;
        let previous = self
            .store
            .password_credential_get(PasswordCredentialParams { identifier: email })
            .await?
            .secret;
        let sealed = self
            .passwords
            .seal_new(identity, password, policy, previous.as_deref())
            .await?;
        self.store
            .password_set(PasswordSetParams {
                identity: identity.to_string(),
                secret: sealed,
                revoke_sessions,
                except_session,
            })
            .await?;
        Ok(())
    }

    async fn check_current_password(
        &self,
        identity: &str,
        current: &SecretString,
    ) -> AuthResult<()> {
        let email = self.identity_email(identity).await?;
        let credential = self
            .store
            .password_credential_get(PasswordCredentialParams { identifier: email })
            .await?;
        match self
            .passwords
            .verify(current, Some(identity), credential.secret.as_deref())
            .await?
        {
            PasswordCheck::Valid { .. } => Ok(()),
            PasswordCheck::Invalid => Err(AuthError::Rejected("AUTH_CREDENTIALS_INVALID")),
        }
    }

    async fn identity_email(&self, identity: &str) -> AuthResult<String> {
        let found = self
            .store
            .identity_get(IdentityGetParams {
                identity: identity.to_string(),
            })
            .await?;
        found.traits.into_json_value()["email"]
            .as_str()
            .map(str::to_string)
            .ok_or(AuthError::Rejected("AUTH_IDENTITY_NOT_FOUND"))
    }

    async fn flow(&self, flow: &str) -> AuthResult<Flow> {
        Ok(self
            .store
            .flow_get(FlowGetParams {
                flow: flow.to_string(),
            })
            .await?)
    }

    /// Code (6 chiffres) et lien (32 octets) : empreintes en base, secret `{ action_url, code }`
    /// scellé pour `lyxal_notification` sous le contexte de l'événement publié.
    async fn send_code(
        &self,
        flow: &Flow,
        purpose: &str,
        address: &str,
        identity: Option<&str>,
        path: &str,
        deliver: bool,
    ) -> AuthResult<()> {
        let pepper = self.keys.code_pepper().await?;
        let code = six_digit_code()?;
        let link = opaque_token("")?;
        let event_type = if purpose == "recovery" {
            "auth.recovery.requested"
        } else {
            "auth.verification.requested"
        };
        let event_id = uuid::Uuid::now_v7().to_string();
        let message = Zeroizing::new(
            serde_json::json!({
                "action_url": format!("{}/{path}?token={}", self.config.public_url, link.value.expose_secret()),
                "code": code.expose_secret()
            })
            .to_string(),
        );
        let context = SecretContext::with_tenant(
            "lyxal_installation",
            "lyxal_auth",
            &event_type.replace('.', "_"),
            &event_id,
            "secret",
        )?;
        let sealed = self
            .crypto
            .seal(&SecretBytes::new(message.as_bytes().to_vec())?, &context)?
            .encode();
        let (locale, name) = match identity {
            Some(identity) => self.recipient(identity).await,
            None => (None, None),
        };
        self.store
            .code_issue(CodeIssueParams {
                flow: flow.id.to_sql(),
                purpose: purpose.to_string(),
                address: address.to_string(),
                code_hash: Some(sign_hmac_sha256_hex(
                    &pepper,
                    code.expose_secret().as_bytes(),
                )?),
                link_hash: link.hash,
                event_id: deliver.then_some(event_id),
                secret: deliver.then_some(sealed),
                locale,
                name,
            })
            .await?;
        Ok(())
    }

    async fn recipient(&self, identity: &str) -> (Option<String>, Option<String>) {
        match self
            .store
            .identity_get(IdentityGetParams {
                identity: identity.to_string(),
            })
            .await
        {
            Ok(found) => {
                let traits = found.traits.into_json_value();
                (
                    traits["locale"].as_str().map(str::to_string),
                    traits["name"]["first"].as_str().map(str::to_string),
                )
            }
            Err(_) => (None, None),
        }
    }

    /// Identité d'un parcours de connexion en attente d'actions imposées.
    async fn login_flow_identity(&self, flow: &str) -> AuthResult<String> {
        let current = self.flow(flow).await?;
        if current.flow_type != "login" || current.state != "action_required" {
            return Err(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"));
        }
        current
            .identity
            .as_ref()
            .map(|id| id.to_sql())
            .ok_or(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"))
    }

    /// Exigences de connexion relues en base (actions imposées, double facteur).
    async fn requirements(
        &self,
        identity: &str,
        organization: Option<String>,
    ) -> AuthResult<LoginRequirements> {
        Ok(self
            .store
            .login_requirements(LoginRequirementsParams {
                identity: identity.to_string(),
                organization,
            })
            .await?)
    }

    /// Étape suivante d'une connexion dont les méthodes `proven` sont vérifiées : second facteur
    /// si l'identité en a un et qu'aucun n'a été prouvé, puis actions imposées (jamais avant le
    /// second facteur : un mot de passe seul ne change rien au compte), puis session. `flow` :
    /// parcours de connexion en cours, poursuivi plutôt que recréé.
    async fn next_step(
        &self,
        identity: &str,
        organization: Option<String>,
        proven: Vec<String>,
        flow: Option<String>,
        client: ClientInfo,
    ) -> AuthResult<LoginOutcome> {
        let requirements = self.requirements(identity, organization.clone()).await?;
        let second_factor = proven
            .iter()
            .any(|m| matches!(m.as_str(), "totp" | "passkey" | "recovery_code"));
        let (state, actions, methods) = if requirements.available_aal >= 2 && !second_factor {
            ("mfa_required", vec![], requirements.methods.clone())
        } else if !requirements.required_actions.is_empty() {
            (
                "action_required",
                requirements.required_actions.clone(),
                proven.clone(),
            )
        } else {
            if let Some(flow) = &flow {
                self.store
                    .flow_submit(FlowSubmitParams {
                        flow: flow.clone(),
                        from: vec!["action_required".into(), "mfa_required".into()],
                        state: "completed".into(),
                        required_actions: Some(vec![]),
                        ..FlowSubmitParams::default()
                    })
                    .await?;
            }
            return Ok(LoginOutcome::Authenticated(Box::new(
                self.open_session(identity, organization, proven, client)
                    .await?,
            )));
        };
        let flow = match flow {
            Some(flow) => self
                .store
                .flow_submit(FlowSubmitParams {
                    flow,
                    from: vec!["action_required".into(), "mfa_required".into()],
                    state: state.into(),
                    required_actions: Some(actions.clone()),
                    methods: Some(methods.clone()),
                    identity: None,
                })
                .await?
                .id
                .to_sql(),
            None => self
                .store
                .flow_start(FlowStartParams {
                    flow_type: "login".to_string(),
                    state: Some(state.to_string()),
                    identity: Some(identity.to_string()),
                    organization,
                    required_actions: actions.clone(),
                    methods: methods.clone(),
                    client,
                    ..FlowStartParams::default()
                })
                .await?
                .id
                .to_sql(),
        };
        Ok(if state == "action_required" {
            LoginOutcome::ActionRequired { flow, actions }
        } else {
            LoginOutcome::MfaRequired { flow, methods }
        })
    }

    /// Vérifie un second facteur : verrouillage contrôlé, échec compté (verrouillage, essais du
    /// parcours), compteur remis à zéro au succès.
    async fn verify_second_factor(
        &self,
        identity: &str,
        organization: Option<String>,
        flow: Option<&str>,
        flow_type: &str,
        proof: MfaProof,
    ) -> AuthResult<&'static str> {
        // Méthode active et autorisée par la politique effective, avant toute vérification (un
        // code de secours n'est pas consommé par une méthode refusée)
        if !self
            .requirements(identity, organization)
            .await?
            .methods
            .iter()
            .any(|m| m == proof.method())
        {
            return Err(AuthError::Rejected("AUTH_MFA_METHOD_DISABLED"));
        }
        let identity_hash = blake3_hex(identity.as_bytes());
        if self
            .store
            .mfa_failure_check(MfaFailureKeyParams {
                identity_hash: identity_hash.clone(),
            })
            .await?
            .locked
        {
            return Err(AuthError::Rejected("AUTH_TOO_MANY_ATTEMPTS"));
        }
        let method = proof.method();
        let outcome = match proof {
            MfaProof::Totp(code) => self.mfa.verify_totp(identity, &code).await,
            MfaProof::RecoveryCode(code) => self
                .mfa
                .verify_recovery_code(identity, &code)
                .await
                .map(|_| ()),
            MfaProof::Passkey { flow, response } => {
                self.mfa
                    .verify_passkey(identity, &flow, flow_type, response)
                    .await
            }
        };
        match outcome {
            Ok(()) => {
                self.store
                    .mfa_failure_reset(MfaFailureKeyParams { identity_hash })
                    .await?;
                Ok(method)
            }
            Err(error) if error.is("AUTH_MFA_INVALID") || error.is("AUTH_PASSKEY_INVALID") => {
                let status = self
                    .store
                    .mfa_failure_record(MfaFailureParams {
                        identity_hash,
                        identity: identity.to_string(),
                        flow: flow.map(str::to_string),
                        method: method.to_string(),
                    })
                    .await?;
                Err(if status.locked {
                    AuthError::Rejected("AUTH_TOO_MANY_ATTEMPTS")
                } else {
                    error
                })
            }
            Err(error) => Err(error),
        }
    }

    /// Mot de passe actuel vérifié avec l'anti-force-brute de la connexion.
    async fn verify_password_counted(
        &self,
        identity: &str,
        password: &SecretString,
    ) -> AuthResult<()> {
        let email = self.identity_email(identity).await?;
        let failure = LoginFailureParams {
            identifier_hash: blake3_hex(email.as_bytes()),
            ip_hash: None,
            identity: Some(identity.to_string()),
        };
        if self
            .store
            .login_failure_check(failure.clone())
            .await?
            .locked
        {
            return Err(AuthError::Rejected("AUTH_TOO_MANY_ATTEMPTS"));
        }
        match self.check_current_password(identity, password).await {
            Ok(()) => Ok(()),
            Err(error) if error.is("AUTH_CREDENTIALS_INVALID") => {
                let status = self.store.login_failure_record(failure).await?;
                Err(AuthError::Rejected(if status.locked {
                    "AUTH_TOO_MANY_ATTEMPTS"
                } else {
                    "AUTH_CREDENTIALS_INVALID"
                }))
            }
            Err(error) => Err(error),
        }
    }

    async fn verify_code(
        &self,
        proof: CodeProof,
        purpose: &str,
    ) -> AuthResult<crate::models::CodeVerified> {
        let params = match proof {
            CodeProof::Code { flow, code } => {
                let pepper = self.keys.code_pepper().await?;
                CodeVerifyParams {
                    flow: Some(flow),
                    purpose: purpose.to_string(),
                    code_hash: Some(sign_hmac_sha256_hex(
                        &pepper,
                        code.expose_secret().as_bytes(),
                    )?),
                    link_hash: None,
                }
            }
            CodeProof::Link(token) => CodeVerifyParams {
                flow: None,
                purpose: purpose.to_string(),
                code_hash: None,
                link_hash: Some(token_hash(&token)),
            },
        };
        Ok(self.store.code_verify(params).await?)
    }

    /// Code ou lien vérifié (consommé), puis parcours passé à `code_verified`. Aucune reprise
    /// sans preuve : l'identifiant d'un parcours n'est pas une preuve de possession de l'adresse.
    async fn verify_proof(&self, proof: CodeProof, purpose: &str) -> AuthResult<Flow> {
        let verified = self.verify_code(proof, purpose).await?;
        Ok(self
            .store
            .flow_submit(FlowSubmitParams {
                flow: verified.flow.to_sql(),
                from: vec!["code_sent".into()],
                state: "code_verified".into(),
                required_actions: None,
                methods: None,
                identity: None,
            })
            .await?)
    }
}

/// Code à 6 chiffres uniforme (`OsRng`, tirage par rejet).
fn six_digit_code() -> AuthResult<SecretString> {
    loop {
        let mut raw = [0u8; 4];
        OsRng
            .try_fill_bytes(&mut raw)
            .map_err(|_| AuthError::Crypto(lyxal_crypto::CryptoError::RandomUnavailable))?;
        let value = u32::from_le_bytes(raw);
        // 4 294 000 000 est un multiple de 1 000 000 : aucun biais
        if value < 4_294_000_000 {
            return Ok(SecretString::new(format!("{:06}", value % 1_000_000))?);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn codes_have_six_digits() {
        for _ in 0..50 {
            let code = six_digit_code().expect("code");
            assert_eq!(code.expose_secret().len(), 6);
            assert!(code.expose_secret().bytes().all(|b| b.is_ascii_digit()));
        }
    }
}
