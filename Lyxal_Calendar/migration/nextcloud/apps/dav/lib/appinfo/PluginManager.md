# Analyse du Fichier `PluginManager.php` de Nextcloud

## Description

`PluginManager` gère le chargement dynamique des plugins Sabre (WebDAV) enregistrés par les apps Nextcloud via leur fichier `info.xml`.

## Rôle et Responsabilités

### 1. Récupération des Plugins
-   `getAppPlugins()` : Retourne les plugins Sabre (`ServerPlugin[]`)
-   `getAppCollections()` : Retourne les collections WebDAV (`Collection[]`)
-   `getAddressBookPlugins()` : Retourne les providers de carnets d'adresses (`IAddressBookProvider[]`)
-   `getCalendarPlugins()` : Retourne les providers de calendriers (`ICalendarProvider[]`)

### 2. Chargement depuis `info.xml`
-   Parse la section `<sabre>` de l'`info.xml` des apps
-   Types supportés : `<plugins>`, `<collections>`, `<address-book-plugins>`, `<calendar-plugins>`

### 3. Instanciation Dynamique
-   `createClass()` : Utilise le container DI ou instancie directement
-   Vérifie que les classes implémentent les bonnes interfaces

## Format `info.xml`
```xml
<sabre>
    <plugins>
        <plugin>OCA\MyApp\DAV\MyPlugin</plugin>
    </plugins>
    <calendar-plugins>
        <plugin>OCA\MyApp\CalDAV\MyCalendarProvider</plugin>
    </calendar-plugins>
</sabre>
```

## Dépendances Clés
-   `ServerContainer` : Container DI pour instanciation
-   `IAppManager` : Liste des apps activées
-   `Sabre\DAV\ServerPlugin` : Interface des plugins Sabre
