//! Contrats Rust ↔ SurrealQL : chaque appel typé traverse sa fonction et se désérialise.

use lyxal_auth::models::{
    IdentityCreateParams, IdentityGetParams, IdentityPermissionsParams, IdentityState,
    MemberAddParams, MemberRemoveParams, OrganizationCreateParams, OrganizationGetParams,
    OrganizationState, PermissionRegisterParams, PermissionScope, PolicyGetParams,
    RoleAssignParams,
};
use lyxal_auth::{AuthHealthCheck, AuthModule};
use lyxal_runtime::health::ModuleHealthCheck;
use lyxal_runtime::LyxalModule;
use lyxal_surreal::{SurrealValue, ToSql, Value};

use crate::support::installed_store;

fn object(json: serde_json::Value) -> Value {
    serde_json::from_value::<serde_json::Value>(json)
        .map(|v| v.into_value())
        .expect("valeur")
}

#[tokio::test]
async fn context_of_the_system_session() {
    let store = installed_store().await;
    let context = store.context().await.expect("contexte");
    assert!(context.system);
    assert!(context.identity.is_none());
}

#[tokio::test]
async fn organization_identity_membership_and_roles_round_trip() {
    let store = installed_store().await;
    let identity = store
        .identity_create(IdentityCreateParams {
            schema_key: None,
            traits: object(
                serde_json::json!({ "email": "Ada@Exemple.fr", "name": { "first": "Ada" } }),
            ),
            external_id: Some("ERP-7".into()),
            organization: None,
            roles: vec![],
        })
        .await
        .expect("identité");
    assert_eq!(identity.state, IdentityState::Active);
    assert_eq!(identity.external_id.as_deref(), Some("ERP-7"));
    let identity_id = identity.id.to_sql();

    let organization = store
        .organization_create(OrganizationCreateParams {
            slug: "alpha".into(),
            name: "Alpha".into(),
            description: None,
            mfa_required: Some(false),
            owner: None,
        })
        .await
        .expect("organisation");
    assert_eq!(organization.state, OrganizationState::Active);
    let organization_id = organization.id.to_sql();
    let fetched = store
        .organization_get(OrganizationGetParams {
            organization: None,
            slug: Some("alpha".into()),
        })
        .await
        .expect("lecture");
    assert_eq!(fetched.id, organization.id);

    let added = store
        .member_add(MemberAddParams {
            organization: organization_id.clone(),
            identity: identity_id.clone(),
            roles: vec!["auth_role:organization_admin".into()],
        })
        .await
        .expect("adhésion");
    assert_eq!(added.roles.len(), 2);

    let permissions = store
        .identity_permissions(IdentityPermissionsParams {
            identity: identity_id.clone(),
            organization: Some(organization_id.clone()),
        })
        .await
        .expect("permissions");
    assert!(permissions
        .organization_permissions
        .contains(&"auth.member.manage".to_string()));
    assert!(permissions.installation.is_empty());
    assert_eq!(permissions.version, 1);

    let assigned = store
        .role_assign(RoleAssignParams {
            role: "auth_role:platform_admin".into(),
            identity: identity_id.clone(),
            organization: None,
        })
        .await
        .expect("rôle d'installation");
    assert!(assigned.assigned);
    let unassigned = store
        .role_unassign(RoleAssignParams {
            role: "auth_role:platform_admin".into(),
            identity: identity_id.clone(),
            organization: None,
        })
        .await
        .expect("retrait");
    assert!(unassigned.unassigned);

    let removed = store
        .member_remove(MemberRemoveParams {
            organization: organization_id,
            identity: identity_id.clone(),
        })
        .await;
    // Ada est la seule administratrice : le retrait est refusé (code de la master data)
    let error = removed.expect_err("dernier administrateur");
    assert!(error.is_business_code("AUTH_LAST_ADMIN"), "{error}");

    let read = store
        .identity_get(IdentityGetParams {
            identity: identity_id,
        })
        .await
        .expect("identité relue");
    assert_eq!(
        read.permissions_version, 2,
        "le retrait du rôle incrémente la version"
    );
}

#[tokio::test]
async fn permission_registration_is_create_only() {
    let store = installed_store().await;
    let params = || PermissionRegisterParams {
        code: "notification.read".into(),
        module: "lyxal_notification".into(),
        scope: PermissionScope::Organization,
        description: object(serde_json::json!({ "fr": "Lire les notifications" })),
    };
    assert!(
        store
            .permission_register(params())
            .await
            .expect("création")
            .created
    );
    let again = store.permission_register(params()).await.expect("rejeu");
    assert!(!again.created);
    assert_eq!(again.scope, PermissionScope::Organization);
}

#[tokio::test]
async fn module_descriptor_and_health_check() {
    let store = installed_store().await;
    let module = AuthModule::new();
    assert_eq!(module.descriptor().id.as_str(), "lyxal_auth");
    let policy = store
        .policy_get(PolicyGetParams::default())
        .await
        .expect("politique");
    assert!(policy.to_sql().contains("invitation_only"));
    let check = AuthHealthCheck::new(store);
    let ctx = lyxal_runtime::ModuleContext::new(lyxal_runtime::types::ModuleId::new("lyxal_auth"));
    let result = check.check(&ctx).await.expect("sonde");
    assert_eq!(result.status, lyxal_runtime::health::HealthStatus::Healthy);
}
