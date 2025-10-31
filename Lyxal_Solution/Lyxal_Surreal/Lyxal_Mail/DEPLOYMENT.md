# 🚀 Déploiement - Lyxal Mail (Cloud-Native)

Ce document explique comment déployer Lyxal Mail en production avec **0 serveur à gérer**.

**Stack** : SurrealDB Cloud + Bunny Container + Bunny CDN + Cloudflare DNS

---

## 📋 Prérequis

### Comptes Cloud (Tous avec Free Tier)

- **SurrealDB Cloud** : https://surrealdb.com/cloud
  - Free tier : 1 GB storage, parfait pour MVP
  - Pro tier : 25-100$/mois pour production

- **Bunny.net** : https://bunny.net
  - Bunny Container : ~5$/mois
  - Bunny CDN : Inclus (1TB gratuit/mois)
  - Bunny Storage : ~2$/mois (100GB)

- **Cloudflare** : https://cloudflare.com
  - Free tier : DNS gratuit, SSL automatique
  - Parfait pour gérer SPF, DKIM, DMARC

### Domaine

- **Nom de domaine** (ex: lyxal.com)
- **Accès DNS** (via Cloudflare)

---

## 🎯 Étape 1 : Configuration Cloudflare DNS

### 1. Ajouter votre domaine à Cloudflare

```
1. Aller sur https://dash.cloudflare.com
2. Cliquer sur "Add a Site"
3. Entrer lyxal.com
4. Suivre les instructions pour changer les nameservers
```

### 2. Configuration DNS de Base

#### Record A (Mail Server)

```
Type: A
Name: mail
IPv4: [Votre IP SMTP sortant - fournie par Bunny]
Proxy: Désactivé (cloud gris)
TTL: Auto
```

**Note** : Si vous utilisez votre propre SMTP server, utilisez son IP. Sinon, Bunny peut fournir une IP pour les containers.

#### Record MX (Optionnel - Réception d'emails)

```
Type: MX
Name: @
Priority: 10
Target: mail.lyxal.com
TTL: Auto
```

### 3. Configuration SPF

```
Type: TXT
Name: @
Content: "v=spf1 ip4:123.45.67.89 include:_spf.bunny.net ~all"
TTL: Auto
```

*(Remplacez 123.45.67.89 par votre IP réelle)*

**Explication** :
- `v=spf1` : Version SPF
- `ip4:123.45.67.89` : IP autorisée à envoyer
- `include:_spf.bunny.net` : Si vous utilisez les IPs Bunny
- `~all` : Softfail (recommandé pour débuter)

### 4. Configuration DKIM

#### Génération de la clé DKIM

```bash
# Sur votre machine locale
openssl genrsa -out dkim_private.pem 2048
openssl rsa -in dkim_private.pem -pubout -out dkim_public.pem

# Formatage pour DNS (supprimer headers et sauts de ligne)
grep -v "BEGIN\|END" dkim_public.pem | tr -d '\n'
```

Vous obtenez quelque chose comme :
```
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
```

#### Record DNS DKIM

```
Type: TXT
Name: lyxal._domainkey
Content: "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA..."
TTL: Auto
```

**Sauvegardez** le fichier `dkim_private.pem`, vous en aurez besoin pour SurrealDB.

### 5. Configuration DMARC

```
Type: TXT
Name: _dmarc
Content: "v=DMARC1; p=quarantine; rua=mailto:dmarc@lyxal.com; pct=100; adkim=r; aspf=r"
TTL: Auto
```

**Explication** :
- `p=quarantine` : Emails suspects en quarantaine
- `rua=mailto:dmarc@lyxal.com` : Rapports DMARC
- `pct=100` : Applique à 100% des emails
- `adkim=r` : DKIM relaxed
- `aspf=r` : SPF relaxed

### 6. Vérification DNS

```bash
# Test SPF
dig +short txt lyxal.com | grep spf

# Test DKIM
dig +short txt lyxal._domainkey.lyxal.com

# Test DMARC
dig +short txt _dmarc.lyxal.com
```

⏳ **Attendre 10-30 minutes** pour la propagation DNS.

---

## 🎯 Étape 2 : Configuration SurrealDB Cloud

### 1. Créer un Compte SurrealDB Cloud

```
1. Aller sur https://surrealdb.com/cloud
2. Sign up (gratuit pour débuter)
3. Créer une nouvelle instance
   - Région : Europe (RGPD compliant)
   - Plan : Free tier (ou Starter 25$/mois)
```

### 2. Obtenir les Credentials

Après création de l'instance, notez :
- **Endpoint** : `wss://cloud.surrealdb.com:443/rpc`
- **Username** : Votre username
- **Password** : Votre password sécurisé
- **Namespace** : `lyxal_solution`
- **Database** : `main`

### 3. Connexion à SurrealDB Cloud

```bash
# Installation CLI SurrealDB
curl -sSf https://install.surrealdb.com | sh

# Connexion
surreal sql \
  --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main \
  --username votre-username \
  --password votre-password
```

### 4. Import du Schéma Lyxal Mail

```bash
# Import des tables
surreal import \
  --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main \
  --username votre-username \
  --password votre-password \
  database/schema.surql

# Import des seeds (templates, domaines)
surreal import \
  --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main \
  --username votre-username \
  --password votre-password \
  database/seeds.surql
```

### 5. Configuration du Domaine dans SurrealDB

```surql
-- Connexion à SurrealDB Cloud
USE NS lyxal_solution DB main;

-- Insertion du domaine lyxal.com
CREATE email_domain:lyxal_com SET
  domain = "lyxal.com",
  smtp_host = "mail.lyxal.com",
  smtp_port = 587,
  dkim_enabled = true,
  dkim_selector = "lyxal",
  dkim_private_key = "-----BEGIN RSA PRIVATE KEY-----
[COLLER ICI LE CONTENU DE dkim_private.pem]
-----END RSA PRIVATE KEY-----",
  spf_record = "v=spf1 ip4:123.45.67.89 ~all",
  dmarc_record = "v=DMARC1; p=quarantine; rua=mailto:dmarc@lyxal.com",
  verified = true,
  verified_at = time::now(),
  tenant_id = "lyxal",
  tenant_name = "Lyxal",
  active = true;

-- Vérification
SELECT * FROM email_domain:lyxal_com;
```

---

## 🎯 Étape 3 : Déploiement du Worker sur Bunny Container

### 1. Préparation du Code

```bash
# Cloner le repo ou créer le dossier
mkdir lyxal-mail-worker
cd lyxal-mail-worker

# Fichiers nécessaires (voir WORKER.md)
# - main.go
# - config.go
# - queue_listener.go
# - smtp_sender.go
# - dkim_signer.go
# - go.mod
# - config.yml
# - Dockerfile
```

### 2. Configuration `config.yml`

```yaml
surrealdb:
  url: "${SURREALDB_URL}"
  host: "${SURREALDB_HOST}"
  namespace: "lyxal_solution"
  database: "main"
  username: "${SURREALDB_USERNAME}"
  password: "${SURREALDB_PASSWORD}"

worker:
  concurrency: 3

logging:
  level: "info"
```

### 3. Build de l'Image Docker

```bash
# Build local
docker build -t lyxal-mail-worker .

# Test local (optionnel)
docker run --rm \
  -e SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc \
  -e SURREALDB_HOST=cloud.surrealdb.com:443 \
  -e SURREALDB_USERNAME=votre-username \
  -e SURREALDB_PASSWORD=votre-password \
  lyxal-mail-worker
```

### 4. Déploiement sur Bunny Container

#### Option A : Via Interface Web (Recommandé pour débuter)

```
1. Aller sur https://bunny.net/dashboard
2. Onglet "Container" → "New Container"
3. Nom : lyxal-mail-worker
4. Source : Upload Dockerfile ou GitHub
5. Variables d'environnement :
   - SURREALDB_URL = wss://cloud.surrealdb.com:443/rpc
   - SURREALDB_HOST = cloud.surrealdb.com:443
   - SURREALDB_USERNAME = votre-username
   - SURREALDB_PASSWORD = votre-password
6. Ressources :
   - CPU : 0.5 core
   - RAM : 512 MB
7. Auto-scaling :
   - Min instances : 1
   - Max instances : 5
8. Deploy
```

#### Option B : Via Bunny CLI

```bash
# Installation CLI (si disponible)
npm install -g @bunny.net/cli

# Login
bunny login

# Push image
docker tag lyxal-mail-worker bunny.net/lyxal/mail-worker:latest
docker push bunny.net/lyxal/mail-worker:latest

# Deploy
bunny deploy \
  --name lyxal-mail-worker \
  --image bunny.net/lyxal/mail-worker:latest \
  --env SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc \
  --env SURREALDB_HOST=cloud.surrealdb.com:443 \
  --env SURREALDB_USERNAME=votre-username \
  --env SURREALDB_PASSWORD=votre-password \
  --scale-min 1 \
  --scale-max 5 \
  --cpu 0.5 \
  --memory 512
```

### 5. Vérification du Déploiement

```bash
# Via CLI
bunny logs lyxal-mail-worker --follow

# Via interface web
https://bunny.net/dashboard/container/lyxal-mail-worker/logs
```

**Logs attendus** :
```
🚀 Lyxal Mail Worker starting...
✅ Config loaded: lyxal_solution@cloud.surrealdb.com:main
✅ Connected to SurrealDB
📡 Starting LIVE QUERY listener...
✅ LIVE QUERY started
👷 Worker #1 started
👷 Worker #2 started
👷 Worker #3 started
✅ Worker started, listening for emails...
```

---

## 🎯 Étape 4 : Tests de Délivrabilité

### 1. Test d'Envoi depuis SurrealDB Cloud

```surql
-- Connexion à SurrealDB Cloud
surreal sql --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution --database main

-- Envoi d'un email de test
SELECT fn::send_email(
  'votre-email@gmail.com',
  'verification_email',
  {
    first_name: 'Test',
    last_name: 'User',
    verification_link: 'https://app.lyxal.com/verify?test=123'
  },
  'fr',
  'lyxal.com',
  NONE
);
```

### 2. Vérification dans email_queue

```surql
-- Voir les emails pending
SELECT * FROM email_queue WHERE status = 'pending' ORDER BY created_at DESC LIMIT 10;

-- Voir les emails sent
SELECT * FROM email_queue WHERE status = 'sent' ORDER BY sent_at DESC LIMIT 10;

-- Voir les erreurs
SELECT * FROM email_queue WHERE status = 'failed' ORDER BY created_at DESC LIMIT 10;
```

### 3. Vérifier la Réception

- ✅ Email reçu en boîte de réception (pas spam)
- ✅ Headers DKIM valides
- ✅ Headers SPF valides

### 4. Tests de Délivrabilité

#### Mail Tester (Score sur 10)

```
1. Aller sur https://www.mail-tester.com
2. Copier l'email temporaire fourni
3. Envoyer un test via fn::send_email
4. Rafraîchir Mail Tester
5. Vérifier le score (objectif : >8/10)
```

#### MX Toolbox

```
1. Aller sur https://mxtoolbox.com/SuperTool.aspx
2. Tester SPF : "spf:lyxal.com"
3. Tester DKIM : "dkim:lyxal._domainkey.lyxal.com"
4. Tester DMARC : "dmarc:lyxal.com"
5. Blacklist check : "blacklist:123.45.67.89"
```

---

## 🎯 Étape 5 : Monitoring & Alertes

### Monitoring SurrealDB Cloud (Natif)

**Tableau de bord SurrealDB Cloud** :
- ✅ Queries per second
- ✅ Latence moyenne
- ✅ Storage utilisé
- ✅ Connexions actives
- ✅ Backups automatiques

### Monitoring Bunny Container (Natif)

**Tableau de bord Bunny.net** :
- ✅ Workers actifs (auto-scaling)
- ✅ CPU/RAM usage
- ✅ Logs en temps réel
- ✅ Coûts en temps réel

### Monitoring Lyxal Mail (Custom)

#### Dashboard dans Lyxal Central

```surql
-- Emails envoyés aujourd'hui
SELECT count() FROM email_queue 
WHERE status = 'sent' 
AND sent_at > time::now() - 1d;

-- Taux de succès
SELECT 
  count(IF status = 'sent' THEN 1 END) AS sent,
  count(IF status = 'failed' THEN 1 END) AS failed,
  (sent / (sent + failed)) * 100 AS success_rate
FROM email_queue
WHERE created_at > time::now() - 1d;

-- Latence moyenne
SELECT AVG(time::diff(sent_at, created_at)) AS avg_latency
FROM email_queue
WHERE status = 'sent'
AND sent_at > time::now() - 1h;
```

### Alertes (Optionnel)

#### Via Cloudflare Workers (Gratuit)

```javascript
// worker-alert.js
addEventListener('scheduled', event => {
  event.waitUntil(checkEmailStats());
});

async function checkEmailStats() {
  const db = await connectSurrealDB();
  const failed = await db.query('SELECT count() FROM email_queue WHERE status = "failed" AND created_at > time::now() - 1h');
  
  if (failed[0].count > 10) {
    await sendAlert('⚠️ Plus de 10 emails failed dans la dernière heure');
  }
}
```

---

## 🎯 Étape 6 : Optimisations Production

### 1. Warm-up de l'IP

**Important** : Nouvelle IP = réputation à construire

```
Jour 1-2 :   50 emails/jour
Jour 3-5 :   100 emails/jour
Jour 6-10 :  200 emails/jour
Jour 11-15 : 500 emails/jour
Jour 16-20 : 1000 emails/jour
Jour 21+ :   Volume cible
```

### 2. Rate Limiting

```surql
-- Limiter à 100 emails/heure par domaine
UPDATE email_domain:lyxal_com SET
  hourly_limit = 100,
  daily_limit = 2000;
```

### 3. Gestion des Bounces

```surql
-- Créer une fonction pour gérer les bounces
DEFINE FUNCTION fn::handle_bounce($email_id, $bounce_type) {
  LET $email = SELECT * FROM $email_id;
  
  -- Si hard bounce (email invalide), marquer l'adresse
  IF $bounce_type = 'hard' THEN
    UPDATE identity 
    SET email_bounced = true, email_bounce_type = 'hard'
    WHERE connexion.email = $email.to;
  END;
  
  -- Si soft bounce (boîte pleine), retry plus tard
  IF $bounce_type = 'soft' THEN
    UPDATE $email_id SET 
      status = 'pending',
      scheduled_at = time::now() + 6h;
  END;
};
```

---

## 🎯 Étape 7 : Scaling Horizontal (Si Nécessaire)

### Auto-Scaling Bunny Container

**Déjà configuré** ! Bunny scale automatiquement selon la charge :

```yaml
# Configuration dans Bunny Dashboard
scaling:
  min_instances: 1
  max_instances: 10  # Augmenter si volumes très élevés
  cpu_threshold: 70
  memory_threshold: 80
```

**Exemple réel** :
- Charge normale (9h-18h) : 2-3 workers
- Pic (lancement newsletter) : Scale automatique à 8-10 workers
- Nuit : Scale down à 1 worker

**Coût** : Paiement à l'usage uniquement ! 💰

---

## 📊 Checklist de Déploiement

### DNS (Cloudflare)
- [ ] Domaine ajouté à Cloudflare
- [ ] Record A (mail) configuré
- [ ] Record SPF configuré
- [ ] Record DKIM configuré (clé générée)
- [ ] Record DMARC configuré
- [ ] DNS propagé (dig tests OK)

### SurrealDB Cloud
- [ ] Instance créée (région EU)
- [ ] Credentials notés
- [ ] Schéma importé (database/schema.surql)
- [ ] Seeds importés (database/seeds.surql)
- [ ] Domaine configuré (email_domain:lyxal_com)
- [ ] Test de connexion OK

### Bunny Container
- [ ] Image Docker buildée
- [ ] Variables d'environnement configurées
- [ ] Worker déployé
- [ ] Logs OK (LIVE QUERY connecté)
- [ ] Auto-scaling configuré

### Tests
- [ ] Email de test envoyé
- [ ] Email reçu en boîte de réception
- [ ] Score Mail Tester > 8/10
- [ ] SPF, DKIM, DMARC validés
- [ ] Pas de blacklist (MX Toolbox)

### Monitoring
- [ ] Dashboard SurrealDB Cloud OK
- [ ] Dashboard Bunny Container OK
- [ ] Métriques Lyxal Mail accessibles
- [ ] Alertes configurées (optionnel)

---

## 🆘 Troubleshooting

### Problème : Worker ne se connecte pas à SurrealDB Cloud

```bash
# Vérifier les variables d'environnement
bunny env list lyxal-mail-worker

# Vérifier les logs
bunny logs lyxal-mail-worker --tail 50

# Tester la connexion depuis local
surreal sql --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main
```

**Solutions** :
- Vérifier l'URL (wss:// et pas ws://)
- Vérifier le port (443 pour Cloud)
- Vérifier username/password

### Problème : Emails en spam

**Causes possibles** :
1. DNS mal configuré (SPF/DKIM/DMARC)
2. IP blacklistée
3. Contenu suspect
4. Nouvelle IP sans réputation

**Solutions** :
```bash
# Vérifier DNS
dig +short txt lyxal.com
dig +short txt lyxal._domainkey.lyxal.com
dig +short txt _dmarc.lyxal.com

# Vérifier blacklist
host 89.67.45.123.zen.spamhaus.org

# Warm-up IP (voir Étape 6.1)
```

### Problème : Emails non envoyés

```surql
-- Vérifier les emails pending
SELECT * FROM email_queue WHERE status = 'pending' ORDER BY created_at DESC;

-- Vérifier les erreurs
SELECT * FROM email_queue WHERE status = 'failed' ORDER BY created_at DESC LIMIT 10;

-- Retry manuel
UPDATE email_queue 
SET status = 'pending', scheduled_at = time::now()
WHERE status = 'failed' AND attempts < 3;
```

---

## 💰 Coûts Mensuels Finaux

### MVP (0-1000 emails/jour)

| Service | Prix |
|---------|------|
| **SurrealDB Cloud** (Free tier) | 0$ |
| **Bunny Container** (1-2 workers) | 3-5$ |
| **Bunny CDN** (< 1TB) | 0$ |
| **Cloudflare** (DNS) | 0$ |
| **Total** | **~3-5$/mois** 🎉 |

### Production (10 000 emails/jour)

| Service | Prix |
|---------|------|
| **SurrealDB Cloud** (Starter) | 25$ |
| **Bunny Container** (3-5 workers) | 10-15$ |
| **Bunny CDN** (1-5TB) | 5-10$ |
| **Cloudflare** (DNS) | 0$ |
| **Total** | **~40-50$/mois** |

**ROI vs Brevo/Mailgun** :
- Brevo 10K emails/jour : 200-500$/mois
- Lyxal Mail : 40-50$/mois
- **Économie : ~150-450$/mois** ! 💰

---

## 🚀 Prochaines Étapes

1. **[MIGRATION.md](./MIGRATION.md)** → Migrer depuis Brevo/Mailgun vers Lyxal Mail
2. **[TEMPLATES.md](./TEMPLATES.md)** → Créer vos templates multilingues
3. **[FUNCTIONS.md](./FUNCTIONS.md)** → Explorer toutes les fonctions SurrealDB

---

## 📞 Support

- **Documentation** : Voir les fichiers `*.md` dans ce dossier
- **SurrealDB Cloud** : https://surrealdb.com/cloud/support
- **Bunny.net** : https://support.bunny.net
- **Cloudflare** : https://support.cloudflare.com

