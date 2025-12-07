# Analyse du Fichier `Proxy/Proxy.php`

Ce document décompose le contenu de la classe `Proxy\Proxy.php`. Il s'agit d'une classe d'entité qui représente une délégation de proxy CalDAV.

---

## 1. Rôle et Responsabilités

La classe `Proxy` est une **Entité** et un **DTO (Data Transfer Object)**. Son unique responsabilité est de servir de **représentation orientée objet d'une ligne de la table de base de données** qui stocke les relations de délégation de proxy.

Elle hérite de `OCP\AppFramework\Db\Entity`, ce qui la lie au système de mapping objet-relationnel (ORM) de Nextcloud et lui fournit automatiquement des méthodes d'accès (`getters` et `setters`).

Cette classe ne contient aucune logique métier ; elle est une simple structure de données.

---

## 2. Structure des Données

La classe définit la structure d'un enregistrement de délégation, qui correspond aux colonnes de la table de la base de données.

- **Propriétés**:
  - `ownerId`: L'identifiant de l'utilisateur qui accorde la délégation (le propriétaire des calendriers).
  - `proxyId`: L'identifiant de l'utilisateur qui reçoit la délégation (celui qui agira en tant que proxy).
  - `permissions`: Un entier représentant le niveau d'accès accordé au proxy.

- **Constructeur**:
  - Le constructeur utilise la méthode `addType` pour déclarer la correspondance entre les propriétés de la classe et les types de données SQL, ce qui est nécessaire pour que l'ORM de Nextcloud puisse mapper correctement les données.

---

## Conclusion

`Proxy` est une classe de la couche de persistance. Elle fournit une structure de données claire et typée pour représenter une délégation de proxy. Elle est utilisée par des classes de plus haut niveau (comme un `ProxyMapper` et des services) pour créer, lire et gérer les délégations dans la base de données de manière structurée et maintenable.
