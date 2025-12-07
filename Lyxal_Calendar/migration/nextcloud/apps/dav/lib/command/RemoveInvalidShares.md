# Analyse de `OCA\DAV\Command\RemoveInvalidShares`

## Description

`RemoveInvalidShares` est une commande de maintenance destinée à nettoyer la base de données des partages DAV orphelins. Elle a été créée pour corriger les incohérences laissées par un ancien bug de l'application Agenda.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:remove-invalid-shares`
-   **Description** : "Remove invalid dav shares" (Supprimer les partages DAV invalides).

### Fonctionnement

1.  **Analyse** :
    *   La commande interroge la table `dav_shares` pour obtenir la liste de tous les `principaluri` (identifiants d'utilisateurs ou de groupes) qui possèdent des partages.

2.  **Vérification** :
    *   Pour chaque `principaluri` trouvé, elle vérifie si l'entité correspondante existe toujours dans le système.
    *   Elle consulte deux backends :
        *   `PrincipalBackend` : Pour les utilisateurs et groupes locaux.
        *   `RemoteUserPrincipalBackend` : Pour les utilisateurs distants (fédération).

3.  **Nettoyage** :
    *   Si un `principaluri` ne peut être résolu (l'utilisateur ou le groupe n'existe plus), la commande considère que ses partages sont invalides.
    *   Elle supprime alors **toutes les entrées** correspondantes dans la table `dav_shares`.

### Cas d'Usage

-   **Maintenance de la base de données** : À exécuter si des utilisateurs se plaignent de voir des partages "fantômes" ou si les logs indiquent des erreurs liées à des principaux manquants.
-   **Correction de bugs** : Spécifiquement conçu pour réparer les dégâts d'un bug historique.

## Dépendances Clés

-   `OCP\IDBConnection`: Accès direct à la base de données pour les requêtes de nettoyage.
-   `OCA\DAV\Connector\Sabre\Principal`: Vérification des utilisateurs locaux.
-   `OCA\DAV\DAV\RemoteUserPrincipalBackend`: Vérification des utilisateurs distants.
