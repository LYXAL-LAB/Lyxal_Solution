# Schéma SurrealDB Officiel V1 - Lyxal Booking (25 Tables)

Ce dossier contient la définition officielle, typée (`SCHEMAFULL` / `TYPE RELATION`) des **25 tables cœur** du schéma SurrealDB pour la solution **Lyxal Booking**.

## 📄 Documentation Officielle Figée V1

La documentation complète décrivant les 25 tables, leurs champs, types, contraintes, permissions `$auth` et le diagramme d'architecture ERD est disponible ici :

👉 **[SCHEMA_DOCUMENTATION.md](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/SCHEMA_DOCUMENTATION.md)**

## 📂 Index des 25 Fichiers Schema Cœur

| Fichier `.surql` | Table SurrealDB | Rôle & Description |
| :--- | :--- | :--- |
| [booking_account.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_account.surql) | `booking_account` | Profils hôtes et utilisateurs |
| [booking_team.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_team.surql) | `booking_team` | Équipes et organisations collectives |
| [booking_team_member.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_team_member.surql) | `booking_team_member` | **Graph** Appartenance équipe et poids Round-Robin |
| [booking_team_invite.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_team_invite.surql) | `booking_team_invite` | Invitations e-mail à rejoindre une équipe |
| [booking_schedule.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_schedule.surql) | `booking_schedule` | Plannings d'horaires réutilisables |
| [booking_schedule_rule.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_schedule_rule.surql) | `booking_schedule_rule` | Plages hebdomadaires récurrentes du planning |
| [booking_schedule_override.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_schedule_override.surql) | `booking_schedule_override` | Exceptions et surcharges de dates par planning |
| [booking_time_off.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_time_off.surql) | `booking_time_off` | Congés et absences globales des hôtes |
| [booking_event_type.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_event_type.surql) | `booking_event_type` | Liens publics (Propriété exclusive `account XOR team` + `schedule`) |
| [booking_frequency_limit.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_frequency_limit.surql) | `booking_frequency_limit` | Quotas de réservations par période |
| [booking_invite.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_invite.surql) | `booking_invite` | Invitations éphémères et liens à usage unique |
| [booking_watcher.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_watcher.surql) | `booking_watcher` | E-mails notifiés en copie |
| [booking_question.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_question.surql) | `booking_question` | Questions sur-mesure du formulaire de RDV |
| [booking_answer.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_answer.surql) | `booking_answer` | Réponses fournies lors de la réservation |
| [booking.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking.surql) | `booking` | Prises de rendez-vous (avec `host` & `assignment_method`) |
| [booking_host.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_host.surql) | `booking_host` | **Graph** Attribution des hôtes principaux et co-hôtes |
| [booking_attendee.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_attendee.surql) | `booking_attendee` | Participants additionnels |
| [booking_activity.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_activity.surql) | `booking_activity` | **Journal immuable Append-Only** des activités |
| [booking_caldav_source.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_caldav_source.surql) | `booking_caldav_source` | Sources distantes (CalDAV, Google, EWS, iCloud) |
| [booking_calendar.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_calendar.surql) | `booking_calendar` | Calendriers distants synchronisés |
| [booking_event.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_event.surql) | `booking_event` | Événements distants bloquant l'agenda |
| [booking_sync_log.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_sync_log.surql) | `booking_sync_log` | Journal et diagnostic des synchronisations distantes |
| [booking_resource.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_resource.surql) | `booking_resource` | Salles et matériels réservables |
| [booking_resource_allocation.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_resource_allocation.surql) | `booking_resource_allocation` | **Graph** Affectation des ressources aux RDV |
| [booking_setting.surql](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/schema/booking_setting.surql) | `booking_setting` | Paramètres système globaux et SMTP |

## 📁 Dossier Hérité de Migration

Les 2 tables héritées sont isolées sous `schema/legacy/` :
- `schema/legacy/booking_availability_rule.surql`
- `schema/legacy/booking_availability_override.surql`
