# 📧 Lyxal Mail - Serveur Email Natif SurrealDB (Cloud)

## 🎯 Vision

**Lyxal Mail** est un serveur d'envoi d'emails **95% SurrealDB Cloud** qui s'intègre parfaitement dans l'architecture "Full Cloud" de Lyxal. Contrairement à Postal ou d'autres solutions, **toute la logique métier est dans SurrealDB**, avec seulement un micro-worker de 200 lignes déployé sur **Bunny Container**.

### 🌐 Architecture Cloud-Native

**Stack Technologique Lyxal** :
- 🗄️ **SurrealDB Cloud** : Base de données gérée (0 maintenance)
- 🐰 **Bunny Container** : Déploiement du worker Go
- 🌐 **Bunny CDN** : Livraison du frontend Lyxal Central
- 📦 **Bunny Storage** : Fichiers et assets
- 🔒 **Cloudflare** : DNS et sécurité (gratuit)

**Coût Total : ~30-50$/mois** pour une infrastructure **0 serveur à gérer** ! 🎉

---

## 🏗️ Architecture Globale

```
┌──────────────────────────────────────────────────────────┐
│              SURREALDB CLOUD (95%)                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │ TABLES                                             │  │
│  │  • email_queue (files d'attente)                   │  │
│  │  • email_template (templates multilingues)         │  │
│  │  • email_domain (config multi-domaines)            │  │
│  │  • email_log (traçabilité complète)                │  │
│  │  • email_stats (analytics temps réel)              │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │ FONCTIONS                                          │  │
│  │  • fn::send_email (enqueue)                        │  │
│  │  • fn::render_template (ML support)                │  │
│  │  • fn::retry_failed_emails (resilience)            │  │
│  │  • fn::get_email_stats (analytics)                 │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │ EVENTS                                             │  │
│  │  • ON INSERT email_queue (notifications)           │  │
│  │  • ON UPDATE email_queue (status changes)          │  │
│  └────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────┘
                     │ WebSocket Sécurisé (WSS)
                     ↓
┌──────────────────────────────────────────────────────────┐
│      BUNNY CONTAINER - Lyxal Mail Worker (5%)            │
│          (200 lignes Go - Auto-scaling)                  │
│  ┌────────────────────────────────────────────────────┐  │
│  │ • Écoute email_queue via LIVE QUERY                │  │
│  │ • Ouvre connexion SMTP sortante                    │  │
│  │ • Signe DKIM                                       │  │
│  │ • Envoie l'email                                   │  │
│  │ • Met à jour le statut dans SurrealDB              │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
                     │ SMTP (TCP)
                     ↓
              [Internet / Gmail / Outlook]
```

---

## ✅ Avantages de cette Architecture

### 1. **Cohérence Totale avec Lyxal**
- 95% de la logique dans SurrealDB
- Aligné avec la vision "Full SurrealDB"
- Pas de backend Node.js/Python complexe

### 2. **Simplicité Extrême**
- Worker de 200 lignes vs Postal 50 000 lignes
- Maintenance quasi-nulle (Bunny + SurrealDB Cloud)
- Un seul langage pour tout (SurrealQL + Go minimal)

### 3. **0 Infrastructure à Gérer**
- ❌ Pas de serveurs VPS
- ❌ Pas de mises à jour OS
- ❌ Pas de configuration firewall
- ✅ Focus 100% sur le produit

### 4. **Multi-Tenant Natif**
- SurrealDB gère naturellement le multi-tenant
- 1 domaine par partenaire (white-label)
- Isolation parfaite des données

### 5. **Scalabilité Native**
- Bunny Container : Auto-scaling automatique
- SurrealDB Cloud : Scaling géré
- LIVE QUERY temps réel

### 6. **Indépendance Totale**
- 0 dépendance externe (Brevo, Mailgun, etc.)
- Contrôle 100% du code source
- Pas de limites de volume
- Coûts prévisibles

### 7. **Traçabilité Complète**
- Tous les événements dans SurrealDB
- Analytics temps réel
- Audit trail complet

---

## 💰 Coûts Mensuels

### Phase MVP (0-1000 emails/jour)

| Service | Prix/mois |
|---------|-----------|
| **SurrealDB Cloud** (Starter) | 0-25$ |
| **Bunny Container** (Worker Go) | 5-10$ |
| **Bunny CDN** (Frontend) | 0-5$ |
| **Bunny Storage** (100GB) | 0-2$ |
| **Cloudflare** (DNS) | 0$ |
| **Total** | **~10-40$/mois** 🎉 |

### Phase Production (10 000+ emails/jour)

| Service | Prix/mois |
|---------|-----------|
| **SurrealDB Cloud** (Pro) | 25-100$ |
| **Bunny Container** (scaled) | 10-20$ |
| **Bunny CDN** | 5-15$ |
| **Bunny Storage** | 5-10$ |
| **Total** | **~45-145$/mois** |

**vs Brevo/Mailgun** : 200-2000$/mois pour le même volume ! 💸

---

## 📚 Documentation

### Fichiers de Documentation

1. **[ARCHITECTURE.md](./ARCHITECTURE.md)**
   - Architecture Cloud détaillée
   - Flux de données
   - Composants techniques

2. **[DATABASE.md](./DATABASE.md)**
   - Structure des tables SurrealDB
   - Schémas complets
   - Relations entre tables

3. **[FUNCTIONS.md](./FUNCTIONS.md)**
   - Toutes les fonctions SurrealDB
   - Code complet et commenté
   - Cas d'usage

4. **[WORKER.md](./WORKER.md)**
   - Code du worker Go complet
   - Configuration pour Bunny Container
   - Déploiement

5. **[TEMPLATES.md](./TEMPLATES.md)**
   - Système de templates multilingues
   - Variables disponibles
   - Exemples concrets

6. **[DEPLOYMENT.md](./DEPLOYMENT.md)**
   - Guide de déploiement Cloud complet
   - Configuration DNS (SPF, DKIM, DMARC)
   - Monitoring

7. **[MIGRATION.md](./MIGRATION.md)**
   - Migration depuis Brevo/Mailgun
   - Stratégie de transition
   - Checklist

---

## 🚀 Démarrage Rapide

### Prérequis

- Compte **SurrealDB Cloud** (gratuit pour débuter)
- Compte **Bunny.net** (gratuit pour débuter)
- Nom de domaine avec accès DNS
- Compte **Cloudflare** (gratuit)

### Installation en 5 étapes

```bash
# 1. Connexion à SurrealDB Cloud
surreal sql \
  --endpoint https://cloud.surrealdb.com \
  --namespace lyxal_solution \
  --database main

# 2. Import du schéma
import database/schema.surql
import database/seeds.surql

# 3. Configuration DNS (voir DEPLOYMENT.md)
# SPF, DKIM, DMARC sur Cloudflare

# 4. Build du worker
cd worker
docker build -t lyxal-mail-worker .

# 5. Déploiement sur Bunny Container
bunny deploy --name lyxal-mail-worker --image lyxal-mail-worker
```

---

## 📊 Comparaison avec les Alternatives

| Aspect | Lyxal Mail | Postal | Brevo/Mailgun |
|--------|-----------|--------|---------------|
| **Infrastructure** | 0 serveur | 1+ serveurs VPS | SaaS |
| **Lignes de code** | 200 (Go) | 50 000 (Ruby) | N/A |
| **Base de données** | SurrealDB Cloud | PostgreSQL + Redis | Propriétaire |
| **Maintenance** | ✅ 0 | ⚠️ Importante | ✅ Gérée |
| **Coûts (10K emails/j)** | ~50$/mois | ~50$/mois + temps | 200-2000$/mois |
| **Scaling** | ✅ Auto | ⚠️ Manuel | ✅ Auto |
| **Multi-tenant** | ✅ Natif | ⚠️ Custom | ✅ Plans payants |
| **Dépendance externe** | ❌ Aucune | ❌ Aucune | ✅ Oui |
| **Cohérence Lyxal** | ✅ 100% | ⚠️ Stack mixte | ❌ Externe |

---

## 🎯 Cas d'Usage

### 1. Emails Transactionnels (Identity)
```surql
-- Envoi automatique lors de la création d'un compte
SELECT fn::send_email(
  $email,
  'verification_email',
  { first_name: $first_name, token: $token },
  'fr',
  'lyxal.com'
);
```

### 2. White-Label pour Partenaires
```surql
-- BatiPro envoie depuis son propre domaine
SELECT fn::send_email(
  $email,
  'invoice_created',
  { invoice_number: $number },
  'fr',
  'batipro.com'  -- ← Domaine du partenaire
);
```

### 3. Emails Marketing (Newsletters)
```surql
-- Envoi de newsletter à tous les utilisateurs actifs
FOR $user IN (SELECT * FROM identity WHERE status = identity_status:active) {
  SELECT fn::send_email(
    $user.connexion.email,
    'newsletter_monthly',
    { first_name: $user.identity.first_name },
    string::split($user.preferences.language, ':')[1],
    'lyxal.com'
  );
};
```

---

## 🛠️ Statut du Projet

### ✅ Phase 1 : Spécification (Actuel)
- [x] Architecture Cloud définie
- [x] Documentation créée
- [ ] Validation des choix techniques

### 📋 Phase 2 : Développement (3-5 jours)
- [ ] Tables SurrealDB
- [ ] Fonctions SurrealDB
- [ ] Worker Go
- [ ] Tests unitaires

### 🚀 Phase 3 : Déploiement (1-2 jours)
- [ ] Configuration DNS
- [ ] Déploiement Bunny Container
- [ ] Tests en production
- [ ] Monitoring

### 🎯 Phase 4 : Production
- [ ] Migration progressive
- [ ] Monitoring continu
- [ ] Optimisations

---

## 📈 Roadmap

### Version 1.0 (MVP)
- ✅ Envoi SMTP de base
- ✅ Templates multilingues
- ✅ Queue et retry
- ✅ Multi-domaines

### Version 1.1
- [ ] Tracking d'ouverture (pixel)
- [ ] Tracking de clics (liens)
- [ ] Webhooks bounce/complaint
- [ ] Dashboard analytics

### Version 2.0
- [ ] Support MIME avancé (pièces jointes)
- [ ] Template builder visuel
- [ ] A/B testing
- [ ] Segmentation avancée

---

## 🤝 Contribution

Ce projet est développé en interne pour Lyxal. Pour toute question :
- Documentation : Voir les fichiers `*.md` dans ce dossier
- Support : Équipe technique Lyxal

---

## 📝 Licence

Propriétaire - Lyxal © 2025

---

## 🔗 Ressources

- [Documentation SurrealDB Cloud](https://surrealdb.com/cloud)
- [Bunny Container Docs](https://docs.bunny.net/docs/stream-container)
- [RFC 5321 - SMTP](https://tools.ietf.org/html/rfc5321)
- [RFC 6376 - DKIM](https://tools.ietf.org/html/rfc6376)
- [Guide délivrabilité](./DEPLOYMENT.md)

