# 🏗️ Architecture Lyxal Mail (Cloud-Native)

## Vue d'Ensemble

Lyxal Mail est conçu selon le principe **95% SurrealDB Cloud / 5% Worker Bunny**. Cette architecture Cloud-Native maximise l'utilisation de SurrealDB Cloud pour toute la logique métier, en ne déléguant au worker Bunny Container que la tâche technique d'envoi SMTP.

**0 serveur à gérer. 100% Cloud.**

---

## 🔄 Flux Complet d'Envoi d'Email

```
┌─────────────────────────────────────────────────────────────────┐
│ ÉTAPE 1 : APPLICATION CLIENTE                                   │
│ (Frontend React via Bunny CDN ou Fonction SurrealDB)            │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ↓ fn::send_email() (WebSocket WSS)
┌─────────────────────────────────────────────────────────────────┐
│ ÉTAPE 2 : SURREALDB CLOUD - Fonction d'Enqueue                 │
│                                                                  │
│  1. Récupère le template depuis email_template                  │
│  2. Rend le template avec variables (ML)                        │
│  3. Récupère config domaine depuis email_domain                 │
│  4. Insère dans email_queue (status: pending)                   │
│  5. Event trigger notifie le worker                             │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ↓ INSERT INTO email_queue
┌─────────────────────────────────────────────────────────────────┐
│ ÉTAPE 3 : SURREALDB CLOUD - Event Trigger                      │
│                                                                  │
│  ON INSERT email_queue WHEN status = 'pending' THEN ...         │
│  → Le worker reçoit la notification via LIVE QUERY (WSS)        │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ↓ LIVE QUERY notification (WebSocket Sécurisé)
┌─────────────────────────────────────────────────────────────────┐
│ ÉTAPE 4 : BUNNY CONTAINER - Worker Go                          │
│                                                                  │
│  1. Reçoit notification du nouvel email                         │
│  2. Récupère l'email complet depuis email_queue                 │
│  3. Récupère config SMTP + DKIM                                 │
│  4. Signe l'email avec DKIM                                     │
│  5. Ouvre connexion SMTP                                        │
│  6. Envoie l'email                                              │
│  7. UPDATE email_queue SET status = 'sent' | 'failed'           │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ↓ SMTP Protocol
┌─────────────────────────────────────────────────────────────────┐
│ ÉTAPE 5 : SERVEUR DESTINATAIRE (Gmail, Outlook, etc.)          │
│                                                                  │
│  1. Reçoit l'email via SMTP                                     │
│  2. Vérifie SPF, DKIM, DMARC                                    │
│  3. Analyse anti-spam                                           │
│  4. Délivre en boîte de réception ou spam                       │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ↓ (Optionnel) Webhooks
┌─────────────────────────────────────────────────────────────────┐
│ ÉTAPE 6 : SURREALDB CLOUD - Tracking & Analytics               │
│                                                                  │
│  • INSERT INTO email_log (événements: sent, opened, clicked)    │
│  • UPDATE email_stats (métriques agrégées)                      │
│  • Triggers pour notifications business                         │
└─────────────────────────────────────────────────────────────────┘
```

**Toute l'infrastructure est gérée** :
- ✅ SurrealDB Cloud : Base de données hautement disponible
- ✅ Bunny Container : Auto-scaling du worker
- ✅ Bunny CDN : Frontend ultra-rapide
- ✅ Cloudflare : DNS et sécurité

---

## 🎨 Diagramme de Composants

```
┌────────────────────────────────────────────────────────────────┐
│                    COUCHE CLIENT (Bunny CDN)                    │
├────────────────────────────────────────────────────────────────┤
│  • Lyxal Central (React SPA via Bunny CDN)                     │
│  • Lyxal Mobile (React Native)                                 │
│  • Assets & Fichiers (Bunny Storage)                           │
└────────────────────┬───────────────────────────────────────────┘
                     │ WebSocket Sécurisé (WSS)
                     ↓
┌────────────────────────────────────────────────────────────────┐
│                COUCHE SURREALDB CLOUD (95%)                     │
├────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ DONNÉES                                                  │  │
│  │  • email_queue         → File d'attente principale       │  │
│  │  • email_template      → Templates ML                    │  │
│  │  • email_domain        → Config multi-domaines           │  │
│  │  • email_log           → Historique événements           │  │
│  │  • email_stats         → Métriques agrégées              │  │
│  │  • email_attachment    → Pièces jointes (v2.0)           │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ LOGIQUE MÉTIER                                           │  │
│  │  • fn::send_email()           → API principale           │  │
│  │  • fn::render_template()      → Rendu ML                 │  │
│  │  • fn::retry_failed_emails()  → Resilience               │  │
│  │  • fn::get_email_stats()      → Analytics                │  │
│  │  • fn::cleanup_old_logs()     → Maintenance              │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ AUTOMATION                                               │  │
│  │  • Event: on_email_queued     → Notification worker      │  │
│  │  • Event: on_email_sent       → Update stats             │  │
│  │  • Event: on_email_failed     → Retry logic              │  │
│  │  • Cron: retry_job (5min)     → Retry automatique        │  │
│  │  • Cron: cleanup_job (1jour)  → Nettoyage logs           │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────┬───────────────────────────────────────────┘
                     │ WebSocket Sécurisé (LIVE QUERY - WSS)
                     ↓
┌────────────────────────────────────────────────────────────────┐
│            COUCHE BUNNY CONTAINER (5%)                          │
│                    Auto-Scaling Géré                            │
├────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ LYXAL MAIL WORKER (Go - ~200 lignes)                    │  │
│  │                                                          │  │
│  │  • main.go           → Point d'entrée                    │  │
│  │  • queue_listener.go → LIVE QUERY handler (WSS)          │  │
│  │  • smtp_sender.go    → Envoi SMTP                        │  │
│  │  • dkim_signer.go    → Signature DKIM                    │  │
│  │  • config.go         → Configuration Cloud               │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────┬───────────────────────────────────────────┘
                     │ SMTP (TCP:25/587/465)
                     ↓
┌────────────────────────────────────────────────────────────────┐
│                     INTERNET / SMTP SERVERS                     │
│  • Gmail (smtp.gmail.com)                                      │
│  • Outlook (smtp-mail.outlook.com)                             │
│  • Autres serveurs SMTP                                        │
└────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Sécurité & Isolation Multi-Tenant

### Namespace & Database (SurrealDB Cloud)

```
cloud.surrealdb.com (endpoint sécurisé WSS)
  └─ lyxal_solution (namespace)
      └─ main (database)
          ├─ identity         → Gestion utilisateurs
          ├─ email_*          → Système email
          ├─ company_*        → Données business
          └─ [autres tables]
```

**Sécurité** :
- ✅ Connexions WSS (WebSocket Sécurisé)
- ✅ Authentification SurrealDB native
- ✅ Backups automatiques
- ✅ Haute disponibilité

### Isolation par Domaine (White-Label)

Chaque partenaire a son propre domaine dans `email_domain` :

```surql
-- Lyxal envoie depuis lyxal.com
email_domain:lyxal_com {
  domain: "lyxal.com",
  smtp_host: "mail.lyxal.com",
  dkim_private_key: "...",
  tenant_id: "lyxal"
}

-- BatiPro envoie depuis batipro.com
email_domain:batipro_com {
  domain: "batipro.com",
  smtp_host: "mail.batipro.com",  // Peut être le même serveur physique
  dkim_private_key: "...",          // Clé différente
  tenant_id: "batipro"
}
```

**Isolation garantie** :
- Chaque email_queue a un `domain` field (record<email_domain>)
- Les stats sont séparées par domaine
- Les logs sont filtrables par tenant

---

## ⚡ Performance & Scalabilité

### LIVE QUERY : Temps Réel

Le worker écoute la queue via **LIVE QUERY** (WebSocket) :

```go
db.Live("SELECT * FROM email_queue WHERE status = 'pending'", func(email Email) {
    // Traitement immédiat dès qu'un email est inséré
})
```

**Avantages** :
- ✅ Latence < 100ms (notification instantanée)
- ✅ Pas de polling (efficace)
- ✅ Reconnexion automatique

### Scaling Horizontal

```
┌──────────────────────┐
│  SurrealDB Cloud     │
│  (Géré + Scaling)    │
└──────┬───────────────┘
       │ LIVE QUERY (WSS)
       ├──────────┬──────────┬──────────┐
       ↓          ↓          ↓          ↓
  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
  │Bunny 1 │ │Bunny 2 │ │Bunny 3 │ │Bunny N │
  └────────┘ └────────┘ └────────┘ └────────┘
    (Auto-scaling Bunny Container)
```

**Avantages Bunny Container** :
- ✅ **Auto-scaling automatique** : Bunny ajoute/retire des workers selon la charge
- ✅ **Edge deployment** : Workers proches des utilisateurs
- ✅ **0 configuration** : Pas de Load Balancer à gérer
- ✅ **Pay-as-you-go** : Paiement à l'usage réel

**Exemple** : 10 000 emails/heure
- Charge faible (8h-18h) : 1-2 workers auto
- Pic de charge : Bunny scale automatiquement à 5-10 workers
- Nuit : Scale down à 0-1 worker (économies)

---

## 🔄 Gestion des Erreurs & Retry

### Stratégie de Retry Exponentiel

```
Tentative 1 : Immédiat
           ↓ (échec)
Tentative 2 : +5 minutes
           ↓ (échec)
Tentative 3 : +30 minutes
           ↓ (échec)
Tentative 4 : +2 heures
           ↓ (échec)
Status : failed (alerte admin)
```

### Types d'Erreurs

| Type | Retry ? | Action |
|------|---------|--------|
| **Temporaire (4xx)** | ✅ Oui | Retry avec backoff |
| **Permanent (5xx)** | ❌ Non | Marquer failed + alerte |
| **Timeout réseau** | ✅ Oui | Retry immédiat |
| **Email invalide** | ❌ Non | Marquer invalid |

### Fonction de Retry Automatique

```surql
-- Cron job toutes les 5 minutes
DEFINE FUNCTION fn::retry_failed_emails() {
  LET $to_retry = SELECT * FROM email_queue 
    WHERE status = 'failed' 
    AND attempts < max_attempts
    AND time::now() > scheduled_at;
  
  FOR $email IN $to_retry {
    UPDATE $email.id SET 
      status = 'pending',
      attempts += 1,
      scheduled_at = time::now() + (5m * math::pow(2, $email.attempts));
  };
};
```

---

## 📊 Monitoring & Observabilité (Cloud-Native)

### Métriques SurrealDB Cloud (Natives)

**Tableau de bord SurrealDB Cloud** :
- ✅ Queries per second
- ✅ Latence moyenne
- ✅ Connexions actives
- ✅ Storage utilisé
- ✅ Backups automatiques

### Métriques Bunny Container (Natives)

**Tableau de bord Bunny.net** :
- ✅ Workers actifs (auto-scaling)
- ✅ CPU/RAM usage
- ✅ Logs en temps réel
- ✅ Requêtes par seconde
- ✅ Coûts en temps réel

### Métriques Lyxal Mail (Custom)

```surql
-- Vue temps réel des performances
SELECT 
  status,
  count() AS count,
  AVG(time::diff(sent_at, created_at)) AS avg_latency
FROM email_queue
WHERE created_at > time::now() - 1h
GROUP BY status;
```

**Résultat** :
```json
[
  { "status": "sent", "count": 8523, "avg_latency": "2.3s" },
  { "status": "pending", "count": 47, "avg_latency": null },
  { "status": "failed", "count": 12, "avg_latency": null }
]
```

### Dashboard Analytics

Intégré dans **Lyxal Central (Bunny CDN)** :
- Taux de délivrabilité (temps réel)
- Taux d'ouverture (si tracking activé)
- Taux de clic
- Volumes par domaine/partenaire
- Latence moyenne
- Erreurs courantes
- Coûts d'infrastructure

---

## 🔗 Intégration avec Lyxal Identity

### Envoi automatique lors de l'inscription

```surql
-- Dans fn::create_identity
LET $user = CREATE identity:$lyxal_id SET ...;

-- Envoi email de vérification automatique
SELECT fn::send_email(
  $email,
  'verification_email',
  {
    first_name: $first_name,
    last_name: $last_name,
    verification_link: "https://app.lyxal.com/verify?id=" + $lyxal_id + "&token=" + $verification_token
  },
  $language,
  'lyxal.com'
);
```

### Envoi lors de l'activation

```surql
-- Dans fn::verify_email (après vérification réussie)
SELECT fn::send_email(
  $user.connexion.email,
  'welcome_email',
  {
    first_name: $user.identity.first_name
  },
  string::split($user.preferences.language, ':')[1],
  'lyxal.com'
);
```

---

## 💰 Coûts d'Infrastructure (Récapitulatif)

### Comparaison Architecture Traditionnelle vs Cloud-Native

| Aspect | Self-Hosted (VPS) | Lyxal Mail (Cloud) |
|--------|-------------------|---------------------|
| **SurrealDB** | Hetzner VPS 5€/mois | SurrealDB Cloud 25$/mois |
| **Worker** | Inclus dans VPS | Bunny Container 10$/mois |
| **Frontend** | Nginx sur VPS | Bunny CDN 5$/mois |
| **Storage** | Inclus dans VPS | Bunny Storage 2$/mois |
| **Backup** | Manuel | Automatique (inclus) |
| **Monitoring** | À configurer | Natif (inclus) |
| **Maintenance** | ⚠️ 5-10h/mois | ✅ 0h/mois |
| **Scaling** | ⚠️ Manuel | ✅ Automatique |
| **Total** | ~5€/mois + 5-10h | ~40$/mois + 0h |

**ROI** : Le temps économisé en maintenance (5-10h/mois) compense largement la différence de coût ! 🎯

---

## 🎯 Prochaines Étapes

1. **[DATABASE.md](./DATABASE.md)** → Voir les schémas complets des tables
2. **[FUNCTIONS.md](./FUNCTIONS.md)** → Code de toutes les fonctions
3. **[WORKER.md](./WORKER.md)** → Code complet du worker Go (Bunny)
4. **[DEPLOYMENT.md](./DEPLOYMENT.md)** → Guide de déploiement Cloud

