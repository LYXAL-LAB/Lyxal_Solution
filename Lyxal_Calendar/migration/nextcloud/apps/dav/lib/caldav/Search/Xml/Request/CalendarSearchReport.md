# Analyse de `OCA\DAV\CalDAV\Search\Xml\Request\CalendarSearchReport`

## Description

La classe `CalendarSearchReport` implémente l'interface `Sabre\Xml\XmlDeserializable` et agit comme le désérialiseur principal et l'objet de transfert de données (DTO) pour l'ensemble d'une requête `REPORT` de type `nc:calendar-search`.

Son rôle est de transformer le corps XML brut de la requête en un objet PHP structuré et validé, qui peut ensuite être facilement utilisé par le reste de l'application pour exécuter la recherche.

## Rôle et Responsabilités

1.  **Objet de Transfert de Données (DTO)** :
    *   La classe définit des propriétés publiques pour contenir toutes les informations pertinentes d'une requête de recherche :
        *   `$properties`: Un tableau des propriétés DAV qui doivent être retournées pour chaque résultat (ex: `{DAV:}getetag`).
        *   `$filters`: Un tableau associatif contenant tous les filtres de recherche (terme de recherche, filtres sur les composants, les propriétés, etc.).
        *   `$limit`: Le nombre maximum de résultats à retourner.
        *   `$offset`: Le décalage pour la pagination des résultats.

2.  **Désérialisation XML Coordonnée (`xmlDeserialize`)** :
    *   C'est la fonction centrale de la classe. Elle orchestre la désérialisation de l'ensemble de l'élément `<nc:calendar-search>`.
    *   Elle utilise la puissante méthode `parseInnerTree` de SabreDAV en lui fournissant une **carte de mapping**. Cette carte associe chaque type d'élément XML enfant (comme `<nc:comp-filter>`, `<nc:limit>`, etc.) à la classe de "parser" spécialisée correspondante (ex: `OCA\DAV\CalDAV\Search\Xml\Filter\CompFilter`).
    *   Cela permet de déléguer la désérialisation de chaque partie de la requête à une classe dédiée, rendant le code modulaire et propre.
    *   Après le parsing initial, elle parcourt la structure de données retournée et l'organise de manière logique dans ses propres propriétés (`$filters`, `$limit`, etc.).

3.  **Validation Sémantique de la Requête** :
    *   Une fois les données désérialisées, la classe effectue une série de vérifications de cohérence cruciales pour s'assurer que la requête de recherche est valide :
        *   Elle vérifie que l'élément `<nc:filter>` est présent.
        *   Elle s'assure qu'un terme de recherche (`<nc:search-term>`) a été fourni.
        *   Elle vérifie qu'au moins un filtre sur une propriété (`<nc:prop-filter>`) ou un paramètre (`<nc:param-filter>`) est spécifié, car une recherche sans critère n'a pas de sens.
        *   Elle impose qu'un filtre sur un composant (`<nc:comp-filter>`) soit défini si un filtre de propriété ou de paramètre est utilisé (on doit savoir dans quel type de composant, ex: `VEVENT`, chercher la propriété).
    *   Si l'une de ces règles n'est pas respectée, elle lève une exception `BadRequest`, ce qui arrête le traitement et renvoie une erreur claire au client.

4.  **Création de l'Objet Final** :
    *   Si le parsing et la validation réussissent, une nouvelle instance de `CalendarSearchReport` est créée (`new self()`).
    *   Les données parsées et structurées sont assignées aux propriétés publiques de cet objet.
    *   L'objet est ensuite retourné au `SearchPlugin`, qui peut désormais accéder aux paramètres de la recherche de manière simple et typée (par ex. `$report->limit`, `$report->filters['search-term']`).

En résumé, `CalendarSearchReport` est le point d'entrée qui transforme une requête XML complexe en un objet PHP propre, validé et facile à manipuler. Il agit comme un chef d'orchestre pour les petits "parsers" de filtres et comme un gardien qui garantit la validité sémantique des requêtes de recherche.
