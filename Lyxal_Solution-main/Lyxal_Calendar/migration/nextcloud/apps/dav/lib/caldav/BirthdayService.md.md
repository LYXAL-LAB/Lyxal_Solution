# Analyse du Fichier `BirthdayService.php` de Nextcloud

Ce document a pour but de décomposer et de clarifier le contenu de la classe `BirthdayService.php`. Ce service est un module automatisé qui crée et maintient un calendrier des anniversaires basé sur les informations des contacts d'un utilisateur.

---

## 1. Rôle et Responsabilités

Contrairement au `CalDavBackend`, le `BirthdayService` n'est pas une API qui répond à des requêtes directes. C'est un **service automatisé qui fonctionne en arrière-plan**. Son unique responsabilité est de **synchroniser les dates spéciales (anniversaires, dates de décès, anniversaires de mariage) des fiches de contact (`VCard`) vers un calendrier dédié et non-modifiable par l'utilisateur.**

Il est entièrement piloté par les événements du module de gestion des contacts (CardDAV).

---

## 2. Déclencheurs et Points d'Entrée

La logique du service est initiée par des événements externes, principalement liés au cycle de vie d'une fiche de contact.

- **`onCardChanged(...)`**:
  - **Déclencheur**: Une fiche de contact est **créée ou modifiée**.
  - **Action**: C'est le point d'entrée principal. Le service identifie tous les utilisateurs concernés (le propriétaire et ceux avec qui le carnet est partagé) et met à jour ou crée les événements d'anniversaire correspondants.

- **`onCardDeleted(...)`**:
  - **Déclencheur**: Une fiche de contact est **supprimée**.
  - **Action**: Le service identifie les utilisateurs concernés et supprime les événements d'anniversaire qui étaient liés à cette fiche.

- **`syncUser(string $user)` et `resetForUser(string $user)`**:
  - **Déclencheur**: Actions administratives (ex: via une commande `occ`).
  - **Action**: `syncUser` force une resynchronisation complète pour un utilisateur. `resetForUser` efface complètement le calendrier d'anniversaires.

---

## 3. Logique Métier Principale
Le cœur du service réside dans sa capacité à transformer les données d'un contact en un événement de calendrier.

- **`ensureCalendarExists(string $principal)`**:
  - **Rôle**: Vérifie si l'utilisateur possède déjà le calendrier spécial "Anniversaires des contacts".
  - **Action**: Si non, elle utilise le `CalDavBackend` pour le créer avec des propriétés par défaut.

- **`buildDateFromContact(string $cardData, ...)`**: **La fonction la plus importante du service.**
  - **Rôle**: C'est le "moteur de conversion" qui prend les données brutes d'une `VCard`.
  - **Actions**:
    1.  Analyse la `VCard`.
    2.  Recherche les champs de date (`BDAY`, `DEATHDATE`, `ANNIVERSARY`).
    3.  Si une date est trouvée, elle construit un objet `VCalendar` complet avec toutes les propriétés requises :
        -   `DTSTART` / `DTEND`: Dates de début/fin.
        -   `RRULE`: Une règle de récurrence annuelle (`FREQ=YEARLY`).
        -   `SUMMARY`: Le titre de l'événement (ex: "🎂 Anniversaire de Jean Dupont").
        -   `UID`: Un identifiant unique.
        -   `VALARM`: Une alarme si configurée.
  - **Retour**: Un objet `VCalendar` prêt à être inséré, ou `null`.

---

## 4. Dépendances Clés

- **`CalDavBackend`**: Pour créer le calendrier et les événements.
- **`CardDavBackend`**: Pour récupérer les informations sur les carnets d'adresses et les contacts.
- **`IConfig`**: Pour vérifier si la fonctionnalité est activée.
- **`IL10N`**: Pour la traduction du nom du calendrier ("Anniversaires des contacts").
