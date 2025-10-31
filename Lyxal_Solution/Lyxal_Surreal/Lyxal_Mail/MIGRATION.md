# 🔄 Migration - Lyxal Mail (Cloud-Native)

Ce document explique comment migrer progressivement de Brevo/Mailgun vers **Lyxal Mail Cloud** (SurrealDB Cloud + Bunny Container).

**Objectif** : Migration **0 downtime**, progressive, réversible, avec **0 serveur à gérer**.

---

## 🎯 Stratégie de Migration Cloud-Native

### Approche Recommandée : Progressive (Blue-Green Cloud)

```
Phase 1 (Semaine 1-2) : Setup Cloud + Warm-up IP
Phase 2 (Semaine 3-4) : 10% trafic → Lyxal Mail Cloud
Phase 3 (Semaine 5-6) : 50% trafic → Lyxal Mail Cloud
Phase 4 (Semaine 7)   : 80% trafic → Lyxal Mail Cloud
Phase 5 (Semaine 8)   : 100% trafic → Lyxal Mail Cloud
Phase 6 (Semaine 9+)  : Désactivation Brevo/Mailgun
```

**Avantages Cloud** :
- ✅ Aucune interruption de service
- ✅ Rollback possible à tout moment
- ✅ Validation progressive
- ✅ **0 maintenance infrastructure** (SurrealDB Cloud + Bunny Container)
- ✅ **Auto-scaling automatique** (Bunny gère la charge)
- ✅ Risques minimisés

---

## 📋 Prérequis de Migration

### Comptes Cloud (Free Tier disponibles)

- [ ] **SurrealDB Cloud** : https://surrealdb.com/cloud
- [ ] **Bunny.net** : https://bunny.net
- [ ] **Cloudflare** : https://cloudflare.com (DNS gratuit)

### Service Actuel (Brevo/Mailgun)

- [ ] API keys actives
- [ ] Accès aux templates
- [ ] Accès aux logs et stats
- [ ] Webhooks documentés (optionnel)

### Préparation

- [ ] Équipe technique formée (SurrealDB + Bunny)
- [ ] Budget cloud validé (~40-50$/mois en production)
- [ ] Domaine avec accès DNS (migration vers Cloudflare)
- [ ] Calendrier de migration défini (8 semaines)

---

## 🚀 Phase 1 : Setup Cloud & Warm-up (Semaine 1-2)

### 1.1. Configuration SurrealDB Cloud

```bash
# 1. Créer compte SurrealDB Cloud
https://surrealdb.com/cloud → Sign Up

# 2. Créer une instance
- Région : Europe (RGPD compliant)
- Plan : Free tier (ou Starter 25$/mois)

# 3. Connexion
surreal sql \
  --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main \
  --username votre-username \
  --password votre-password

# 4. Import du schéma
surreal import \
  --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main \
  --username votre-username \
  --password votre-password \
  database/schema.surql
```

### 1.2. Configuration Cloudflare DNS

```
1. Ajouter lyxal.com à Cloudflare (gratuit)
2. Changer les nameservers chez votre registrar
3. Configurer les records :
   - A : mail.lyxal.com → IP Bunny
   - TXT (SPF) : v=spf1 ip4:... ~all
   - TXT (DKIM) : lyxal._domainkey → clé publique
   - TXT (DMARC) : _dmarc → politique
```

**Voir [DEPLOYMENT.md](./DEPLOYMENT.md) Étape 1** pour les détails complets.

### 1.3. Déploiement Worker sur Bunny Container

```bash
# 1. Build Docker image
docker build -t lyxal-mail-worker .

# 2. Déploiement via interface Bunny.net
https://bunny.net/dashboard/container → New Container

# Configuration :
- Name : lyxal-mail-worker
- CPU : 0.5 core
- RAM : 512 MB
- Min instances : 1
- Max instances : 5 (auto-scaling)
- Env vars :
  * SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc
  * SURREALDB_USERNAME=votre-username
  * SURREALDB_PASSWORD=votre-password
```

**Voir [DEPLOYMENT.md](./DEPLOYMENT.md) Étape 3** pour les détails complets.

### 1.4. Configuration du Domaine dans SurrealDB

```surql
-- Connexion à SurrealDB Cloud
USE NS lyxal_solution DB main;

-- Configuration domaine avec clé DKIM
CREATE email_domain:lyxal_com SET
  domain = "lyxal.com",
  smtp_host = "mail.lyxal.com",
  smtp_port = 587,
  dkim_enabled = true,
  dkim_selector = "lyxal",
  dkim_private_key = "-----BEGIN RSA PRIVATE KEY-----
[VOTRE CLÉ DKIM ICI]
-----END RSA PRIVATE KEY-----",
  spf_record = "v=spf1 ip4:123.45.67.89 ~all",
  dmarc_record = "v=DMARC1; p=quarantine; rua=mailto:dmarc@lyxal.com",
  verified = true,
  verified_at = time::now(),
  tenant_id = "lyxal",
  tenant_name = "Lyxal",
  active = true;
```

### 1.5. Migration des Templates

#### Depuis Brevo

```surql
-- Exemple : Template de vérification
CREATE email_template:verification_email SET
  code = "verification_email",
  name = {
    fr: "Email de vérification",
    en: "Verification Email"
  },
  subject = {
    fr: "Vérifiez votre email - Lyxal",
    en: "Verify your email - Lyxal"
  },
  body_html = {
    fr: "<html>[HTML COPIÉ DEPUIS BREVO]</html>",
    en: "<html>[HTML COPIED FROM BREVO]</html>"
  },
  body_text = {
    fr: "Version texte...",
    en: "Plain text version..."
  },
  variables = ["first_name", "last_name", "verification_link"],
  category = "transactional",
  active = true;
```

**Conversion des variables** :
- Brevo : `{{ variable }}` (avec espaces)
- Lyxal : `{{variable}}` (sans espaces)

```javascript
// Script de conversion
function convertBrevoToLyxal(html) {
  return html.replace(/\{\{\s*(\w+)\s*\}\}/g, '{{$1}}');
}
```

#### Depuis Mailgun

```javascript
// Mailgun utilise %recipient.variable%
function convertMailgunToLyxal(html) {
  return html.replace(/%recipient\.(\w+)%/g, '{{$1}}');
}
```

### 1.6. Warm-up de l'IP

**Important** : Nouvelle IP = réputation à construire progressivement.

```
Jour 1-2 :   50 emails/jour   (emails internes)
Jour 3-5 :   100 emails/jour  (emails internes + test)
Jour 6-10 :  200 emails/jour  (emails internes + test)
Jour 11-15 : 500 emails/jour  (début emails externes)
```

**Script de warm-up** :

```surql
-- Envoi quotidien d'emails internes
FOR $user IN (SELECT * FROM identity WHERE internal = true LIMIT 50) {
  SELECT fn::send_email(
    $user.connexion.email,
    'internal_newsletter',
    { first_name: $user.identity.first_name },
    string::split($user.preferences.language, ':')[1],
    'lyxal.com'
  );
};
```

### 1.7. Tests de Délivrabilité

```bash
# Test avec Mail Tester
1. Aller sur https://www.mail-tester.com
2. Envoyer un email de test à l'adresse fournie
3. Vérifier le score (objectif : >8/10)

# Test avec MX Toolbox
https://mxtoolbox.com/SuperTool.aspx
- Test SPF : spf:lyxal.com
- Test DKIM : dkim:lyxal._domainkey.lyxal.com
- Test DMARC : dmarc:lyxal.com
- Blacklist check : 123.45.67.89
```

**Critères de validation** :
- ✅ Score Mail Tester > 8/10
- ✅ SPF, DKIM, DMARC validés
- ✅ Pas de blacklist
- ✅ Emails reçus en inbox (pas spam)

---

## 🔄 Phase 2 : Routing 10% (Semaine 3-4)

### 2.1. Configuration du Routing dans SurrealDB

```surql
-- Table de configuration routing
CREATE config:email_routing SET
  lyxal_mail_percentage = 10,
  brevo_enabled = true,
  brevo_api_key = "votre-api-key-brevo",
  monitoring_enabled = true,
  created_at = time::now();
```

### 2.2. Fonction de Routing Cloud-Native

**Option A : Routing dans SurrealDB (Recommandé)**

```surql
-- Fonction de routing intelligente
DEFINE FUNCTION fn::send_email_with_routing(
  $to: string,
  $template: string,
  $variables: object,
  $language: string,
  $domain: string
) {
  -- Récupérer la config de routing
  LET $routing = (SELECT * FROM config:email_routing LIMIT 1)[0];
  LET $percentage = $routing.lyxal_mail_percentage;
  
  -- Génération aléatoire (0-100)
  LET $random = math::floor(math::random() * 100);
  
  IF $random < $percentage THEN
    -- Route vers Lyxal Mail Cloud (natif)
    RETURN fn::send_email($to, $template, $variables, $language, $domain);
  ELSE
    -- Route vers Brevo (fallback via HTTP)
    RETURN http::post('https://api.brevo.com/v3/smtp/email', {
      headers: { 
        'api-key': $routing.brevo_api_key,
        'Content-Type': 'application/json'
      },
      body: {
        to: [{ email: $to }],
        templateId: $template,
        params: $variables
      }
    });
  END;
};
```

**Option B : Routing dans le Frontend (Si nécessaire)**

```typescript
// frontend/services/email-router.ts
import { Surreal } from 'surrealdb.js';

class EmailRouter {
  private db: Surreal;

  async send(email: EmailData) {
    const routing = await this.getRoutingConfig();
    
    if (Math.random() * 100 < routing.lyxal_mail_percentage) {
      return await this.sendViaLyxalCloud(email);
    } else {
      return await this.sendViaBrevo(email);
    }
  }

  private async getRoutingConfig() {
    return await this.db.query('SELECT * FROM config:email_routing LIMIT 1');
  }

  private async sendViaLyxalCloud(email: EmailData) {
    // Connexion directe à SurrealDB Cloud (WSS)
    const db = new Surreal();
    await db.connect('wss://cloud.surrealdb.com:443/rpc');
    await db.signin({ username: '...', password: '...' });
    await db.use('lyxal_solution', 'main');
    
    return await db.query(`
      SELECT fn::send_email(
        '${email.to}',
        '${email.template}',
        ${JSON.stringify(email.variables)},
        '${email.language}',
        'lyxal.com'
      )
    `);
  }

  private async sendViaBrevo(email: EmailData) {
    // API Brevo classique
    return await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: { 'api-key': process.env.BREVO_API_KEY },
      body: JSON.stringify({
        to: [{ email: email.to }],
        templateId: email.template,
        params: email.variables
      })
    });
  }
}
```

### 2.3. Déploiement du Routing

```bash
# 1. Update de la config dans SurrealDB Cloud
surreal sql --endpoint wss://cloud.surrealdb.com:443/rpc

UPDATE config:email_routing SET lyxal_mail_percentage = 10;

# 2. Vérifier le worker Bunny Container
bunny logs lyxal-mail-worker --follow

# 3. Observer l'auto-scaling
https://bunny.net/dashboard/container/lyxal-mail-worker/metrics
```

### 2.4. Monitoring Comparatif

**Métriques à surveiller** :

```surql
-- Stats Lyxal Mail Cloud (temps réel)
SELECT 
  count(IF status = 'sent' THEN 1 END) AS sent,
  count(IF status = 'failed' THEN 1 END) AS failed,
  (sent / (sent + failed)) * 100 AS delivery_rate,
  AVG(time::diff(sent_at, created_at)) AS avg_latency
FROM email_queue
WHERE created_at > time::now() - 1d;
```

**Dashboard Bunny Container** :
```
- Workers actifs : 1-2 (auto-scaling selon charge)
- CPU usage : ~30%
- RAM usage : ~200 MB
- Coût actuel : ~$0.10/jour
```

**Comparaison** :

| Métrique | Brevo | Lyxal Cloud | Objectif |
|----------|-------|-------------|----------|
| Delivery rate | 99.2% | 99.3% | >= Brevo |
| Latence moyenne | 2.5s | 2.3s | <= Brevo |
| Emails spam | 0.1% | 0.1% | <= Brevo |
| Coût/1000 emails | $1.50 | $0.05 | < Brevo |

**Critères de validation Phase 2** :
- ✅ Delivery rate >= Brevo
- ✅ Aucune régression de délivrabilité
- ✅ Worker Bunny stable (uptime 99.9%)
- ✅ Auto-scaling fonctionne correctement

---

## 📈 Phase 3 : Routing 50% (Semaine 5-6)

### 3.1. Augmentation Progressive

```surql
-- Augmentation à 50%
UPDATE config:email_routing SET
  lyxal_mail_percentage = 50,
  updated_at = time::now();

-- Vérification
SELECT * FROM config:email_routing;
```

### 3.2. Tests de Charge

**Objectif** : Vérifier que Bunny Container scale correctement.

```bash
# Observer le scaling automatique
bunny metrics lyxal-mail-worker --watch

# Pendant un pic d'envoi (ex: newsletter)
# Bunny devrait auto-scale de 1-2 workers à 4-5 workers
```

**Métriques attendues** :
- Workers : Auto-scale de 1-2 → 4-5 pendant les pics
- CPU : Reste < 70% même en pic
- RAM : Reste < 80% même en pic
- Latence : < 3s même en pic

### 3.3. Tests de Tous les Types d'Emails

```surql
-- Test emails transactionnels
SELECT fn::send_email_with_routing(..., 'verification_email', ...);

-- Test emails marketing
SELECT fn::send_email_with_routing(..., 'newsletter_monthly', ...);

-- Test emails système
SELECT fn::send_email_with_routing(..., 'password_reset', ...);

-- Test emails invoices
SELECT fn::send_email_with_routing(..., 'invoice_created', ...);
```

**Critères de validation Phase 3** :
- ✅ Tous les types d'emails OK
- ✅ Auto-scaling performant (pics gérés)
- ✅ Coûts Bunny Container prévisibles (~$2-3/jour)
- ✅ Monitoring stable (SurrealDB + Bunny)

---

## 🚀 Phase 4 : Routing 80% (Semaine 7)

### 4.1. Augmentation à 80%

```surql
UPDATE config:email_routing SET
  lyxal_mail_percentage = 80,
  updated_at = time::now();
```

### 4.2. Validation Finale avant 100%

**Checklist** :
- [ ] Delivery rate >= 99% sur 7 jours
- [ ] Aucun email critique en spam
- [ ] Worker Bunny Container uptime > 99.9%
- [ ] Auto-scaling testé en conditions réelles
- [ ] Coûts Cloud conformes au budget
- [ ] Équipe technique à l'aise avec la stack
- [ ] Procédure de rollback testée

**Procédure de Rollback** (si besoin) :

```surql
-- Rollback instantané à 10%
UPDATE config:email_routing SET
  lyxal_mail_percentage = 10;

-- Ou rollback total à 0% (100% Brevo)
UPDATE config:email_routing SET
  lyxal_mail_percentage = 0;
```

---

## 🎉 Phase 5 : Migration 100% (Semaine 8)

### 5.1. Basculement Complet

```surql
-- Connexion à SurrealDB Cloud
surreal sql --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution --database main

-- Basculement 100% Lyxal Mail Cloud
UPDATE config:email_routing SET
  lyxal_mail_percentage = 100,
  brevo_enabled = false,
  switched_at = time::now();

-- Vérification
SELECT * FROM config:email_routing;
```

### 5.2. Optimisation Auto-Scaling

```bash
# Si volumes très élevés, augmenter max_instances
bunny scale lyxal-mail-worker --max 10

# Configuration dans Bunny Dashboard
scaling:
  min_instances: 1
  max_instances: 10  # ← Augmenté
  cpu_threshold: 70
  memory_threshold: 80
```

### 5.3. Monitoring Post-Migration (48h)

**Métriques à surveiller intensivement** :

```surql
-- Monitoring continu
SELECT 
  count() AS total,
  count(IF status = 'sent' THEN 1 END) AS sent,
  count(IF status = 'failed' THEN 1 END) AS failed,
  (sent / total) * 100 AS success_rate,
  AVG(time::diff(sent_at, created_at)) AS avg_latency
FROM email_queue
WHERE created_at > time::now() - 1h
GROUP BY time::hour(created_at);
```

**Bunny Container Metrics** :
- Workers actifs : 2-8 (selon charge)
- Coût quotidien : ~$3-5/jour
- Uptime : > 99.9%

### 5.4. Validation Finale

**Critères de succès** :
- ✅ 48h sans incident majeur
- ✅ Delivery rate >= 99%
- ✅ Latence < 3s
- ✅ Auto-scaling stable
- ✅ Coûts conformes (~40-50$/mois)
- ✅ Équipe satisfaite

---

## 🔚 Phase 6 : Désactivation Brevo/Mailgun (Semaine 9+)

### 6.1. Période de Sécurité (1 mois)

**Garder Brevo actif mais non utilisé pendant 1 mois** :
- API key conservée
- Compte non résilié
- Possibilité de rollback si problème majeur

### 6.2. Résiliation Définitive

```bash
# 1. Export final des stats Brevo (pour historique)
# 2. Téléchargement des logs importants
# 3. Sauvegarde de la configuration Brevo
# 4. Résiliation du compte Brevo

# 5. Nettoyage du code
# Supprimer les références à Brevo dans le code
```

```surql
-- Supprimer la config Brevo de SurrealDB
UPDATE config:email_routing SET
  brevo_enabled = false,
  brevo_api_key = NONE;
```

### 6.3. Documentation Finale

- [ ] Documenter l'architecture Cloud finale
- [ ] Mettre à jour les runbooks
- [ ] Former toute l'équipe
- [ ] Documenter les procédures de monitoring
- [ ] Documenter les procédures d'alerte

---

## 💰 ROI de la Migration Cloud

### Comparaison des Coûts (10 000 emails/jour)

| Service | Brevo/Mailgun | Lyxal Mail Cloud | Économie |
|---------|---------------|------------------|----------|
| **Emails** | 200-500$/mois | 0$ (inclus) | 200-500$ |
| **SurrealDB** | N/A | 25$/mois (Cloud) | N/A |
| **Worker** | N/A | 10$/mois (Bunny) | N/A |
| **CDN** | N/A | 5$/mois (Bunny) | N/A |
| **DNS** | ~5$/mois | 0$ (Cloudflare) | 5$ |
| **Maintenance** | 0h (SaaS) | **0h** (Cloud géré) | 0h |
| **Serveurs VPS** | N/A | **0** (pas de VPS) | Temps économisé |
| **Total** | **205-510$/mois** | **40-50$/mois** | **155-460$/mois** 🎉 |

### ROI Timeline

```
Investissement initial :
- Migration (dev + tests) : 40h × 50€/h = 2000€
- Setup Cloud : 4h × 50€/h = 200€
- Configuration DNS : 2h × 50€/h = 100€
- Formation équipe : 4h × 50€/h = 200€
- Total : ~2500€

Économies mensuelles : 155-460€/mois

ROI : 5-16 mois
```

**Au-delà de 16 mois** :
- ✅ Pure économie (155-460€/mois)
- ✅ Contrôle total du code
- ✅ Indépendance des SaaS tiers
- ✅ **0 maintenance infrastructure**
- ✅ **Auto-scaling automatique**
- ✅ **Pas de limites de volume**

**Bonus** : Le temps économisé en maintenance (5-10h/mois avec un VPS) n'existe même pas ici ! C'est du 100% Cloud géré ! ⚡

---

## 📊 Checklist Complète de Migration

### Préparation Cloud
- [ ] Compte SurrealDB Cloud créé
- [ ] Compte Bunny.net créé
- [ ] Domaine migré vers Cloudflare DNS
- [ ] Budget cloud validé (~40-50$/mois)

### Phase 1 (Semaine 1-2)
- [ ] SurrealDB Cloud instance déployée
- [ ] Schéma importé dans SurrealDB Cloud
- [ ] Worker Bunny Container déployé
- [ ] DNS Cloudflare configuré (SPF, DKIM, DMARC)
- [ ] Templates migrés depuis Brevo/Mailgun
- [ ] Warm-up IP complété (500 emails/jour OK)
- [ ] Score Mail Tester > 8/10
- [ ] Auto-scaling Bunny testé

### Phase 2 (Semaine 3-4)
- [ ] Routing 10% configuré dans SurrealDB
- [ ] Monitoring comparatif en place
- [ ] Delivery rate >= Brevo
- [ ] Worker Bunny Container stable
- [ ] Coûts cloud suivis (~$0.50/jour)

### Phase 3 (Semaine 5-6)
- [ ] Routing augmenté à 50%
- [ ] Tests de charge réussis
- [ ] Auto-scaling validé (pics gérés)
- [ ] Tous types d'emails testés
- [ ] Aucune régression

### Phase 4 (Semaine 7)
- [ ] Routing augmenté à 80%
- [ ] Validation finale OK
- [ ] Équipe technique formée
- [ ] Procédure de rollback testée

### Phase 5 (Semaine 8)
- [ ] Basculement 100% Lyxal Mail Cloud
- [ ] Brevo désactivé (mais gardé 1 mois)
- [ ] Monitoring 48h stable
- [ ] Success rate >= 99%
- [ ] Coûts conformes (~$40-50/mois)

### Phase 6 (Semaine 9+)
- [ ] 1 mois de stabilité confirmée
- [ ] Compte Brevo résilié
- [ ] Documentation mise à jour
- [ ] Équipe autonome sur la stack Cloud
- [ ] Optimisations finales effectuées

---

## 🆘 Troubleshooting Migration

### Problème : Delivery rate < Brevo après migration

**Diagnostic** :
```surql
-- Analyser les failures
SELECT 
  error_code,
  count() AS count,
  array_agg(to) AS recipients
FROM email_queue
WHERE status = 'failed'
AND created_at > time::now() - 1d
GROUP BY error_code;
```

**Solutions** :
1. Vérifier SPF/DKIM/DMARC (DNS)
2. Vérifier IP non blacklistée
3. Ralentir le warm-up si nécessaire
4. Rollback temporaire à Brevo (10%)

### Problème : Worker Bunny Container ne scale pas

**Diagnostic** :
```bash
# Vérifier les logs Bunny
bunny logs lyxal-mail-worker --tail 100

# Vérifier la config auto-scaling
bunny config get lyxal-mail-worker
```

**Solutions** :
1. Vérifier les seuils de scaling (CPU/RAM)
2. Augmenter max_instances si nécessaire
3. Vérifier les quotas Bunny.net
4. Contacter le support Bunny

### Problème : Coûts Cloud > prévisions

**Diagnostic** :
```bash
# Dashboard Bunny : Coûts en temps réel
https://bunny.net/dashboard/billing

# Dashboard SurrealDB : Usage
https://surrealdb.com/cloud/usage
```

**Solutions** :
1. Optimiser le min_instances (scale down la nuit)
2. Analyser les pics de charge (réduire si possible)
3. Vérifier les queries SurrealDB (optimiser si lent)
4. Ajuster les ressources worker (0.5 CPU → 0.25 CPU ?)

### Problème : Rollback nécessaire

**Procédure d'urgence** :

```surql
-- Rollback immédiat à 0% Lyxal Mail
UPDATE config:email_routing SET
  lyxal_mail_percentage = 0,
  brevo_enabled = true;

-- Vérifier que Brevo reprend le trafic
-- Attendre 5 minutes
-- Analyser les logs Bunny et SurrealDB
-- Identifier le problème
-- Corriger
-- Retester avec 10%
```

---

## 🎯 Prochaines Étapes

Une fois la migration terminée :

1. **Optimisation** : Fine-tuning des ressources Bunny
2. **Monitoring avancé** : Alertes PagerDuty/Slack
3. **A/B Testing** : Tester différents templates
4. **Analytics** : Dashboard dédicat dans Lyxal Central
5. **White-Label** : Déployer pour les partenaires (BatiPro, etc.)

---

## 📞 Support Migration

- **Documentation** : Voir [DEPLOYMENT.md](./DEPLOYMENT.md), [ARCHITECTURE.md](./ARCHITECTURE.md)
- **SurrealDB Cloud** : https://surrealdb.com/cloud/support
- **Bunny.net** : https://support.bunny.net
- **Cloudflare** : https://support.cloudflare.com

---

**Migration réussie = Économies + Indépendance + 0 maintenance** ! 🎉🚀

