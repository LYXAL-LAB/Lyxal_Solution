# Analyse du Fichier `Calendar.php` de Nextcloud

Ce document décompose le contenu de la classe `Calendar.php`. Cette classe est la représentation concrète, dans le framework SabreDAV, d'un calendrier standard appartenant à un utilisateur.

---

## 1. Rôle et Responsabilités

La classe `Calendar` est l'équivalent de `CachedSubscription` mais pour les calendriers normaux, en lecture/écriture. Elle hérite de `\Sabre\CalDAV\Calendar` et implémente des interfaces DAV supplémentaires pour gérer des fonctionnalités avancées :
- **`IShareable`**: Indique que ce calendrier peut être partagé avec d'autres utilisateurs.
- **`IRestorable`**: Indique que ce calendrier peut être restauré depuis la corbeille.
- **`IMoveTarget`**: Indique que ce calendrier peut servir de "cible" lorsqu'on déplace un événement depuis un autre calendrier.

Son rôle principal est d'agir comme une **façade DAV** pour un calendrier stocké en base de données. Elle reçoit les requêtes du protocole CalDAV et les **délègue** au service `CalDavBackend` pour l'exécution.

---

## 2. Fonctions Publiques (Interface DAV et Extensions)

### Opérations sur les Événements (Enfants)
- **`getChild($name)`, `getChildren()`, etc.**:
  - **Rôle**: Gérer l'accès aux événements.
  - **Action**: Appelle les méthodes correspondantes du `CalDavBackend`. Elle applique également une logique de sécurité importante : elle **filtre les événements marqués comme "privés" (`CLASSIFICATION_PRIVATE`) si le calendrier est consulté par quelqu'un avec qui il est partagé.**

### Opérations sur le Calendrier Lui-même
- **`delete()`**:
  - **Rôle**: Supprimer le calendrier.
  - **Action**: Gère plusieurs cas. Si c'est un calendrier partagé, "supprimer" signifie "se désabonner". Si c'est un calendrier propre, elle appelle `caldavBackend->deleteCalendar(...)`.

- **`propPatch(PropPatch $propPatch)`**:
  - **Rôle**: Mettre à jour les propriétés du calendrier.
  - **Action**: Appelle la logique de mise à jour du `CalDavBackend`.

### Gestion du Partage
- **`updateShares(...)` et `getShares()`**:
  - **Rôle**: Gérer l'ajout/suppression de personnes avec qui le calendrier est partagé.
  - **Action**: Délègue les appels au `CalDavBackend`.

- **`setPublishStatus(...)`**:
  - **Rôle**: Gérer le partage public du calendrier via un lien.
  - **Action**: Délègue l'appel au `CalDavBackend`.

### Gestion des Permissions (ACL)
- **`getACL()`**:
  - **Rôle**: Définir les permissions d'accès au calendrier.
  - **Action**: Méthode complexe qui construit dynamiquement la liste des permissions en fonction du propriétaire, du statut de partage, et du type de calendrier (ex: le calendrier d'anniversaires a des restrictions d'écriture).

### Gestion de la Corbeille
- **`restore()`**:
  - **Rôle**: Restaure le calendrier depuis la corbeille.
  - **Action**: Appelle `caldavBackend->restoreCalendar(...)`.

---

## Conclusion

La classe `Calendar` est une **façade architecturale** qui expose un calendrier normal au monde DAV. Elle est complexe car elle gère la lecture **et l'écriture**, le **partage**, la **corbeille**, et une logique de **permissions dynamique**. Son rôle est de recevoir les requêtes DAV génériques, d'appliquer des règles métier (sécurité des événements privés, etc.) et de déléguer l'exécution au `CalDavBackend`.
