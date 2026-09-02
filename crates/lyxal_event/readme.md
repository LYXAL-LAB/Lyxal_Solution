Lyxal Event --- Concept d'Architecture

Objectif

lyxal_event est le moteur d'événements interne de Lyxal OS.

Son rôle n'est pas de remplacer SurrealDB ni les modules métiers,mais de servir de point de communication entre tous les modules dusystème.

Le principe est simple :

un module métier publie un événement ;

les autres modules décident librement de le consommer ;

le module émetteur ne connaît jamais les modules consommateurs.

Cette approche réduit fortement le couplage entre les modules.

Philosophie

Au lieu d'avoir :

Booking → Notification → Scheduler → CRM → Webhook

Chaque module publie uniquement un événement.

Booking
    │
    ▼
Lyxal Event
    │
    ├── Notification
    ├── Scheduler
    ├── CRM
    ├── Analytics
    ├── Webhook
    └── IA

Ainsi, Booking ne dépend d'aucun de ces moteurs.

Utilisation de DEFINE EVENT

Les événements SurrealDB servent à détecter les changements de données.

Exemple :

CREATE booking CONTENT { ... };

Puis :

DEFINE EVENT booking_created
ON TABLE booking
WHEN $event = "CREATE"
THEN (
    CREATE event_outbox CONTENT {
        module: "booking",
        event: "booking.created",
        source: $value.id,
        created_at: time::now()
    };
);

Le rôle du DEFINE EVENT est de publier un événement interne de manièreautomatique.

Ce qui doit être fait dans DEFINE EVENT

Les traitements doivent être :

rapides ;

atomiques ;

directement liés à la transaction.

Exemples :

créer une entrée d'audit ;

créer une activité métier ;

incrémenter un compteur ;

publier un événement dans event_outbox.

Ce qui ne doit pas être fait dans DEFINE EVENT

À éviter :

appels HTTP ;

envoi d'e-mails ;

synchronisation CalDAV ;

appels OAuth ;

traitements IA ;

calculs longs.

Ces opérations doivent être exécutées par des workers.

Event Outbox

Le moteur s'appuie sur une table technique :

event_outbox

Exemple de contenu :

{
  "module": "booking",
  "event": "booking.created",
  "source": "booking:abc123",
  "payload": {
    "booking_id": "booking:abc123"
  },
  "status": "pending"
}

Les workers lisent cette table et exécutent les traitements nécessaires.

Modules producteurs

Tous les modules Lyxal peuvent publier des événements :

lyxal_booking

lyxal_crm

lyxal_scheduler

lyxal_notification

lyxal_documents

lyxal_storage

etc.

Modules consommateurs

Un même événement peut être traité par plusieurs moteurs.

Exemple :

booking.created
        │
        ├── Notification
        ├── Scheduler
        ├── CRM
        ├── Analytics
        ├── Webhook
        └── IA

Aucun consommateur n'est connu du producteur.

Exemple de flux

Utilisateur crée une réservation
            │
            ▼
CREATE booking
            │
            ▼
DEFINE EVENT
            │
            ▼
event_outbox
            │
            ▼
Worker Lyxal Event
            │
            ├── Notification
            ├── Scheduler
            ├── CRM
            ├── Webhook
            └── Analytics

Avantages

Architecture découplée.

Modules indépendants.

Réutilisation des moteurs.

Évolutivité.

Journalisation centralisée.

Possibilité de rejouer des événements.

Ajout d'un nouveau module sans modifier les modules existants.

Position dans Lyxal OS

Modules métiers
    │
    ├── Booking
    ├── CRM
    ├── Facturation
    ├── Documents
    └── ...

            │
            ▼

      Lyxal Event

            │

    ├── Notification
    ├── Scheduler
    ├── Webhook
    ├── Analytics
    ├── IA
    └── autres moteurs

Principe fondamental

Les modules métiers ne communiquent jamais directement entre eux.

Ils publient des événements.

Les moteurs techniques décident quoi faire avec ces événements.

Cette architecture permet à Lyxal OS de rester modulaire, extensible etindépendant de chaque implémentation métier.