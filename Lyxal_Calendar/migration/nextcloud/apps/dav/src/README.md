# Analyse du Répertoire `src` de Nextcloud DAV

Ce répertoire contient le code frontend (Vue.js/TypeScript) de l'app DAV.

---

## Points d'Entrée (`.ts`)

| Fichier | Page |
|---------|------|
| `settings-admin.ts` | Paramètres admin CalDAV |
| `settings-admin-example-content.ts` | Paramètres admin contenu d'exemple |
| `settings-personal-availability.ts` | Disponibilité utilisateur |

---

## Vues (`views/`)

### `CalDavSettings.vue`
-   **Fonction** : Page de paramètres admin CalDAV
-   **Options** : Invitations par email, rappels, synchronisation
-   **Tests** : `CalDavSettings.spec.js`

### `UserAvailability.vue`
-   **Fonction** : Configuration des heures de disponibilité

### `ExampleContentSettingsSection.vue`
-   **Fonction** : Section paramètres pour contenu d'exemple

---

## Composants (`components/`)

### Disponibilité
-   `AbsenceForm.vue` : Formulaire de configuration d'absence (Out-of-Office)
-   `AvailabilityForm.vue` : Définition des plages horaires disponibles

### Contenu d'Exemple
-   `ExampleContactSettings.vue` : Gestion du contact d'exemple
-   `ExampleEventSettings.vue` : Gestion de l'événement d'exemple
-   `ExampleContentDownloadButton.vue` : Bouton de téléchargement

---

## Services (`service/`)

| Service | Fonction |
|---------|----------|
| `CalendarService.ts` | Opérations CRUD calendrier |
| `ExampleEventService.ts` | Gestion de l'événement d'exemple |
| `PreferenceService.ts` | Préférences utilisateur |
| `logger.ts` | Logger frontend |

---

## Utilitaires (`utils/`)
Fonctions utilitaires JavaScript/TypeScript.

## DAV (`dav/`)
Clients et utilitaires WebDAV côté frontend.
