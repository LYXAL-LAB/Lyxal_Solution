# Lyxal Bridge : Système d'Intégrations Sortantes (Outbound)

## 1. Vision et Concept
Le **Lyxal Bridge** est le module de "sortie" (outbound) de la Lyxal Solution. Contrairement à une base de données passive qui attend des requêtes, Lyxal Bridge permet au moteur de devenir un agent actif capable d'interagir nativement avec le Web et des services tiers (APIs, Webhooks, Cloud Services) sans dépendre d'outils externes comme n8n ou Zapier.

L'objectif est d'intégrer la puissance des connecteurs n8n directement au cœur du runtime Rust de SurrealDB (Lyxal Fork).

## 2. Architecture Technique

### Emplacement suggéré
`surrealdb/core/src/bridge/`

### Structure des composants
- **`bridge/mod.rs`** : Orchestrateur central et gestionnaire de flux.
- **`bridge/transport/`** : Couche réseau haute performance (basée sur `lyxal_net` et `reqwest`). Gère les retries, le streaming et les timeouts.
- **`bridge/auth/`** : Gestionnaire sécurisé des secrets (OAuth2, API Keys, Bearer Tokens) avec chiffrement au repos.
- **`bridge/catalog/`** : Bibliothèque de connecteurs natifs (ex: `slack.rs`, `github.rs`, `stripe.rs`).
- **`bridge/engine/`** : Logique de transformation des données (Mapping JSON/CBOR vers formats propriétaires).

## 3. Capacités Clés

### A. Connecteurs Natifs (Catalog)
Chaque connecteur est implémenté en Rust pur pour une vitesse maximale :
- **Communication Directe** : Pas de couche d'abstraction JS lente.
- **Validation Typée** : Vérification des schémas de données avant l'envoi.
- **Auto-découverte** : Capacité pour l'IA d'ajouter de nouveaux connecteurs en suivant un template standardisé.

### B. Gestion des Erreurs et Résilience
- **Retry Policy** : Stratégies d'exponentiel backoff paramétrables.
- **Queueing** : En cas d'échec critique, les messages sont mis en attente et gérés par le `lyxal_scheduler`.
- **Logging** : Traçabilité complète des appels sortants directement dans les logs système.

### C. Sécurité "Zero-Trust"
- Les clés d'API ne sont jamais exposées dans les logs ou via le SDK.
- Isolation des processus de transport pour éviter les fuites de mémoire ou les injections.

## 4. Intégration SurrealQL (Syntaxe Étendue)

Le Bridge permet d'utiliser des commandes natives simplifiées au sein de la base de données :

```sql
-- Exemple d'utilisation dans un Event ou une Function
DEFINE EVENT order_placed ON TABLE orders WHEN $event = 'CREATE' THEN {
    -- Appel au bridge avec le connecteur Slack
    SEND TO bridge::slack {
        channel: 'sales-notifications',
        message: 'Nouvelle commande ! ID: ' + $after.id,
        auth: 'lyxal_slack_token'
    };
};
```

## 5. Synergie avec l'Écosystème Lyxal

| Module | Interaction avec Lyxal Bridge |
| :--- | :--- |
| **Lyxal Scheduler** | Permet de différer des appels API ou de planifier des synchronisations massives. |
| **Lyxal API** | Reçoit les webhooks de retour (Inbound) pour fermer la boucle de communication. |
| **Lyxal SDK** | Permet de configurer les connecteurs et de monitorer l'état du Bridge depuis le frontend. |
| **Lyxal Dav** | Permet d'envoyer des fichiers stockés localement vers des Clouds tiers (S3, Drive). |

## 6. Roadmap d'Implémentation

### Phase 1 : Fondations (Core Bridge)
- Mise en place du `Transport Layer`.
- Création du système de gestion des `Credentials` sécurisés.
- Support du connecteur générique `Webhook/HTTP`.

### Phase 2 : Catalog Initial
- Implémentation des connecteurs critiques : Slack, Discord, Email (SMTP/Sendgrid).
- Intégration de la syntaxe `SEND TO` dans l'analyseur de requêtes (Parser).

### Phase 3 : Intelligence & Automatisation
- Support OAuth2 complet avec rafraîchissement automatique des tokens.
- Système de monitoring des intégrations via le `Lyxal Admin`.

---
*Ce document fait partie de la documentation technique de Lyxal Solution.*