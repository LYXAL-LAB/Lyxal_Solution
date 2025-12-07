# Analyse du Répertoire `templates` de Nextcloud DAV

Ce répertoire contient les templates PHP pour les pages HTML.

---

## Réponses de Planification (Schedule Response)

Templates pour les réponses aux invitations de calendrier (RSVP via email).

### `schedule-response-options.php`
-   **Fonction** : Page avec boutons Accept/Decline/Tentative
-   **Usage** : Lien dans l'email d'invitation

### `schedule-response-success.php`
-   **Fonction** : Confirmation après réponse à l'invitation

### `schedule-response-error.php`
-   **Fonction** : Page d'erreur si la réponse échoue

---

## Pages de Paramètres

### `settings-admin-caldav.php`
-   **Fonction** : Template pour les paramètres admin CalDAV
-   **Contenu** : Container pour le composant Vue.js

### `settings-admin-example-content.php`
-   **Fonction** : Template pour les paramètres contenu d'exemple

### `settings-personal-availability.php`
-   **Fonction** : Template pour la page de disponibilité utilisateur
