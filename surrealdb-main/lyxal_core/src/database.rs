use surrealdb::engine::remote::ws::{Client, Ws};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;
use tracing::info;
use crate::error::{Result, CoreError};

/// Database manager for the Lyxal Identity system using SurrealDB.
#[derive(Clone, Debug)]
pub struct Database {
    client: Surreal<Client>,
}

impl Database {
    /// Creates a new Database instance by connecting to the provided SurrealDB URL.
    pub async fn new(url: &str) -> Result<Self> {
        info!("Initializing SurrealDB connection...");
        let client = Surreal::new::<Ws>(url).await
            .map_err(|e| CoreError::Database(e.to_string()))?;
        info!("SurrealDB connection established successfully.");
        Ok(Self { client })
    }

    pub async fn signin(&self, user: &str, pass: &str) -> Result<()> {
        self.client.signin(Root {
            username: user,
            password: pass,
        }).await.map_err(|e| CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub async fn use_ns_db(&self, ns: &str, db: &str) -> Result<()> {
        self.client.use_ns(ns).use_db(db).await
            .map_err(|e| CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub fn client(&self) -> &Surreal<Client> {
        &self.client
    }

    pub async fn health_check(&self) -> Result<()> {
        self.client.health().await
            .map_err(|e| CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub async fn close(&self) {
        info!("SurrealDB connection dropped.");
    }
}

#[async_trait::async_trait]
pub trait DatabaseExt {
    async fn migrate(&self) -> Result<()>;
}

#[async_trait::async_trait]
impl DatabaseExt for Database {
    async fn migrate(&self) -> Result<()> {
        info!("Defining full SurrealDB schema (Logto port)...");

        let mut query = String::new();
        
        // Identity
        query.push_str(include_str!("../../database/identity/users.surql"));
        query.push_str(include_str!("../../database/identity/account_centers.surql"));
        query.push_str(include_str!("../../database/identity/custom_profile_fields.surql"));
        query.push_str(include_str!("../../database/identity/user_geo_locations.surql"));
        query.push_str(include_str!("../../database/identity/user_sign_in_countries.surql"));
        query.push_str(include_str!("../../database/identity/user_sso_identities.surql"));
        
        // Organization
        query.push_str(include_str!("../../database/organization/organizations.surql"));
        query.push_str(include_str!("../../database/organization/organization_invitations.surql"));
        query.push_str(include_str!("../../database/organization/organization_roles.surql"));
        query.push_str(include_str!("../../database/organization/organization_user_relations.surql"));
        query.push_str(include_str!("../../database/organization/organization_role_user_relations.surql"));
        query.push_str(include_str!("../../database/organization/organization_application_relations.surql"));
        query.push_str(include_str!("../../database/organization/organization_jit_roles.surql"));
        query.push_str(include_str!("../../database/organization/organization_role_application_relations.surql"));
        query.push_str(include_str!("../../database/organization/organization_role_resource_scope_relations.surql"));
        query.push_str(include_str!("../../database/organization/organization_role_scope_relations.surql"));
        
        // RBAC
        query.push_str(include_str!("../../database/rbac/roles.surql"));
        query.push_str(include_str!("../../database/rbac/permissions.surql"));
        query.push_str(include_str!("../../database/rbac/resources.surql"));
        query.push_str(include_str!("../../database/rbac/scopes.surql"));
        query.push_str(include_str!("../../database/rbac/roles_scopes.surql"));
        query.push_str(include_str!("../../database/rbac/users_roles.surql"));
        query.push_str(include_str!("../../database/rbac/application_user_consent_organizations.surql"));
        query.push_str(include_str!("../../database/rbac/application_user_consent_organization_resource_scopes.surql"));
        query.push_str(include_str!("../../database/rbac/application_user_consent_organization_scopes.surql"));
        query.push_str(include_str!("../../database/rbac/application_user_consent_resource_scopes.surql"));
        query.push_str(include_str!("../../database/rbac/application_user_consent_user_scopes.surql"));
        query.push_str(include_str!("../../database/rbac/organization_scopes.surql"));
        query.push_str(include_str!("../../database/rbac/organization_invitation_role_relations.surql"));
        query.push_str(include_str!("../../database/rbac/organization_jit_email_domains.surql"));
        query.push_str(include_str!("../../database/rbac/organization_jit_sso_connectors.surql"));
        
        // Auth
        query.push_str(include_str!("../../database/auth/oidc_model_instances.surql"));
        query.push_str(include_str!("../../database/auth/verification_records.surql"));
        query.push_str(include_str!("../../database/auth/connectors.surql"));
        query.push_str(include_str!("../../database/auth/passcodes.surql"));
        query.push_str(include_str!("../../database/auth/personal_access_tokens.surql"));
        query.push_str(include_str!("../../database/auth/sso_connectors.surql"));
        query.push_str(include_str!("../../database/auth/subject_tokens.surql"));
        query.push_str(include_str!("../../database/auth/verification_statuses.surql"));
        query.push_str(include_str!("../../database/auth/one_time_tokens.surql"));
        query.push_str(include_str!("../../database/auth/secret_enterprise_sso_connector_relations.surql"));
        query.push_str(include_str!("../../database/auth/secret_social_connector_relations.surql"));
        
        // App
        query.push_str(include_str!("../../database/app/applications.surql"));
        query.push_str(include_str!("../../database/app/sign_in_experiences.surql"));
        query.push_str(include_str!("../../database/app/application_sign_in_experiences.surql"));
        query.push_str(include_str!("../../database/app/applications_roles.surql"));
        
        // SAML
        query.push_str(include_str!("../../database/saml/saml_application_configs.surql"));
        query.push_str(include_str!("../../database/saml/saml_application_secrets.surql"));
        query.push_str(include_str!("../../database/saml/saml_application_sessions.surql"));
        query.push_str(include_str!("../../database/saml/sso_connector_idp_initiated_auth_configs.surql"));
        query.push_str(include_str!("../../database/saml/idp_initiated_saml_sso_sessions.surql"));

        // Stats
        query.push_str(include_str!("../../database/stats/daily_active_users.surql"));
        query.push_str(include_str!("../../database/stats/aggregated_daily_active_users.surql"));
        query.push_str(include_str!("../../database/stats/daily_token_usage.surql"));

        // System & Log
        query.push_str(include_str!("../../database/system/domains.surql"));
        query.push_str(include_str!("../../database/system/hooks.surql"));
        query.push_str(include_str!("../../database/system/logto_configs.surql"));
        query.push_str(include_str!("../../database/system/custom_phrases.surql"));
        query.push_str(include_str!("../../database/system/captcha_providers.surql"));
        query.push_str(include_str!("../../database/system/systems.surql"));
        query.push_str(include_str!("../../database/system/sentinel_activities.surql"));
        query.push_str(include_str!("../../database/system/secrets.surql"));
        query.push_str(include_str!("../../database/log/logs.surql"));
        query.push_str(include_str!("../../database/log/service_logs.surql"));

        self.client.query(query).await
            .map_err(|e| CoreError::Database(e.to_string()))?;

        info!("SurrealDB schema defined (Full Logto port - ~65 tables).");
        Ok(())
    }
}
