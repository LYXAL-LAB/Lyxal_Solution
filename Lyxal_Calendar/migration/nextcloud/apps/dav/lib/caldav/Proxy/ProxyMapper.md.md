# Analyse du Fichier `Proxy/ProxyMapper.php`

Ce document décompose le contenu de la classe `Proxy\ProxyMapper.php`. Il s'agit d'une classe de la couche d'accès aux données, responsable des interactions avec la table de base de données des délégations de proxy CalDAV.

---

## 1. Rôle et Responsabilités

La classe `ProxyMapper` est un **Data Mapper**. Son unique responsabilité est d'exécuter des requêtes de lecture sur la table `dav_cal_proxy` pour récupérer des informations sur les délégations de proxy.

Elle encapsule la logique SQL et fait le pont entre la base de données et le monde orienté objet de l'application (en retournant des tableaux d'objets `Proxy`).

---

## 2. Logique Principale

La classe hérite de `QBMapper`, ce qui lui fournit une base pour construire des requêtes. Elle définit le nom de la table (`dav_cal_proxy`) et la classe entité associée (`Proxy`) dans son constructeur.

Elle expose deux méthodes de lecture principales, qui répondent à deux questions symétriques.

- **`getProxiesFor(string $proxyId)`**:
  - **Objectif**: Répondre à la question : "Quels sont les utilisateurs qui m'ont désigné comme leur délégué (proxy) ?".
  - **Action**: Elle exécute une requête `SELECT` sur la table `dav_cal_proxy` en filtrant sur la colonne `proxy_id`. Elle retourne une liste d'entités `Proxy` représentant toutes les délégations qu'un utilisateur a reçues.

- **`getProxiesOf(string $ownerId)`**:
  - **Objectif**: Répondre à la question : "À quels utilisateurs ai-je délégué l'accès à mes calendriers ?".
  - **Action**: Elle exécute une requête `SELECT` en filtrant sur la colonne `owner_id`. Elle retourne une liste d'entités `Proxy` représentant toutes les délégations qu'un utilisateur a accordées.

Les opérations d'écriture (création, mise à jour, suppression) ne sont pas explicitement définies dans cette classe mais sont probablement gérées soit par les méthodes héritées de `QBMapper`, soit par un service de plus haut niveau qui utilise ce mapper.

---

## Conclusion

`ProxyMapper` est une implémentation propre d'une classe de la couche d'accès aux données. Elle fournit une API claire et orientée métier pour interroger les relations de délégation de proxy, tout en masquant complètement la complexité et la syntaxe des requêtes SQL sous-jacentes. Elle est un composant essentiel pour que la fonctionnalité de délégation de proxy CalDAV puisse lire et utiliser les configurations de délégation stockées en base de données.
