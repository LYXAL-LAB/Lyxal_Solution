# 📑 Spécification Complète des APIs — Lyxal Booking

Ce document contient l'inventaire exhaustif et la spécification de toutes les routes et endpoints HTTP du module **Lyxal Booking**.

---

## 📄 Sommaire
1. [Authentification & Sessions (`/auth`)](#1-authentification--sessions-auth)
2. [Types d'Événements & Prestations (`/dashboard/event-types`)](#2-types-dévénements--prestations-dashboardevent-types)
3. [Disponibilités & Surcharges (`/dashboard/availability`)](#3-disponibilités--surcharges-dashboardavailability)
4. [Gestion des Réservations Hôte (`/dashboard/bookings`)](#4-gestion-des-réservations-hôte-dashboardbookings)
5. [Équipes & Rendez-vous Collectifs (`/dashboard/teams`)](#5-équipes--rendez-vous-collectifs-dashboardteams)
6. [Invitations Privées & Liens Éphémères (`/dashboard/invites`)](#6-invitations-privées--liens-éphémères-dashboardinvites)
7. [Synchronisation Calendriers Externes (`/dashboard/sources`)](#7-synchronisation-calendriers-externes-dashboardsources)
8. [Réservation Publique Invité / Client](#8-réservation-publique-invité--client)
9. [Administration & Paramètres Globaux (`/dashboard/admin`)](#9-administration--paramètres-globaux-dashboardadmin)

---

## 1. 🔐 Authentification & Sessions (`/auth`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/auth/login` | Affiche le formulaire de connexion hôte. |
| `POST` | `/auth/login` | Valide les identifiants (email, mot de passe) et initialise la session. |
| `GET` | `/auth/register` | Affiche le formulaire de création de compte hôte. |
| `POST` | `/auth/register` | Enregistre un nouvel utilisateur hôte dans le système. |
| `POST` | `/auth/logout` | Détruit le jeton de session courant et déconnecte l'utilisateur. |
| `GET` | `/auth/oidc/login` | Inicie la redirection vers le fournisseur Single Sign-On (SSO / OIDC). |
| `GET` | `/auth/oidc/callback` | Réceptionne le jeton d'authentification OIDC et connecte l'utilisateur. |

---

## 2. 📆 Types d'Événements & Prestations (`/dashboard/event-types`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/event-types` | Liste tous les types de RDV configurés par l'hôte. |
| `GET` | `/dashboard/event-types/new` | Affiche le formulaire de création de type d'événement. |
| `POST` | `/dashboard/event-types/new` | Enregistre un nouveau type de RDV (titre, slug, durée, buffers, lieu). |
| `GET` | `/dashboard/event-types/{slug}/edit` | Affiche le formulaire de modification d'un type d'événement. |
| `POST` | `/dashboard/event-types/{slug}/edit` | Met à jour les paramètres d'un type d'événement. |
| `POST` | `/dashboard/event-types/{slug}/toggle` | Active ou désactive la prise de RDV sur le lien correspondant. |
| `POST` | `/dashboard/event-types/{slug}/delete` | Supprime définitivement un type d'événement. |
| `POST` | `/dashboard/event-types/{slug}/priority/{user_id}` | Ajuste la priorité d'attribution d'un membre pour ce type de RDV. |
| `GET` | `/dashboard/event-types/{slug}/embed` | Génère le code d'intégration iFrame / Widget pour site web. |

---

## 3. 🗓️ Disponibilités & Surcharges (`/dashboard/availability`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/availability/default` | Affiche les plages de disponibilité hebdomadaires récurrentes. |
| `GET` | `/dashboard/event-types/{slug}/overrides` | Liste les dates d'exception et blocages spécifiques. |
| `POST` | `/dashboard/event-types/{slug}/overrides` | Ajoute une exception horaire ou un blocage de date. |
| `POST` | `/dashboard/event-types/{slug}/overrides/{override_id}/delete` | Supprime une date d'exception configurée. |

---

## 4. 📅 Gestion des Réservations Hôte (`/dashboard/bookings`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/bookings` | Liste les réservations (à venir, passées, annulées, en attente). |
| `POST` | `/dashboard/bookings/{id}/confirm` | Approuve manuellement une demande de réservation en attente. |
| `POST` | `/dashboard/bookings/{id}/cancel` | Annule une réservation existante et notifie l'invité par e-mail. |
| `GET` | `/dashboard/bookings/{id}/reschedule` | Formulaire de sélection d'une nouvelle date par l'hôte. |
| `POST` | `/dashboard/bookings/{id}/reschedule` | Valide la reprogrammation du rendez-vous par l'hôte. |

---

## 5. 👥 Équipes & Rendez-vous Collectifs (`/dashboard/teams`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/teams` | Liste les équipes dont l'hôte fait partie. |
| `GET` | `/dashboard/teams/new` | Affiche le formulaire de création d'une nouvelle équipe. |
| `POST` | `/dashboard/teams/new` | Enregistre une nouvelle équipe (nom, slug, description). |
| `GET` | `/dashboard/teams/{team_id}/settings` | Configuration et liste des membres de l'équipe. |
| `POST` | `/dashboard/teams/{team_id}/settings` | Met à jour les membres et leurs rôles dans l'équipe. |
| `POST` | `/dashboard/teams/{team_id}/avatar` | Téléverse le logo ou l'image de l'équipe. |
| `POST` | `/dashboard/teams/{team_id}/avatar/delete` | Supprime l'image de l'équipe. |
| `POST` | `/dashboard/teams/{team_id}/delete` | Supprime définitivement l'équipe. |
| `GET` | `/dashboard/group-event-types/new` | Formulaire de création d'un type de RDV d'équipe (Round-Robin). |
| `POST` | `/dashboard/group-event-types/new` | Enregistre un type de RDV d'équipe. |
| `GET` | `/dashboard/group-event-types/{team_id}/{slug}/edit` | Formulaire d'édition de type de RDV d'équipe. |
| `POST` | `/dashboard/group-event-types/{team_id}/{slug}/edit` | Met à jour un type de RDV d'équipe. |
| `POST` | `/dashboard/group-event-types/{team_id}/{slug}/toggle` | Activer/Désactiver un type de RDV d'équipe. |
| `POST` | `/dashboard/group-event-types/{team_id}/{slug}/delete` | Supprime un type de RDV d'équipe. |

---

## 6. 📩 Invitations Privées & Liens Éphémères (`/dashboard/invites`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/invites/{event_type_id}` | Liste les invitations privées générées pour un type de RDV. |
| `POST` | `/dashboard/invites/{event_type_id}/send` | Envoie des invitations personnalisées par e-mail à une liste d'invités. |
| `POST` | `/dashboard/invites/{event_type_id}/quick-link` | Génère un lien de réservation éphémère à usage unique. |
| `POST` | `/dashboard/invites/{invite_id}/delete` | Révoque et supprime une invitation privée. |

---

## 7. 🔄 Synchronisation Calendriers Externes (`/dashboard/sources`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/sources` | Liste les calendriers externes connectés (CalDAV, Google, EWS). |
| `GET` | `/dashboard/sources/new` | Formulaire de connexion d'un serveur CalDAV ou EWS. |
| `POST` | `/dashboard/sources/new` | Enregistre les identifiants d'un serveur de calendrier externe. |
| `GET` | `/dashboard/sources/{id}/edit` | Affiche les paramètres de la source de calendrier. |
| `POST` | `/dashboard/sources/{id}/edit` | Met à jour les paramètres de la source. |
| `POST` | `/dashboard/sources/{id}/remove` | Déconnecte et supprime une source de calendrier. |
| `POST` | `/dashboard/sources/{id}/test` | Exécute un test de connexion au serveur distant. |
| `POST` | `/dashboard/sources/{id}/sync` | Déclenche une synchronisation incrémentale. |
| `POST` | `/dashboard/sources/{id}/force-sync` | Force la resynchronisation complète de l'agenda. |
| `GET` | `/dashboard/sources/google/connect` | Redirige vers le flux OAuth2 de Google Calendar. |
| `GET` | `/dashboard/sources/google/callback` | Reçoit le code OAuth2 et enregistre les jetons de synchronisation. |
| `GET` | `/dashboard/sources/{id}/setup-write` | Affiche les calendriers de destination disponibles. |
| `POST` | `/dashboard/sources/{id}/write-calendar` | Définit le calendrier dans lequel les nouveaux RDV sont écrits. |

---

## 8. 🌐 Réservation Publique (Invité / Client)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/u/{username}` | Page de profil public de l'hôte avec la liste des types de RDV. |
| `GET` | `/u/{username}/{slug}` | Affiche le calendrier interactif et les créneaux libres. |
| `GET` | `/u/{username}/{slug}/book` | Formulaire de saisie des coordonnées du client. |
| `POST` | `/u/{username}/{slug}/book` | Valide la réservation et envoie les confirmations iCal. |
| `GET` | `/team/{team_slug}` | Page publique de présentation d'une équipe. |
| `GET` | `/team/{team_slug}/{slug}` | Sélection de créneau pour un rendez-vous d'équipe. |
| `GET` | `/team/{team_slug}/{slug}/book` | Formulaire de réservation d'équipe. |
| `POST` | `/team/{team_slug}/{slug}/book` | Valide la réservation distribuée en Round-Robin. |
| `GET` | `/booking/cancel/{token}` | Formulaire d'annulation d'un RDV par le client. |
| `POST` | `/booking/cancel/{token}` | Confirme l'annulation par le client via jeton unique. |
| `GET` | `/booking/reschedule/{token}` | Sélection d'une nouvelle date de RDV par le client. |
| `POST` | `/booking/reschedule/{token}` | Valide la reprogrammation du RDV par le client. |
| `GET` | `/booking/approve/{token}` | Lien d'approbation rapide d'un RDV par l'hôte. |
| `GET` | `/booking/decline/{token}` | Lien de refus rapide d'un RDV par l'hôte. |
| `GET` | `/booking/claim/{booking_id}` | Formulaire de réclamation ou rattachement d'un RDV à un compte. |

---

## 9. ⚙️ Administration & Paramètres Globaux (`/dashboard/admin`)

| Méthode | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/dashboard/settings` | Paramètres du profil hôte (nom, bio, langue, timezone). |
| `POST` | `/dashboard/settings` | Enregistre les modifications du profil hôte. |
| `POST` | `/dashboard/settings/timezone` | Met à jour le fuseau horaire par défaut de l'hôte. |
| `POST` | `/dashboard/settings/avatar` | Téléverse la photo de profil de l'hôte. |
| `POST` | `/dashboard/settings/avatar/delete` | Supprime la photo de profil. |
| `GET` | `/dashboard/admin` | Tableau de bord d'administration globale du serveur. |
| `POST` | `/dashboard/admin/users/{id}/toggle-role` | Change les privilèges d'un utilisateur (`admin` / `user`). |
| `POST` | `/dashboard/admin/users/{id}/toggle-enabled` | Active ou suspend un compte d'utilisateur. |
| `POST` | `/dashboard/admin/users/{id}/delete` | Supprime définitivement un compte utilisateur. |
| `POST` | `/dashboard/admin/auth` | Définit la politique d'inscription et de sécurité. |
| `POST` | `/dashboard/admin/smtp` | Configuration du serveur d'envoi d'e-mails SMTP. |
| `POST` | `/dashboard/admin/smtp/test` | Envoie un e-mail de test pour vérifier la configuration SMTP. |
| `POST` | `/dashboard/admin/smtp/clear` | Efface les paramètres SMTP enregistrés. |
| `POST` | `/dashboard/admin/jitsi` | Configure l'intégration du serveur de visioconférence Jitsi Meet. |
| `POST` | `/dashboard/admin/meeting-webhook` | Configure l'URL Webhook déclenchée à la réservation. |
| `POST` | `/dashboard/admin/resources` | Crée une ressource réservable (ex: Salle de réunion). |
| `POST` | `/dashboard/admin/resources/{id}` | Met à jour les propriétés d'une ressource. |
| `POST` | `/dashboard/admin/resources/{id}/delete` | Supprime une ressource réservable. |
| `POST` | `/dashboard/admin/impersonate/{id}` | Permet à un administrateur d'usurper temporairement un compte. |
| `POST` | `/dashboard/admin/stop-impersonate` | Arrête l'usurpation et réintégre la session administrateur. |
