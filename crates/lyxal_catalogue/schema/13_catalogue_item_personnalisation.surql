-- ============================================================================
-- TABLE  : catalogue_item_personnalisation
-- MODULE : lyxal_catalogue
-- RÔLE   : Personnalisation d'un article maître par un locataire (libellé, code interne,
--          disponibilité), sans jamais modifier l'article maître partagé
-- ============================================================================
-- Une ligne par couple (article maître, locataire). Seul le locataire propriétaire la lit et
-- l'écrit ; l'agent de synchronisation n'y a aucun accès. Un article privé appartient déjà à
-- son locataire : il se modifie directement et n'a pas de personnalisation.

DEFINE TABLE OVERWRITE catalogue_item_personnalisation
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND $token.role = "tenant_user"
                AND $token.tenant_id != NONE AND tenant_id = $token.tenant_id)
            OR ($token == NONE AND $auth != NONE AND $auth.role = "tenant_user"
                AND $auth.tenant_id != NONE AND tenant_id = $auth.tenant_id)
        )
    COMMENT "Personnalisations des articles maîtres par locataire (libellé, code interne, disponibilité)";

DEFINE FIELD OVERWRITE item ON TABLE catalogue_item_personnalisation
    TYPE record<catalogue_item>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Article maître personnalisé";

DEFINE FIELD OVERWRITE tenant_id ON TABLE catalogue_item_personnalisation
    TYPE string
    DEFAULT IF $token.tenant_id != NONE { $token.tenant_id } ELSE IF $auth.tenant_id != NONE { $auth.tenant_id } ELSE { NONE }
    READONLY
    ASSERT string::len($value) >= 1
    COMMENT "Locataire propriétaire, pris de la session";

DEFINE FIELD OVERWRITE libelle_personnalise ON TABLE catalogue_item_personnalisation
    TYPE option<string>
    ASSERT $value = NONE OR (string::len($value) >= 1 AND string::len($value) <= 255)
    COMMENT "Désignation affichée par ce locataire à la place du libellé officiel";

DEFINE FIELD OVERWRITE code_interne_client ON TABLE catalogue_item_personnalisation
    TYPE option<string>
    ASSERT $value = NONE OR (string::len($value) >= 1 AND string::len($value) <= 64)
    COMMENT "Code article propre à ce locataire";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_item_personnalisation
    TYPE bool
    DEFAULT true
    COMMENT "Disponibilité de l'article pour ce locataire (n'affecte aucun autre locataire)";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_item_personnalisation
    TYPE datetime
    VALUE time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_item_personnalisation
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE idx_personnalisation_item_tenant ON TABLE catalogue_item_personnalisation
    FIELDS item, tenant_id UNIQUE;

-- ----------------------------------------------------------------------------
-- GARDIEN : seuls les articles maîtres se personnalisent
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_personnalisation_guard ON TABLE catalogue_item_personnalisation
WHEN $event = "CREATE"
THEN {
    IF (SELECT VALUE is_custom FROM ONLY $after.item) != false {
        THROW "CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER: Seul un article maître se personnalise ; un article privé se modifie directement par son locataire.";
    };
};
