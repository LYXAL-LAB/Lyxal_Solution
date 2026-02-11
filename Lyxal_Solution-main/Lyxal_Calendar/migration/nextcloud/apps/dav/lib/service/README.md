# Analyse du Répertoire `Service` de Nextcloud DAV

Ce répertoire contient les services métier du module DAV (4 fichiers).

---

## `AbsenceService.php`
-   **Fonction** : Gestion des absences (Out-of-Office)
-   **Opérations** : Créer, mettre à jour, supprimer une absence
-   **Intégration** : Mapper `AbsenceMapper`, événements CalDAV

## `ASyncService.php`
-   **Type** : Classe abstraite
-   **Fonction** : Base pour les services de synchronisation (CardDAV, CalDAV)
-   **Capabilities** : Sync incrémental, sync initial

## `ExampleContactService.php`
-   **Fonction** : Crée un contact d'exemple dans le carnet d'adresses
-   **Usage** : Premier lancement, démonstration

## `ExampleEventService.php`
-   **Fonction** : Crée un événement d'exemple dans le calendrier
-   **Usage** : Premier lancement, démonstration
