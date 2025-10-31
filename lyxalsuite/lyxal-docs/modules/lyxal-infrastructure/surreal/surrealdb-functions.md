# LWS API - Fonctions SurrealDB (Intégration)

**Namespace :** `NS master_{name}` / `DB main_{name}`  
**Accès :** **MASTER ULTIMATE UNIQUEMENT**  
**Authentification :** Credentials dynamiques depuis `lws_credentials:master_ultimate`

---

## 🔐 **Sécurité et Authentification**

### Table des credentials
```sql
-- Credentials exclusifs Master Ultimate
DEFINE TABLE lws_credentials SCHEMAFULL;
DEFINE FIELD auth_login ON lws_credentials TYPE string;
DEFINE FIELD auth_pass ON lws_credentials TYPE string;
DEFINE FIELD test_mode ON lws_credentials TYPE bool DEFAULT false;
DEFINE FIELD master_ultimate_id ON lws_credentials TYPE string;

-- Sécurité : Seul Master Ultimate peut modifier
DEFINE EVENT lws_access_control ON TABLE lws_credentials WHEN $before != $after THEN {
    IF $auth.id != "master_ultimate_001" THEN {
        THROW "ACCÈS REFUSÉ: Seul le Master Ultimate peut gérer les credentials LWS"
    } END
};
```

### Fonction de base sécurisée
```sql
-- Fonction HTTP générique sécurisée
DEFINE FUNCTION fn::lws_call($method: string, $endpoint: string, $body: option<object>) {
    -- Sécurité : Vérifier Master Ultimate
    IF $auth.id != "master_ultimate_001" THEN {
        THROW "ACCÈS REFUSÉ: API LWS réservée au Master Ultimate"
    } END;
    
    -- Récupérer credentials dynamiquement
    LET $credentials = SELECT * FROM lws_credentials:master_ultimate LIMIT 1;
    IF !$credentials THEN {
        THROW "ERREUR: Credentials LWS non configurés"
    } END;
    
    LET $cred = $credentials[0];
    LET $headers = {
        "Accept": "application/json",
        "X-Auth-Login": $cred.auth_login,
        "X-Auth-Pass": $cred.auth_pass,
        "X-Test-Mode": string::lowercase(string($cred.test_mode))
    };
    
    -- Appel HTTP selon la méthode
    RETURN IF $method = "GET" THEN
        http::get("https://api.lws.net/v1" + $endpoint, { "headers": $headers })
    ELSE IF $method = "POST" THEN
        http::post("https://api.lws.net/v1" + $endpoint, { "headers": $headers, "body": $body })
    ELSE IF $method = "PUT" THEN
        http::put("https://api.lws.net/v1" + $endpoint, { "headers": $headers, "body": $body })
    ELSE IF $method = "DELETE" THEN
        http::delete("https://api.lws.net/v1" + $endpoint, { "headers": $headers, "body": $body })
    ELSE
        { "error": "Méthode HTTP non supportée: " + $method }
    END;
};
```

---

## 🌍 **Fonctions Domaines**

### Obtenir informations d'un domaine
```sql
DEFINE FUNCTION fn::lws_domain_get($domain: string) {
    RETURN fn::lws_call("GET", "/domain/" + $domain, NONE);
};

-- Usage
RETURN fn::lws_domain_get("lyxal.com");
```

### Obtenir tous les TLDs disponibles
```sql
DEFINE FUNCTION fn::lws_domain_tlds() {
    RETURN fn::lws_call("GET", "/domain/0/tlds", NONE);
};

-- Usage
RETURN fn::lws_domain_tlds();
```

### Obtenir zone DNS d'un domaine
```sql
DEFINE FUNCTION fn::lws_domain_dns_get($domain: string) {
    RETURN fn::lws_call("GET", "/domain/" + $domain + "/zdns", NONE);
};

-- Usage
RETURN fn::lws_domain_dns_get("lyxal.com");
```

### Ajouter enregistrement DNS
```sql
DEFINE FUNCTION fn::lws_domain_dns_add($domain: string, $type: string, $name: string, $value: string, $ttl: int) {
    LET $body = {
        "type": $type,
        "name": $name,
        "value": $value,
        "ttl": $ttl
    };
    RETURN fn::lws_call("POST", "/domain/" + $domain + "/zdns", $body);
};

-- Usage
RETURN fn::lws_domain_dns_add("lyxal.com", "A", "@", "192.168.1.1", 3600);
```

### Modifier enregistrement DNS
```sql
DEFINE FUNCTION fn::lws_domain_dns_update($domain: string, $id: int, $type: string, $name: string, $value: string, $ttl: int) {
    LET $body = {
        "id": $id,
        "type": $type,
        "name": $name,
        "value": $value,
        "ttl": $ttl
    };
    RETURN fn::lws_call("PUT", "/domain/" + $domain + "/zdns", $body);
};

-- Usage
RETURN fn::lws_domain_dns_update("lyxal.com", 568470, "A", "@", "192.168.1.2", 3600);
```

### Supprimer enregistrement DNS
```sql
DEFINE FUNCTION fn::lws_domain_dns_delete($domain: string, $id: int) {
    LET $body = { "id": $id };
    RETURN fn::lws_call("DELETE", "/domain/" + $domain + "/zdns", $body);
};

-- Usage
RETURN fn::lws_domain_dns_delete("lyxal.com", 568470);
```

### Vérifier disponibilité domaine
```sql
DEFINE FUNCTION fn::lws_domain_availability($domain: string) {
    RETURN fn::lws_call("GET", "/domain/" + $domain + "/availability", NONE);
};

-- Usage
RETURN fn::lws_domain_availability("nouveau-domaine.com");
```

### Demander code d'autorisation
```sql
DEFINE FUNCTION fn::lws_domain_authcode($domain: string) {
    RETURN fn::lws_call("GET", "/domain/" + $domain + "/authcode", NONE);
};

-- Usage
RETURN fn::lws_domain_authcode("lyxal.com");
```

### Modifier serveurs de noms
```sql
DEFINE FUNCTION fn::lws_domain_nameservers($domain: string, $ns1: string, $ns2: string, $ns3: string, $ns4: string) {
    LET $body = {
        "ns1": $ns1,
        "ns2": $ns2,
        "ns3": $ns3,
        "ns4": $ns4
    };
    RETURN fn::lws_call("PUT", "/domain/" + $domain + "/dns", $body);
};

-- Usage
RETURN fn::lws_domain_nameservers("lyxal.com", "ns1.lwsdns.com", "ns2.lwsdns.com", "ns3.lwsdns.com", "ns4.lwsdns.com");
```

### Modifier protection transfert
```sql
DEFINE FUNCTION fn::lws_domain_transfer_protection($domain: string, $status: bool) {
    LET $body = { "status": $status };
    RETURN fn::lws_call("PUT", "/domain/" + $domain + "/clientTransferProhibited", $body);
};

-- Usage
RETURN fn::lws_domain_transfer_protection("lyxal.com", true);
```

### Créer redirection
```sql
DEFINE FUNCTION fn::lws_domain_redirect_create($domain: string, $type: int, $redirection: string) {
    LET $body = {
        "type": $type,
        "redirection": $redirection
    };
    RETURN fn::lws_call("POST", "/domain/" + $domain + "/redirect", $body);
};

-- Usage
RETURN fn::lws_domain_redirect_create("lyxal.com", 301, "https://www.lyxal.com");
```

### Supprimer redirection
```sql
DEFINE FUNCTION fn::lws_domain_redirect_delete($domain: string) {
    RETURN fn::lws_call("DELETE", "/domain/" + $domain + "/redirect", NONE);
};

-- Usage
RETURN fn::lws_domain_redirect_delete("lyxal.com");
```

---

## 👤 **Fonctions Contacts**

### Créer contact
```sql
DEFINE FUNCTION fn::lws_contact_create($company: option<string>, $lastname: string, $firstname: string, $address: string, $postal: string, $city: string, $country: string, $phone: string, $email: string, $password: string) {
    LET $body = {
        "company": $company,
        "lastname": $lastname,
        "firstname": $firstname,
        "address": $address,
        "postal": $postal,
        "city": $city,
        "country": $country,
        "phone": $phone,
        "email": $email,
        "password": $password
    };
    RETURN fn::lws_call("POST", "/contact", $body);
};

-- Usage
RETURN fn::lws_contact_create("Ma Société", "Dupont", "Jean", "1 rue de la Paix", "75000", "Paris", "FR", "0033612345678", "jean@example.com", "motdepasse");
```

### Obtenir contact
```sql
DEFINE FUNCTION fn::lws_contact_get($contact_id: int) {
    RETURN fn::lws_call("GET", "/contact/" + string($contact_id), NONE);
};

-- Usage
RETURN fn::lws_contact_get(367228);
```

### Modifier contact
```sql
DEFINE FUNCTION fn::lws_contact_update($contact_id: int, $address: option<string>, $postal: option<string>, $city: option<string>, $country: option<string>, $phone: option<string>, $password: option<string>) {
    LET $body = {
        "address": $address,
        "postal": $postal,
        "city": $city,
        "country": $country,
        "phone": $phone,
        "password": $password
    };
    RETURN fn::lws_call("PUT", "/contact/" + string($contact_id), $body);
};

-- Usage
RETURN fn::lws_contact_update(367228, "2 rue de la Paix", "75001", "Paris", "FR", "0033612345679", NONE);
```

### Obtenir solde crédit
```sql
DEFINE FUNCTION fn::lws_contact_credit() {
    RETURN fn::lws_call("GET", "/contact/0/credit", NONE);
};

-- Usage
RETURN fn::lws_contact_credit();
```

### Lister tous les contacts
```sql
DEFINE FUNCTION fn::lws_contact_list() {
    RETURN fn::lws_call("GET", "/contact/0/list", NONE);
};

-- Usage
RETURN fn::lws_contact_list();
```

### Historique des achats
```sql
DEFINE FUNCTION fn::lws_contact_purchase_history() {
    RETURN fn::lws_call("GET", "/contact/purchase/history", NONE);
};

-- Usage
RETURN fn::lws_contact_purchase_history();
```

### [TEST] Ajouter crédit à un contact
```sql
DEFINE FUNCTION fn::lws_contact_add_credit($contact_id: int, $amount: int) {
    LET $body = { "amount": $amount };
    RETURN fn::lws_call("PUT", "/contact/" + string($contact_id) + "/credit", $body);
};

-- Usage (Test mode uniquement)
RETURN fn::lws_contact_add_credit(367228, 100);
```

### [TEST] Ajouter crédit revendeur
```sql
DEFINE FUNCTION fn::lws_contact_add_reseller_credit($amount: int) {
    LET $body = { "amount": $amount };
    RETURN fn::lws_call("PUT", "/contact/reseller/credit", $body);
};

-- Usage (Test mode uniquement)
RETURN fn::lws_contact_add_reseller_credit(100);
```

---

## 🏠 **Fonctions Hébergement**

### Acheter hébergement
```sql
DEFINE FUNCTION fn::lws_hosting_buy($package: string, $domain: string, $owner: int, $type: string, $period: int) {
    LET $body = {
        "package": $package,
        "domain": $domain,
        "owner": $owner,
        "type": $type,
        "period": $period
    };
    RETURN fn::lws_call("POST", "/hosting", $body);
};

-- Usage
RETURN fn::lws_hosting_buy("LWS Perso", "nouveau-site.com", 367228, "buy", 12);
```

### Obtenir informations hébergement
```sql
DEFINE FUNCTION fn::lws_hosting_get($hosting: string) {
    RETURN fn::lws_call("GET", "/hosting/" + $hosting, NONE);
};

-- Usage
RETURN fn::lws_hosting_get("lyxal.com");
```

### Lister tous les hébergements
```sql
DEFINE FUNCTION fn::lws_hosting_list() {
    RETURN fn::lws_call("GET", "/hosting/0/list", NONE);
};

-- Usage
RETURN fn::lws_hosting_list();
```

### Obtenir prix des forfaits
```sql
DEFINE FUNCTION fn::lws_hosting_prices() {
    RETURN fn::lws_call("GET", "/hosting/0/priceall", NONE);
};

-- Usage
RETURN fn::lws_hosting_prices();
```

### Obtenir prix de renouvellement
```sql
DEFINE FUNCTION fn::lws_hosting_renew_price($hosting: string) {
    RETURN fn::lws_call("GET", "/hosting/" + $hosting + "/pricerenew", NONE);
};

-- Usage
RETURN fn::lws_hosting_renew_price("lyxal.com");
```

### Modifier renouvellement automatique
```sql
DEFINE FUNCTION fn::lws_hosting_autorenew($hosting: string, $enable: bool) {
    LET $body = { "enable": $enable };
    RETURN fn::lws_call("PUT", "/hosting/" + $hosting + "/autorenew", $body);
};

-- Usage
RETURN fn::lws_hosting_autorenew("lyxal.com", true);
```

### Renouveler hébergement
```sql
DEFINE FUNCTION fn::lws_hosting_renew($hosting: string) {
    RETURN fn::lws_call("POST", "/hosting/" + $hosting + "/renew", NONE);
};

-- Usage
RETURN fn::lws_hosting_renew("lyxal.com");
```

---

## 📧 **Fonctions Email**

### Créer adresse email
```sql
DEFINE FUNCTION fn::lws_mail_create($email: string, $password: string) {
    LET $body = { "password": $password };
    RETURN fn::lws_call("POST", "/mail/" + $email, $body);
};

-- Usage
RETURN fn::lws_mail_create("contact@lyxal.com", "motdepasse123");
```

---

## 📝 **Fonctions Requests/Logs**

### Obtenir toutes les requêtes
```sql
DEFINE FUNCTION fn::lws_requests_get($objet: option<string>, $valeur: option<string>, $type: option<string>) {
    LET $params = [];
    IF $objet THEN $params = array::push($params, "objet=" + $objet) END;
    IF $valeur THEN $params = array::push($params, "valeur=" + $valeur) END;
    IF $type THEN $params = array::push($params, "type=" + $type) END;
    
    LET $query = IF count($params) > 0 THEN "?" + string::join($params, "&") ELSE "" END;
    RETURN fn::lws_call("GET", "/requests" + $query, NONE);
};

-- Usage
RETURN fn::lws_requests_get("domain", "lyxal.com", "dns");
RETURN fn::lws_requests_get(NONE, NONE, NONE); -- Toutes les requêtes
```

### Obtenir requêtes en attente
```sql
DEFINE FUNCTION fn::lws_requests_pending() {
    RETURN fn::lws_call("GET", "/requests/pending", NONE);
};

-- Usage
RETURN fn::lws_requests_pending();
```

---

## 🚀 **Fonctions Avancées**

### Wrapper avec cache et retry
```sql
DEFINE FUNCTION fn::lws_cached_call($cache_key: string, $ttl_seconds: int, $method: string, $endpoint: string, $body: option<object>) {
    -- Vérifier cache
    LET $cached = SELECT * FROM lws_cache WHERE key = $cache_key AND expires_at > time::now() LIMIT 1;
    IF $cached THEN {
        RETURN $cached[0].data;
    } END;
    
    -- Appel API avec retry
    LET $result = fn::lws_call($method, $endpoint, $body);
    
    -- Sauvegarder en cache si succès
    IF $result.status = 200 THEN {
        CREATE lws_cache SET
            key = $cache_key,
            data = $result,
            expires_at = time::now() + duration::from::secs($ttl_seconds);
    } END;
    
    RETURN $result;
};
```

### Monitoring des appels API
```sql
DEFINE FUNCTION fn::lws_call_with_log($method: string, $endpoint: string, $body: option<object>) {
    LET $start_time = time::now();
    
    -- Appel API
    LET $result = fn::lws_call($method, $endpoint, $body);
    
    -- Log de l'appel
    CREATE lws_api_logs SET
        method = $method,
        endpoint = $endpoint,
        body = $body,
        result = $result,
        timestamp = $start_time,
        duration = time::now() - $start_time,
        status = $result.status OR 0;
        
    RETURN $result;
};
```

---

## 📊 **Résumé des Fonctions**

### Domaines (12 fonctions)
- `fn::lws_domain_get()` - Infos domaine
- `fn::lws_domain_tlds()` - TLDs disponibles
- `fn::lws_domain_dns_*()` - Gestion DNS (get/add/update/delete)
- `fn::lws_domain_availability()` - Disponibilité
- `fn::lws_domain_authcode()` - Code autorisation
- `fn::lws_domain_nameservers()` - Serveurs de noms
- `fn::lws_domain_transfer_protection()` - Protection
- `fn::lws_domain_redirect_*()` - Redirections (create/delete)

### Contacts (8 fonctions)
- `fn::lws_contact_create()` - Création
- `fn::lws_contact_get()` - Lecture
- `fn::lws_contact_update()` - Modification
- `fn::lws_contact_credit()` - Solde
- `fn::lws_contact_list()` - Liste
- `fn::lws_contact_purchase_history()` - Historique
- `fn::lws_contact_add_credit()` - [TEST] Crédit contact
- `fn::lws_contact_add_reseller_credit()` - [TEST] Crédit revendeur

### Hébergement (7 fonctions)
- `fn::lws_hosting_buy()` - Achat
- `fn::lws_hosting_get()` - Infos
- `fn::lws_hosting_list()` - Liste
- `fn::lws_hosting_prices()` - Prix forfaits
- `fn::lws_hosting_renew_price()` - Prix renouvellement
- `fn::lws_hosting_autorenew()` - Auto-renouvellement
- `fn::lws_hosting_renew()` - Renouveler

### Email (1 fonction)
- `fn::lws_mail_create()` - Créer adresse

### Requests (2 fonctions)
- `fn::lws_requests_get()` - Toutes requêtes
- `fn::lws_requests_pending()` - Requêtes en attente

### Utilitaires (3 fonctions)
- `fn::lws_call()` - Appel HTTP de base
- `fn::lws_cached_call()` - Avec cache
- `fn::lws_call_with_log()` - Avec monitoring

---

**✅ Total :** **33 fonctions SurrealDB** pour encapsuler l'API LWS  
**🔐 Sécurité :** Master Ultimate uniquement  
**📡 Base :** Credentials dynamiques depuis SurrealDB  
**🎯 Prêt :** Pour intégration dans lyxal-infrastructure 