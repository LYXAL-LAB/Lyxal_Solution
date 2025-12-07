# Analyse du Fichier `LegacyDAVACL.php` de Nextcloud

## Description

`LegacyDAVACL` est une extension de `DavAclPlugin` conçue pour maintenir la rétrocompatibilité avec les anciens clients WebDAV qui s'attendent à une structure d'URL de principaux différente (v1 vs v2).

## Rôle et Responsabilités

### 1. Compatibilité des Principaux (`getCurrentUserPrincipals`)
-   Retourne à la fois le principal "moderne" (v2, ex: `principals/users/admin`) et le principal "legacy" (v1, ex: `principals/admin`).
-   Cela permet aux clients qui utilisent l'ancien format d'URL de continuer à fonctionner.

### 2. Surcharge de `current-user-principal` (`propFind`)
-   Modifie la propriété `{DAV:}current-user-principal` pour retourner l'URL du principal courant.

## Dépendances Clés
-   `OCA\DAV\Connector\Sabre\DavAclPlugin` : Classe parente.
