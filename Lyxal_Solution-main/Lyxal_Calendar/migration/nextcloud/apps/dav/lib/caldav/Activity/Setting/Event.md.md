# Analyse du Fichier `Activity/Setting/Event.php`

Ce document décompose le contenu de la classe `Activity\Setting\Event.php`. Il s'agit d'une classe de configuration qui déclare une option de notification spécifique pour les modifications d'événements.

---

## 1. Rôle et Responsabilités

La classe `Event` hérite de `CalDAVSetting`. Son unique responsabilité est de **définir et d'enregistrer une option de notification** dans les paramètres de l'application Activity.

Elle est responsable de l'affichage et du comportement de la case à cocher correspondant à la phrase "Un **événement** de calendrier a été modifié".

---

## 2. Méthodes

La classe est structurellement identique à `Activity\Setting\Calendar` mais est configurée pour le type "événement".

- **`getIdentifier()`**:
  - **Action**: Retourne `calendar_event`. Cet identifiant lie cette option de configuration aux événements d'activité dont le `type` est `calendar_event` (générés par le `Activity\Backend`).

- **`getName()`**:
  - **Action**: Retourne la chaîne de caractères traduite qui sera affichée, par exemple "Un **événement** de calendrier a été modifié".

- **`getPriority()`, `canChangeStream()`, `isDefaultEnabledStream()`, etc.**:
  - **Action**: Ces méthodes définissent le comportement de l'option de la même manière que pour les calendriers : prioritaire, modifiable par l'utilisateur, activée par défaut pour le flux mais pas pour les emails.

---

## Conclusion

`Activity\Setting\Event` est une classe de configuration symétrique à `Activity\Setting\Calendar`. Elle fournit le point de contrôle nécessaire pour que les utilisateurs puissent choisir s'ils veulent être notifiés des créations, modifications, etc., qui surviennent sur les événements au sein de leurs calendriers.
