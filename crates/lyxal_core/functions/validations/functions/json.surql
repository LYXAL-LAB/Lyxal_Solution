-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/json.surql
-- Fonction     : fn::validation_json
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est une chaîne contenant un document JSON
-- valide, puis décode ce document en valeur SurrealQL.
--
-- La fonction utilise :
--
--   encoding::json::decode()
--
-- Elle reçoit donc une chaîne JSON :
--
--   '{"name":"Lyxal","enabled":true}'
--
-- puis retourne la valeur SurrealQL correspondante :
--
--   {
--       name: "Lyxal",
--       enabled: true
--   }
--
-- Types JSON acceptés
-- -------------------
-- Un document JSON valide peut représenter :
--
--   - un objet ;
--   - un tableau ;
--   - une chaîne ;
--   - un nombre ;
--   - un booléen ;
--   - la valeur null.
--
-- Exemples valides :
--
--   '{"name":"Lyxal"}'
--   '["booking","calendar","crm"]'
--   '"Lyxal"'
--   '42'
--   '19.99'
--   'true'
--   'false'
--   'null'
--
-- La fonction ne force donc pas le résultat à être un objet.
--
-- Pour exiger spécifiquement un objet JSON, la fonction métier pourra appeler
-- ensuite :
--
--   fn::validation_object()
--
-- Pour exiger spécifiquement un tableau JSON, elle pourra utiliser une future
-- fonction spécialisée :
--
--   fn::validation_array()
--
-- Différence entre JSON et valeur SurrealQL
-- -----------------------------------------
-- Le paramètre reçu par cette fonction doit être une chaîne contenant du JSON.
--
-- Exemple attendu :
--
--   '{"name":"Lyxal"}'
--
-- Un objet SurrealQL déjà décodé :
--
--   {
--       name: "Lyxal"
--   }
--
-- n'est pas accepté par cette fonction, car il ne nécessite plus de validation
-- ni de décodage JSON.
--
-- Pour valider un objet SurrealQL déjà construit, utiliser :
--
--   fn::validation_object()
--
-- JSON strict
-- -----------
-- La syntaxe JSON est plus stricte que la syntaxe objet SurrealQL.
--
-- En JSON :
--
--   - les clés doivent être placées entre guillemets doubles ;
--   - les chaînes utilisent des guillemets doubles ;
--   - les virgules finales sont interdites ;
--   - les commentaires sont interdits ;
--   - NONE n'existe pas ;
--   - les Record IDs SurrealDB n'existent pas ;
--   - les datetimes SurrealDB n'existent pas ;
--   - les UUID SurrealDB n'existent pas.
--
-- Exemple JSON valide :
--
--   '{"name":"Lyxal","enabled":true}'
--
-- Exemple non valide en JSON :
--
--   '{name:"Lyxal",enabled:true}'
--
-- Même si certaines structures similaires peuvent être exprimées directement
-- en SurrealQL, elles ne constituent pas nécessairement du JSON strict.
--
-- Conversion du résultat
-- ----------------------
-- La fonction retourne la valeur produite par encoding::json::decode().
--
-- Correspondances principales :
--
--   JSON object
--     devient un object SurrealQL.
--
--   JSON array
--     devient un array SurrealQL.
--
--   JSON string
--     devient un string SurrealQL.
--
--   JSON integer
--     devient une valeur numérique SurrealQL adaptée.
--
--   JSON decimal
--     devient une valeur numérique SurrealQL adaptée.
--
--   JSON boolean
--     devient un bool SurrealQL.
--
--   JSON null
--     devient NULL.
--
-- Attention :
--
-- JSON possède moins de types que SurrealQL. Un aller-retour entre une valeur
-- SurrealQL et JSON ne garantit donc pas la conservation exacte du type
-- d'origine.
--
-- Par exemple, NONE encodé en JSON puis décodé devient NULL.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une valeur de type string.
--
-- Elle refuse notamment :
--
--   NONE
--   NULL
--   {}
--   []
--   42
--   true
--
-- même lorsqu'une de ces valeurs pourrait être encodée en JSON.
--
-- La fonction vérifie une représentation JSON textuelle, elle ne convertit pas
-- automatiquement une valeur SurrealQL vers JSON.
--
-- Pour encoder une valeur SurrealQL en JSON, utiliser :
--
--   encoding::json::encode()
--
-- Nettoyage
-- ----------
-- Les espaces périphériques entourant le document JSON sont supprimés avec :
--
--   string::trim()
--
-- Exemple :
--
--   '   {"name":"Lyxal"}   '
--
-- devient :
--
--   '{"name":"Lyxal"}'
--
-- Les espaces situés à l'intérieur des chaînes JSON sont préservés.
--
-- Limite de taille
-- ----------------
-- Une longueur maximale facultative peut être appliquée avant le décodage.
--
-- Cette limite permet notamment :
--
--   - d'éviter des charges JSON excessivement volumineuses ;
--   - de protéger les fonctions métier ;
--   - de limiter le coût du décodage ;
--   - d'appliquer une limite adaptée au module.
--
-- La longueur est calculée sur la chaîne nettoyée avant son décodage.
--
-- Gestion d'un JSON invalide
-- --------------------------
-- Si la chaîne ne contient pas un document JSON valide,
-- encoding::json::decode() interrompt l'exécution avec une erreur native
-- SurrealDB.
--
-- SurrealQL ne fournit pas ici de mécanisme permettant d'intercepter localement
-- cette erreur de décodage et de la remplacer par un THROW personnalisé.
--
-- Les erreurs contrôlées par cette fonction concernent donc :
--
--   - l'absence de valeur ;
--   - NULL ;
--   - le mauvais type ;
--   - la chaîne vide ;
--   - la longueur maximale.
--
-- Une erreur de syntaxe JSON reste une erreur native du décodeur.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Chaîne JSON obligatoire à contrôler et à décoder.
--
--   Le type option<any> permet de produire des erreurs explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur d'un type incorrect ;
--     - une chaîne vide.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - JSON_DATA
--     - PAYLOAD
--     - CONFIGURATION
--     - METADATA
--     - WEBHOOK_PAYLOAD
--     - IMPORT_DATA
--     - OPTIONS
--
-- $max_length:
--   Type : option<int>
--
--   Longueur maximale autorisée pour la chaîne JSON nettoyée.
--
--   Utiliser NONE lorsqu'aucune limite particulière n'est requise.
--
--   La limite doit être strictement supérieure à zéro lorsqu'elle est définie.
--
-- Valeur retournée
-- ----------------
-- Type : any
--
-- Retourne la valeur SurrealQL obtenue après décodage du document JSON.
--
-- Exemple avec un objet :
--
--   fn::validation_json(
--       '{"name":"Lyxal","enabled":true}',
--       "CONFIGURATION",
--       10000
--   )
--
-- retourne :
--
--   {
--       name: "Lyxal",
--       enabled: true
--   }
--
-- Exemple avec un tableau :
--
--   fn::validation_json(
--       '["booking","calendar"]',
--       "MODULES",
--       10000
--   )
--
-- retourne :
--
--   [
--       "booking",
--       "calendar"
--   ]
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
--   La chaîne JSON dépasse la longueur maximale configurée.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_MAX_LENGTH
--   La longueur maximale configurée est négative ou égale à zéro.
--
-- Erreur native SurrealDB
--   La chaîne ne contient pas un document JSON valide et ne peut pas être
--   décodée avec encoding::json::decode().
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est sans écriture et sans accès aux tables :
--
--   - elle ne lit aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne contacte aucun service externe ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur les paramètres transmis.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Attention :
--
-- La validation syntaxique d'un JSON ne garantit pas que son contenu respecte
-- les règles métier.
--
-- Après le décodage, la fonction appelante doit encore contrôler :
--
--   - les champs obligatoires ;
--   - les types attendus ;
--   - les propriétés autorisées ;
--   - les profondeurs maximales ;
--   - les tailles des tableaux ;
--   - les valeurs métier ;
--   - les autorisations liées au contenu.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::len()
--   - string::concat()
--   - type::is_string()
--   - type::is_null()
--   - encoding::json::decode()
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
-- Décodage d'une configuration :
--
-- LET $configuration = fn::validation_json(
--     $configuration_json,
--     "CONFIGURATION",
--     100000
-- );
--
-- Décodage d'un payload :
--
-- LET $payload = fn::validation_json(
--     $payload_json,
--     "PAYLOAD",
--     1000000
-- );
--
-- Décodage sans limite particulière :
--
-- LET $metadata = fn::validation_json(
--     $metadata_json,
--     "METADATA",
--     NONE
-- );
--
-- Validation supplémentaire du résultat :
--
-- LET $configuration = fn::validation_json(
--     $configuration_json,
--     "CONFIGURATION",
--     100000
-- );
--
-- IF !type::is_object($configuration) {
--     THROW "CONFIGURATION_INVALID_TYPE";
-- };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_json(
    $value: option<any>,
    $field: string,
    $max_length: option<int>
) -> any {

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
    -- Cette fonction valide une représentation JSON textuelle.
    --
    -- Un objet ou un tableau SurrealQL déjà construit doit être validé avec
    -- une fonction correspondant directement à son type.

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
    -- 8. Décodage du document JSON
    -- ------------------------------------------------------------------------
    -- encoding::json::decode() transforme la chaîne JSON en valeur SurrealQL.
    --
    -- Si la syntaxe JSON est invalide, le moteur interrompt l'exécution avec
    -- une erreur native de décodage.

    LET $decoded_value = encoding::json::decode(
        $clean_value
    );

    -- ------------------------------------------------------------------------
    -- 9. Retour de la valeur JSON décodée
    -- ------------------------------------------------------------------------

    RETURN $decoded_value;
}
COMMENT "
Valide qu'une valeur obligatoire est une chaîne JSON non vide, contrôle
facultativement sa longueur maximale, puis la décode en valeur SurrealQL avec
encoding::json::decode(). Retourne un type any correspondant au contenu JSON.
"
PERMISSIONS FULL;