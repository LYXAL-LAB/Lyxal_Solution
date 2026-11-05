-- ============================================================================
-- FONCTION : fn::ingestion_session_identity (interne)
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Identité de l'appelant, lue uniquement dans la session
-- ============================================================================
-- Seul endroit où le module détermine qui agit : fonctions du Data Steward, approbation
-- des manifestes et gardes des tables. Jamais lue dans les paramètres d'un appel.
--
-- * Session utilisateur (jeton ou session d'enregistrement `ingestion_session`) :
--   rôle = claim `role` du jeton, sinon champ `role` de la session ; opérateur = claim `sub`
--   du jeton, sinon identifiant de la session.
-- * Session système (utilisateur système : root de l'hôte, en mode embarqué, par identifiants
--   ou par jeton root ; aucune méthode d'accès `$session.ac` ni session `$auth`) : rôle et
--   opérateur `system`. Elle maîtrise déjà toute la base. Un invité n'est pas une session
--   système : il est refusé par PERMISSIONS ci-dessous et par celles des fonctions appelantes.

DEFINE FUNCTION OVERWRITE fn::ingestion_session_identity($params: object) -> object {
    IF $session.ac == NONE AND $auth == NONE {
        RETURN { role: "system", operator: "system", is_system: true };
    };
    LET $role = $token.role ?? $auth.role;
    LET $operator = $token.sub ?? (IF $auth != NONE { <string> $auth.id } ELSE { NONE });
    RETURN {
        role: IF $role != NONE { <string> $role } ELSE { NONE },
        operator: IF $operator != NONE { <string> $operator } ELSE { NONE },
        is_system: false
    };
} COMMENT "Interne : identité de l'appelant (rôle, opérateur), lue uniquement dans la session ; session système = system"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
