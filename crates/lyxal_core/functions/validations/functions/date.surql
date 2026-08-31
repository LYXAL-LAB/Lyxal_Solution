-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/date.surql
-- Fonction     : fn::validation_date
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire représente une date civile valide selon
-- la convention adoptée par Lyxal OS.
--
-- SurrealDB ne possède pas de type date distinct du type datetime.
--
-- Une date civile est donc représentée par un datetime positionné exactement
-- à minuit UTC :
--
--   d"2026-08-03T00:00:00Z"
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une date minimale ;
--   - une date maximale ;
--   - une plage comprise entre deux dates civiles.
--
-- Elle est destinée aux champs dont l'heure ne possède aucune signification
-- métier, notamment :
--
--   - une date de naissance ;
--   - une date de début de contrat ;
--   - une date de fin de contrat ;
--   - une date d'échéance civile ;
--   - une date de livraison ;
--   - une date de facturation ;
--   - une date de chantier ;
--   - une date de validité ;
--   - une date d'inscription ;
--   - un jour férié.
--
-- Convention Lyxal OS
-- -------------------
-- Une date civile doit être représentée ainsi :
--
--   d"YYYY-MM-DDT00:00:00Z"
--
-- Exemple :
--
--   d"2026-08-03T00:00:00Z"
--
-- La partie heure doit être exactement égale à minuit UTC.
--
-- Sont donc interdits :
--
--   d"2026-08-03T10:30:00Z"
--   d"2026-08-03T00:00:01Z"
--   d"2026-08-03T23:59:59Z"
--
-- même si ces valeurs appartiennent au même jour civil.
--
-- Cette validation stricte évite qu'un champ censé représenter uniquement une
-- date contienne accidentellement une heure significative.
--
-- Différence avec validation_datetime
-- -----------------------------------
-- fn::validation_datetime() valide un instant précis :
--
--   d"2026-08-03T14:30:00Z"
--
-- fn::validation_date() valide un jour civil :
--
--   d"2026-08-03T00:00:00Z"
--
-- Utiliser validation_datetime pour :
--
--   - un rendez-vous ;
--   - une date d'exécution ;
--   - une date de création ;
--   - une date d'expiration précise ;
--   - un événement avec heure.
--
-- Utiliser validation_date pour :
--
--   - une date de naissance ;
--   - une journée de chantier ;
--   - une date de facture ;
--   - une date de livraison sans créneau horaire ;
--   - une date de début ou de fin civile.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une véritable valeur datetime SurrealDB.
--
-- Exemple accepté :
--
--   d"2026-08-03T00:00:00Z"
--
-- Exemples refusés :
--
--   "2026-08-03"
--     chaîne non convertie.
--
--   "2026-08-03T00:00:00Z"
--     chaîne ISO non convertie.
--
--   d"2026-08-03T10:00:00Z"
--     datetime contenant une heure.
--
--   20260803
--     entier.
--
--   NONE
--     absence de valeur.
--
--   NULL
--     valeur explicitement vide.
--
-- La fonction n'effectue aucune conversion automatique.
--
-- Conversion explicite
-- --------------------
-- Une chaîne représentant une date peut être convertie avec :
--
--   type::datetime($value)
--
-- ou :
--
--   <datetime>$value
--
-- Exemple :
--
--   LET $converted_date = type::datetime(
--       "2026-08-03"
--   );
--
--   LET $date = fn::validation_date(
--       $converted_date,
--       "START_DATE",
--       NONE,
--       NONE
--   );
--
-- SurrealDB accepte une date contenant uniquement l'année, le mois et le jour
-- lors de la conversion en datetime et la représente à minuit UTC.
--
-- Vérification de minuit UTC
-- ---------------------------
-- La fonction vérifie la convention de date civile avec :
--
--   time::floor($value, 1d)
--
-- Une date valide doit satisfaire :
--
--   $value = time::floor($value, 1d)
--
-- time::floor() tronque le datetime au multiple inférieur de la durée demandée
-- depuis l'époque Unix.
--
-- Avec une durée de 1d, une valeur positionnée exactement à minuit UTC reste
-- inchangée.
--
-- Exemple valide :
--
--   d"2026-08-03T00:00:00Z"
--
-- Exemple invalide :
--
--   d"2026-08-03T10:30:00Z"
--
-- car :
--
--   time::floor(
--       d"2026-08-03T10:30:00Z",
--       1d
--   )
--
-- retourne :
--
--   d"2026-08-03T00:00:00Z"
--
-- Fuseaux horaires
-- ----------------
-- SurrealDB convertit les datetimes reçus avec un décalage horaire vers UTC.
--
-- Exemple :
--
--   d"2026-08-03T00:00:00+02:00"
--
-- est stocké comme :
--
--   d"2026-08-02T22:00:00Z"
--
-- Cette valeur ne respecte donc pas la convention de minuit UTC et sera
-- refusée par cette fonction.
--
-- Pour une date civile, il est recommandé de construire directement :
--
--   d"2026-08-03T00:00:00Z"
--
-- ou de convertir :
--
--   <datetime>"2026-08-03"
--
-- Cette convention évite qu'une date civile change de jour selon le fuseau
-- horaire de lecture.
--
-- Attention :
--
-- Une date civile ne doit pas être reconvertie automatiquement dans le fuseau
-- horaire de l'utilisateur comme s'il s'agissait d'un instant réel.
--
-- Elle représente un jour du calendrier et non un moment physique précis.
--
-- Limites minimale et maximale
-- -----------------------------
-- Les bornes minimale et maximale sont facultatives et inclusives.
--
-- Exemple :
--
--   valeur :
--     d"2026-08-15T00:00:00Z"
--
--   minimum :
--     d"2026-08-01T00:00:00Z"
--
--   maximum :
--     d"2026-08-31T00:00:00Z"
--
-- La valeur est acceptée.
--
-- Une date antérieure au minimum produit :
--
--   <FIELD>_TOO_EARLY
--
-- Une date postérieure au maximum produit :
--
--   <FIELD>_TOO_LATE
--
-- Validation des bornes
-- ---------------------
-- Les limites doivent elles-mêmes respecter la convention de date civile.
--
-- Ainsi, une limite comme :
--
--   d"2026-08-01T12:00:00Z"
--
-- est refusée avec :
--
--   VALIDATION_INVALID_MIN_DATE
--
-- De même, une limite maximale contenant une heure produit :
--
--   VALIDATION_INVALID_MAX_DATE
--
-- Cela évite de comparer une date civile à une borne contenant une heure
-- cachée.
--
-- Cohérence de la plage
-- ----------------------
-- Lorsque les deux limites sont renseignées, la date minimale ne peut pas être
-- postérieure à la date maximale.
--
-- Exemple invalide :
--
--   min :
--     d"2026-08-31T00:00:00Z"
--
--   max :
--     d"2026-08-01T00:00:00Z"
--
-- produit :
--
--   VALIDATION_INVALID_DATE_RANGE
--
-- Années bissextiles et dates invalides
-- -------------------------------------
-- La construction du datetime est assurée par SurrealDB.
--
-- Une date impossible ne peut pas devenir un datetime valide.
--
-- Exemple :
--
--   <datetime>"2026-02-30"
--
-- produit une erreur native de conversion avant l'appel de cette fonction.
--
-- Une date bissextile valide comme :
--
--   <datetime>"2024-02-29"
--
-- peut être validée normalement.
--
-- Conservation de la valeur
-- --------------------------
-- La fonction retourne exactement la valeur datetime reçue.
--
-- Elle ne réalise :
--
--   - aucune conversion ;
--   - aucun changement de fuseau horaire ;
--   - aucune modification du jour ;
--   - aucun formatage ;
--   - aucune conversion en chaîne ;
--   - aucun calcul de calendrier ;
--   - aucun ajustement aux jours ouvrés.
--
-- Format d'affichage
-- -------------------
-- Pour afficher la date sans la partie horaire, la fonction métier ou
-- l'interface peut utiliser :
--
--   time::format($date, "%Y-%m-%d")
--
-- Exemple :
--
--   time::format(
--       d"2026-08-03T00:00:00Z",
--       "%Y-%m-%d"
--   )
--
-- retourne une représentation textuelle du jour.
--
-- La valeur stockée doit toutefois rester un datetime.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence de la valeur ;
--   - le refus de NULL ;
--   - le type datetime ;
--   - la position exacte à minuit UTC ;
--   - la date minimale ;
--   - la date maximale.
--
-- Elle ne vérifie pas :
--
--   - l'âge d'une personne ;
--   - qu'une date correspond à un jour ouvré ;
--   - qu'une date n'est pas un jour férié ;
--   - qu'une date est disponible dans un planning ;
--   - qu'une date correspond au fuseau métier d'un établissement ;
--   - la cohérence avec une autre date métier ;
--   - qu'une date de fin est postérieure à une date de début ;
--   - les permissions associées au calendrier ;
--   - les règles de réservation.
--
-- Ces contrôles appartiennent aux fonctions métier ou à des validateurs
-- spécialisés.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La limite minimale doit représenter minuit UTC lorsqu'elle est définie ;
--   3. La limite maximale doit représenter minuit UTC lorsqu'elle est définie ;
--   4. La limite minimale ne doit pas dépasser la limite maximale ;
--   5. La valeur doit être présente ;
--   6. La valeur ne doit pas être NULL ;
--   7. La valeur doit être strictement de type datetime ;
--   8. La valeur doit représenter exactement minuit UTC ;
--   9. La date minimale est contrôlée lorsqu'elle est définie ;
--  10. La date maximale est contrôlée lorsqu'elle est définie ;
--  11. La valeur datetime d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Date civile obligatoire à contrôler.
--
--   La valeur doit être un datetime à minuit UTC.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - BIRTH_DATE
--     - START_DATE
--     - END_DATE
--     - DELIVERY_DATE
--     - INVOICE_DATE
--     - WORKSITE_DATE
--     - VALID_FROM
--     - VALID_UNTIL
--
-- $min_value:
--   Type : option<datetime>
--
--   Date civile minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune date minimale n'est requise.
--
--   La valeur doit être positionnée à minuit UTC.
--
--   La limite est inclusive.
--
-- $max_value:
--   Type : option<datetime>
--
--   Date civile maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune date maximale n'est requise.
--
--   La valeur doit être positionnée à minuit UTC.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : datetime
--
-- Retourne la valeur datetime d'origine à minuit UTC.
--
-- Exemple :
--
--   fn::validation_date(
--       d"2026-08-15T00:00:00Z",
--       "START_DATE",
--       d"2026-08-01T00:00:00Z",
--       d"2026-08-31T00:00:00Z"
--   )
--
-- retourne :
--
--   d"2026-08-15T00:00:00Z"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas strictement de type datetime.
--
-- <FIELD>_INVALID_DATE
--   La valeur est un datetime, mais elle ne représente pas exactement minuit
--   UTC.
--
-- <FIELD>_TOO_EARLY
--   La date est antérieure à la limite minimale.
--
-- <FIELD>_TOO_LATE
--   La date est postérieure à la limite maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_MIN_DATE
--   La limite minimale contient une heure et ne représente pas minuit UTC.
--
-- VALIDATION_INVALID_MAX_DATE
--   La limite maximale contient une heure et ne représente pas minuit UTC.
--
-- VALIDATION_INVALID_DATE_RANGE
--   La date minimale est postérieure à la date maximale.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne consulte aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_datetime()
--   - time::floor()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome.
--
-- Elle est toutefois logiquement liée aux fonctions :
--
--   - fn::validation_datetime()
--   - fn::validation_future_datetime()
--   - fn::validation_past_datetime()
--   - fn::validation_time_range()
--
-- Exemples d'utilisation
-- ----------------------
-- Date sans limites :
--
-- LET $invoice_date = fn::validation_date(
--     $invoice_date,
--     "INVOICE_DATE",
--     NONE,
--     NONE
-- );
--
-- Date de naissance limitée à aujourd'hui :
--
-- LET $today = time::floor(
--     time::now(),
--     1d
-- );
--
-- LET $birth_date = fn::validation_date(
--     $birth_date,
--     "BIRTH_DATE",
--     NONE,
--     $today
-- );
--
-- Date comprise dans une période :
--
-- LET $worksite_date = fn::validation_date(
--     $worksite_date,
--     "WORKSITE_DATE",
--     d"2026-08-01T00:00:00Z",
--     d"2026-08-31T00:00:00Z"
-- );
--
-- Conversion explicite avant validation :
--
-- LET $converted_date = type::datetime(
--     "2026-08-03"
-- );
--
-- LET $date = fn::validation_date(
--     $converted_date,
--     "START_DATE",
--     NONE,
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_date(
    $value: option<any>,
    $field: string,
    $min_value: option<datetime>,
    $max_value: option<datetime>
) -> datetime {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la limite minimale
    -- ------------------------------------------------------------------------
    -- La limite minimale doit elle-même représenter une date civile à minuit
    -- UTC.
    --
    -- Une valeur à minuit reste inchangée après time::floor(..., 1d).

    IF $min_value IS NOT NONE
        AND $min_value != time::floor($min_value, 1d)
    {
        THROW "VALIDATION_INVALID_MIN_DATE";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation de la limite maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NOT NONE
        AND $max_value != time::floor($max_value, 1d)
    {
        THROW "VALIDATION_INVALID_MAX_DATE";
    };

    -- ------------------------------------------------------------------------
    -- 4. Validation de la cohérence de la plage
    -- ------------------------------------------------------------------------

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_DATE_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification stricte du type datetime
    -- ------------------------------------------------------------------------
    -- SurrealDB représente une date civile avec le type datetime.
    --
    -- Cette fonction refuse toute chaîne qui n'a pas été convertie
    -- explicitement avant l'appel.

    IF !type::is_datetime($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Vérification de la convention de date civile
    -- ------------------------------------------------------------------------
    -- Une date civile Lyxal doit être exactement positionnée à minuit UTC.
    --
    -- time::floor($value, 1d) retourne le début du jour UTC correspondant.
    --
    -- Si le résultat diffère de la valeur d'origine, celle-ci contient une
    -- composante horaire et doit être refusée.

    IF $value != time::floor($value, 1d) {
        THROW string::concat(
            $clean_field,
            "_INVALID_DATE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Validation de la date minimale
    -- ------------------------------------------------------------------------

    IF $min_value IS NOT NONE
        AND $value < $min_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_EARLY"
        );
    };

    -- ------------------------------------------------------------------------
    -- 10. Validation de la date maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NOT NONE
        AND $value > $max_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LATE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 11. Retour de la date civile validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire représente une date civile selon la convention
Lyxal OS : un datetime positionné exactement à minuit UTC. Refuse NONE, NULL,
les autres types et les datetimes contenant une heure. Contrôle facultativement
les dates minimale et maximale, puis retourne la valeur datetime d'origine.
"
PERMISSIONS FULL;