-- ============================================================================
-- Fichier : resource/calendar/utils/applyPropertyMap.surql
-- Module : calendar
-- Fonction : fn::calendar_utils_applyPropertyMap
-- Description : Applique la table de correspondance des propriétés.
--
-- Logique :
-- 1. Récupère le dictionnaire de mappage centralisé.
-- 2. Parcourt les propriétés fournies par le client.
-- 3. Construit et retourne un nouvel objet contenant uniquement les propriétés
--    reconnues, traduites avec les noms de champs de la base de données.
--
-- Paramètres :
--   - $properties (object) : L'objet de propriétés brutes venant du client CalDAV.
--
-- Retourne :
--   - (object) : Un objet avec les clés traduites et leurs valeurs.
-- ============================================================================
DEFINE FUNCTION fn::calendar_utils_applyPropertyMap(
    $properties: object,
    $inverse_mapping: bool 
) {
    LET $propertyMap = fn::calendar_utils_getPropertyMap();
    LET $mappedValues = {};
    IF $inverse_mapping = false {
        -- Application du propertyMap
        FOR $xmlName, $dbName IN $propertyMap {
            IF $properties[$xmlName] != NONE {
                LET $mappedValues[$dbName] = $properties[$xmlName];
            };
        };
    } 
    ELSE {
        -- Application du propertyMap inverse
        FOR $dbName, $xmlName IN $propertyMap {
            IF $properties[$dbName] != NONE {
                LET $mappedValues[$xmlName] = $properties[$dbName];
            };
        };
    };
    RETURN $mappedValues;
};
