# Analyse des Fichiers Racine de `lib/` de Nextcloud DAV

Ce document décrit les 6 fichiers PHP à la racine du répertoire `lib/`.

---

## `Capabilities.php`
-   **Interface** : `ICapability`
-   **Fonction** : Expose les capacités du module DAV à l'API Nextcloud
-   **Capacités exposées** :
    -   `chunking: "1.0"` : Upload par morceaux
    -   `public_shares_chunking: true` : Chunking sur partages publics
    -   `bulkupload: "1.0"` : Upload en masse (si activé)
    -   `absence-supported`, `absence-replacement` : Support Out-of-Office

---

## `ConfigLexicon.php`
-   **Interface** : `ILexicon`
-   **Fonction** : Définit les clés de configuration de l'app
-   **Clés** :
    -   `SYSTEM_ADDRESSBOOK_EXPOSED` : Exposer le carnet d'adresses système (bool, défaut: true)

---

## `ResponseDefinitions.php`
-   **Fonction** : Définit les types Psalm pour les réponses API
-   **Types** :
    -   `DAVOutOfOfficeData` : Données d'absence
    -   `DAVCurrentOutOfOfficeData` : Absence en cours
    -   `DAVUpcomingEvent` : Événement à venir

---

## `RootCollection.php`
-   **Classe parente** : `Sabre\DAV\SimpleCollection`
-   **Fonction** : Construit l'arborescence racine du serveur WebDAV

### Structure de l'Arborescence
```
/dav/
├── principals/
│   ├── users/
│   ├── groups/
│   ├── system/
│   ├── calendar-resources/
│   ├── calendar-rooms/
│   └── federated-users/
├── files/
├── calendars/
├── remote-calendars/
├── system-calendars/
│   ├── calendar-resources/
│   └── calendar-rooms/
├── public-calendars/
├── addressbooks/
│   ├── users/
│   └── system/
├── systemtags/
├── systemtags-relations/
├── systemtags-in-use/
├── comments/
├── uploads/
├── avatars/
└── provisioning/
    └── apple-provisioning.mobileconfig
```

---

## `Server.php`
-   **Fonction** : Point d'entrée principal du serveur WebDAV
-   **Responsabilités** :
    1. Crée l'instance `RootCollection`
    2. Initialise le serveur Sabre via `Connector\Sabre\Server`
    3. Enregistre tous les plugins selon le contexte

### Plugins Enregistrés (résumé)
-   **Auth** : PublicAuth, BearerAuth, Auth
-   **CalDAV** : Plugin CalDAV, Schedule, ICS Export, Publish, Trashbin
-   **CardDAV** : Plugin CardDAV, VCF Export, Photo, Image
-   **Files** : FilesPlugin, Tags, Shares, Quota, Search
-   **System** : SystemTags, Comments, Chunking v1/v2, Bulk Upload

### Méthode `exec()`
Lance le serveur Sabre et collecte les données de profilage.

---

## `ServerFactory.php`
-   **Fonction** : Fabrique de serveurs spécialisés
-   **Méthodes** :
    -   `createInvitationResponseServer()` : Serveur pour réponses d'invitation (RSVP)
    -   `createAttendeeAvailabilityServer()` : Serveur pour vérifier la disponibilité
