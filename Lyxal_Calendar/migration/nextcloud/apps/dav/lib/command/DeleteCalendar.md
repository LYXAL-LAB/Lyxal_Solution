# Analyse de `OCA\DAV\Command\DeleteCalendar`

## Description

`DeleteCalendar` est une commande console `occ` qui fournit aux administrateurs un moyen de supprimer un calendrier spécifique appartenant à un utilisateur.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:delete-calendar`
-   **Description** : "Delete a dav calendar" (Supprimer un calendrier DAV).

### Fonctionnement

1.  **Arguments et Options** : La commande offre plusieurs façons de cibler le calendrier à supprimer :
    *   `uid` (obligatoire) : L'identifiant de l'utilisateur propriétaire du calendrier.
    *   `name` (optionnel) : L'URI du calendrier (son "nom de fichier" dans le backend DAV). Cet argument est obligatoire si l'option `--birthday` n'est pas utilisée.
    *   `--birthday` (option) : Un drapeau (`--birthday`) qui permet de cibler spécifiquement et facilement le calendrier des anniversaires de l'utilisateur, sans avoir à connaître son URI exact.
    *   `--force` ou `-f` (option) : Un drapeau qui, s'il est présent, modifie le comportement de la suppression pour qu'elle soit **définitive**, en contournant la corbeille.

2.  **Validation** :
    *   La commande vérifie d'abord que l'utilisateur (`uid`) existe.
    *   Elle s'assure ensuite que l'un des arguments `name` ou `--birthday` a bien été fourni.
    *   Elle utilise le `CalDavBackend` pour vérifier que le calendrier ciblé existe bien pour l'utilisateur spécifié. Si ce n'est pas le cas, elle renvoie une erreur informative suggérant d'utiliser la commande `dav:list-calendars`.

3.  **Action de Suppression** :
    *   La commande instancie un objet `OCA\DAV\CalDAV\Calendar`, qui est la représentation DAV du calendrier à supprimer.
    *   **Gestion de la Suppression Forcée** : Si l'option `--force` est utilisée, la commande appelle la méthode `$calendar->disableTrashbin()` sur l'objet. Cette méthode place un drapeau sur l'objet pour indiquer que la prochaine opération de suppression doit être définitive.
    *   **Suppression** : Enfin, elle appelle la méthode `$calendar->delete()`.
        *   Par défaut, cette action déplace le calendrier et son contenu vers la corbeille.
        *   Si `disableTrashbin()` a été appelé juste avant, cette même méthode `delete()` effectuera une suppression physique et irréversible.

### Cas d'Usage

Cette commande est un outil d'administration essentiel pour :
-   Supprimer des calendriers pour des utilisateurs dans le cadre de scripts de maintenance ou de déprovisionnement.
-   Forcer la suppression de calendriers corrompus ou problématiques qui ne peuvent pas être supprimés via l'interface utilisateur.
-   Gérer le cycle de vie des calendriers des anniversaires.

## Dépendances Clés

-   `OCA\DAV\CalDAV\CalDavBackend`: Pour vérifier l'existence du calendrier.
-   `OCP\IUserManager`: Pour valider l'existence de l'utilisateur.
-   `Symfony\Component\Console`: Le framework pour la structure de la commande.
