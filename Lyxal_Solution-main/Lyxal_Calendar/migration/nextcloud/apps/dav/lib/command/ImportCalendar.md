# Analyse de `OCA\DAV\Command\ImportCalendar`

## Description

`ImportCalendar` est une commande console `occ`, symétrique à `calendar:export`, qui permet aux administrateurs d'importer des données de calendrier (depuis un fichier ou l'entrée standard) dans un calendrier existant d'un utilisateur.

## Rôle et Responsabilités

-   **Nom de la commande** : `calendar:import`
-   **Description** : "Import calendar data to supported calendars from disk or stdin" (Importer des données de calendrier vers les calendriers supportés depuis le disque ou l'entrée standard).

### Fonctionnement

1.  **Arguments et Options Riches** : La commande offre un contrôle très fin sur le processus d'importation :
    *   **Cible** (`uid`, `uri` - obligatoires) : Identifient l'utilisateur et le calendrier de destination.
    *   **Source** (`location` - optionnel) : Spécifie le chemin du fichier à importer. Si omis, la commande lit les données depuis l'entrée standard (`stdin`), ce qui permet d'utiliser des pipes (ex: `cat mycalendar.ics | occ calendar:import ...`).
    *   **Format** (`--format`) : Permet de spécifier le format des données d'entrée : `ical` (par défaut), `jcal`, ou `xcal`.
    *   **Gestion des Erreurs** (`--errors`, `--validation`) : Options numériques pour définir comment la commande doit réagir face à des éléments mal formés ou invalides (0 = continuer, 1 = ignorer l'élément, 2 = arrêter l'importation).
    *   **Mode de Remplacement** (`--supersede`) : Si cette option est activée, les événements du fichier d'import qui ont le même UID qu'un événement déjà existant dans le calendrier cible remplaceront (mettront à jour) l'événement existant. Par défaut, ils sont ignorés.
    *   **Rapport Détaillé** (`--show-created`, `--show-updated`, etc.) : Une série d'options pour demander à la commande d'afficher la liste des UID pour chaque catégorie de résultat (créé, mis à jour, ignoré, en erreur).

2.  **Validation en Amont** :
    *   La commande s'assure que l'utilisateur et le calendrier de destination existent.
    *   Elle vérifie que le calendrier cible est un calendrier standard (`CalendarImpl`), qu'il est inscriptible (`isWritable`), et qu'il n'est pas dans la corbeille (`isDeleted`).

3.  **Logique d'Importation** :
    *   Elle construit un objet `CalendarImportOptions` pour encapsuler toutes les options de configuration.
    *   Elle gère la source des données (fichier ou `stdin`). Pour `stdin`, elle copie d'abord le flux dans un fichier temporaire pour permettre au service d'importation d'y accéder de manière fiable.
    *   Elle délègue l'ensemble du processus de parsing et d'importation au `OCA\DAV\CalDAV\Import\ImportService`. Le `ImportService` utilise des générateurs et des parseurs efficaces en mémoire, ce qui rend la commande capable de gérer de très gros fichiers d'import.

4.  **Rapport d'Exécution** :
    *   Une fois l'importation terminée, le `ImportService` retourne un tableau de résultats (`$outcome`).
    *   La commande analyse ce tableau et affiche un **rapport final complet** à l'administrateur, incluant le temps total d'exécution et le nombre d'éléments dans chaque catégorie (créés, mis à jour, ignorés, en erreur).

### Cas d'Usage

-   Migrer des calendriers d'un autre système vers Nextcloud.
-   Restaurer un calendrier à partir d'une sauvegarde.
-   Importer des calendriers partagés (fichiers `.ics`) de manière centralisée pour les utilisateurs.
-   Automatiser l'ajout d'événements à des calendriers via des scripts.

## Dépendances Clés

-   `OCP\IUserManager`, `OCP\Calendar\IManager`: Pour valider la cible de l'import.
-   `OCA\DAV\CalDAV\Import\ImportService`: Le service métier qui contient toute la logique complexe de parsing et d'importation.
-   `OCP\ITempManager`: Pour gérer la création de fichiers temporaires lors de la lecture depuis `stdin`.
-   `Symfony\Component\Console`: Le framework pour la structure de la commande.
