# Analyse du Répertoire `UserMigration` de Nextcloud DAV

Ce répertoire implémente l'export/import de données utilisateur (6 fichiers).

---

## Migrateurs

### `CalendarMigrator.php`
-   **Interface** : `IMigrator`
-   **Fonction** : Export/import des calendriers CalDAV
-   **Export** : Génère un fichier ICS par calendrier
-   **Import** : Crée les calendriers et importe les événements
-   **Métadonnées** : Couleur, ordre, propriétés personnalisées

### `ContactsMigrator.php`
-   **Interface** : `IMigrator`
-   **Fonction** : Export/import des contacts CardDAV
-   **Export** : Génère un fichier VCF par carnet d'adresses
-   **Import** : Crée les carnets et importe les contacts

---

## Exceptions

| Exception | Déclencheur |
|-----------|-------------|
| `CalendarMigratorException` | Erreur lors de migration calendrier |
| `ContactsMigratorException` | Erreur lors de migration contacts |
| `InvalidCalendarException` | Calendrier invalide à l'import |
| `InvalidAddressBookException` | Carnet d'adresses invalide à l'import |
