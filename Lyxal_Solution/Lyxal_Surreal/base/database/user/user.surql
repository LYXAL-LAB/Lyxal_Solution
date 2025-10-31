-- =============================================================================
-- MODULE: BASE SOUS MODULE : USER
-- TABLE: base_user (User) - Définition de base
-- Utilisateurs du système avec leurs propriétés étendues
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_user TYPE NORMAL SCHEMAFULL
COMMENT "Utilisateurs du système avec leurs propriétés étendues"
PERMISSIONS FULL;

-- Champs de base
DEFINE FIELD name ON base_user TYPE string
COMMENT "Nom de l'utilisateur";
DEFINE FIELD email ON base_user TYPE option<string>
COMMENT "Email de l'utilisateur";
DEFINE FIELD password ON base_user TYPE string
COMMENT "Mot de passe de l'utilisateur";
DEFINE FIELD transientPassword ON base_user TYPE option<string>
COMMENT "Mot de passe temporaire de l'utilisateur";
DEFINE FIELD homeAction ON base_user TYPE option<string>
COMMENT "Action par défaut de l'utilisateur";

-- Relations avec les entreprises
DEFINE FIELD companySet ON base_user TYPE array<record<base_company>>
COMMENT "Entreprises de l'utilisateur";
DEFINE FIELD activeCompany ON base_user TYPE option<record<base_company>>
COMMENT "Entreprise active de l'utilisateur";

-- Relation avec Partner
DEFINE FIELD partner ON base_user TYPE option<record<base_partner>>
COMMENT "Partenaire de l'utilisateur";

-- Gestion des équipes
DEFINE FIELD teamSet ON base_user TYPE array<record<base_team>>
COMMENT "Équipes de l'utilisateur";
DEFINE FIELD activeTeam ON base_user TYPE option<record<base_team>>
COMMENT "Équipe active de l'utilisateur";

-- Gestion temporelle
DEFINE FIELD todayDateT ON base_user TYPE option<datetime>
COMMENT "Date du jour de l'utilisateur";
DEFINE FIELD activateOn ON base_user TYPE option<datetime>
COMMENT "Date d'activation de l'utilisateur";
DEFINE FIELD expiresOn ON base_user TYPE option<datetime>
COMMENT "Date d'expiration de l'utilisateur";

-- Nom complet calculé
DEFINE FIELD fullName ON base_user TYPE string
COMMENT "Nom complet de l'utilisateur";

-- Calendrier et planification
DEFINE FIELD iCalendar ON base_user TYPE option<record<base_icalendar>>
COMMENT "Calendrier de l'utilisateur";
DEFINE FIELD followersCalUserSet ON base_user TYPE array<record<base_user>>
COMMENT "Utilisateurs suivis par l'utilisateur";

-- Signature électronique
DEFINE FIELD electronicSignature ON base_user TYPE option<record<base_meta_file>>
COMMENT "Signature électronique de l'utilisateur";
DEFINE FIELD useSignatureForSalesQuotations ON base_user TYPE bool DEFAULT false
COMMENT "Utiliser la signature pour les devis de vente";
DEFINE FIELD useSignatureForPurchaseQuotations ON base_user TYPE bool DEFAULT false
COMMENT "Utiliser la signature pour les devis d'achat";

-- Groupes et rôles
DEFINE FIELD userGroup ON base_user TYPE option<record<base_user_group>>
COMMENT "Groupe de l'utilisateur";
DEFINE FIELD userRoles ON base_user TYPE array<record<base_user_role>>
COMMENT "Rôles de l'utilisateur";

-- Préférences utilisateur
DEFINE FIELD language ON base_user TYPE option<string>
COMMENT "Langue de l'utilisateur";
DEFINE FIELD theme ON base_user TYPE option<string>
COMMENT "Thème de l'utilisateur";
DEFINE FIELD singleTab ON base_user TYPE bool DEFAULT false
COMMENT "Utiliser un seul onglet";
DEFINE FIELD noHelp ON base_user TYPE bool DEFAULT false
COMMENT "Désactiver l'aide";
DEFINE FIELD receiveEmails ON base_user TYPE bool DEFAULT true
COMMENT "Recevoir les emails";

-- Gestion du statut
DEFINE FIELD blocked ON base_user TYPE bool DEFAULT true
COMMENT "Bloqué";
DEFINE FIELD sendEmailUponPasswordChange ON base_user TYPE bool DEFAULT false
COMMENT "Envoyer un email lors du changement de mot de passe";
DEFINE FIELD stepStatusSelect ON base_user TYPE int DEFAULT 0
COMMENT "Statut de l'utilisateur";

-- Entités suivies
DEFINE FIELD followedMetaModelSet ON base_user TYPE array<record<base_meta_model>>
COMMENT "Entités suivies par l'utilisateur";

-- Attributs JSON
DEFINE FIELD attrs ON base_user TYPE option<object>
COMMENT "Attributs de l'utilisateur";

-- Signature email
DEFINE FIELD emailSignature ON base_user TYPE option<string>
COMMENT "Signature email de l'utilisateur";

-- Nom commercial
DEFINE FIELD tradingName ON base_user TYPE option<record<base_trading_name>>
COMMENT "Nom commercial de l'utilisateur";

-- Batches associés
DEFINE FIELD batchSet ON base_user TYPE array<record<base_batch>>
COMMENT "Batches de l'utilisateur";

-- Localisation
DEFINE FIELD localization ON base_user TYPE option<record<base_localization>>
COMMENT "Localisation de l'utilisateur";

-- Index et contraintes
DEFINE INDEX idx_user_email ON base_user FIELDS email UNIQUE;
DEFINE INDEX idx_user_partner ON base_user FIELDS partner UNIQUE;
DEFINE INDEX idx_user_active_company ON base_user FIELDS activeCompany;



-- ✅ Structure cohérente avec références validées
DEFINE FIELD roles ON user TYPE array<string>
    COMMENT "Rôles utilisateur - référence system_roles.role_id"
    ASSERT array::all($value, |$role| { 
        SELECT COUNT() FROM system_roles 
        WHERE role_id = $role AND is_active = true 
    } > 0);

-- ✅ Permissions avec validation automatique  
DEFINE FIELD permissions ON user TYPE array<string>
    COMMENT "Permissions explicites - référence system_permissions.permission_id"
    ASSERT array::all($value, |$perm| {
        SELECT COUNT() FROM system_permissions 
        WHERE permission_id = $perm AND is_active = true
    } > 0);