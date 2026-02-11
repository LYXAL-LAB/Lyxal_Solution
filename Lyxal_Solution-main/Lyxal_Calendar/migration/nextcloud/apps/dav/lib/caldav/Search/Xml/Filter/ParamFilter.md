# Analyse de `OCA\DAV\CalDAV\Search\Xml\Filter\ParamFilter`

## Description

La classe `ParamFilter` implémente `Sabre\Xml\XmlDeserializable` et sert à désérialiser l'élément XML `<nc:param-filter>` utilisé dans les requêtes de recherche `nc:calendar-search`. Cet élément permet de spécifier un filtre basé sur l'existence d'un paramètre particulier au sein d'une propriété iCalendar.

## Rôle et Responsabilités

-   **Désérialisation XML** : La méthode `xmlDeserialize(Reader $reader)` est appelée par le moteur SabreDAV lorsqu'il rencontre l'élément `<nc:param-filter>`.
-   **Extraction des Attributs** : La méthode lit deux attributs depuis l'élément XML :
    1.  `property`: Le nom de la propriété iCalendar cible (ex: `"ATTENDEE"`).
    2.  `name`: Le nom du paramètre à vérifier sur cette propriété (ex: `"PARTSTAT"`).
-   **Validation** : Elle s'assure que les deux attributs sont présents et sont des chaînes de caractères, levant une `BadRequest` si ce n'est pas le cas.
-   **Retour de la Valeur** : La méthode retourne un tableau associatif contenant les noms de la propriété et du paramètre. Par exemple, pour `<nc:param-filter property="ATTENDEE" name="PARTSTAT" />`, elle retournera :
    ```php
    [
        'property' => 'ATTENDEE',
        'parameter' => 'PARTSTAT',
    ]
    ```

En résumé, `ParamFilter` est un "parser" qui extrait de la requête XML les informations nécessaires pour construire une condition de recherche du type "trouver les événements où la propriété X a le paramètre Y".
