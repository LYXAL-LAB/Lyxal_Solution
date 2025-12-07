# Analyse de `OCA\DAV\CalDAV\Security\RateLimitingPlugin`

## Description

`RateLimitingPlugin` est un plugin SabreDAV qui a pour but de renforcer la sécurité et la stabilité du serveur CalDAV en empêchant les abus liés à la création de calendriers et d'abonnements. Il met en place deux types de limitations distinctes pour les utilisateurs authentifiés.

## Rôle et Responsabilités

1.  **Interception de la Création de Calendriers** :
    *   Le plugin s'abonne à l'événement `beforeBind` du serveur SabreDAV, avec une priorité élevée (1). Cet événement est déclenché juste avant qu'un nouveau nœud (fichier ou collection) ne soit créé à un chemin donné.
    *   Il cible spécifiquement les chemins qui correspondent à la création d'un calendrier ou d'un abonnement dans le "calendar home" d'un utilisateur (ex: `/calendars/user-id/new-calendar/`).

2.  **Limitation de Taux (Rate Limiting)** :
    *   Le plugin utilise le service de limitation de taux central de Nextcloud (`OC\Security\RateLimiting\Limiter`).
    *   Il enregistre chaque tentative de création de calendrier sous l'identifiant `caldav-create-calendar`.
    *   Il applique une limite sur le **nombre de calendriers qu'un utilisateur peut créer sur une période donnée**.
    *   Ces limites sont configurables via `app.config` :
        *   `dav.rateLimitCalendarCreation` (défaut : 10)
        *   `dav.rateLimitPeriodCalendarCreation` (défaut : 3600 secondes)
    *   Si un utilisateur dépasse cette limite, le `Limiter` lève une `RateLimitExceededException`, qui est interceptée et transformée en une exception DAV `OCA\DAV\Connector\Sabre\Exception\TooManyRequests` (correspondant au code HTTP 429).

3.  **Limite Absolue sur le Nombre Total de Calendriers** :
    *   En plus de la limitation de taux, le plugin impose une **limite maximale sur le nombre total de calendriers et d'abonnements** qu'un utilisateur peut posséder.
    *   Avant d'autoriser la création, il interroge le `CalDavBackend` pour compter le nombre actuel de calendriers (`getCalendarsForUserCount`) et d'abonnements (`getSubscriptionsForUserCount`) de l'utilisateur.
    *   Il compare ce total à la limite définie dans la configuration `dav.maximumCalendarsSubscriptions` (défaut : 30). Une valeur de -1 désactive la limite.
    *   Si la limite est atteinte ou dépassée, le plugin lève une exception `Sabre\DAV\Exception\Forbidden` (correspondant au code HTTP 403).

4.  **Ciblage** :
    *   La logique de limitation ne s'applique qu'aux utilisateurs authentifiés (`$this->userId !== null`). Les requêtes anonymes ne sont pas concernées.

## Dépendances

-   `OC\Security\RateLimiting\Limiter`: Le service central de Nextcloud pour la limitation de taux.
-   `OCP\IUserManager`: Pour récupérer l'objet utilisateur à partir de l'ID.
-   `OCA\DAV\CalDAV\CalDavBackend`: Pour compter le nombre de calendriers et d'abonnements existants pour un utilisateur.
-   `OCP\IAppConfig`: Pour lire les valeurs de configuration qui définissent les limites.

En résumé, `RateLimitingPlugin` est un mécanisme de sécurité essentiel qui protège l'instance Nextcloud contre les attaques par déni de service ou les abus (intentionnels ou non) où un utilisateur ou un script pourrait créer un nombre excessif de calendriers, consommant ainsi des ressources serveur.
