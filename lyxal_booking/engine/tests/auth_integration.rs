//! Suite d'intégration du moteur d'authentification Lyxal OS (SurrealDB In-Memory).
//! 30 scénarios de tests d'intégration réels (27 migrés de Cal.rs + 3 durcissements OIDC).

use lyxal_booking::auth::*;
use lyxal_booking::db::SurrealBookingStore;
use surrealdb::engine::local::Mem;
use surrealdb::Surreal;
use tempfile::tempdir;

/// Harnais d'initialisation du store SurrealDB in-memory avec chargement STRICT de tous les schémas réels.
async fn setup_test_store() -> SurrealBookingStore {
    let db = Surreal::new::<Mem>(())
        .await
        .expect("Failed to initialize SurrealDB in-memory");

    db.use_ns("test_ns")
        .use_db("test_db")
        .await
        .expect("Failed to select ns/db");

    // Définition des fonctions universelles de retour LyxalResult
    let result_helpers = r#"
        DEFINE FUNCTION IF NOT EXISTS fn::result_ok($data: any) {
            RETURN { ok: true, data: $data, error: NONE };
        };
        DEFINE FUNCTION IF NOT EXISTS fn::result_error($code: string, $language: string, $details: object) {
            RETURN {
                ok: false,
                data: NONE,
                error: {
                    code: $code,
                    module: "booking",
                    domain: "auth",
                    category: "validation",
                    severity: "error",
                    message: $code,
                    http_status: 400,
                    retryable: false,
                    timestamp: time::now(),
                    details: $details
                }
            };
        };
    "#;
    db.query(result_helpers).await.expect("Failed to define result helpers");

    // Chargement strict de l'ensemble des schémas réels avec contrôle des erreurs
    let schema_account = include_str!("../../schema/booking_account.surql");
    let schema_indexes = include_str!("../../schema/account_indexes.surql");
    let schema_session = include_str!("../../schema/booking_session.surql");
    let schema_booking = include_str!("../../schema/booking.surql");
    let schema_ev_type = include_str!("../../schema/booking_event_type.surql");
    let schema_invite = include_str!("../../schema/booking_invite.surql");
    let schema_group = include_str!("../../schema/booking_group.surql");
    let schema_group_member = include_str!("../../schema/booking_group_member.surql");
    let schema_team = include_str!("../../schema/booking_team.surql");
    let schema_team_group = include_str!("../../schema/booking_team_group.surql");
    let schema_team_member = include_str!("../../schema/booking_team_member.surql");
    let schema_schedule = include_str!("../../schema/booking_schedule.surql");
    let schema_setting = include_str!("../../schema/booking_setting.surql");

    db.query(schema_account).await.expect("Failed to load schema booking_account");
    db.query(schema_indexes).await.expect("Failed to load schema account_indexes");
    db.query(schema_session).await.expect("Failed to load schema booking_session");
    db.query(schema_booking).await.expect("Failed to load schema booking");
    db.query(schema_ev_type).await.expect("Failed to load schema booking_event_type");
    db.query(schema_invite).await.expect("Failed to load schema booking_invite");
    db.query(schema_group).await.expect("Failed to load schema booking_group");
    db.query(schema_group_member).await.expect("Failed to load schema booking_group_member");
    db.query(schema_team).await.expect("Failed to load schema booking_team");
    db.query(schema_team_group).await.expect("Failed to load schema booking_team_group");
    db.query(schema_team_member).await.expect("Failed to load schema booking_team_member");
    db.query(schema_schedule).await.expect("Failed to load schema booking_schedule");
    db.query(schema_setting).await.expect("Failed to load schema booking_setting");

    // Chargement strict de toutes les fonctions SurrealQL d'authentification avec contrôle d'erreur
    let fn_gen_username = include_str!("../../functions/auth/fn_generate_username.surql");
    let fn_create_local = include_str!("../../functions/auth/fn_create_local_account.surql");
    let fn_create_session = include_str!("../../functions/auth/fn_create_session.surql");
    let fn_validate_session = include_str!("../../functions/auth/fn_validate_session.surql");
    let fn_delete_session = include_str!("../../functions/auth/fn_delete_session.surql");
    let fn_cleanup = include_str!("../../functions/auth/fn_cleanup_expired_sessions.surql");
    let fn_get_account = include_str!("../../functions/auth/fn_get_account_by_id.surql");
    let fn_delete_user = include_str!("../../functions/auth/fn_delete_user.surql");
    let fn_oidc = include_str!("../../functions/auth/fn_find_or_create_oidc_account.surql");
    let fn_sync_groups = include_str!("../../functions/auth/fn_sync_oidc_groups.surql");

    db.query(fn_gen_username).await.expect("Failed to load fn_generate_username");
    db.query(fn_create_local).await.expect("Failed to load fn_create_local_account");
    db.query(fn_create_session).await.expect("Failed to load fn_create_session");
    db.query(fn_validate_session).await.expect("Failed to load fn_validate_session");
    db.query(fn_delete_session).await.expect("Failed to load fn_delete_session");
    db.query(fn_cleanup).await.expect("Failed to load fn_cleanup_expired_sessions");
    db.query(fn_get_account).await.expect("Failed to load fn_get_account_by_id");
    db.query(fn_delete_user).await.expect("Failed to load fn_delete_user");
    db.query(fn_oidc).await.expect("Failed to load fn_find_or_create_oidc_account");
    db.query(fn_sync_groups).await.expect("Failed to load fn_sync_oidc_groups");

    SurrealBookingStore::new_mem(db)
}

// ----------------------------------------------------------------------------
// SESSIONS ET RÉCUPÉRATION DE COMPTE
// ----------------------------------------------------------------------------

#[tokio::test]
async fn test_1_create_and_validate_session() {
    let store = setup_test_store().await;
    let user = create_local_user(&store, "sess@test.com", "Session User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "sessuser", false, "fr").await.unwrap();

    let session = create_session(&store, &user.id, "fr").await.unwrap();
    assert!(!session.id.is_empty());

    let validated = validate_session(&store, &session.id, "fr").await.unwrap();
    assert_eq!(validated.user.id, user.id);
    assert_eq!(validated.user.email, "sess@test.com");
}

#[tokio::test]
async fn test_2_validate_session_invalid_token() {
    let store = setup_test_store().await;
    let res = validate_session(&store, "invalid-token-123", "fr").await;
    assert!(res.is_err());
    assert!(res.unwrap_err().is_business_code("BOOKING_SESSION_NOT_FOUND"));
}

#[tokio::test]
async fn test_3_validate_session_expired() {
    let store = setup_test_store().await;
    let user = create_local_user(&store, "exp@test.com", "Exp User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "expuser", false, "fr").await.unwrap();
    let session = create_session(&store, &user.id, "fr").await.unwrap();

    store.query(&format!("UPDATE booking_session SET expires_at = time::now() - 1d WHERE id = '{}';", session.id)).await.unwrap();

    let res = validate_session(&store, &session.id, "fr").await;
    assert!(res.is_err());
    assert!(res.unwrap_err().is_business_code("BOOKING_SESSION_NOT_FOUND"));
}

#[tokio::test]
async fn test_4_delete_session_succeeds() {
    let store = setup_test_store().await;
    let user = create_local_user(&store, "delsess@test.com", "Del User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "delsessuser", false, "fr").await.unwrap();
    let session = create_session(&store, &user.id, "fr").await.unwrap();

    let del_res = delete_session(&store, &session.id, "fr").await.unwrap();
    assert!(del_res.deleted);

    let val_res = validate_session(&store, &session.id, "fr").await;
    assert!(val_res.is_err());
}

#[tokio::test]
async fn test_5_delete_session_nonexistent() {
    let store = setup_test_store().await;
    let del_res = delete_session(&store, "nonexistent_token", "fr").await.unwrap();
    assert!(!del_res.deleted);
}

#[tokio::test]
async fn test_6_cleanup_expired_sessions_removes_old_keeps_valid() {
    let store = setup_test_store().await;
    let user = create_local_user(&store, "clean@test.com", "Clean User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "cleanuser", false, "fr").await.unwrap();

    let s1 = create_session(&store, &user.id, "fr").await.unwrap();
    let s2 = create_session(&store, &user.id, "fr").await.unwrap();

    store.query(&format!("UPDATE booking_session SET expires_at = time::now() - 1d WHERE id = '{}';", s1.id)).await.unwrap();

    let cleanup_res = cleanup_expired_sessions(&store).await.unwrap();
    assert!(cleanup_res.cleaned);

    assert!(validate_session(&store, &s1.id, "fr").await.is_err());
    assert!(validate_session(&store, &s2.id, "fr").await.is_ok());
}

#[tokio::test]
async fn test_7_get_user_by_id_succeeds() {
    let store = setup_test_store().await;
    let created = create_local_user(&store, "getid@test.com", "GetId User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "getiduser", false, "fr").await.unwrap();

    let fetched = get_user_by_id(&store, &created.id, "fr").await.unwrap();
    assert_eq!(fetched.id, created.id);
    assert_eq!(fetched.email, "getid@test.com");
}

// ----------------------------------------------------------------------------
// GÉNÉRATION ET COLLISIONS DE PSEUDONAMES
// ----------------------------------------------------------------------------

#[tokio::test]
async fn test_8_generate_username_basic() {
    let store = setup_test_store().await;
    let uname = generate_username(&store, "alice.smith@example.com", "fr").await.unwrap();
    assert_eq!(uname.username, "alice-smith");
}

#[tokio::test]
async fn test_9_generate_username_strips_special_chars() {
    let store = setup_test_store().await;
    let uname = generate_username(&store, "al!ce+tag@example.com", "fr").await.unwrap();
    assert_eq!(uname.username, "alcetag");
}

#[tokio::test]
async fn test_10_generate_username_uppercase_lowered() {
    let store = setup_test_store().await;
    let uname = generate_username(&store, "Alice.BOB@example.com", "fr").await.unwrap();
    assert_eq!(uname.username, "alice-bob");
}

#[tokio::test]
async fn test_11_generate_username_empty_local_part_fallback() {
    let store = setup_test_store().await;
    let uname = generate_username(&store, "@example.com", "fr").await.unwrap();
    assert_eq!(uname.username, "user");
}

#[tokio::test]
async fn test_12_generate_username_no_at_sign() {
    let store = setup_test_store().await;
    let uname = generate_username(&store, "justname", "fr").await.unwrap();
    assert_eq!(uname.username, "justname");
}

#[tokio::test]
async fn test_13_generate_username_collision_appends_suffix() {
    let store = setup_test_store().await;
    create_local_user(&store, "alice@one.com", "Alice One", "$argon2id$v=19$m=65536,t=3,p=1$fake", "alice", false, "fr").await.unwrap();

    let uname = generate_username(&store, "alice@two.com", "fr").await.unwrap();
    assert_eq!(uname.username, "alice-1");
}

#[tokio::test]
async fn test_14_generate_username_multiple_collisions() {
    let store = setup_test_store().await;
    create_local_user(&store, "bob@one.com", "Bob One", "$argon2id$v=19$m=65536,t=3,p=1$fake", "bob", false, "fr").await.unwrap();

    store.query("CREATE ONLY booking_account CONTENT { name: 'Bob 2', email: 'bob2@test.com', username: 'bob-1', role: 'user', timezone: 'UTC', language: 'fr', enabled: true };").await.unwrap();
    store.query("CREATE ONLY booking_account CONTENT { name: 'Bob 3', email: 'bob3@test.com', username: 'bob-2', role: 'user', timezone: 'UTC', language: 'fr', enabled: true };").await.unwrap();

    let uname = generate_username(&store, "bob@new.com", "fr").await.unwrap();
    assert_eq!(uname.username, "bob-3");
}

// ----------------------------------------------------------------------------
// CRÉATION DE COMPTE ET DROITS ATOMIQUES
// ----------------------------------------------------------------------------

#[tokio::test]
async fn test_15_create_local_user_first_user_is_admin() {
    let store = setup_test_store().await;
    let u1 = create_local_user(&store, "admin@test.com", "Admin User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "admin", false, "fr").await.unwrap();
    assert_eq!(u1.role, "admin");
}

#[tokio::test]
async fn test_16_create_local_user_second_user_is_normal_role() {
    let store = setup_test_store().await;
    let u1 = create_local_user(&store, "first@test.com", "First User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "first", false, "fr").await.unwrap();
    let u2 = create_local_user(&store, "second@test.com", "Second User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "second", false, "fr").await.unwrap();

    assert_eq!(u1.role, "admin");
    assert_eq!(u2.role, "user");
}

#[tokio::test]
async fn test_17_create_local_user_force_admin() {
    let store = setup_test_store().await;
    create_local_user(&store, "first@test.com", "First User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "first", false, "fr").await.unwrap();
    let forced = create_local_user(&store, "forced@test.com", "Forced Admin", "$argon2id$v=19$m=65536,t=3,p=1$fake", "forced", true, "fr").await.unwrap();

    assert_eq!(forced.role, "admin");
}

#[tokio::test]
async fn test_18_create_local_user_duplicate_email_fails() {
    let store = setup_test_store().await;
    create_local_user(&store, "dup@test.com", "Dup One", "$argon2id$v=19$m=65536,t=3,p=1$fake", "dup1", false, "fr").await.unwrap();

    let res = create_local_user(&store, "dup@test.com", "Dup Two", "$argon2id$v=19$m=65536,t=3,p=1$fake", "dup2", false, "fr").await;
    assert!(res.is_err());
}

// ----------------------------------------------------------------------------
// SUPPRESSION D'UTILISATEUR ET PROTECTIONS MÉTIER
// ----------------------------------------------------------------------------

#[tokio::test]
async fn test_19_delete_user_not_found() {
    let store = setup_test_store().await;
    let res = delete_user(&store, "booking_account:nonexistent", Some("booking_account:admin"), None).await;
    assert!(matches!(res, Err(DeleteUserError::NotFound)));
}

#[tokio::test]
async fn test_20_delete_user_cannot_delete_self() {
    let store = setup_test_store().await;
    let admin = create_local_user(&store, "admin@test.com", "Admin User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "admin", false, "fr").await.unwrap();

    let res = delete_user(&store, &admin.id, Some(&admin.id), None).await;
    assert!(matches!(res, Err(DeleteUserError::SelfDelete)));
}

#[tokio::test]
async fn test_21_delete_user_cannot_delete_last_admin() {
    let store = setup_test_store().await;
    let admin = create_local_user(&store, "admin@test.com", "Admin User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "admin", false, "fr").await.unwrap();
    let other = create_local_user(&store, "other@test.com", "Other User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "other", false, "fr").await.unwrap();

    let res = delete_user(&store, &admin.id, Some(&other.id), None).await;
    assert!(matches!(res, Err(DeleteUserError::LastAdmin)));
}

#[tokio::test]
async fn test_22_a_delete_user_blocked_by_host_future_bookings() {
    let store = setup_test_store().await;
    let admin = create_local_user(&store, "admin@test.com", "Admin User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "admin", false, "fr").await.unwrap();
    let host = create_local_user(&store, "host@test.com", "Host User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "hostuser", false, "fr").await.unwrap();

    let ev_query = format!("CREATE ONLY booking_event_type CONTENT {{ account: {}, title: 'Meeting' }};", host.id);
    let mut ev_res = store.query(&ev_query).await.unwrap();
    let ev: serde_json::Value = ev_res.take(0).unwrap();
    let ev_id = ev.get("id").unwrap().as_str().unwrap();

    let bk_query = format!("CREATE ONLY booking CONTENT {{ event_type: {}, status: 'confirmed', start_at: time::now() + 1d }};", ev_id);
    store.query(&bk_query).await.unwrap();

    let res = delete_user(&store, &host.id, Some(&admin.id), None).await;
    assert!(matches!(res, Err(DeleteUserError::HasFutureBookings { count: 1 })));
}

#[tokio::test]
async fn test_22_b_delete_user_blocked_by_assignee_future_bookings() {
    let store = setup_test_store().await;
    let admin = create_local_user(&store, "admin@test.com", "Admin User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "admin", false, "fr").await.unwrap();
    let assignee = create_local_user(&store, "assignee@test.com", "Assignee User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "assigneeuser", false, "fr").await.unwrap();

    let bk_query = format!("CREATE ONLY booking CONTENT {{ assigned_account: {}, status: 'confirmed', start_at: time::now() + 1d }};", assignee.id);
    store.query(&bk_query).await.unwrap();

    let res = delete_user(&store, &assignee.id, Some(&admin.id), None).await;
    assert!(matches!(res, Err(DeleteUserError::HasFutureBookings { count: 1 })));
}

#[tokio::test]
async fn test_23_delete_user_purges_invites_sessions_and_avatar() {
    let store = setup_test_store().await;
    let admin = create_local_user(&store, "admin@test.com", "Admin User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "admin", false, "fr").await.unwrap();
    let target = create_local_user(&store, "target@test.com", "Target User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "targetuser", false, "fr").await.unwrap();

    let dir = tempdir().unwrap();
    let avatar_file_name = format!("{}_avatar.png", target.id.replace(":", "_"));
    let avatar_file_path = dir.path().join(&avatar_file_name);
    std::fs::write(&avatar_file_path, b"fake_png_bytes").unwrap();

    store.query(&format!("UPDATE {} SET avatar_path = '{}';", target.id, avatar_file_name)).await.unwrap();

    create_session(&store, &target.id, "fr").await.unwrap();
    store.query(&format!("CREATE ONLY booking_invite CONTENT {{ created_by: {}, email: 'guest@test.com' }};", target.id)).await.unwrap();

    let del_res = delete_user(&store, &target.id, Some(&admin.id), Some(dir.path())).await;
    assert!(del_res.is_ok());

    let mut check_inv = store.query("SELECT * FROM booking_invite;").await.unwrap();
    let invites: Vec<serde_json::Value> = check_inv.take(0).unwrap_or_default();
    assert_eq!(invites.len(), 0);

    let mut check_sess = store.query(&format!("SELECT * FROM booking_session WHERE account = {};", target.id)).await.unwrap();
    let sessions: Vec<serde_json::Value> = check_sess.take(0).unwrap_or_default();
    assert_eq!(sessions.len(), 0);

    assert!(!avatar_file_path.exists());
}

// ----------------------------------------------------------------------------
// INTEGRATION ET SYNCHRONISATION OIDC
// ----------------------------------------------------------------------------

#[tokio::test]
async fn test_24_find_or_create_oidc_user_links_subject() {
    let store = setup_test_store().await;
    let u1 = find_or_create_oidc_user(&store, "https://oidc.example.com", "sub123", "oidc@test.com", true, "OIDC User", None, true, "fr").await.unwrap();
    let u2 = find_or_create_oidc_user(&store, "https://oidc.example.com", "sub123", "newemail@test.com", true, "OIDC User Updated", None, true, "fr").await.unwrap();

    assert_eq!(u1.id, u2.id);

    let mut check = store.query(&format!("SELECT email, name, oidc_issuer, oidc_sub FROM ONLY {};", u1.id)).await.unwrap();
    let res: serde_json::Value = check.take(0).unwrap();
    assert_eq!(res.get("email").unwrap().as_str().unwrap(), "newemail@test.com");
    assert_eq!(res.get("name").unwrap().as_str().unwrap(), "OIDC User Updated");
    assert_eq!(res.get("oidc_issuer").unwrap().as_str().unwrap(), "https://oidc.example.com");
    assert_eq!(res.get("oidc_sub").unwrap().as_str().unwrap(), "sub123");
}

#[tokio::test]
async fn test_25_find_or_create_oidc_user_links_email() {
    let store = setup_test_store().await;
    let local = create_local_user(&store, "link@test.com", "Link User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "linkuser", false, "fr").await.unwrap();

    let oidc = find_or_create_oidc_user(&store, "https://oidc.provider.com", "sub_new_456", "link@test.com", true, "Linked OIDC", None, true, "fr").await.unwrap();
    assert_eq!(local.id, oidc.id);

    let mut check = store.query(&format!("SELECT oidc_issuer, oidc_sub FROM ONLY {};", local.id)).await.unwrap();
    let res: serde_json::Value = check.take(0).unwrap();
    assert_eq!(res.get("oidc_issuer").unwrap().as_str().unwrap(), "https://oidc.provider.com");
    assert_eq!(res.get("oidc_sub").unwrap().as_str().unwrap(), "sub_new_456");
}

#[tokio::test]
async fn test_26_find_or_create_oidc_user_syncs_title() {
    let store = setup_test_store().await;
    let u = find_or_create_oidc_user(&store, "https://oidc.provider.com", "sub_title_789", "title@test.com", true, "Title User", Some("Senior Architect"), true, "fr").await.unwrap();

    let mut title_res = store.query(&format!("SELECT VALUE title FROM ONLY {};", u.id)).await.unwrap();
    let db_title: Option<String> = title_res.take(0).unwrap_or(None);
    assert_eq!(db_title.as_deref(), Some("Senior Architect"));
}

#[tokio::test]
async fn test_27_sync_user_groups_diff_and_preserves_direct() {
    let store = setup_test_store().await;
    let user = create_local_user(&store, "group@test.com", "Group User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "grpuser", false, "fr").await.unwrap();

    store.query("CREATE ONLY booking_team:devs_team CONTENT { name: 'Devs' };").await.unwrap();
    store.query("CREATE ONLY booking_team:sales_team CONTENT { name: 'Sales' };").await.unwrap();

    let grp_devs = "booking_group:oidc:devs";
    let grp_sales = "booking_group:oidc:sales";
    store.query(&format!("CREATE ONLY {} CONTENT {{ display_name: 'devs', provider: 'oidc' }};", grp_devs)).await.unwrap();
    store.query(&format!("CREATE ONLY {} CONTENT {{ display_name: 'sales', provider: 'oidc' }};", grp_sales)).await.unwrap();

    store.query(&format!("RELATE {}->booking_team_group->booking_team:devs_team;", grp_devs)).await.unwrap();
    store.query(&format!("RELATE {}->booking_team_group->booking_team:sales_team;", grp_sales)).await.unwrap();

    store.query("CREATE ONLY booking_team:direct_team CONTENT { name: 'Direct Team' };").await.unwrap();
    store.query(&format!("RELATE {}->booking_team_member->booking_team:direct_team CONTENT {{ role: 'member', source: 'direct' }};", user.id)).await.unwrap();

    let pass1_groups = vec!["devs".to_string(), "sales".to_string()];
    let res1 = sync_user_groups(&store, &user.id, "oidc", &pass1_groups, "fr").await.unwrap();
    assert_eq!(res1.team_memberships_added, 2);

    let pass2_groups = vec!["devs".to_string()];
    let res2 = sync_user_groups(&store, &user.id, "oidc", &pass2_groups, "fr").await.unwrap();
    assert_eq!(res2.team_memberships_removed, 1);

    // Contrôle strict du modèle Graph canonique SurrealDB IN/OUT
    let mut direct_check = store.query(&format!("SELECT * FROM booking_team_member WHERE in = {} AND source = 'direct';", user.id)).await.unwrap();
    let direct_members: Vec<serde_json::Value> = direct_check.take(0).unwrap_or_default();
    assert_eq!(direct_members.len(), 1);
}

#[tokio::test]
async fn test_28_find_or_create_oidc_unverified_email_fails() {
    let store = setup_test_store().await;
    let res = find_or_create_oidc_user(&store, "https://oidc.provider.com", "sub_unverified", "unverified@test.com", false, "Unverified User", None, true, "fr").await;
    assert!(res.is_err());
    assert!(res.unwrap_err().is_business_code("BOOKING_AUTH_OIDC_EMAIL_NOT_VERIFIED"));
}

#[tokio::test]
async fn test_29_find_or_create_oidc_auto_register_disabled_fails() {
    let store = setup_test_store().await;
    let res = find_or_create_oidc_user(&store, "https://oidc.provider.com", "sub_no_auto", "noauto@test.com", true, "No Auto User", None, false, "fr").await;
    assert!(res.is_err());
    assert!(res.unwrap_err().is_business_code("BOOKING_AUTH_OIDC_ACCOUNT_NOT_LINKED"));
}

#[tokio::test]
async fn test_30_find_or_create_oidc_disabled_user_fails() {
    let store = setup_test_store().await;
    let user = create_local_user(&store, "disabled@test.com", "Disabled User", "$argon2id$v=19$m=65536,t=3,p=1$fake", "disuser", false, "fr").await.unwrap();

    store.query(&format!("UPDATE {} SET enabled = false;", user.id)).await.unwrap();

    let res = find_or_create_oidc_user(&store, "https://oidc.provider.com", "sub_dis", "disabled@test.com", true, "Disabled User", None, true, "fr").await;
    assert!(res.is_err());
    assert!(res.unwrap_err().is_business_code("BOOKING_AUTH_USER_DISABLED"));
}
