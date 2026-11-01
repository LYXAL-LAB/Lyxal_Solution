-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/timestamp.surql
-- Fonction : fn::sanitize_timestamp
--
-- Convertit un datetime en horodatage Unix entier (secondes, millisecondes,
-- microsecondes ou nanosecondes). En nanosecondes, SurrealDB lève son erreur
-- au-delà de l'an 2262.
--
-- Paramètres
--   $value : any — valeur à nettoyer (datetime, ou NONE)
--   $unit  : string — "seconds", "milliseconds", "microseconds" ou "nanoseconds", insensible à la casse
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'horodatage entier
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : unité inconnue
--
-- Exemple
--   LET $ts = fn::sanitize_timestamp($params.at, "seconds");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_timestamp(
    $value: any,
    $unit: string
) -> option<int> {
    LET $mode = string::lowercase(string::trim($unit));
    IF $mode NOT IN ["seconds", "milliseconds", "microseconds", "nanoseconds"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_datetime($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN IF $mode = "seconds" { time::unix($value) } ELSE IF $mode = "milliseconds" { time::millis($value) }
        ELSE IF $mode = "microseconds" { time::micros($value) } ELSE { time::nano($value) };
}
COMMENT "Convertit un datetime en horodatage Unix entier (secondes, millisecondes, microsecondes ou nanosecondes). En nanosecondes, SurrealDB lève son erreur au-delà de l'an 2262. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
