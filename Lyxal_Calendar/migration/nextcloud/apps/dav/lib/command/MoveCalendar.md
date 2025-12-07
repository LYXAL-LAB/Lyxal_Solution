# Analyse de `OCA\DAV\Command\MoveCalendar`

## Description

`MoveCalendar` est une commande console `occ` puissante qui permet de transférer la propriété d'un calendrier d'un utilisateur à un autre. C'est utile lors de la suppression de comptes, de changements de poste, ou de fusions d'utilisateurs.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:move-calendar`
-   **Description** : "Move a calendar from an user to another" (Déplacer un calendrier d'un utilisateur vers un autre).

### Fonctionnement

1.  **Arguments Requis** :
    *   `name` : Le nom (URI) du calendrier à déplacer.
    *   `sourceuid` : L'identifiant du propriétaire actuel.
    *   `destinationuid` : L'identifiant du nouveau propriétaire.

2.  **Option** :
    *   `--force` (`-f`) : Force la migration en résolvant automatiquement les conflits (suppression de partages invalides, renommage en cas de doublon).

3.  **Validation Initiale** :
    *   Vérifie que les utilisateurs source et destination existent.
    *   Vérifie que le calendrier source existe.

4.  **Gestion des Conflits de Nom** :
    *   Si l'utilisateur de destination possède déjà un calendrier avec le même nom :
        *   **Sans `--force`** : La commande échoue.
        *   **Avec `--force`** : La commande tente de trouver un nouveau nom disponible en ajoutant un suffixe incrémental (ex: `mon-calendrier-1`, `mon-calendrier-2`).

5.  **Gestion des Partages (`checkShares`)** :
    *   La commande analyse les partages existants du calendrier.
    *   **Conflit de Groupe** : Si le calendrier est partagé avec un groupe dont le *nouveau* propriétaire ne fait pas partie (et que le partage est restreint aux membres du groupe) :
        *   Sans `--force` : Erreur.
        *   Avec `--force` : Le partage avec ce groupe est supprimé.
    *   **Conflit de Destination** : Si le calendrier était déjà partagé *avec* le futur propriétaire :
        *   Sans `--force` : Erreur (car on ne peut pas partager un calendrier avec soi-même).
        *   Avec `--force` : Le partage vers le destinataire est supprimé.
    *   **Avertissement** : Si des partages existent, la commande avertit que les liens de partage (URL CalDAV) vont changer pour les bénéficiaires.

6.  **Exécution** :
    *   Appelle `calDav->moveCalendar(...)` pour effectuer le changement de propriétaire en base de données.

### Cas d'Usage

-   **Offboarding** : Récupérer les calendriers professionnels d'un employé qui quitte l'entreprise pour les attribuer à son remplaçant.
-   **Maintenance** : Corriger des erreurs d'attribution de calendriers.

## Dépendances Clés

-   `OCP\IUserManager` / `OCP\IGroupManager`: Gestion des utilisateurs et groupes.
-   `OCP\Share\IManager`: Vérification des politiques de partage.
-   `OCA\DAV\CalDAV\CalDavBackend`: Le service qui effectue le déplacement réel.
