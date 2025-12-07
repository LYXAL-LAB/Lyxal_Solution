# Analyse du Répertoire `Search` de Nextcloud DAV

Ce répertoire implémente les fournisseurs de recherche unifiée (4 fichiers).

---

## Providers

### `ACalendarSearchProvider.php`
-   **Type** : Classe abstraite
-   **Fonction** : Base commune pour les providers de recherche calendrier
-   **Implémente** : `IProvider` (Unified Search)

### `EventsSearchProvider.php`
-   **Fonction** : Recherche dans les événements CalDAV
-   **Champs** : Titre, description, lieu, participants
-   **Résultats** : Événements correspondants avec aperçu

### `TasksSearchProvider.php`
-   **Fonction** : Recherche dans les tâches (VTODO)
-   **Champs** : Titre, description

### `ContactsSearchProvider.php`
-   **Fonction** : Recherche dans les contacts CardDAV
-   **Champs** : Nom, email, téléphone, organisation
