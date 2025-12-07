# Analyse de `OCA\DAV\CalDAV\Search\Xml\Filter\OffsetFilter`

## Description

La classe `OffsetFilter` implémente l'interface `Sabre\Xml\XmlDeserializable`. Elle est structurellement et fonctionnellement identique à `LimitFilter`. Son unique rôle est de désérialiser la valeur numérique contenue dans un élément `<nc:offset>` au sein d'une requête de recherche.

## Rôle et Responsabilités

-   **Désérialisation XML** : La méthode statique `xmlDeserialize(Reader $reader)` est appelée par le moteur de parsing de SabreDAV lorsqu'il rencontre un élément `<nc:offset>`.
-   **Extraction de la Valeur** : Elle lit le contenu textuel de l'élément. Pour `<nc:offset>20</nc:offset>`, elle extraira la valeur `20`.
-   **Validation et Conversion** : Elle s'assure que la valeur est de type numérique ou une chaîne de caractères convertible, levant une exception `BadRequest` en cas d'échec.
-   **Retour de la Valeur** : Elle retourne la valeur convertie en entier, qui représente le point de départ (l'offset) pour la pagination des résultats de recherche.

En résumé, `OffsetFilter` est un simple "parser" qui extrait l'instruction de décalage des résultats depuis la requête XML pour la mettre à disposition de la logique de recherche sous forme d'entier.
