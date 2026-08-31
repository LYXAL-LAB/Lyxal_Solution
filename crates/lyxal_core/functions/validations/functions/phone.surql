-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/phone.surql
-- Fonction     : fn::validation_phone
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire respecte le format téléphonique
-- international canonique adopté par Lyxal OS.
--
-- Le format attendu est :
--
--   +<indicatif pays><numéro national>
--
-- Exemples valides :
--
--   +33612345678
--   +442071234567
--   +12125551234
--   +212612345678
--
-- Expression régulière utilisée :
--
--   ^\+[1-9][0-9]{7,14}$
--
-- Cette convention impose :
--
--   - un signe + au début ;
--   - un premier chiffre compris entre 1 et 9 ;
--   - uniquement des chiffres après le signe + ;
--   - entre 8 et 15 chiffres au total ;
--   - aucun espace ;
--   - aucun tiret ;
--   - aucune parenthèse ;
--   - aucun point ;
--   - aucun préfixe international écrit sous la forme 00.
--
-- Cette fonction est destinée à valider une valeur déjà normalisée.
--
-- Elle accepte :
--
--   +33612345678
--
-- Elle refuse :
--
--   0612345678
--   0033612345678
--   +33 6 12 34 56 78
--   +33-6-12-34-56-78
--   (+33) 6 12 34 56 78
--
-- Une future fonction du domaine core/sanitize pourra convertir différentes
-- écritures utilisateur vers le format canonique :
--
--   fn::sanitize_phone()
--
-- Cette séparation permet de distinguer :
--
--   - la normalisation d'une saisie utilisateur ;
--   - la validation du format final stocké.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement la structure générale du numéro.
--
-- Elle ne vérifie pas :
--
--   - que l'indicatif pays existe réellement ;
--   - que la longueur est valide pour le pays concerné ;
--   - que le préfixe opérateur existe ;
--   - que le numéro est attribué ;
--   - que le numéro est actif ;
--   - que le numéro peut recevoir des SMS ;
--   - que le numéro appartient à l'utilisateur ;
--   - que le numéro est unique dans une table ;
--   - que le numéro est fixe, mobile ou surtaxé.
--
-- Ces contrôles nécessitent une bibliothèque téléphonique spécialisée, un
-- service externe ou une logique métier propre au pays concerné.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La valeur doit être présente ;
--   3. La valeur ne doit pas être NULL ;
--   4. La valeur doit être strictement de type string ;
--   5. Les espaces périphériques sont supprimés ;
--   6. La chaîne nettoyée ne doit pas être vide ;
--   7. Le numéro doit respecter le format international canonique ;
--   8. Le numéro nettoyé est retourné lorsqu'il est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet de détecter explicitement :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur d'un type incorrect ;
--     - une chaîne vide ;
--     - un numéro au format incorrect.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - PHONE
--     - USER_PHONE
--     - CONTACT_PHONE
--     - MOBILE_PHONE
--     - BILLING_PHONE
--     - EMERGENCY_PHONE
--     - WHATSAPP_PHONE
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne le numéro nettoyé sans autre transformation.
--
-- Exemple :
--
--   fn::validation_phone(
--       "  +33612345678  ",
--       "USER_PHONE"
--   )
--
-- retourne :
--
--   "+33612345678"
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
-- <FIELD>_INVALID_FORMAT
--   La chaîne ne respecte pas le format téléphonique international canonique.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne lit aucune table ;
--   - elle ne contacte aucun service externe ;
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
-- Les autorisations concernant l'accès, la vérification ou l'utilisation du
-- numéro restent sous la responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - string::matches()
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
-- Numéro principal :
--
-- LET $phone = fn::validation_phone(
--     $phone,
--     "USER_PHONE"
-- );
--
-- Numéro d'urgence :
--
-- LET $emergency_phone = fn::validation_phone(
--     $emergency_phone,
--     "EMERGENCY_PHONE"
-- );
--
-- Validation avant création :
--
-- LET $phone = fn::validation_phone(
--     $phone,
--     "CONTACT_PHONE"
-- );
--
-- RETURN CREATE contact CONTENT {
--     phone: $phone
-- };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_phone(
    $value: option<any>,
    $field: string
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 3. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification stricte du type string
    -- ------------------------------------------------------------------------

    IF !type::is_string($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Suppression des espaces périphériques
    -- ------------------------------------------------------------------------

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Validation du format téléphonique
    -- ------------------------------------------------------------------------
    -- Format canonique Lyxal :
    --
    --   + suivi de 8 à 15 chiffres ;
    --   premier chiffre différent de zéro ;
    --   aucun séparateur ou caractère supplémentaire.
    --
    -- La double barre oblique protège le caractère + dans l'expression
    -- régulière transmise sous forme de chaîne.

    LET $matches_phone_format = string::matches(
        $clean_value,
        "^\\+[1-9][0-9]{7,14}$"
    );

    IF !$matches_phone_format {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Retour du numéro validé
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Valide qu'une valeur obligatoire respecte le format téléphonique international
canonique adopté par Lyxal OS : signe + suivi de 8 à 15 chiffres, sans espaces
ni séparateurs. Retourne le numéro nettoyé lorsqu'il est valide.
"
PERMISSIONS FULL;