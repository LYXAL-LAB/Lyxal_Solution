-- ============================================================
-- SEEDS: identity_status (Référentiel)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================


-- DONNÉES INITIALES (SEED)
fn::identity_create_identity_status("Created", "Compte créé, email non vérifié");
fn::identity_create_identity_status("Active", "Compte actif et vérifié");
fn::identity_create_identity_status("Suspended", "Compte suspendu (sécurité ou paiement)");
fn::identity_create_identity_status("Archived", "Compte supprimé logiquement (soft delete)");
fn::identity_create_identity_status("Deleted", "Compte supprimé définitivement (hard delete)");
fn::identity_create_identity_status("Expired", "Compte expiré (date de début de validité dépassée)");
fn::identity_create_identity_status("Pending", "Compte en attente de vérification (email non vérifié)");
fn::identity_create_identity_status("Verified", "Compte vérifié (email vérifié)");