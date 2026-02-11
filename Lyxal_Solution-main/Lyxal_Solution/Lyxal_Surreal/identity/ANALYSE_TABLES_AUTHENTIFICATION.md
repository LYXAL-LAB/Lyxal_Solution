# 🔐 Analyse des Tables d'Authentification - Système de Cron Jobs

## 📋 Vue d'Ensemble

Le dossier `database_reprise_job_cr` contient **11 tables** qui forment le système d'authentification et de gestion des utilisateurs de votre application de cron jobs/scheduler.

### 📊 Schéma Global

```
┌──────────────────────────────────────────────────────────────┐
│           SYSTÈME D'AUTHENTIFICATION SCHEDULER               │
└──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ UTILISATEURS & GROUPES                                       │
├─────────────────────────────────────────────────────────────┤
│ • scheduler_user                (Utilisateurs)              │
│ • scheduler_usergroup           (Groupes & Permissions)     │
│ • scheduler_usergroupnode       (Relations groupes-nœuds)   │
│ • scheduler_usergroupchange     (Historique changements)    │
│ • scheduler_userdeletelog       (Journalisation suppressions)│
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ AUTHENTIFICATION & SÉCURITÉ                                  │
├─────────────────────────────────────────────────────────────┤
│ • scheduler_refreshtoken        (Jetons de rafraîchissement)│
│ • scheduler_mfadevice           (Authentification 2FA/MFA)  │
│ • scheduler_user_pwreset        (Réinitialisation MDP)      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PAIEMENTS & ABONNEMENTS                                      │
├─────────────────────────────────────────────────────────────┤
│ • scheduler_user_subscription         (Abonnements Stripe)  │
│ • scheduler_user_paddle_subscription  (Abonnements Paddle)  │
│ • scheduler_user_stripe_mapping       (Mapping Stripe ID)   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Détail des Tables

### 1. 👤 scheduler_user
**Rôle** : Table principale des utilisateurs

**Champs** :
- `userid` : Identifiant unique de l'utilisateur
- `usergroupid` : Lien vers le groupe d'appartenance
- `status` : Statut du compte (0=inactif, 1=actif, etc.)
- `email` : Email de l'utilisateur
- `password` / `password_salt` : Mot de passe haché et sel
- `firstname` / `lastname` : Nom et prénom
- `signup_ip` / `signup_date` : IP et date d'inscription
- `verification_token` / `verification_date` : Token et date de vérification email
- `lastlogin_ip` / `lastlogin_date` / `lastlogin_lang` : Dernière connexion
- `timezone` : Fuseau horaire (défaut: Europe/Berlin)
- `newsletter_subscribe` : Abonnement newsletter (yes/no/undefined)
- `notifications_auto_disabled` : Désactivation automatique des notifications
- `last_password_change` : Date du dernier changement de mot de passe

**Index** :
- `user_userid_unique` : Unicité sur userid
- `user_email_idx` : Index sur email

---

### 2. 👥 scheduler_usergroup
**Rôle** : Définit les groupes d'utilisateurs avec leurs permissions et limites

**Champs** :
- `usergroupid` : ID du groupe
- `title` : Nom du groupe
- **Limites de ressources** :
  - `max_status_pages` : Nombre max de pages de statut (5)
  - `max_status_page_monitors` : Nombre max de monitors (10)
  - `max_status_page_domains` : Nombre max de domaines (2)
  - `request_timeout` : Timeout des requêtes (30s)
  - `request_max_size` : Taille max des requêtes (8192)
  - `max_failures` : Nombre max d'échecs (15)
- **Configuration** :
  - `execution_priority` : Priorité d'exécution (0)
  - `api_requests_per_day` : Quota API (100/jour)
  - `max_api_keys` : Nombre max de clés API (1)
  - `enable_waf_validator` : WAF activé (true)

**Index** :
- `usergroup_usergroupid_unique` : Unicité sur usergroupid

**💡 Usage** : Système de quotas/plans (Free, Pro, Enterprise)

---

### 3. 🔗 scheduler_usergroupnode
**Rôle** : Table d'arête (edge) reliant les groupes d'utilisateurs aux nœuds

**Champs** :
- `enabled` : Relation activée ou non (true)
- Champs implicites `in` et `out` (gérés par SurrealDB)

**💡 Usage** : Gestion des permissions par nœud de l'infrastructure

---

### 4. 📝 scheduler_usergroupchange
**Rôle** : Journalise les changements de groupe des utilisateurs

**Champs** :
- `usergroupchangeid` : ID du changement
- `userid` : Utilisateur concerné
- `oldusergroupid` : Ancien groupe
- `newusergroupid` : Nouveau groupe
- `created` : Date de création du changement
- `processed` : Date de traitement

**Index** :
- `usergroupchange_id_unique` : Unicité sur l'ID
- `usergroupchange_processed_idx` : Index sur processed

**💡 Usage** : Audit trail des changements de plans/groupes

---

### 5. 🗑️ scheduler_userdeletelog
**Rôle** : Journalise les suppressions d'utilisateurs

**Champs** :
- `userid` : Utilisateur supprimé
- `date` : Date de début de suppression
- `source` : Source de la suppression (api/ops/unknown)
- `date_finished` : Date de fin de suppression
- `email` / `email_salt` : Email chiffré de l'utilisateur

**Index** :
- `userdeletelog_userid_unique` : Unicité sur userid

**💡 Usage** : Conformité RGPD, audit des suppressions

---

### 6. 🔄 scheduler_refreshtoken
**Rôle** : Stocke les jetons de rafraîchissement (refresh tokens)

**Champs** :
- `token` : Jeton de rafraîchissement
- `environmentid` : Lien vers l'environnement
- `device` : Identifiant du dispositif
- `expires` : Date d'expiration

**Index** :
- `refreshtoken_token_unique` : Unicité sur token

**💡 Usage** : Authentification stateless avec JWT

---

### 7. 📱 scheduler_mfadevice
**Rôle** : Gestion de l'authentification multi-facteurs (2FA/MFA)

**Champs** :
- `environment` : Lien vers l'environnement utilisateur
- `enabled` : Appareil activé (false par défaut)
- `title` : Nom de l'appareil
- `secret` : Secret TOTP
- `type` : Type d'appareil (0)
- `created` : Date de création
- `last_timeslot` : Dernier slot de temps utilisé

**Index** :
- `mfadevice_environment_idx` : Index sur environment

**💡 Usage** : Sécurité renforcée avec Google Authenticator, Authy, etc.

---

### 8. 🔑 scheduler_user_pwreset
**Rôle** : Gestion de la réinitialisation des mots de passe

**Champs** :
- `userid` : Utilisateur demandant la réinitialisation
- `expires` : Date d'expiration du token
- `token` : Token de réinitialisation
- `password` / `password_salt` : Nouveau mot de passe (temporaire)

**Index** :
- `user_pwreset_userid_unique` : Unicité sur userid
- `user_pwreset_expires_idx` : Index sur expires

**💡 Usage** : Workflow "Mot de passe oublié"

---

### 9. 💳 scheduler_user_subscription
**Rôle** : Abonnements Stripe des utilisateurs

**Champs** :
- `userid` : Utilisateur abonné
- `product_id` : ID du produit Stripe
- `subscription_id` : ID de l'abonnement Stripe
- `current_period_start` / `current_period_end` : Période d'abonnement
- `cancel_at` : Date d'annulation planifiée
- `status` : Statut de l'abonnement (0)

**Index** :
- `user_subscription_userid_unique` : Unicité sur userid

**💡 Usage** : Facturation via Stripe

---

### 10. 🏝️ scheduler_user_paddle_subscription
**Rôle** : Abonnements Paddle des utilisateurs

**Champs** : Identiques à `scheduler_user_subscription` mais pour Paddle
- `userid` : Utilisateur abonné
- `product_id` : ID du produit Paddle
- `subscription_id` : ID de l'abonnement Paddle
- `current_period_start` / `current_period_end` : Période
- `cancel_at` : Date d'annulation
- `status` : Statut
- `updated` : Date de mise à jour

**Index** :
- `user_paddle_subscription_userid_unique` : Unicité sur userid

**💡 Usage** : Facturation via Paddle (alternative à Stripe)

---

### 11. 🔗 scheduler_user_stripe_mapping
**Rôle** : Mapping entre utilisateur Lyxal et client Stripe

**Champs** :
- `userid` : Utilisateur Lyxal
- `stripe_customer_id` : ID client Stripe

**Index** :
- `user_stripe_mapping_userid_unique` : Unicité sur userid
- `user_stripe_mapping_stripeid_unique` : Unicité sur stripe_customer_id

**💡 Usage** : Liaison entre les deux systèmes

---

## 🔄 Flux d'Authentification

### 1. Inscription
```sql
-- Création utilisateur
INSERT INTO scheduler_user {
  userid: 12345,
  email: 'user@example.com',
  password: 'hashed_password',
  password_salt: 'random_salt',
  usergroupid: record<scheduler_usergroup>:1,  -- Groupe Free
  status: 0,  -- En attente de vérification
  signup_date: time::now()
}
```

### 2. Connexion avec MFA
```sql
-- 1. Vérification du mot de passe
SELECT * FROM scheduler_user WHERE email = $email

-- 2. Si MFA activé
SELECT * FROM scheduler_mfadevice 
WHERE environment = $env AND enabled = true

-- 3. Génération refresh token
INSERT INTO scheduler_refreshtoken {
  token: 'refresh_token_xyz',
  environmentid: $env,
  expires: time::now() + 30d
}
```

### 3. Changement de Plan
```sql
-- 1. Log du changement
INSERT INTO scheduler_usergroupchange {
  userid: record<scheduler_user>:12345,
  oldusergroupid: record<scheduler_usergroup>:1,  -- Free
  newusergroupid: record<scheduler_usergroup>:3,  -- Pro
  created: time::now()
}

-- 2. Mise à jour utilisateur
UPDATE scheduler_user:12345 SET usergroupid = record<scheduler_usergroup>:3
```

---

## 🎯 Comparaison avec Identité Lyxal

### Architecture Actuelle (Cron Jobs)
```
scheduler_user
├── Authentification par email/password
├── Groupes avec quotas
├── MFA optionnel
├── Abonnements Stripe/Paddle
└── Refresh tokens
```

### Architecture Identité Lyxal (Recommandée)
```
lyxal_users
├── Authentification SurrealDB native
├── Namespace personnel par utilisateur
├── Multi-SaaS avec contextes
├── Permissions granulaires
└── Live queries temps réel
```

---

## 🔄 Migration Possible

### Option 1 : Remplacement Complet
Remplacer toutes les tables `scheduler_*` par le système Identité Lyxal

**Avantages** :
- ✅ Architecture moderne
- ✅ Multi-SaaS natif
- ✅ Performance optimale

**Inconvénients** :
- ⚠️ Migration complexe
- ⚠️ Données à migrer

### Option 2 : Cohabitation
Garder `scheduler_*` pour le scheduler, utiliser Identité Lyxal pour les nouveaux SaaS

**Avantages** :
- ✅ Pas de migration
- ✅ Progressive

**Inconvénients** :
- ⚠️ Deux systèmes à maintenir
- ⚠️ Expérience utilisateur fragmentée

### Option 3 : Intégration (Recommandée)
Créer un lien entre `scheduler_user` et `lyxal_users`

```sql
-- Ajout d'un champ dans scheduler_user
DEFINE FIELD lyxal_identity_id ON scheduler_user 
  TYPE record<lyxal_users>;

-- Liaison
UPDATE scheduler_user:12345 SET 
  lyxal_identity_id = record<lyxal_users>:user_jean_123
```

**Avantages** :
- ✅ Best of both worlds
- ✅ Migration progressive
- ✅ Rétrocompatibilité

---

## 📊 Statistiques

| Table | Fonction | Complexité | Critique |
|-------|----------|------------|----------|
| scheduler_user | Utilisateurs | ⭐⭐⭐ | ✅ Essentiel |
| scheduler_usergroup | Quotas/Plans | ⭐⭐ | ✅ Essentiel |
| scheduler_refreshtoken | Auth | ⭐⭐ | ✅ Essentiel |
| scheduler_mfadevice | Sécurité | ⭐⭐ | ⚠️ Important |
| scheduler_user_pwreset | Récupération | ⭐ | ⚠️ Important |
| scheduler_user_subscription | Paiements | ⭐⭐ | ⚠️ Important |
| scheduler_user_paddle_subscription | Paiements | ⭐⭐ | ⚠️ Important |
| scheduler_user_stripe_mapping | Intégration | ⭐ | ⚠️ Important |
| scheduler_usergroupchange | Audit | ⭐ | ℹ️ Utile |
| scheduler_usergroupnode | Permissions | ⭐⭐ | ℹ️ Utile |
| scheduler_userdeletelog | Conformité | ⭐ | ℹ️ Utile |

---

## 🚀 Recommandation

### Pour Votre Application de Scheduler

**L'architecture actuelle est solide** pour une application de cron jobs, avec :
- ✅ Authentification complète
- ✅ Système de quotas/plans
- ✅ Gestion des abonnements
- ✅ Sécurité (MFA)
- ✅ Audit trail

### Pour Intégrer avec Identité Lyxal

**Approche Progressive Recommandée** :

1. **Phase 1** : Garder `scheduler_*` pour le scheduler
2. **Phase 2** : Implémenter Identité Lyxal pour les nouveaux SaaS
3. **Phase 3** : Créer un pont entre les deux systèmes
4. **Phase 4** : Migration progressive (optionnelle)

---

**Document créé le : 2024-01-20**  
**Version : 1.0**  
**Chemin : C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\authentification\**

