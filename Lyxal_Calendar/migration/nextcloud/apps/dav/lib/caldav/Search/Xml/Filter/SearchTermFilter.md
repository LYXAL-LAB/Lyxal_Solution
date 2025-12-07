# Analyse de `OCA\DAV\CalDAV\Search\Xml\Filter\SearchTermFilter`

## Description

La classe `SearchTermFilter` implémente `Sabre\Xml\XmlDeserializable`. C'est le dernier des "parsers" XML simples de ce dossier, conçu pour désérialiser l'élément `<nc:search-term>` d'une requête de recherche `nc:calendar-search`.

## Rôle et Responsabilités

-   **Désérialisation XML** : La méthode statique `xmlDeserialize(Reader $reader)` est invoquée par SabreDAV pour traiter l'élément `<nc:search-term>`.
-   **Extraction de la Valeur** : Elle lit le contenu textuel de l'élément. Par exemple, pour `<nc:search-term>Réunion marketing</nc:search-term>`, elle extraira la chaîne de caractères `"Réunion marketing"`.
-   **Validation** : Elle s'assure que la valeur est bien une chaîne de caractères, levant une `BadRequest` si ce n'est pas le cas.
-   **Retour de la Valeur** : La méthode retourne la chaîne de caractères lue, qui représente le terme de recherche à utiliser pour trouver des correspondances dans les propriétés des événements.

En résumé, `SearchTermFilter` a pour unique fonction d'extraire la chaîne de recherche textuelle de la requête XML afin que la logique de recherche principale puisse l'utiliser dans ses requêtes.
