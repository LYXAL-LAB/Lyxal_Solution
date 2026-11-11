-- ============================================================================
-- FONCTIONS : droits sur les traductions
-- MODULE    : lyxal_i18n
-- ============================================================================
-- Utilisées par les PERMISSIONS de i18n_translation et par les fonctions publiques.

DEFINE FUNCTION OVERWRITE fn::i18n_can_translate($params: object) -> bool {
    IF fn::auth_has_permission({ permission: "i18n.translation.manage" }) { RETURN true; };
    IF $params.tenant IS NONE { RETURN false; };
    RETURN fn::auth_has_permission({ permission: "i18n.organization.translation.manage", tenant: $params.tenant });
} COMMENT "Vrai si l'appelant peut écrire les textes de la portée ({ tenant }) : i18n.translation.manage (installation et toute organisation) ou i18n.organization.translation.manage sur son organisation active. Jamais d'erreur";

DEFINE FUNCTION OVERWRITE fn::i18n_can_read($params: object) -> bool {
    IF $params.tenant IS NONE { RETURN true; };
    IF fn::auth_has_permission({ permission: "i18n.translation.manage" }) OR fn::auth_has_permission({ permission: "i18n.translation.read" }) { RETURN true; };
    LET $context = fn::auth_context({});
    RETURN $context.ok AND $context.data.organization = $params.tenant;
} COMMENT "Vrai si l'appelant peut lire les textes de la portée ({ tenant }) : installation ouverte ; surcharges lues par l'organisation active de l'appelant, par i18n.translation.manage ou par i18n.translation.read. Jamais d'erreur";
