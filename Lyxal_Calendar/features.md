# Fonctionnalités complètes de Cal.com

## 🗓️ Gestion de Calendrier (Core)

### Event Types (Types d'événements)
- Création d'événements personnalisés (durée, nom, description)
- URL personnalisée (`username/event-slug`)
- Prix et paiements optionnels
- Capacité multi-créneaux (seats)
- Buffers avant/après événements
- Périodes de disponibilité (dates début/fin)
- Durées minimales de préavis (minimum booking notice)
- Liens secrets (hashed links) pour accès privés
- Événements récurrents

### Disponibilités (Availability)
- Créneaux horaires personnalisés par jour
- Schedules multiples (travail, personnel, etc.)
- Gestion des fuseaux horaires
- Overrides de disponibilité (dates spécifiques)
- Out-of-office (OOO) avec redirection vers collègue

### Bookings (Réservations)
- Réservation de créneaux
- Annulation/Reprogrammation
- Participants multiples
- Formulaires personnalisés (custom inputs)
- Notes internes
- Statuts : PENDING, ACCEPTED, REJECTED, CANCELLED, AWAITING_HOST
- No-show tracking (host/guest)
- Ratings et feedback

## 👥 Multi-utilisateurs & Teams

### Organisations
- Hiérarchie d'organisations (parent/child)
- Sous-équipes
- Profils par organisation
- Branding personnalisé (logo, couleurs)
- Domaines personnalisés

### Membres & Rôles
- Rôles : OWNER, ADMIN, MEMBER
- Système de permissions (RBAC avec `Role` et `RolePermission`)
- Attributs d'utilisateurs (custom attributes)
- Invitations d'équipe

### Round Robin & Assignment
- Attribution automatique de réservations
- Pondération (weights) pour distribution
- Raisons d'attribution (routing form, salesforce, etc.)

## 📧 Workflows & Automation

### Workflows
- Déclencheurs : BEFORE_EVENT, AFTER_EVENT, NEW_EVENT, CANCELLED, etc.
- Actions : EMAIL_HOST, EMAIL_ATTENDEE, SMS, WHATSAPP, CAL_AI_PHONE_CALL
- Templates de messages
- Reminders automatiques
- Délais configurables (X minutes/heures/jours avant/après)

### Routing Forms
- Formulaires de qualification
- Routage conditionnel vers différents event types
- Champs personnalisés
- Logique métier (si réponse X → event type Y)
- Intégration avec workflows

### Webhooks
- Événements : BOOKING_CREATED, CANCELLED, RESCHEDULED, etc.
- URL personnalisée par webhook
- Payload templates
- Retry automatique

## 🎥 Intégrations Vidéo

- Liens de réunion automatiques (Zoom, Meet, Teams, etc.)
- Vidéo embarquée (Daily.co)
- Enregistrements de réunion
- Transcriptions IA
- Détection de no-show vidéo

## 💳 Paiements

- Stripe, PayPal, etc.
- Prix par event type
- Paiement à la réservation ou HOLD
- Remboursements
- Multi-devises

## 📊 CRM & Sales

- Push de contacts vers Salesforce, HubSpot, etc.
- Création automatique de leads
- Mapping de champs personnalisés
- Incomplete booking actions (Salesforce flow)

## 🔐 Auth & Sécurité

- NextAuth.js (OAuth, Email, Credentials)
- 2FA/OTP
- Impersonation (admin)
- API Keys avec rate limiting
- SSO (SAML via BoxyHQ)
- Watchlist (blocage email/domaine)

## 📈 Analytics & Tracking

- Insights de réservations
- No-show rates
- Conversion tracking
- UTM tracking
- Intégrations : GA4, PostHog, Fathom, etc.

## 🌐 Embed & Distribution

- Widget JavaScript embarquable
- Modes : inline, popup, modal
- React component (`@calcom/embed-react`)
- API v2 (Platform API)

## 🤖 IA & Automatisation

### Cal.ai
- Agents vocaux (Retell AI)
- Appels sortants automatiques
- Numéros de téléphone virtuels
- Conversation IA

### Auto-check-in
- Confirmation automatique de présence

## 🌍 Internationalisation

- Support multi-langues (28 langues)
- Traductions auto des event types
- Locales par utilisateur

## 🔔 Notifications

- Email (Nodemailer, Sendgrid)
- SMS (Twilio-like)
- WhatsApp
- In-app notifications

## 📱 Platform API (v2)

- OAuth clients
- CRUD event types, bookings
- Gestion d'organisations
- Webhooks platform

## 🛡️ Enterprise Features (EE)

- SAML SSO
- Directory Sync (DSync)
- Domain-wide delegation (Google Workspace)
- Managed organizations
- Platform billing
- Advanced RBAC
- Audit logs (BookingAudit)

## 📅 Autres Features

- QR codes pour événements
- iCal feeds
- Signature emails
- Booking reports (spam detection)
- Tasks background (Tasker)
- Feature flags
- Cache calendrier
- Deployment settings (logo, theme global)
