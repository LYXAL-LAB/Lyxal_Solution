# Analyse de `OCA\DAV\CalDAV\Trashbin\Plugin`

## Description

La classe `Plugin` est un `ServerPlugin` pour SabreDAV qui active et orchestre la fonctionnalité de corbeille pour les objets CalDAV. Il ne gère pas directement les données de la corbeille, mais agit comme une couche d'intégration qui expose les fonctionnalités de la corbeille au monde extérieur via le protocole DAV.

## Rôle et Responsabilités

1.  **Annonce de la Fonctionnalité** :
    *   La méthode `getFeatures()` retourne `['nc-calendar-trashbin']`. Cela permet au plugin d'annoncer aux clients CalDAV compatibles (comme le client web de Nextcloud) que le serveur supporte la fonctionnalité de corbeille pour les calendriers.

2.  **Désactivation Optionnelle de la Corbeille** :
    *   Le plugin introduit un mécanisme pour contourner la corbeille et effectuer une suppression définitive.
    *   Dans son **constructeur**, il vérifie la présence de l'en-tête HTTP `X-NC-CalDAV-No-Trashbin`.
    *   La méthode **`beforeMethod()`**, qui s'exécute avant chaque requête DAV, utilise cette information. Si l'en-tête est présent, elle localise l'objet `Calendar` concerné par la requête et appelle sa méthode `disableTrashbin()`.
    *   Cela a pour effet que toute opération de suppression (`DELETE`) effectuée dans cette requête entraînera une suppression physique immédiate plutôt qu'un déplacement vers la corbeille. C'est utile pour les opérations de synchronisation ou de nettoyage où la corbeille n'est pas souhaitée.

3.  **Exposition de Propriétés DAV Personnalisées (`propFind`)** :
    *   C'est l'une des responsabilités majeures du plugin. Il s'abonne à l'événement `propFind` pour enrichir les réponses avec des métadonnées spécifiques à la corbeille.
    *   **Pour les objets dans la corbeille (`DeletedCalendarObject`)** :
        *   Il expose la propriété `nc:deleted-at` (`{http://nextcloud.com/ns}deleted-at`), qui contient la date et l'heure de la suppression de l'objet, formatée en `ATOM`.
        *   Il expose la propriété `nc:calendar-uri` (`{http://nextcloud.com/ns}calendar-uri`), qui indique l'URI du calendrier d'où l'objet a été supprimé.
    *   **Pour la racine de la corbeille (`TrashbinHome`)** :
        *   Il expose la propriété `nc:trash-bin-retention-duration` (`{http://nextcloud.com/ns}trash-bin-retention-duration`). La valeur est récupérée depuis le `RetentionService` et informe le client de la durée de conservation des éléments dans la corbeille (par exemple, "P30D" pour 30 jours).

## Dépendances

-   `OCP\IRequest`: Pour lire les en-têtes HTTP de la requête entrante.
-   `OCA\DAV\CalDAV\RetentionService`: Pour obtenir la politique de rétention des éléments de la corbeille.
-   `Sabre\DAV\Server`: Le plugin s'intègre au cycle de vie du serveur pour écouter les événements.

En résumé, `Trashbin\Plugin` est la colle qui intègre la logique de la corbeille CalDAV dans le serveur DAV. Il ne manipule pas les données lui-même mais agit comme un contrôleur qui :
1.  Fournit un mécanisme de désactivation conditionnelle de la corbeille.
2.  Traduit les données internes de la corbeille (comme la date de suppression) en propriétés DAV standardisées que les clients peuvent comprendre et afficher.
3.  Annonce la présence de la fonctionnalité au réseau.
