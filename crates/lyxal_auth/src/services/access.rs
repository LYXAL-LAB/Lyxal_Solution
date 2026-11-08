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
    ApiKeySessionParams, ClientInfo, CodeIssueParams, CodeVerifyParams, Flow, FlowGetParams,
    FlowStartParams, FlowSubmitParams, IdentityGetParams, LoginFailureParams,
    LoginFailureResetParams, PasswordCredentialParams, PasswordSetParams, PolicyGetParams,
    RegistrationCompleteParams, RegistrationStartParams, RegistrationStarted,
    RequiredActionCompleteParams, RequiredActionListParams, ServiceSessionParams,
    SessionCreateParams, SessionRefreshParams, SessionRevokeAllParams, SessionRevokeParams,
    SessionSwitchParams, SetupStartParams,
};
use crate::services::keys::SigningKeyService;
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
    /// Adresse publique de l'interface (`https://…`), pour les liens des messages.
    pub public_url: String,
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
        Ok(Self {
            passwords: PasswordService::new(crypto.clone()),
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
        if !credential.required_actions.is_empty() {
            let flow = self
                .store
                .flow_start(FlowStartParams {
                    flow_type: "login".to_string(),
                    state: Some("action_required".to_string()),
                    identity: Some(identity),
                    organization: request.organization,
                    required_actions: credential.required_actions.clone(),
                    client: request.client,
                    ..FlowStartParams::default()
                })
                .await?;
            return Ok(LoginOutcome::ActionRequired {
                flow: flow.id.to_sql(),
                actions: credential.required_actions,
            });
        }
        Ok(LoginOutcome::Authenticated(Box::new(
            self.open_session(
                &identity,
                request.organization,
                vec!["password".into()],
                request.client,
            )
            .await?,
        )))
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
        if !self
            .pending_actions(&identity)
            .await?
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
        // Actions relues : une action levée ailleurs (adresse vérifiée par le parcours de
        // vérification) ne bloque plus, une action ajoutée depuis est exigée.
        let mut remaining = self.pending_actions(&identity).await?;
        if remaining.iter().any(|a| a == "update_password") {
            if let Some(password) = &actions.new_password {
                self.set_password(&identity, password, true, None).await?;
                remaining.retain(|a| a != "update_password");
            }
        }
        if actions.accept_terms && remaining.iter().any(|a| a == "accept_terms") {
            self.store
                .required_action_complete(RequiredActionCompleteParams {
                    identity: identity.clone(),
                    action: "accept_terms".to_string(),
                })
                .await?;
            remaining.retain(|a| a != "accept_terms");
        }
        if !remaining.is_empty() {
            self.store
                .flow_submit(FlowSubmitParams {
                    flow: flow.to_string(),
                    from: vec!["action_required".into()],
                    state: "action_required".into(),
                    required_actions: Some(remaining.clone()),
                    identity: None,
                })
                .await?;
            return Ok(LoginOutcome::ActionRequired {
                flow: flow.to_string(),
                actions: remaining,
            });
        }
        self.store
            .flow_submit(FlowSubmitParams {
                flow: flow.to_string(),
                from: vec!["action_required".into()],
                state: "completed".into(),
                required_actions: Some(vec![]),
                identity: None,
            })
            .await?;
        let organization = current.organization.as_ref().map(|id| id.to_sql());
        Ok(LoginOutcome::Authenticated(Box::new(
            self.open_session(&identity, organization, vec!["password".into()], client)
                .await?,
        )))
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
        self.check_current_password(identity, current).await?;
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
        if active {
            if let Some(identity) = &credential.identity {
                self.send_code(
                    &flow,
                    "recovery",
                    &credential.identifier,
                    Some(&identity.to_sql()),
                    "recovery",
                )
                .await?;
            }
        }
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
        self.send_code(&flow, "verification", &address, Some(identity), "verify")
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
        current: &SecretString,
        new_address: &str,
        client: ClientInfo,
    ) -> AuthResult<String> {
        self.check_current_password(identity, current).await?;
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
    ) -> AuthResult<IssuedTokens> {
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
        self.open_session(
            &identity,
            completed.organization.as_ref().map(|id| id.to_sql()),
            vec!["password".into()],
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
                event_id: Some(event_id),
                secret: Some(sealed),
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

    /// Actions imposées en attente, relues en base.
    async fn pending_actions(&self, identity: &str) -> AuthResult<Vec<String>> {
        Ok(self
            .store
            .required_action_list(RequiredActionListParams {
                identity: Some(identity.to_string()),
            })
            .await?
            .into_iter()
            .map(|a| a.action)
            .collect())
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
