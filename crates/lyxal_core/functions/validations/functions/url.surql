-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/url.surql
-- Fonction     : fn::validation_url
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est une URL syntaxiquement valide.
--
-- Cette fonction applique les règles suivantes :
--
--   1. Le nom technique du champ doit être renseigné ;
--   2. La longueur maximale configurée doit être valide ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être NULL ;
--   5. La valeur doit être strictement de type string ;
--   6. Les espaces périphériques sont supprimés ;
--   7. La chaîne nettoyée ne doit pas être vide ;
--   8. La longueur maximale est contrôlée lorsqu'elle est définie ;
--   9. Le format est vérifié avec string::is_url() ;
--  10. L'URL nettoyée est retournée lorsqu'elle est valide.
--
-- Cette fonction contrôle uniquement la syntaxe générale de l'URL.
--
-- Elle ne vérifie pas :
--
--   - que la ressource distante existe ;
--   - que le domaine existe ;
--   - que le serveur est accessible ;
--   - que le certificat TLS est valide ;
--   - que la ressource répond avec un statut HTTP valide ;
--   - que le protocole est autorisé par la logique métier ;
--   - que le domaine appartient à une liste autorisée ;
--   - que l'URL ne pointe pas vers une adresse réseau privée ;
--   - que l'URL est protégée contre les attaques SSRF ;
--   - que l'URL est unique dans une table.
--
-- Ces vérifications relèvent des fonctions métier, du moteur HTTP, des règles
-- de sécurité réseau ou de futures fonctions du domaine core/security.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une valeur de type string.
--
-- Exemples acceptés :
--
--   "https://example.com"
--   "https://example.com/path"
--   "https://example.com/path?value=1"
--
-- Exemples refusés :
--
--   NONE
--   NULL
--   123
--   true
--   ["https://example.com"]
--
-- Nettoyage et normalisation
-- --------------------------
-- La fonction supprime uniquement les espaces périphériques avec
-- string::trim().
--
-- Exemple :
--
--   "  https://example.com/path  "
--
-- devient :
--
--   "https://example.com/path"
--
-- La fonction ne modifie volontairement pas :
--
--   - la casse du chemin ;
--   - la casse des paramètres ;
--   - le protocole ;
--   - le domaine ;
--   - le port ;
--   - le fragment ;
--   - les caractères encodés.
--
-- Une éventuelle normalisation devra être effectuée par une future fonction :
--
--   fn::sanitize_url()
--
-- Restriction des protocoles
-- --------------------------
-- Cette fonction ne force pas l'utilisation de HTTP ou HTTPS.
--
-- Lorsqu'un champ métier doit accepter uniquement ces protocoles, la fonction
-- appelante devra appliquer une règle supplémentaire ou utiliser une future
-- fonction spécialisée, par exemple :
--
--   fn::validation_http_url()
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
--     - une URL au format invalide.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - URL
--     - WEBSITE_URL
--     - CALLBACK_URL
--     - WEBHOOK_URL
--     - REDIRECT_URL
--     - AVATAR_URL
--     - DOCUMENT_URL
--     - EXTERNAL_URL
--
-- $max_length:
--   Type : option<int>
--
--   Longueur maximale autorisée après suppression des espaces périphériques.
--
--   Utiliser NONE lorsqu'aucune limite particulière n'est requise.
--
--   Une limite comprise entre 2 048 et 8 192 caractères peut être choisie
--   selon les besoins du module et les contraintes du système destinataire.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne l'URL nettoyée, sans autre transformation.
--
-- Exemple :
--
--   fn::validation_url(
--       "  https://example.com/path  ",
--       "WEBSITE_URL",
--       2048
--   )
--
-- retourne :
--
--   "https://example.com/path"
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
--   L'URL dépasse la longueur maximale configurée.
--
-- <FIELD>_INVALID_FORMAT
--   La chaîne ne correspond pas au format d'une URL valide.
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
--   - elle ne contacte aucune ressource distante ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Attention :
--
-- Une URL syntaxiquement valide peut néanmoins être dangereuse.
--
-- Pour les webhooks, imports, téléchargements ou appels serveur, la fonction
-- métier doit également contrôler :
--
--   - les protocoles autorisés ;
--   - les domaines autorisés ;
--   - les adresses IP privées ;
--   - les redirections ;
--   - les ports autorisés ;
--   - les risques SSRF.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::len()
--   - string::concat()
--   - string::is_url()
--   - type::is_string()
--   - type::is_null()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment des autres
-- fonctions de validation.
--
-- Exemples d'utilisation
-- ----------------------
-- URL de site internet :
--
-- LET $website_url = fn::validation_url(
--     $website_url,
--     "WEBSITE_URL",
--     2048
-- );
--
-- URL de webhook :
--
-- LET $webhook_url = fn::validation_url(
--     $webhook_url,
--     "WEBHOOK_URL",
--     4096
-- );
--
-- URL sans limite particulière :
--
-- LET $external_url = fn::validation_url(
--     $external_url,
--     "EXTERNAL_URL",
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_url(
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
    -- 6. Suppression des espaces périphériques
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
    -- 8. Validation du format de l'URL
    -- ------------------------------------------------------------------------
    -- string::is_url() vérifie que la chaîne possède une syntaxe d'URL valide.
    --
    -- Cette validation ne contacte pas la ressource et ne garantit pas que
    -- l'URL est accessible, sûre ou autorisée par la logique métier.

    IF !string::is_url($clean_value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Retour de l'URL validée
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Valide qu'une valeur obligatoire est une URL syntaxiquement valide. Refuse
NONE, NULL et les types incorrects, supprime les espaces périphériques,
contrôle facultativement la longueur maximale et retourne l'URL nettoyée sans
autre transformation.
"
PERMISSIONS FULL;