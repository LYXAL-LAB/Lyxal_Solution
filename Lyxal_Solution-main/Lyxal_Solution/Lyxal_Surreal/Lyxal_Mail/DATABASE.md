# 🗄️ Base de Données - Lyxal Mail

Ce document détaille toutes les tables SurrealDB utilisées par Lyxal Mail.

---

## 📋 Vue d'Ensemble des Tables

```
email_queue          → File d'attente principale (emails à envoyer)
email_template       → Templates multilingues
email_domain         → Configuration domaines (white-label)
email_log            → Historique des événements
email_stats          → Métriques agrégées
email_bounce         → Gestion des bounces (v1.1)
email_unsubscribe    → Liste de désabonnement (v1.1)
```

---

## 1️⃣ Table `email_queue`

**Description** : File d'attente principale. Tous les emails passent par cette table.

### Schéma Complet

```surql
-- =====================================================
-- TABLE : email_queue
-- Description : File d'attente des emails à envoyer
-- =====================================================

DEFINE TABLE IF NOT EXISTS email_queue TYPE NORMAL SCHEMAFULL
  COMMENT 'File d\'attente des emails à envoyer'
  PERMISSIONS 
    FOR SELECT, CREATE WHERE $auth.id != NONE
    FOR UPDATE, DELETE WHERE $auth.id = created_by;

-- Destinataire
DEFINE FIELD IF NOT EXISTS to ON email_queue 
  TYPE string
  ASSERT string::is::email($value)
  COMMENT 'Email du destinataire';

-- Expéditeur
DEFINE FIELD IF NOT EXISTS from ON email_queue 
  TYPE string
  ASSERT string::is::email($value)
  COMMENT 'Email de l\'expéditeur';

DEFINE FIELD IF NOT EXISTS from_name ON email_queue 
  TYPE option<string>
  COMMENT 'Nom de l\'expéditeur (ex: "Lyxal Support")';

-- Contenu
DEFINE FIELD IF NOT EXISTS subject ON email_queue 
  TYPE string
  ASSERT string::len($value) > 0 AND string::len($value) <= 998
  COMMENT 'Sujet de l\'email (max 998 caractères RFC5322)';

DEFINE FIELD IF NOT EXISTS html_body ON email_queue 
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'Corps HTML de l\'email';

DEFINE FIELD IF NOT EXISTS text_body ON email_queue 
  TYPE option<string>
  COMMENT 'Corps texte brut (fallback)';

-- Headers personnalisés
DEFINE FIELD IF NOT EXISTS headers ON email_queue 
  TYPE option<object>
  COMMENT 'Headers SMTP supplémentaires';

-- Configuration
DEFINE FIELD IF NOT EXISTS domain ON email_queue 
  TYPE record<email_domain>
  COMMENT 'Domaine d\'envoi (white-label)';

DEFINE FIELD IF NOT EXISTS template_code ON email_queue 
  TYPE option<string>
  COMMENT 'Code du template utilisé (traçabilité)';

-- Statut & Retry
DEFINE FIELD IF NOT EXISTS status ON email_queue 
  TYPE string
  ASSERT $value IN ['pending', 'sending', 'sent', 'failed', 'invalid']
  DEFAULT 'pending'
  COMMENT 'Statut actuel de l\'email';

DEFINE FIELD IF NOT EXISTS attempts ON email_queue 
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre de tentatives d\'envoi';

DEFINE FIELD IF NOT EXISTS max_attempts ON email_queue 
  TYPE int
  DEFAULT 3
  COMMENT 'Nombre maximum de tentatives';

DEFINE FIELD IF NOT EXISTS error_message ON email_queue 
  TYPE option<string>
  COMMENT 'Message d\'erreur si échec';

DEFINE FIELD IF NOT EXISTS error_code ON email_queue 
  TYPE option<string>
  COMMENT 'Code d\'erreur SMTP (ex: 550, 4xx)';

-- Dates & Scheduling
DEFINE FIELD IF NOT EXISTS scheduled_at ON email_queue 
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date d\'envoi programmée';

DEFINE FIELD IF NOT EXISTS sent_at ON email_queue 
  TYPE option<datetime>
  COMMENT 'Date d\'envoi effective';

DEFINE FIELD IF NOT EXISTS created_at ON email_queue 
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

-- Traçabilité
DEFINE FIELD IF NOT EXISTS created_by ON email_queue 
  TYPE option<record<identity>>
  COMMENT 'Utilisateur créateur (si applicable)';

DEFINE FIELD IF NOT EXISTS metadata ON email_queue 
  TYPE option<object>
  COMMENT 'Métadonnées additionnelles (campagne, tags, etc.)';

-- Tracking (v1.1)
DEFINE FIELD IF NOT EXISTS tracking ON email_queue 
  TYPE object
  DEFAULT {
    opens: 0,
    clicks: 0,
    last_opened_at: NONE,
    last_clicked_at: NONE
  }
  COMMENT 'Données de tracking';

-- Index ESSENTIELS
DEFINE INDEX IF NOT EXISTS status_scheduled_idx ON email_queue 
  FIELDS status, scheduled_at
  COMMENT 'Index pour le worker (emails pending à traiter)';

DEFINE INDEX IF NOT EXISTS domain_idx ON email_queue 
  FIELDS domain
  COMMENT 'Index pour filtrer par domaine (stats)';

DEFINE INDEX IF NOT EXISTS created_at_idx ON email_queue 
  FIELDS created_at
  COMMENT 'Index pour tri chronologique';

DEFINE INDEX IF NOT EXISTS to_idx ON email_queue 
  FIELDS to
  COMMENT 'Index pour recherche par destinataire';
```

### Exemple d'Enregistrement

```json
{
  "id": "email_queue:abc123",
  "to": "user@example.com",
  "from": "noreply@lyxal.com",
  "from_name": "Lyxal",
  "subject": "Vérifiez votre adresse email",
  "html_body": "<html>...</html>",
  "text_body": "Cliquez sur ce lien...",
  "domain": "email_domain:lyxal_com",
  "template_code": "verification_email",
  "status": "sent",
  "attempts": 1,
  "max_attempts": 3,
  "scheduled_at": "2025-01-15T10:00:00Z",
  "sent_at": "2025-01-15T10:00:02.3Z",
  "created_at": "2025-01-15T09:59:58Z",
  "tracking": {
    "opens": 1,
    "clicks": 1,
    "last_opened_at": "2025-01-15T10:05:00Z",
    "last_clicked_at": "2025-01-15T10:05:15Z"
  }
}
```

---

## 2️⃣ Table `email_template`

**Description** : Templates d'emails multilingues avec support des variables.

### Schéma Complet

```surql
-- =====================================================
-- TABLE : email_template
-- Description : Templates multilingues
-- =====================================================

DEFINE TABLE IF NOT EXISTS email_template TYPE NORMAL SCHEMAFULL
  COMMENT 'Templates d\'emails multilingues';

-- Code unique
DEFINE FIELD IF NOT EXISTS code ON email_template 
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'Code unique du template (ex: verification_email)';

-- Nom & Description
DEFINE FIELD IF NOT EXISTS name ON email_template 
  TYPE object
  COMMENT 'Nom du template par langue { fr: "...", en: "..." }';

DEFINE FIELD IF NOT EXISTS description ON email_template 
  TYPE object
  COMMENT 'Description du template par langue';

-- Contenu multilingue
DEFINE FIELD IF NOT EXISTS subject ON email_template 
  TYPE object
  COMMENT 'Sujet par langue { fr: "...", en: "...", es: "..." }';

DEFINE FIELD IF NOT EXISTS body_html ON email_template 
  TYPE object
  COMMENT 'Corps HTML par langue avec variables {{var}}';

DEFINE FIELD IF NOT EXISTS body_text ON email_template 
  TYPE object
  COMMENT 'Corps texte par langue';

-- Variables disponibles
DEFINE FIELD IF NOT EXISTS variables ON email_template 
  TYPE array
  DEFAULT []
  COMMENT 'Liste des variables utilisables (ex: ["first_name", "link"])';

-- Configuration
DEFINE FIELD IF NOT EXISTS from_name ON email_template 
  TYPE option<string>
  COMMENT 'Nom expéditeur par défaut';

DEFINE FIELD IF NOT EXISTS category ON email_template 
  TYPE string
  ASSERT $value IN ['transactional', 'marketing', 'notification', 'system']
  DEFAULT 'transactional'
  COMMENT 'Catégorie du template';

-- Statut
DEFINE FIELD IF NOT EXISTS active ON email_template 
  TYPE bool
  DEFAULT true
  COMMENT 'Template actif ou archivé';

-- Métadonnées
DEFINE FIELD IF NOT EXISTS created_at ON email_template 
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS updated_at ON email_template 
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour';

-- Index
DEFINE INDEX IF NOT EXISTS code_unique ON email_template 
  FIELDS code UNIQUE
  COMMENT 'Code unique';

DEFINE INDEX IF NOT EXISTS category_idx ON email_template 
  FIELDS category
  COMMENT 'Index par catégorie';
```

### Exemple d'Enregistrement

```json
{
  "id": "email_template:verification_email",
  "code": "verification_email",
  "name": {
    "fr": "Email de vérification",
    "en": "Verification Email",
    "es": "Correo de verificación"
  },
  "subject": {
    "fr": "Vérifiez votre adresse email - Lyxal",
    "en": "Verify your email address - Lyxal",
    "es": "Verifique su dirección de correo - Lyxal"
  },
  "body_html": {
    "fr": "<html><body><p>Bonjour {{first_name}},</p><p>Cliquez sur ce lien : <a href='{{verification_link}}'>Vérifier</a></p></body></html>",
    "en": "<html><body><p>Hello {{first_name}},</p><p>Click here: <a href='{{verification_link}}'>Verify</a></p></body></html>"
  },
  "variables": ["first_name", "last_name", "verification_link"],
  "from_name": "Lyxal",
  "category": "transactional",
  "active": true
}
```

---

## 3️⃣ Table `email_domain`

**Description** : Configuration des domaines d'envoi (multi-tenant / white-label).

### Schéma Complet

```surql
-- =====================================================
-- TABLE : email_domain
-- Description : Configuration domaines d'envoi
-- =====================================================

DEFINE TABLE IF NOT EXISTS email_domain TYPE NORMAL SCHEMAFULL
  COMMENT 'Configuration des domaines d\'envoi (white-label)';

-- Domaine
DEFINE FIELD IF NOT EXISTS domain ON email_domain 
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'Nom de domaine (ex: lyxal.com)';

-- Configuration SMTP
DEFINE FIELD IF NOT EXISTS smtp_host ON email_domain 
  TYPE string
  COMMENT 'Serveur SMTP (ex: mail.lyxal.com)';

DEFINE FIELD IF NOT EXISTS smtp_port ON email_domain 
  TYPE int
  DEFAULT 587
  ASSERT $value IN [25, 587, 465, 2525]
  COMMENT 'Port SMTP';

-- DKIM Configuration
DEFINE FIELD IF NOT EXISTS dkim_enabled ON email_domain 
  TYPE bool
  DEFAULT true
  COMMENT 'Activer la signature DKIM';

DEFINE FIELD IF NOT EXISTS dkim_selector ON email_domain 
  TYPE string
  DEFAULT 'lyxal'
  COMMENT 'Sélecteur DKIM (ex: lyxal)';

DEFINE FIELD IF NOT EXISTS dkim_private_key ON email_domain 
  TYPE string
  COMMENT 'Clé privée DKIM (RSA 2048)';

-- Configuration DNS (pour vérification)
DEFINE FIELD IF NOT EXISTS spf_record ON email_domain 
  TYPE string
  COMMENT 'Record SPF configuré';

DEFINE FIELD IF NOT EXISTS dmarc_record ON email_domain 
  TYPE option<string>
  COMMENT 'Record DMARC configuré';

-- Statut de vérification
DEFINE FIELD IF NOT EXISTS verified ON email_domain 
  TYPE bool
  DEFAULT false
  COMMENT 'Domaine vérifié (DNS OK)';

DEFINE FIELD IF NOT EXISTS verified_at ON email_domain 
  TYPE option<datetime>
  COMMENT 'Date de vérification';

-- Tenant (white-label)
DEFINE FIELD IF NOT EXISTS tenant_id ON email_domain 
  TYPE string
  COMMENT 'ID du tenant (lyxal, batipro, etc.)';

DEFINE FIELD IF NOT EXISTS tenant_name ON email_domain 
  TYPE string
  COMMENT 'Nom du tenant';

-- Limites & Quotas
DEFINE FIELD IF NOT EXISTS daily_limit ON email_domain 
  TYPE option<int>
  COMMENT 'Limite d\'envoi quotidienne (NONE = illimité)';

DEFINE FIELD IF NOT EXISTS hourly_limit ON email_domain 
  TYPE option<int>
  COMMENT 'Limite d\'envoi horaire';

-- Métadonnées
DEFINE FIELD IF NOT EXISTS active ON email_domain 
  TYPE bool
  DEFAULT true
  COMMENT 'Domaine actif';

DEFINE FIELD IF NOT EXISTS created_at ON email_domain 
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

-- Index
DEFINE INDEX IF NOT EXISTS domain_unique ON email_domain 
  FIELDS domain UNIQUE
  COMMENT 'Domaine unique';

DEFINE INDEX IF NOT EXISTS tenant_idx ON email_domain 
  FIELDS tenant_id
  COMMENT 'Index par tenant';
```

### Exemple d'Enregistrement

```json
{
  "id": "email_domain:lyxal_com",
  "domain": "lyxal.com",
  "smtp_host": "mail.lyxal.com",
  "smtp_port": 587,
  "dkim_enabled": true,
  "dkim_selector": "lyxal",
  "dkim_private_key": "-----BEGIN RSA PRIVATE KEY-----\n...",
  "spf_record": "v=spf1 ip4:123.45.67.89 ~all",
  "dmarc_record": "v=DMARC1; p=quarantine; rua=mailto:dmarc@lyxal.com",
  "verified": true,
  "verified_at": "2025-01-10T10:00:00Z",
  "tenant_id": "lyxal",
  "tenant_name": "Lyxal",
  "daily_limit": null,
  "hourly_limit": null,
  "active": true
}
```

---

## 4️⃣ Table `email_log`

**Description** : Historique de tous les événements liés aux emails.

### Schéma Complet

```surql
-- =====================================================
-- TABLE : email_log
-- Description : Historique des événements
-- =====================================================

DEFINE TABLE IF NOT EXISTS email_log TYPE NORMAL SCHEMAFULL
  COMMENT 'Historique des événements emails';

-- Référence email
DEFINE FIELD IF NOT EXISTS email_id ON email_log 
  TYPE record<email_queue>
  COMMENT 'Email concerné';

-- Type d'événement
DEFINE FIELD IF NOT EXISTS event ON email_log 
  TYPE string
  ASSERT $value IN ['queued', 'sending', 'sent', 'delivered', 'opened', 'clicked', 'bounced', 'complained', 'failed']
  COMMENT 'Type d\'événement';

-- Détails
DEFINE FIELD IF NOT EXISTS details ON email_log 
  TYPE option<object>
  COMMENT 'Détails de l\'événement (error, link clicked, etc.)';

-- Métadonnées
DEFINE FIELD IF NOT EXISTS timestamp ON email_log 
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Horodatage de l\'événement';

DEFINE FIELD IF NOT EXISTS ip_address ON email_log 
  TYPE option<string>
  COMMENT 'IP de l\'utilisateur (pour opened/clicked)';

DEFINE FIELD IF NOT EXISTS user_agent ON email_log 
  TYPE option<string>
  COMMENT 'User agent (pour opened/clicked)';

-- Index
DEFINE INDEX IF NOT EXISTS email_id_idx ON email_log 
  FIELDS email_id
  COMMENT 'Index par email';

DEFINE INDEX IF NOT EXISTS event_timestamp_idx ON email_log 
  FIELDS event, timestamp
  COMMENT 'Index pour analytics';
```

---

## 5️⃣ Table `email_stats`

**Description** : Statistiques agrégées pour analytics rapides.

### Schéma Complet

```surql
-- =====================================================
-- TABLE : email_stats
-- Description : Statistiques agrégées
-- =====================================================

DEFINE TABLE IF NOT EXISTS email_stats TYPE NORMAL SCHEMAFULL
  COMMENT 'Statistiques agrégées par jour/domaine';

-- Période
DEFINE FIELD IF NOT EXISTS date ON email_stats 
  TYPE datetime
  COMMENT 'Date (agrégation journalière)';

-- Domaine
DEFINE FIELD IF NOT EXISTS domain ON email_stats 
  TYPE record<email_domain>
  COMMENT 'Domaine concerné';

-- Métriques d'envoi
DEFINE FIELD IF NOT EXISTS sent_count ON email_stats 
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre d\'emails envoyés';

DEFINE FIELD IF NOT EXISTS failed_count ON email_stats 
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre d\'échecs';

DEFINE FIELD IF NOT EXISTS bounced_count ON email_stats 
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre de bounces';

-- Métriques d'engagement
DEFINE FIELD IF NOT EXISTS opened_count ON email_stats 
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre d\'ouvertures';

DEFINE FIELD IF NOT EXISTS clicked_count ON email_stats 
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre de clics';

-- Taux calculés
DEFINE FIELD IF NOT EXISTS delivery_rate ON email_stats 
  TYPE float
  COMMENT 'Taux de délivrabilité (sent - bounced) / sent';

DEFINE FIELD IF NOT EXISTS open_rate ON email_stats 
  TYPE float
  COMMENT 'Taux d\'ouverture';

DEFINE FIELD IF NOT EXISTS click_rate ON email_stats 
  TYPE float
  COMMENT 'Taux de clic';

-- Index
DEFINE INDEX IF NOT EXISTS date_domain_idx ON email_stats 
  FIELDS date, domain UNIQUE
  COMMENT 'Unique par jour/domaine';
```

---

## 🔄 Relations entre Tables

```
email_domain ←──────┐
     ↓              │
     │              │
email_queue ────────┘
     ↓
     ├──→ email_log (événements)
     └──→ email_stats (agrégation)
     
email_template (lecture seule pour rendering)
```

---

## 📊 Volumétrie Estimée

| Table | Volume (Phase 1) | Volume (Phase 3) | Rétention |
|-------|------------------|------------------|-----------|
| `email_queue` | 1K emails/jour | 50K emails/jour | 90 jours |
| `email_template` | ~20 templates | ~100 templates | Permanent |
| `email_domain` | 2-5 domaines | 50-100 domaines | Permanent |
| `email_log` | 5K events/jour | 250K events/jour | 1 an |
| `email_stats` | 5 rows/jour | 100 rows/jour | Permanent |

---

## 🚀 Prochaines Étapes

Voir **[FUNCTIONS.md](./FUNCTIONS.md)** pour le code complet des fonctions SurrealDB qui manipulent ces tables.

