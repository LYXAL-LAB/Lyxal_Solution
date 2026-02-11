# ⚙️ Fonctions SurrealDB - Lyxal Mail

Ce document contient le code complet de toutes les fonctions SurrealDB pour Lyxal Mail.

---

## 📋 Liste des Fonctions

1. **`fn::send_email()`** - Fonction principale d'envoi
2. **`fn::render_template()`** - Rendu de template multilingue
3. **`fn::retry_failed_emails()`** - Retry automatique
4. **`fn::get_email_stats()`** - Statistiques
5. **`fn::verify_domain_dns()`** - Vérification DNS
6. **`fn::cleanup_old_logs()`** - Maintenance

---

## 1️⃣ Fonction Principale : `fn::send_email()`

**Description** : Fonction principale pour envoyer un email. Gère le templating, la validation et l'enqueue.

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Envoi d'email principal
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::send_email(
  $to: string,
  $template_code: string,
  $variables: object,
  $language: string,
  $domain_name: string,
  $scheduled_at: option<datetime>
) {
  
  -- Validation email destinataire
  IF !string::is::email($to) {
    RETURN {
      success: false,
      error: 'invalid_email',
      message: 'Email destinataire invalide'
    };
  };
  
  -- Récupération du template
  LET $template = (SELECT * FROM email_template 
    WHERE code = $template_code 
    AND active = true 
    LIMIT 1);
  
  IF array::len($template) = 0 {
    RETURN {
      success: false,
      error: 'template_not_found',
      message: 'Template introuvable : ' + $template_code
    };
  };
  
  LET $template = $template[0];
  
  -- Vérification langue disponible
  IF !$template.subject[$language] {
    LET $language = 'fr'; -- Fallback français
  };
  
  -- Récupération config domaine
  LET $domain = (SELECT * FROM email_domain 
    WHERE domain = $domain_name 
    AND active = true 
    LIMIT 1);
  
  IF array::len($domain) = 0 {
    RETURN {
      success: false,
      error: 'domain_not_found',
      message: 'Domaine introuvable : ' + $domain_name
    };
  };
  
  LET $domain = $domain[0];
  
  -- Vérification domaine vérifié
  IF !$domain.verified {
    RETURN {
      success: false,
      error: 'domain_not_verified',
      message: 'Le domaine ' + $domain_name + ' n\'est pas vérifié (DNS)'
    };
  };
  
  -- Rendu du template
  LET $rendered = fn::render_template($template, $variables, $language);
  
  IF !$rendered.success {
    RETURN $rendered;
  };
  
  -- Génération FROM
  LET $from = 'noreply@' + $domain_name;
  LET $from_name = IF $template.from_name THEN $template.from_name ELSE $domain.tenant_name END;
  
  -- Date d'envoi
  LET $send_at = IF $scheduled_at THEN $scheduled_at ELSE time::now() END;
  
  -- Création de l'email dans la queue
  LET $email = CREATE email_queue SET
    to = $to,
    from = $from,
    from_name = $from_name,
    subject = $rendered.subject,
    html_body = $rendered.html_body,
    text_body = $rendered.text_body,
    domain = $domain.id,
    template_code = $template_code,
    status = 'pending',
    scheduled_at = $send_at,
    metadata = {
      template_code: $template_code,
      language: $language,
      variables: $variables
    };
  
  -- Log événement "queued"
  CREATE email_log SET
    email_id = $email.id,
    event = 'queued',
    details = {
      template: $template_code,
      language: $language
    };
  
  RETURN {
    success: true,
    email_id: $email.id,
    scheduled_at: $send_at
  };
};
```

---

## 2️⃣ Fonction de Rendu : `fn::render_template()`

**Description** : Rend un template avec variables en remplaçant `{{variable}}` par les valeurs.

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Rendu de template multilingue
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::render_template(
  $template: object,
  $variables: object,
  $language: string
) {
  
  -- Récupération du contenu dans la langue
  LET $subject = $template.subject[$language];
  LET $html_body = $template.body_html[$language];
  LET $text_body = $template.body_text[$language];
  
  -- Vérification contenu existe
  IF !$subject OR !$html_body {
    RETURN {
      success: false,
      error: 'template_language_missing',
      message: 'Template non disponible pour la langue : ' + $language
    };
  };
  
  -- Fonction de remplacement de variables
  -- Remplace {{variable}} par la valeur
  FOR $var_name IN array::sort(object::keys($variables)) {
    LET $var_value = $variables[$var_name];
    LET $placeholder = '{{' + $var_name + '}}';
    
    -- Remplacement dans subject
    LET $subject = string::replace($subject, $placeholder, $var_value);
    
    -- Remplacement dans html_body
    LET $html_body = string::replace($html_body, $placeholder, $var_value);
    
    -- Remplacement dans text_body (si existe)
    IF $text_body {
      LET $text_body = string::replace($text_body, $placeholder, $var_value);
    };
  };
  
  -- Vérification variables manquantes
  -- Si encore des {{...}} c'est qu'il manque des variables
  IF string::contains($subject, '{{') OR string::contains($html_body, '{{') {
    RETURN {
      success: false,
      error: 'missing_variables',
      message: 'Variables manquantes dans le template'
    };
  };
  
  RETURN {
    success: true,
    subject: $subject,
    html_body: $html_body,
    text_body: $text_body
  };
};
```

---

## 3️⃣ Fonction de Retry : `fn::retry_failed_emails()`

**Description** : Retry automatique des emails en échec avec backoff exponentiel.

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Retry des emails en échec
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::retry_failed_emails() {
  
  -- Récupération emails éligibles au retry
  LET $to_retry = SELECT * FROM email_queue 
    WHERE status = 'failed' 
    AND attempts < max_attempts
    AND scheduled_at <= time::now();
  
  LET $retried_count = 0;
  
  -- Retry chaque email
  FOR $email IN $to_retry {
    -- Calcul backoff exponentiel : 5min * 2^attempts
    LET $backoff_minutes = 5 * math::pow(2, $email.attempts);
    LET $next_attempt = time::now() + duration::from::mins($backoff_minutes);
    
    -- Mise à jour statut
    UPDATE $email.id SET 
      status = 'pending',
      attempts = $email.attempts + 1,
      scheduled_at = $next_attempt,
      error_message = NONE,
      error_code = NONE;
    
    -- Log retry
    CREATE email_log SET
      email_id = $email.id,
      event = 'retry',
      details = {
        attempt: $email.attempts + 1,
        next_scheduled: $next_attempt
      };
    
    LET $retried_count = $retried_count + 1;
  };
  
  RETURN {
    success: true,
    retried_count: $retried_count,
    message: string::concat('Retried ', $retried_count, ' emails')
  };
};
```

---

## 4️⃣ Fonction Analytics : `fn::get_email_stats()`

**Description** : Récupère les statistiques d'envoi (temps réel ou agrégées).

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Statistiques emails
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_email_stats(
  $domain_name: option<string>,
  $start_date: option<datetime>,
  $end_date: option<datetime>
) {
  
  -- Dates par défaut (dernières 24h)
  LET $start = IF $start_date THEN $start_date ELSE time::now() - 24h END;
  LET $end = IF $end_date THEN $end_date ELSE time::now() END;
  
  -- Requête de base
  LET $query = SELECT * FROM email_queue 
    WHERE created_at >= $start 
    AND created_at <= $end;
  
  -- Filtre par domaine si spécifié
  IF $domain_name {
    LET $domain = (SELECT * FROM email_domain WHERE domain = $domain_name LIMIT 1)[0];
    LET $query = SELECT * FROM email_queue 
      WHERE created_at >= $start 
      AND created_at <= $end
      AND domain = $domain.id;
  };
  
  -- Agrégation des métriques
  LET $total = array::len($query);
  LET $sent = array::len(SELECT * FROM $query WHERE status = 'sent');
  LET $pending = array::len(SELECT * FROM $query WHERE status = 'pending');
  LET $failed = array::len(SELECT * FROM $query WHERE status = 'failed');
  
  -- Calcul taux
  LET $delivery_rate = IF $total > 0 THEN ($sent / $total) * 100 ELSE 0 END;
  
  -- Latence moyenne (temps entre création et envoi)
  LET $sent_emails = SELECT created_at, sent_at FROM $query WHERE status = 'sent';
  LET $total_latency = 0;
  
  FOR $email IN $sent_emails {
    IF $email.sent_at {
      LET $latency = time::unix($email.sent_at) - time::unix($email.created_at);
      LET $total_latency = $total_latency + $latency;
    };
  };
  
  LET $avg_latency = IF array::len($sent_emails) > 0 
    THEN $total_latency / array::len($sent_emails) 
    ELSE 0 END;
  
  -- Statistiques d'engagement (si tracking activé)
  LET $opened = 0;
  LET $clicked = 0;
  
  FOR $email IN $query {
    LET $opened = $opened + $email.tracking.opens;
    LET $clicked = $clicked + $email.tracking.clicks;
  };
  
  LET $open_rate = IF $sent > 0 THEN ($opened / $sent) * 100 ELSE 0 END;
  LET $click_rate = IF $sent > 0 THEN ($clicked / $sent) * 100 ELSE 0 END;
  
  RETURN {
    period: {
      start: $start,
      end: $end
    },
    domain: $domain_name,
    metrics: {
      total: $total,
      sent: $sent,
      pending: $pending,
      failed: $failed,
      delivery_rate: math::round($delivery_rate * 100) / 100,
      avg_latency_seconds: math::round($avg_latency * 100) / 100
    },
    engagement: {
      opened: $opened,
      clicked: $clicked,
      open_rate: math::round($open_rate * 100) / 100,
      click_rate: math::round($click_rate * 100) / 100
    }
  };
};
```

---

## 5️⃣ Fonction Vérification DNS : `fn::verify_domain_dns()`

**Description** : Vérifie que les enregistrements DNS (SPF, DKIM) sont correctement configurés.

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Vérification DNS d'un domaine
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::verify_domain_dns($domain_name: string) {
  
  -- Récupération du domaine
  LET $domain = (SELECT * FROM email_domain 
    WHERE domain = $domain_name 
    LIMIT 1);
  
  IF array::len($domain) = 0 {
    RETURN {
      success: false,
      error: 'domain_not_found',
      message: 'Domaine introuvable : ' + $domain_name
    };
  };
  
  LET $domain = $domain[0];
  
  -- Vérification SPF via DNS (requête externe)
  -- Note: SurrealDB ne peut pas faire de requêtes DNS directement
  -- Cette vérification doit être faite par le worker ou un service externe
  -- Ici on vérifie juste que le record est configuré dans la base
  
  LET $checks = {
    spf_configured: IF $domain.spf_record THEN true ELSE false END,
    dkim_configured: IF $domain.dkim_private_key THEN true ELSE false END,
    dmarc_configured: IF $domain.dmarc_record THEN true ELSE false END
  };
  
  -- Tous les checks doivent passer
  LET $all_passed = $checks.spf_configured 
    AND $checks.dkim_configured 
    AND $checks.dmarc_configured;
  
  -- Mise à jour du statut de vérification
  IF $all_passed {
    UPDATE $domain.id SET 
      verified = true,
      verified_at = time::now();
  };
  
  RETURN {
    success: true,
    domain: $domain_name,
    checks: $checks,
    verified: $all_passed,
    message: IF $all_passed 
      THEN 'Domaine vérifié avec succès' 
      ELSE 'Configuration DNS incomplète' END
  };
};
```

---

## 6️⃣ Fonction Maintenance : `fn::cleanup_old_logs()`

**Description** : Nettoie les anciens logs pour optimiser la base.

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Nettoyage des anciens logs
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::cleanup_old_logs($retention_days: int) {
  
  -- Date limite (par défaut 90 jours)
  LET $days = IF $retention_days THEN $retention_days ELSE 90 END;
  LET $cutoff_date = time::now() - duration::from::days($days);
  
  -- Suppression des emails envoyés anciens
  LET $deleted_emails = DELETE email_queue 
    WHERE status = 'sent' 
    AND sent_at < $cutoff_date;
  
  -- Suppression des logs anciens
  LET $deleted_logs = DELETE email_log 
    WHERE timestamp < $cutoff_date;
  
  -- Suppression des emails failed trop anciens (après max retry)
  LET $deleted_failed = DELETE email_queue 
    WHERE status = 'failed' 
    AND attempts >= max_attempts 
    AND created_at < $cutoff_date;
  
  RETURN {
    success: true,
    deleted: {
      emails: array::len($deleted_emails),
      logs: array::len($deleted_logs),
      failed: array::len($deleted_failed)
    },
    cutoff_date: $cutoff_date,
    retention_days: $days
  };
};
```

---

## 7️⃣ Fonction Agrégation : `fn::aggregate_daily_stats()`

**Description** : Agrège les statistiques quotidiennes dans `email_stats`.

### Code Complet

```surql
-- =================================================================================================
-- FUNCTION : Agrégation des stats quotidiennes
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::aggregate_daily_stats($date: datetime) {
  
  -- Début et fin de la journée
  LET $start = time::floor($date, 1d);
  LET $end = $start + 1d;
  
  -- Récupération de tous les domaines
  LET $domains = SELECT * FROM email_domain WHERE active = true;
  
  FOR $domain IN $domains {
    
    -- Récupération emails de ce domaine pour cette date
    LET $emails = SELECT * FROM email_queue 
      WHERE domain = $domain.id
      AND created_at >= $start 
      AND created_at < $end;
    
    -- Calcul métriques
    LET $sent = array::len(SELECT * FROM $emails WHERE status = 'sent');
    LET $failed = array::len(SELECT * FROM $emails WHERE status = 'failed');
    LET $bounced = array::len(SELECT * FROM email_log 
      WHERE email_id IN array::map($emails, |$e| $e.id)
      AND event = 'bounced');
    
    LET $opened = 0;
    LET $clicked = 0;
    
    FOR $email IN $emails {
      LET $opened = $opened + $email.tracking.opens;
      LET $clicked = $clicked + $email.tracking.clicks;
    };
    
    -- Calcul taux
    LET $total = array::len($emails);
    LET $delivery_rate = IF $total > 0 THEN (($sent - $bounced) / $total) * 100 ELSE 0 END;
    LET $open_rate = IF $sent > 0 THEN ($opened / $sent) * 100 ELSE 0 END;
    LET $click_rate = IF $sent > 0 THEN ($clicked / $sent) * 100 ELSE 0 END;
    
    -- Upsert dans email_stats
    LET $stat_id = 'email_stats:' + string::replace($domain.id, ':', '_') + '_' + time::format($start, '%Y%m%d');
    
    UPDATE type::thing('email_stats', $stat_id) SET
      date = $start,
      domain = $domain.id,
      sent_count = $sent,
      failed_count = $failed,
      bounced_count = $bounced,
      opened_count = $opened,
      clicked_count = $clicked,
      delivery_rate = $delivery_rate,
      open_rate = $open_rate,
      click_rate = $click_rate
    -- Si n'existe pas, créer
    IF NONE {
      CREATE type::thing('email_stats', $stat_id) SET
        date = $start,
        domain = $domain.id,
        sent_count = $sent,
        failed_count = $failed,
        bounced_count = $bounced,
        opened_count = $opened,
        clicked_count = $clicked,
        delivery_rate = $delivery_rate,
        open_rate = $open_rate,
        click_rate = $click_rate
    };
  };
  
  RETURN {
    success: true,
    date: $start,
    aggregated_domains: array::len($domains)
  };
};
```

---

## 🔄 Events & Triggers

### Event : Notification Worker

```surql
-- =================================================================================================
-- EVENT : Notification worker lors d'un nouvel email
-- =================================================================================================

DEFINE EVENT IF NOT EXISTS email_queued ON email_queue WHEN $event = "CREATE" THEN {
  -- Le worker reçoit automatiquement la notification via LIVE QUERY
  -- Pas besoin d'action supplémentaire ici
  -- On log juste l'événement
  CREATE email_log SET
    email_id = $value.id,
    event = 'queued';
};
```

### Event : Update Stats après envoi

```surql
-- =================================================================================================
-- EVENT : Update stats après envoi réussi
-- =================================================================================================

DEFINE EVENT IF NOT EXISTS email_sent ON email_queue WHEN $event = "UPDATE" AND $after.status = 'sent' THEN {
  -- Log événement sent
  CREATE email_log SET
    email_id = $after.id,
    event = 'sent',
    details = {
      sent_at: $after.sent_at,
      attempts: $after.attempts
    };
};
```

---

## 🔧 Cron Jobs (Scheduled Tasks)

### Cron : Retry automatique

```surql
-- =================================================================================================
-- CRON : Retry des emails failed toutes les 5 minutes
-- =================================================================================================

-- À configurer dans SurrealDB ou via un scheduler externe
-- Appeler : fn::retry_failed_emails() toutes les 5 minutes
```

### Cron : Agrégation quotidienne

```surql
-- =================================================================================================
-- CRON : Agrégation des stats tous les jours à minuit
-- =================================================================================================

-- À configurer dans SurrealDB ou via un scheduler externe
-- Appeler : fn::aggregate_daily_stats(time::now() - 1d) tous les jours à 00:05
```

### Cron : Nettoyage logs

```surql
-- =================================================================================================
-- CRON : Nettoyage des anciens logs toutes les semaines
-- =================================================================================================

-- À configurer dans SurrealDB ou via un scheduler externe
-- Appeler : fn::cleanup_old_logs(90) tous les dimanches à 02:00
```

---

## 📝 Exemples d'Utilisation

### Exemple 1 : Envoi Email de Vérification

```surql
-- Dans fn::create_identity
SELECT fn::send_email(
  'user@example.com',
  'verification_email',
  {
    first_name: 'Jean',
    last_name: 'Dupont',
    verification_link: 'https://app.lyxal.com/verify?id=jean_dupont_abc123&token=xyz789'
  },
  'fr',
  'lyxal.com',
  NONE  -- Envoi immédiat
);
```

### Exemple 2 : Email Programmé

```surql
-- Newsletter programmée pour demain 10h
SELECT fn::send_email(
  'user@example.com',
  'newsletter_monthly',
  { first_name: 'Marie' },
  'fr',
  'lyxal.com',
  time::now() + 1d + 10h  -- Programmé
);
```

### Exemple 3 : White-Label (Partenaire)

```surql
-- BatiPro envoie depuis son domaine
SELECT fn::send_email(
  'client@entreprise.com',
  'invoice_created',
  { 
    invoice_number: 'FACT-2025-001',
    amount: '1250.00',
    due_date: '2025-02-15'
  },
  'fr',
  'batipro.com',  -- ← Domaine du partenaire
  NONE
);
```

### Exemple 4 : Récupération Stats

```surql
-- Stats des dernières 24h pour lyxal.com
SELECT fn::get_email_stats('lyxal.com', time::now() - 24h, time::now());

-- Stats de la semaine dernière (tous domaines)
SELECT fn::get_email_stats(NONE, time::now() - 7d, time::now());
```

---

## 🚀 Prochaines Étapes

Voir **[WORKER.md](./WORKER.md)** pour le code complet du worker Go qui consomme ces fonctions.

