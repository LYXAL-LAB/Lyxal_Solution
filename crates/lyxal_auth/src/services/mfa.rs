//! Seconds facteurs (lot 4) : ce qui relève du système — secrets TOTP (`lyxal_crypto::totp`),
//! codes de secours (`OsRng`, HMAC `code_pepper`), cérémonies passkeys (`webauthn-rs`), scellement
//! des secrets et des états de cérémonie. Les règles (acteur, actions sensibles, anti-rejeu,
//! usage unique, dernier facteur, niveau d'assurance) sont dans les fonctions `fn::auth_mfa_*`.

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{
    sign_hmac_sha256_hex, totp_uri, totp_verify, CryptoEngine, EncryptedEnvelope, KeyResolver,
    SecretBytes, SecretContext, SecretString, TotpConfig, TotpSecret,
};
use lyxal_surreal::{SurrealValue, ToSql};
use rand_core::{OsRng, RngCore};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use webauthn_rs::prelude::{
    DiscoverableAuthentication, Passkey, PasskeyAuthentication, PasskeyRegistration,
    PublicKeyCredential, RegisterPublicKeyCredential, Url, Uuid, Webauthn, WebauthnBuilder,
    WebauthnError,
};

use crate::error::{AuthError, AuthResult};
use crate::models::{
    FlowStartParams, FlowStateSaveParams, FlowStateTakeParams, FlowSubmitParams, IdentityGetParams,
    MfaFactorListParams, MfaFactors, PasskeyFindParams, PasskeyListForParams, PasskeySaveParams,
    PasskeySaved, PasskeyUpdateParams, PolicyGetParams, RecoveryCodeUseParams, RecoveryCodeUsed,
    RecoveryCodesReplaceParams, TotpActivateParams, TotpActivated, TotpBeginParams,
    TotpSecretGetParams, TotpStepUseParams,
};
use crate::services::keys::SigningKeyService;
use crate::store::AuthStore;

/// Fenêtre d'acceptation d'un code TOTP (pas de chaque côté).
const TOTP_WINDOW: u8 = 1;
/// Alphabet des codes de secours, sans caractères ambigus (0/o, 1/l/i).
const RECOVERY_ALPHABET: &[u8] = b"23456789abcdefghjkmnpqrstuvwxyz";
/// Longueur d'un code de secours (≈ 50 bits).
const RECOVERY_LENGTH: usize = 10;

/// Partie de confiance WebAuthn : identifiant (domaine), origine et nom affiché.
#[derive(Debug, Clone)]
pub struct PasskeyConfig {
    /// Identifiant de la partie de confiance (domaine, ex. `console.example.com`).
    pub rp_id: String,
    /// Origine de l'interface (`https://console.example.com`).
    pub origin: String,
    /// Nom affiché par l'appareil.
    pub rp_name: String,
}

/// Au nom de qui agit l'hôte : la session interactive de l'utilisateur, ou son parcours de
/// connexion en attente de `configure_mfa`. L'identité sert aux cérémonies ; la base revérifie
/// l'acteur à chaque écriture.
#[derive(Debug, Clone)]
pub struct MfaActor {
    /// Identité (texte `auth_identity:<clé>`).
    pub identity: String,
    /// Session interactive (texte).
    pub session: Option<String>,
    /// Parcours de connexion (texte).
    pub flow: Option<String>,
}

/// TOTP en attente : URI `otpauth://` (QR code affiché par l'interface), une seule fois.
pub struct TotpEnrollment {
    /// Moyen en attente.
    pub credential: String,
    /// URI `otpauth://totp/...` (contient le secret).
    pub otpauth_uri: SecretString,
}

impl std::fmt::Debug for TotpEnrollment {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("TotpEnrollment")
            .field("credential", &self.credential)
            .field("otpauth_uri", &"[REDACTED]")
            .finish()
    }
}

/// Défi WebAuthn à transmettre au navigateur, avec le parcours qui en garde l'état.
#[derive(Debug, Clone)]
pub struct PasskeyChallenge {
    /// Parcours (texte).
    pub flow: String,
    /// Options `navigator.credentials.create` / `get` (JSON WebAuthn).
    pub options: serde_json::Value,
}

/// Résultat d'une connexion sans mot de passe vérifiée.
#[derive(Debug, Clone)]
pub struct PasskeyLogin {
    /// Identité authentifiée.
    pub identity: String,
}

/// Service des seconds facteurs, sur la session système de l'hôte.
pub struct MfaService<R: KeyResolver> {
    store: AuthStore,
    crypto: Arc<CryptoEngine<R>>,
    keys: Arc<SigningKeyService<R>>,
    webauthn: Option<Webauthn>,
    issuer: String,
}

impl<R: KeyResolver + 'static> MfaService<R> {
    /// Service ; sans configuration de passkeys, les cérémonies répondent
    /// `AUTH_PASSKEY_UNAVAILABLE`.
    pub fn new(
        store: AuthStore,
        crypto: Arc<CryptoEngine<R>>,
        keys: Arc<SigningKeyService<R>>,
        issuer: String,
        passkeys: Option<PasskeyConfig>,
    ) -> AuthResult<Self> {
        let webauthn = match passkeys {
            None => None,
            Some(config) => {
                let origin = Url::parse(&config.origin)
                    .map_err(|_| AuthError::InvalidParameter("origin"))?;
                Some(
                    WebauthnBuilder::new(&config.rp_id, &origin)
                        .and_then(|builder| builder.rp_name(&config.rp_name).build())
                        .map_err(|_| AuthError::InvalidParameter("rp_id"))?,
                )
            }
        };
        if issuer.is_empty() || issuer.contains(':') {
            return Err(AuthError::InvalidParameter("issuer"));
        }
        Ok(Self {
            store,
            crypto,
            keys,
            webauthn,
            issuer,
        })
    }

    /// Passkeys disponibles sur ce serveur.
    pub fn passkeys_enabled(&self) -> bool {
        self.webauthn.is_some()
    }

    /// Seconds facteurs de l'acteur (sans secret).
    pub async fn factors(&self, actor: &MfaActor) -> AuthResult<MfaFactors> {
        Ok(self
            .store
            .mfa_factor_list(MfaFactorListParams {
                session: actor.session.clone(),
                flow: actor.flow.clone(),
                identity: None,
            })
            .await?)
    }

    // ------------------------------------------------------------------------------------------
    // TOTP
    // ------------------------------------------------------------------------------------------

    /// Enrôlement TOTP (action sensible) : secret de 20 octets (`OsRng`), scellé sur
    /// l'identifiant du moyen, URI `otpauth://` à afficher une seule fois.
    pub async fn totp_begin(&self, actor: &MfaActor) -> AuthResult<TotpEnrollment> {
        let config = TotpConfig::default();
        let secret = TotpSecret::generate(&config)?;
        let key = uuid::Uuid::now_v7().simple().to_string();
        let credential = format!("auth_credential:{key}");
        let sealed = self.crypto.seal(
            &SecretBytes::new(secret.expose_secret().to_vec())?,
            &totp_context(&key)?,
        )?;
        let begun = self
            .store
            .mfa_totp_begin(TotpBeginParams {
                session: actor.session.clone(),
                flow: actor.flow.clone(),
                credential: credential.clone(),
                secret: sealed.encode(),
                algorithm: "SHA1".to_string(),
                digits: i64::from(config.digits),
                step_seconds: i64::from(config.step_seconds),
            })
            .await?;
        let account = begun.account.unwrap_or_else(|| actor.identity.clone());
        Ok(TotpEnrollment {
            credential: begun.credential.to_sql(),
            otpauth_uri: totp_uri(&secret, &config, &self.issuer, &account)?,
        })
    }

    /// Confirme l'enrôlement par un premier code juste (action sensible).
    pub async fn totp_confirm(
        &self,
        actor: &MfaActor,
        code: &SecretString,
    ) -> AuthResult<TotpActivated> {
        let (credential, step) = self.totp_check(&actor.identity, code, "pending").await?;
        Ok(self
            .store
            .mfa_totp_activate(TotpActivateParams {
                session: actor.session.clone(),
                flow: actor.flow.clone(),
                credential,
                step: step_i64(step)?,
            })
            .await?)
    }

    /// Vérifie un code TOTP du facteur actif et consomme son pas (anti-rejeu en base).
    pub async fn verify_totp(&self, identity: &str, code: &SecretString) -> AuthResult<()> {
        let (credential, step) = self.totp_check(identity, code, "active").await?;
        self.store
            .mfa_totp_step_use(TotpStepUseParams {
                credential,
                step: step_i64(step)?,
            })
            .await?;
        Ok(())
    }

    async fn totp_check(
        &self,
        identity: &str,
        code: &SecretString,
        state: &str,
    ) -> AuthResult<(String, u64)> {
        let record = self
            .store
            .mfa_totp_secret_get(TotpSecretGetParams {
                identity: identity.to_string(),
                state: state.to_string(),
            })
            .await?;
        let key = record_key(&record.credential.to_sql())?;
        let bytes = self.crypto.open(
            &EncryptedEnvelope::parse(&record.secret)?,
            &totp_context(&key)?,
        )?;
        let secret = TotpSecret::import(bytes)?;
        let config = totp_config(&record.public_data.into_json_value())?;
        match totp_verify(
            &secret,
            &config,
            code.expose_secret().trim(),
            unix_now()?,
            TOTP_WINDOW,
        )? {
            Some(step) => Ok((record.credential.to_sql(), step)),
            None => Err(AuthError::Rejected("AUTH_MFA_INVALID")),
        }
    }

    // ------------------------------------------------------------------------------------------
    // Codes de secours
    // ------------------------------------------------------------------------------------------

    /// Génère les codes de secours (action sensible), affichés une seule fois ; les précédents
    /// sont remplacés.
    pub async fn recovery_codes(&self, actor: &MfaActor) -> AuthResult<Vec<SecretString>> {
        let policy = self.store.policy_get(PolicyGetParams::default()).await?;
        let count = policy.into_json_value()["mfa"]["recovery_code_count"]
            .as_u64()
            .unwrap_or(10)
            .clamp(5, 20) as usize;
        let pepper = self.keys.code_pepper().await?;
        let mut codes = Vec::with_capacity(count);
        let mut hashes = Vec::with_capacity(count);
        while codes.len() < count {
            let code = recovery_code()?;
            let hash =
                sign_hmac_sha256_hex(&pepper, normalize_code(code.expose_secret()).as_bytes())?;
            if !hashes.contains(&hash) {
                hashes.push(hash);
                codes.push(code);
            }
        }
        self.store
            .mfa_recovery_codes_replace(RecoveryCodesReplaceParams {
                session: actor.session.clone(),
                flow: actor.flow.clone(),
                batch: uuid::Uuid::now_v7().simple().to_string(),
                code_hashes: hashes,
            })
            .await?;
        Ok(codes)
    }

    /// Consomme un code de secours (usage unique, atomique en base).
    pub async fn verify_recovery_code(
        &self,
        identity: &str,
        code: &SecretString,
    ) -> AuthResult<RecoveryCodeUsed> {
        let pepper = self.keys.code_pepper().await?;
        let normalized = normalize_code(code.expose_secret());
        if normalized.len() != RECOVERY_LENGTH {
            return Err(AuthError::Rejected("AUTH_MFA_INVALID"));
        }
        Ok(self
            .store
            .mfa_recovery_code_use(RecoveryCodeUseParams {
                identity: identity.to_string(),
                code_hash: sign_hmac_sha256_hex(&pepper, normalized.as_bytes())?,
            })
            .await?)
    }

    // ------------------------------------------------------------------------------------------
    // Passkeys
    // ------------------------------------------------------------------------------------------

    /// Défi d'enregistrement d'une passkey (action sensible vérifiée à l'enregistrement) ; les
    /// clés déjà enregistrées de l'identité sont exclues.
    pub async fn passkey_registration_options(
        &self,
        actor: &MfaActor,
    ) -> AuthResult<PasskeyChallenge> {
        let webauthn = self.webauthn()?;
        let user = user_uuid(&actor.identity)?;
        let identity = self
            .store
            .identity_get(IdentityGetParams {
                identity: actor.identity.clone(),
            })
            .await?;
        let traits = identity.traits.into_json_value();
        let name = traits["email"]
            .as_str()
            .ok_or(AuthError::Rejected("AUTH_IDENTITY_NOT_FOUND"))?
            .to_string();
        let display = traits["name"]["first"]
            .as_str()
            .map(str::to_string)
            .unwrap_or_else(|| name.clone());
        let exclude = self
            .passkeys_of(&actor.identity)
            .await?
            .into_iter()
            .map(|(_, passkey)| passkey.cred_id().clone())
            .collect::<Vec<_>>();
        let (options, state) = webauthn
            .start_passkey_registration(user, &name, &display, Some(exclude))
            .map_err(passkey_error)?;
        let flow = self
            .store
            .flow_start(FlowStartParams {
                flow_type: "mfa_enrollment".to_string(),
                identity: Some(actor.identity.clone()),
                session: actor.session.clone(),
                methods: vec!["passkey".to_string()],
                ..FlowStartParams::default()
            })
            .await?;
        let flow = flow.id.to_sql();
        self.save_state(&flow, &state).await?;
        Ok(PasskeyChallenge {
            flow,
            options: to_json(&options)?,
        })
    }

    /// Termine l'enregistrement : réponse vérifiée, clé enregistrée (action sensible en base).
    pub async fn passkey_register(
        &self,
        actor: &MfaActor,
        flow: &str,
        response: serde_json::Value,
        label: Option<String>,
    ) -> AuthResult<PasskeySaved> {
        let webauthn = self.webauthn()?;
        let state: PasskeyRegistration = self
            .take_state(flow, "mfa_enrollment", Some(&actor.identity))
            .await?;
        let response: RegisterPublicKeyCredential = serde_json::from_value(response)
            .map_err(|_| AuthError::Rejected("AUTH_PASSKEY_INVALID"))?;
        let passkey = webauthn
            .finish_passkey_registration(&response, &state)
            .map_err(passkey_error)?;
        let saved = self
            .store
            .mfa_passkey_save(PasskeySaveParams {
                session: actor.session.clone(),
                flow: actor.flow.clone(),
                credential_id: URL_SAFE_NO_PAD.encode(passkey.cred_id()),
                label,
                public_data: passkey_document(&passkey)?.into_value(),
            })
            .await?;
        self.complete_flow(flow).await?;
        Ok(saved)
    }

    /// Défi de second facteur par passkey pour une identité, gardé dans le parcours `flow`
    /// (connexion `mfa_required` ou réauthentification).
    pub async fn passkey_challenge(
        &self,
        identity: &str,
        flow: &str,
    ) -> AuthResult<serde_json::Value> {
        let webauthn = self.webauthn()?;
        let passkeys: Vec<Passkey> = self
            .passkeys_of(identity)
            .await?
            .into_iter()
            .map(|(_, passkey)| passkey)
            .collect();
        if passkeys.is_empty() {
            return Err(AuthError::Rejected("AUTH_MFA_NOT_ENROLLED"));
        }
        let (options, state) = webauthn
            .start_passkey_authentication(&passkeys)
            .map_err(passkey_error)?;
        self.save_state(flow, &state).await?;
        to_json(&options)
    }

    /// Vérifie la réponse à un défi de second facteur ; compteur et indicateurs mis à jour.
    pub async fn verify_passkey(
        &self,
        identity: &str,
        flow: &str,
        flow_type: &str,
        response: serde_json::Value,
    ) -> AuthResult<()> {
        let webauthn = self.webauthn()?;
        let state: PasskeyAuthentication = self.take_state(flow, flow_type, Some(identity)).await?;
        let response: PublicKeyCredential = serde_json::from_value(response)
            .map_err(|_| AuthError::Rejected("AUTH_PASSKEY_INVALID"))?;
        let result = match webauthn.finish_passkey_authentication(&response, &state) {
            Ok(result) => result,
            Err(error) => return Err(self.passkey_failure(&response, error).await),
        };
        let mut known = self.passkeys_of(identity).await?;
        let (credential, passkey) = known
            .iter_mut()
            .find(|(_, passkey)| passkey.cred_id() == result.cred_id())
            .ok_or(AuthError::Rejected("AUTH_PASSKEY_INVALID"))?;
        passkey.update_credential(&result);
        self.store
            .mfa_passkey_update(PasskeyUpdateParams {
                credential: credential.clone(),
                public_data: passkey_document(passkey)?.into_value(),
            })
            .await?;
        Ok(())
    }

    /// Défi de connexion sans mot de passe (clé découvrable, vérification de l'utilisateur).
    pub async fn passkey_login_options(&self) -> AuthResult<PasskeyChallenge> {
        let webauthn = self.webauthn()?;
        let (options, state) = webauthn
            .start_discoverable_authentication()
            .map_err(passkey_error)?;
        let flow = self
            .store
            .flow_start(FlowStartParams {
                flow_type: "passkey_login".to_string(),
                ..FlowStartParams::default()
            })
            .await?;
        let flow = flow.id.to_sql();
        self.save_state(&flow, &state).await?;
        Ok(PasskeyChallenge {
            flow,
            options: to_json(&options)?,
        })
    }

    /// Vérifie une connexion sans mot de passe : clé retrouvée par son identifiant, identité de
    /// la clé égale à celle annoncée par l'appareil, signature vérifiée.
    pub async fn passkey_login(
        &self,
        flow: &str,
        response: serde_json::Value,
    ) -> AuthResult<PasskeyLogin> {
        let webauthn = self.webauthn()?;
        let state: DiscoverableAuthentication =
            self.take_state(flow, "passkey_login", None).await?;
        let response: PublicKeyCredential = serde_json::from_value(response)
            .map_err(|_| AuthError::Rejected("AUTH_PASSKEY_INVALID"))?;
        let (user, credential_id) = webauthn
            .identify_discoverable_authentication(&response)
            .map_err(passkey_error)?;
        let found = self
            .store
            .mfa_passkey_find(PasskeyFindParams {
                credential_id: URL_SAFE_NO_PAD.encode(credential_id),
            })
            .await?;
        let identity = found.identity.to_sql();
        if user_uuid(&identity)? != user || found.identity_state.as_deref() != Some("active") {
            return Err(AuthError::Rejected("AUTH_PASSKEY_INVALID"));
        }
        let mut passkey = stored_passkey(&found.public_data.into_json_value())?;
        let result =
            match webauthn.finish_discoverable_authentication_v2(&response, state, &passkey) {
                Ok(result) => result,
                Err(error) => return Err(self.passkey_failure(&response, error).await),
            };
        passkey.update_credential(&result);
        self.store
            .mfa_passkey_update(PasskeyUpdateParams {
                credential: found.credential.to_sql(),
                public_data: passkey_document(&passkey)?.into_value(),
            })
            .await?;
        self.complete_flow(flow).await?;
        Ok(PasskeyLogin { identity })
    }

    // ------------------------------------------------------------------------------------------
    // Interne
    // ------------------------------------------------------------------------------------------

    fn webauthn(&self) -> AuthResult<&Webauthn> {
        self.webauthn
            .as_ref()
            .ok_or(AuthError::Rejected("AUTH_PASSKEY_UNAVAILABLE"))
    }

    async fn passkeys_of(&self, identity: &str) -> AuthResult<Vec<(String, Passkey)>> {
        self.store
            .mfa_passkey_list_for(PasskeyListForParams {
                identity: identity.to_string(),
            })
            .await?
            .into_iter()
            .map(|record| {
                Ok((
                    record.credential.to_sql(),
                    stored_passkey(&record.public_data.into_json_value())?,
                ))
            })
            .collect()
    }

    /// Refus d'une authentification ; une clé dont le compteur recule est signalée.
    async fn passkey_failure(
        &self,
        response: &PublicKeyCredential,
        error: WebauthnError,
    ) -> AuthError {
        if matches!(error, WebauthnError::CredentialPossibleCompromise) {
            let flagged = self
                .store
                .mfa_passkey_flag(PasskeyFindParams {
                    credential_id: URL_SAFE_NO_PAD.encode(response.get_credential_id()),
                })
                .await;
            if let Err(flag_error) = flagged {
                tracing::error!(error = %flag_error, "signalement d'une passkey clonée impossible");
            }
        }
        passkey_error(error)
    }

    async fn save_state<T: serde::Serialize>(&self, flow: &str, state: &T) -> AuthResult<()> {
        let json = zeroize::Zeroizing::new(
            serde_json::to_vec(state).map_err(|_| AuthError::Rejected("AUTH_CRYPTO_ERROR"))?,
        );
        let sealed = self
            .crypto
            .seal(&SecretBytes::new(json.to_vec())?, &state_context(flow)?)?;
        self.store
            .flow_state_save(FlowStateSaveParams {
                flow: flow.to_string(),
                secret_state: sealed.encode(),
            })
            .await?;
        Ok(())
    }

    async fn take_state<T: serde::de::DeserializeOwned>(
        &self,
        flow: &str,
        flow_type: &str,
        identity: Option<&str>,
    ) -> AuthResult<T> {
        let taken = self
            .store
            .flow_state_take(FlowStateTakeParams {
                flow: flow.to_string(),
            })
            .await?;
        let owner = taken.identity.as_ref().map(|id| id.to_sql());
        if taken.flow_type != flow_type || (identity.is_some() && owner.as_deref() != identity) {
            return Err(AuthError::Rejected("AUTH_FLOW_INVALID_STATE"));
        }
        let bytes = self.crypto.open(
            &EncryptedEnvelope::parse(&taken.secret_state)?,
            &state_context(flow)?,
        )?;
        serde_json::from_slice(bytes.expose_secret())
            .map_err(|_| AuthError::Rejected("AUTH_FLOW_INVALID_STATE"))
    }

    async fn complete_flow(&self, flow: &str) -> AuthResult<()> {
        self.store
            .flow_submit(FlowSubmitParams {
                flow: flow.to_string(),
                from: vec!["started".into()],
                state: "completed".into(),
                ..FlowSubmitParams::default()
            })
            .await?;
        Ok(())
    }
}

/// Contexte de scellement du secret TOTP : lié à l'identifiant du moyen.
fn totp_context(credential_key: &str) -> AuthResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        "lyxal_installation",
        "lyxal_auth",
        "auth_credential",
        credential_key,
        "totp",
    )?)
}

/// Contexte de scellement de l'état d'une cérémonie : lié au parcours.
fn state_context(flow: &str) -> AuthResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        "lyxal_installation",
        "lyxal_auth",
        "auth_flow",
        &record_key(flow)?,
        "webauthn_state",
    )?)
}

/// Clé d'un identifiant `table:clé` (UUID v7 hexadécimal).
fn record_key(record: &str) -> AuthResult<String> {
    record
        .split_once(':')
        .map(|(_, key)| key.trim_matches(['⟨', '⟩', '`']).to_string())
        .filter(|key| !key.is_empty())
        .ok_or(AuthError::InvalidParameter("record"))
}

/// Identifiant WebAuthn de l'utilisateur : l'UUID de son identité (aucune donnée personnelle).
fn user_uuid(identity: &str) -> AuthResult<Uuid> {
    Uuid::parse_str(&record_key(identity)?).map_err(|_| AuthError::InvalidParameter("identity"))
}

fn totp_config(public: &serde_json::Value) -> AuthResult<TotpConfig> {
    // Paramètres enregistrés à l'enrôlement, exigés : aucune valeur par défaut sur une donnée
    // stockée
    let invalid = || AuthError::Rejected("AUTH_CRYPTO_ERROR");
    let algorithm = match public["algorithm"].as_str().ok_or_else(invalid)? {
        "SHA1" => lyxal_crypto::TotpAlgorithm::Sha1,
        "SHA256" => lyxal_crypto::TotpAlgorithm::Sha256,
        _ => return Err(invalid()),
    };
    Ok(TotpConfig {
        algorithm,
        digits: u8::try_from(public["digits"].as_u64().ok_or_else(invalid)?)
            .map_err(|_| invalid())?,
        step_seconds: u32::try_from(public["step_seconds"].as_u64().ok_or_else(invalid)?)
            .map_err(|_| invalid())?,
    })
}

fn unix_now() -> AuthResult<u64> {
    Ok(SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|_| AuthError::Rejected("AUTH_CRYPTO_ERROR"))?
        .as_secs())
}

fn step_i64(step: u64) -> AuthResult<i64> {
    i64::try_from(step).map_err(|_| AuthError::Rejected("AUTH_MFA_INVALID"))
}

/// Code de secours : 10 caractères tirés uniformément (`OsRng`, tirage par rejet), affiché en
/// deux groupes de 5.
fn recovery_code() -> AuthResult<SecretString> {
    let mut code = zeroize::Zeroizing::new(String::with_capacity(RECOVERY_LENGTH + 1));
    let limit = 256 - (256 % RECOVERY_ALPHABET.len());
    while code.len() < RECOVERY_LENGTH + 1 {
        if code.len() == 5 {
            code.push('-');
            continue;
        }
        let mut byte = [0u8; 1];
        OsRng
            .try_fill_bytes(&mut byte)
            .map_err(|_| AuthError::Crypto(lyxal_crypto::CryptoError::RandomUnavailable))?;
        if usize::from(byte[0]) < limit {
            code.push(char::from(
                RECOVERY_ALPHABET[usize::from(byte[0]) % RECOVERY_ALPHABET.len()],
            ));
        }
    }
    Ok(SecretString::new(code.to_string())?)
}

/// Forme comparée d'un code de secours : minuscules, sans séparateurs ni espaces.
fn normalize_code(code: &str) -> String {
    code.chars()
        .filter(|c| c.is_ascii_alphanumeric())
        .map(|c| c.to_ascii_lowercase())
        .collect()
}

/// Document conservé pour une passkey : la clé sérialisée et ses indicateurs de sauvegarde.
fn passkey_document(passkey: &Passkey) -> AuthResult<serde_json::Value> {
    let serialized = to_json(passkey)?;
    Ok(serde_json::json!({
        "passkey": serialized,
        "backup_eligible": serialized["cred"]["backup_eligible"].as_bool().unwrap_or(false),
        "backup_state": serialized["cred"]["backup_state"].as_bool().unwrap_or(false),
    }))
}

fn stored_passkey(document: &serde_json::Value) -> AuthResult<Passkey> {
    serde_json::from_value(document["passkey"].clone())
        .map_err(|_| AuthError::Rejected("AUTH_PASSKEY_INVALID"))
}

fn to_json<T: serde::Serialize>(value: &T) -> AuthResult<serde_json::Value> {
    serde_json::to_value(value).map_err(|_| AuthError::Rejected("AUTH_PASSKEY_INVALID"))
}

fn passkey_error(error: WebauthnError) -> AuthError {
    tracing::info!(error = %error, "cérémonie passkey refusée");
    AuthError::Rejected("AUTH_PASSKEY_INVALID")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn recovery_codes_use_the_unambiguous_alphabet() {
        for _ in 0..50 {
            let code = recovery_code().expect("code");
            let text = code.expose_secret();
            assert_eq!(text.len(), 11);
            assert_eq!(&text[5..6], "-");
            assert_eq!(normalize_code(text).len(), RECOVERY_LENGTH);
            assert!(normalize_code(text)
                .bytes()
                .all(|b| RECOVERY_ALPHABET.contains(&b)));
        }
        assert_eq!(normalize_code(" AB2C3-D4E5F "), "ab2c3d4e5f");
    }

    #[test]
    fn record_keys_and_user_ids() {
        let key = uuid::Uuid::now_v7().simple().to_string();
        assert_eq!(record_key(&format!("auth_flow:{key}")).expect("clé"), key);
        assert!(user_uuid(&format!("auth_identity:{key}")).is_ok());
        assert!(record_key("sans_cle").is_err());
    }
}
