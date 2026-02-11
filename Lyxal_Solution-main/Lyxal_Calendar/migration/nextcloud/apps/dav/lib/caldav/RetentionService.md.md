# Analyse du Fichier `RetentionService.php` de Nextcloud

Ce document décompose le contenu de la classe `RetentionService.php`. Il s'agit d'un service de maintenance chargé de la suppression définitive des éléments mis à la corbeille.

---

## 1. Rôle et Responsabilités

La classe `RetentionService` est un **service de nettoyage automatisé**. Sa seule responsabilité est de gérer le cycle de vie des calendriers et des événements qui ont été "soft-deleted" (mis à la corbeille).

Il est conçu pour être déclenché périodiquement par une tâche de fond (cron job). Sa mission est d'appliquer la politique de rétention des données définie par l'administrateur en **supprimant définitivement** les éléments qui sont restés dans la corbeille au-delà d'une certaine durée.

---

## 2. Logique de la Classe

### Configuration
- **`RETENTION_CONFIG_KEY`**: Définit la clé (`calendarRetentionObligation`) utilisée dans la configuration de Nextcloud pour stocker la durée de rétention.
- **`DEFAULT_RETENTION_SECONDS`**: Une valeur par défaut de 30 jours, utilisée si aucune configuration spécifique n'est trouvée.

### Fonctions Publiques
- **`getDuration()`**:
  - **Rôle**: Récupérer la durée de rétention configurée en secondes.
  - **Action**: Lit la valeur depuis la configuration de l'application via le `IConfig` service. Elle s'assure également que la valeur retournée n'est jamais négative pour éviter des suppressions accidentelles.

- **`cleanUp()`**:
  - **Rôle**: C'est la méthode principale qui exécute le processus de nettoyage.
  - **Logique d'exécution**:
    1.  Récupère la durée de rétention via `getDuration()`.
    2.  Calcule un timestamp "limite" (`$now - $retentionTime`). Tout élément supprimé avant ce timestamp doit être purgé.
    3.  Appelle `calDavBackend->getDeletedCalendars(...)` en lui passant ce timestamp pour obtenir la liste de tous les calendriers qui sont dans la corbeille depuis assez longtemps.
    4.  Boucle sur cette liste et appelle `calDavBackend->deleteCalendar($id, true)` pour chaque calendrier, le `true` indiquant une suppression forcée (hard delete).
    5.  Fait de même pour les objets de calendrier (événements/tâches) en appelant `calDavBackend->getDeletedCalendarObjects(...)` et `calDavBackend->deleteCalendarObject(..., true)`.

---

## 3. Dépendances

- **`IConfig $config`**: Le service de configuration pour lire la durée de rétention.
- **`ITimeFactory $time`**: Un service pour obtenir l'heure actuelle de manière testable.
- **`CalDavBackend $calDavBackend`**: Le service de bas niveau pour interagir avec la base de données afin de récupérer et de supprimer les éléments.

---

## Conclusion

`RetentionService` est un service de maintenance essentiel pour la gestion du stockage et le respect des politiques de données. En s'exécutant en arrière-plan, il automatise le processus de purge de la corbeille, évitant ainsi que les données supprimées ne s'accumulent indéfiniment. C'est un composant typique d'une application robuste qui gère le cycle de vie complet des données de ses utilisateurs.
