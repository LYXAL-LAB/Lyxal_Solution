# Analyse du Fichier `CalendarObject.php` de Nextcloud

Ce document décompose le contenu de la classe `CalendarObject.php`. Cette classe est la représentation DAV d'un unique objet calendrier (événement, tâche) appartenant à un calendrier standard (non-abonnement).

---

## 1. Rôle et Responsabilités

La classe `CalendarObject` représente un événement ou une tâche dans l'arborescence DAV. Elle hérite de `\Sabre\CalDAV\CalendarObject`.

Sa responsabilité principale n'est pas seulement de servir les données brutes de l'événement, mais aussi d'appliquer une **logique de confidentialité et de filtrage** lorsque l'événement est accédé via un calendrier partagé. Elle s'assure que les informations sensibles ne sont pas exposées à des utilisateurs qui n'ont que des droits de lecture limités.

---

## 2. Fonctions Publiques et Logique de Filtrage

- **`get()`**: **La méthode la plus importante de la classe.**
  - **Rôle**: Récupérer les données iCalendar brutes de l'événement.
  - **Action**: Au lieu de simplement retourner les données, elle applique une série de filtres si le calendrier parent est partagé (`isShared()` est vrai) :
    1.  **Suppression des alarmes**: Si le calendrier est partagé en lecture seule (`!canWrite()`), la méthode parcourt l'objet iCalendar et en **retire toutes les alarmes (`VALARM`)**.
    2.  **Anonymisation des événements confidentiels**: Si l'événement est marqué comme "confidentiel" (`CLASSIFICATION_CONFIDENTIAL`), la méthode **masque les détails**. Elle remplace le titre (`SUMMARY`) par "Occupé" (`Busy`) et supprime la plupart des autres propriétés (description, participants, lieu, etc.), ne laissant que les informations temporelles.

---

## 3. Logique Interne et Dépendances

- **Méthodes de vérification (`isShared()`, `canWrite()`, `isPublic()`)**:
  - **Rôle**: Fonctions utilitaires internes pour déterminer le contexte d'accès : le calendrier est-il partagé ? L'utilisateur actuel a-t-il les droits d'écriture ? Est-il accessible publiquement ?
  - **Action**: Lisent les propriétés correspondantes depuis le tableau `$calendarInfo` du calendrier parent.

- **Méthodes de transformation (`createConfidentialObject(...)`, `removeVAlarms(...)`)**:
  - **Rôle**: Fonctions privées contenant la logique de modification de l'objet iCalendar pour le filtrage et l'anonymisation.

---

## Conclusion

`CalendarObject` est plus qu'un simple conteneur de données. C'est une classe qui applique des **règles métier critiques liées à la confidentialité** dans un contexte de partage. En agissant comme un filtre intelligent au moment de la lecture des données, elle garantit que les informations sensibles d'un utilisateur ne sont pas divulguées involontairement lorsque ses calendriers sont partagés.
