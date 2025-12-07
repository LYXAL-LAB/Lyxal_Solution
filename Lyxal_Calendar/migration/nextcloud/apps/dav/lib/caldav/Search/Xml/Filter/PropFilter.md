# Analyse de `OCA\DAV\CalDAV\Search\Xml\Filter\PropFilter`

## Description

La classe `PropFilter` implémente l'interface `Sabre\Xml\XmlDeserializable`. Elle est fonctionnellement identique à `CompFilter`, mais elle est mappée à l'élément XML `<nc:prop-filter>`. Son rôle est de désérialiser ce fragment XML pour en extraire le nom d'une propriété iCalendar.

## Rôle et Responsabilités

-   **Désérialisation XML** : La méthode statique `xmlDeserialize(Reader $reader)` est appelée par SabreDAV lorsqu'il rencontre un élément `<nc:prop-filter>` dans le corps d'une requête `REPORT`.
-   **Extraction de l'Attribut `name`** : La méthode lit la valeur de l'attribut `name`. Par exemple, pour `<nc:prop-filter name="SUMMARY">`, elle extraira la chaîne de caractères `"SUMMARY"`.
-   **Validation** : Elle vérifie que l'attribut `name` est bien présent et est une chaîne de caractères, levant une `BadRequest` en cas d'échec.
-   **Retour de la Valeur** : La méthode retourne la valeur de l'attribut `name`.

En résumé, `PropFilter` est un "parser" simple qui a pour unique but d'extraire le nom d'une propriété iCalendar (comme `SUMMARY`, `LOCATION`, `UID`, etc.) à partir de la requête XML. Cette information est ensuite utilisée par la logique de recherche principale pour construire les filtres de la requête.
