# Analyse du Fichier `CachedSubscriptionObject.php` de Nextcloud

Ce document décompose le contenu de la classe `CachedSubscriptionObject.php`. Cette classe représente un unique événement (un "objet") au sein d'un calendrier de type abonnement.

---

## 1. Rôle et Responsabilités

La classe `CachedSubscriptionObject` est une **spécialisation** de `CalendarObject`. Son rôle est de représenter un événement qui provient d'un abonnement externe et qui est mis en cache localement.

Sa responsabilité principale est de **renforcer la nature en lecture seule** d'un abonnement en interdisant explicitement toute opération d'écriture sur les événements qu'il contient.

---

## 2. Logique de la Classe

La classe hérite de `CalendarObject` mais surcharge (modifie) plusieurs méthodes clés pour bloquer les actions de modification.

- **`put($data)`**:
  - **Rôle**: Gérer une tentative de mise à jour complète de l'événement.
  - **Action**: Lève systématiquement une exception `Forbidden`, interdisant l'opération.

- **`delete()`**:
  - **Rôle**: Gérer une tentative de suppression de l'événement.
  - **Action**: Lève systématiquement une exception `Forbidden`.

- **`patch(PropPatch $propPatch)`**:
  - **Rôle**: Gérer une tentative de mise à jour partielle des propriétés de l'événement.
  - **Action**: Lève systématiquement une exception `Forbidden`.

- **`isShared()`**:
  - **Rôle**: Indiquer si l'objet est dans un contexte de partage.
  - **Action**: Retourne toujours `true`, car un abonnement est par nature considéré comme une ressource partagée. Cela garantit que toute la logique de filtrage de la classe parente `CalendarObject` (suppression des alarmes, etc.) est bien appliquée.

---

## Conclusion

`CachedSubscriptionObject` est une classe de **sécurisation**. Son but principal n'est pas d'ajouter des fonctionnalités, mais d'en retirer. En héritant de `CalendarObject` et en bloquant toutes les méthodes d'écriture (`put`, `delete`, `patch`), elle garantit l'intégrité de la copie locale d'un abonnement. Elle agit comme un "garde-fou" qui empêche les utilisateurs de modifier ou de supprimer par erreur des événements sur lesquels ils ne devraient avoir qu'un accès en lecture seule, respectant ainsi la nature unidirectionnelle d'un abonnement de calendrier.
