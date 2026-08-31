-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/email.surql
-- Fonction     : fn::validation_email
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est une adresse e-mail syntaxiquement
-- valide.
--
-- Cette fonction applique les règles suivantes :
--
--   1. Le nom technique du champ doit être renseigné ;
--   2. La longueur maximale configurée doit être valide ;
--   3. La valeur doit être présente ;
--   4. La valeur doit être strictement de type string ;
--   5. Les espaces périphériques sont supprimés ;
--   6. La chaîne nettoyée ne doit pas être vide ;
--   7. La longueur maximale est contrôlée lorsqu'elle est définie ;
--   8. Le format est vérifié avec string::is_email() ;
--   9. L'adresse nettoyée est retournée lorsqu'elle est valide.
--
-- Cette fonction contrôle uniquement la syntaxe de l'adresse.
--
-- Elle ne vérifie pas :
--
--   - que le domaine existe ;
--   - que le domaine possède des enregistrements MX ;
--   - que la boîte e-mail existe réellement ;
--   - que l'utilisateur possède cette adresse ;
--   - que l'adresse est unique dans une table ;
--   - que l'adresse a été confirmée ;
--   - que le domaine est autorisé par une règle métier ;
--   - que l'adresse est jetable ou temporaire.
--
-- Ces contrôles devront être réalisés par des fonctions métier, des services
-- externes ou d'autres fonctions Core spécialisées.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une valeur de type string.
--
-- Exemple accepté :
--
--   "contact@example.com"
--
-- Exemples refusés :
--
--   NONE
--   NULL
--   123
--   true
--   ["contact@example.com"]
--
-- Nettoyage et normalisation
-- --------------------------
-- La fonction utilise string::trim() afin de supprimer les espaces situés au
-- début et à la fin de l'adresse.
--
-- Exemple :
--
--   "  contact@example.com  "
--
-- devient :
--
--   "contact@example.com"
--
-- La fonction ne convertit volontairement pas l'adresse en minuscules.
--
-- Une éventuelle normalisation devra être réalisée par une future fonction :
--
--   fn::sanitize_email()
--
-- Cette séparation permet de distinguer clairement :
--
--   - la validation du format ;
--   - la normalisation de la donnée.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet de détecter :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur d'un type incorrect ;
--     - une chaîne vide ;
--     - une adresse au format invalide.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - EMAIL
--     - USER_EMAIL
--     - CONTACT_EMAIL
--     - BILLING_EMAIL
--     - NOTIFICATION_EMAIL
--     - RECIPIENT_EMAIL
--
-- $max_length:
--   Type : option<int>
--
--   Longueur maximale autorisée après suppression des espaces périphériques.
--
--   Utiliser NONE lorsqu'aucune limite particulière n'est requise.
--
--   Une limite de 254 ou 255 caractères est généralement adaptée au stockage
--   d'une adresse e-mail.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne l'adresse e-mail nettoyée, sans modifier sa casse.
--
-- Exemple :
--
--   fn::validation_email(
--       "  Contact@Example.com  ",
--       "CONTACT_EMAIL",
--       254
--   )
--
-- retourne :
--
--   "Contact@Example.com"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente, égale à NONE ou vide après nettoyage.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas de type string.
--
-- <FIELD>_TOO_LONG
--   L'adresse dépasse la longueur maximale configurée.
--
-- <FIELD>_INVALID_FORMAT
--   La chaîne ne correspond pas au format d'une adresse e-mail valide.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_MAX_LENGTH
--   La longueur maximale configurée est négative ou égale à zéro.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne lit aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne vérifie pas l'existence d'un compte ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Les permissions relatives au compte ou à l'adresse validée restent sous la
-- responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::len()
--   - string::concat()
--   - string::is_email()
--   - type::is_string()
--   - type::is_null()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- La fonction reste autonome afin de pouvoir produire elle-même des erreurs
-- distinctes pour les valeurs absentes, NULL ou d'un type incorrect.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment des autres
-- fonctions de validation.
--
-- Exemples d'utilisation
-- ----------------------
-- Adresse e-mail limitée à 254 caractères :
--
-- LET $email = fn::validation_email(
--     $email,
--     "USER_EMAIL",
--     254
-- );
--
-- Adresse sans limite particulière :
--
-- LET $email = fn::validation_email(
--     $email,
--     "CONTACT_EMAIL",
--     NONE
-- );
--
-- Validation avant création d'un utilisateur :
--
-- LET $email = fn::validation_email(
--     $email,
--     "USER_EMAIL",
--     254
-- );
--
-- RETURN CREATE identity_user CONTENT {
--     email: $email
-- };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_email(
    $value: option<any>,
    $field: string,
    $max_length: option<int>
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la longueur maximale configurée
    -- ------------------------------------------------------------------------

    IF $max_length IS NOT NONE
        AND $max_length <= 0
    {
        THROW "VALIDATION_INVALID_MAX_LENGTH";
    };

    -- ------------------------------------------------------------------------
    -- 3. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification stricte du type string
    -- ------------------------------------------------------------------------

    IF !type::is_string($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Nettoyage des espaces périphériques
    -- ------------------------------------------------------------------------

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Validation de la longueur maximale
    -- ------------------------------------------------------------------------

    IF $max_length IS NOT NONE
        AND string::len($clean_value) > $max_length
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LONG"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Validation du format de l'adresse e-mail
    -- ------------------------------------------------------------------------
    -- string::is_email() vérifie que la chaîne possède la syntaxe d'une
    -- adresse e-mail.
    --
    -- Cette vérification ne prouve pas que l'adresse ou son domaine existent.

    IF !string::is_email($clean_value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Retour de l'adresse e-mail validée
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Valide qu'une valeur obligatoire est une adresse e-mail syntaxiquement valide.
Refuse NONE, NULL et les types incorrects, supprime les espaces périphériques,
contrôle facultativement la longueur maximale et retourne l'adresse nettoyée
sans modifier sa casse.
"
PERMISSIONS FULL;