-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/normalize_unicode.surql
-- Fonction     : fn::sanitize_normalize_unicode
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Normalise les espaces Unicode courants et supprime les caractères invisibles dangereux ou inutiles.
--
-- Règles appliquées
-- -----------------
--   1. Les espaces insécables et espaces typographiques sont convertis en espace ASCII.
--   2. Les caractères zero-width et le BOM sont supprimés.
--   3. Les séparateurs Unicode de lignes sont convertis en retour à la ligne.
--   4. Un regroupement facultatif des espaces peut être appliqué.
--   5. Cette primitive ne réalise pas une normalisation canonique NFC/NFKC.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $collapse_whitespace: bool
--
-- Valeur retournée
-- ----------------
-- Retourne une chaîne nettoyée.
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Propriétés
-- -----------
--   - fonction pure ;
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune conversion implicite d'un type non textuel ;
--   - résultat déterministe pour une même entrée.

--
-- Limite Unicode
-- ---------------
-- SurrealQL ne fournit pas actuellement de primitive native NFC, NFD, NFKC ou
-- NFKD. Cette fonction réalise une normalisation de transport et d'affichage,
-- sans recomposer les graphèmes.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_normalize_unicode(
    $value: option<any>,
    $field: string,
    $collapse_whitespace: bool
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_string($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    LET $normalized = string::replace(
        $value,
        <regex>"[\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]",
        " "
    );

    LET $normalized = string::replace(
        $normalized,
        <regex>"[\u200B\u200C\u200D\u2060\uFEFF]",
        ""
    );

    LET $normalized = string::replace(
        $normalized,
        <regex>"[\u2028\u2029]",
        "
"
    );

    RETURN IF $collapse_whitespace {
        string::trim(
            string::replace(
                $normalized,
                <regex>"\s+",
                " "
            )
        )
    } ELSE {
        $normalized
    };
}
COMMENT "
Normalise les espaces Unicode et retire plusieurs caractères invisibles, sans
prétendre effectuer une normalisation canonique NFC ou NFKC.
"
PERMISSIONS FULL;
