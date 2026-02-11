# LWS API - Hébergement (Officiel)

**Base URL :** `https://api.lws.net/v1/`  
**Authentification :** Headers `X-Auth-Login` + `X-Auth-Pass` + `X-Test-Mode`

---

## 🛒 **Acheter un hébergement/domaine**

### POST /hosting

**[Différé] [Action payante]** Acheter un domaine ou un hébergement. Le compte sera débité pour l'hébergement choisi et, si 'buy' est sélectionné, pour le domaine.

#### Body JSON (required)
```json
{
  "package": "LWS Perso",        // Nom de l'hébergement à acheter
  "domain": "exemple.com",       // Nom de domaine à associer
  "owner": 565487,               // Propriétaire de l'hébergement (ID contact)
  "type": "buy",                 // buy|host|transfer
  "period": 12                   // Période en mois
}
```

#### Types d'achat
- **buy** : Acheter hébergement + domaine
- **host** : Acheter uniquement l'hébergement (domaine déjà possédé)
- **transfer** : Transférer un domaine existant vers LWS

#### Requête
```http
POST /v1/hosting HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 107

{
  "package": "LWS Perso",
  "domain": "exemple.com",
  "owner": 565487,
  "type": "buy",
  "period": 12
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Your domain example.com has been bought with the hosting LWS Perso.",
  "data": {}
}
```

#### Erreurs
```json
// Validation échouée (400)
{
  "code": 400,
  "info": {
    "domain": "Required field"
  },
  "data": {
    "domain": "/^(?!-)([A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,15}$/"
  }
}

// Erreur serveur (500)
{
  "code": 500,
  "info": "Internal Server Error",
  "data": "Error message"
}
```

---

## 🔍 **Obtenir les informations d'hébergement**

### GET /hosting/:hosting

Obtenir des informations détaillées sur l'hébergement spécifié. Il doit être géré par l'utilisateur.

#### Paramètres
- **hosting** (string, required) : Le nom de domaine dont récupérer les informations d'hébergement

#### Requête
```http
GET /v1/hosting/:hosting HTTP/1.1
Host: api.lws.net
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Retrieved hosting info",
  "data": {
    "domain": "exemple.com",
    "date_purchase": "2023-01-01",
    "date_expiration": "2024-01-01",
    "ns1": "ns1.lwsdns.com",
    "ns2": "ns2.lwsdns.com",
    "ns3": "ns3.lwsdns.com",
    "ns4": "ns4.lwsdns.com",
    "owner": 547645,
    "package": "LWS Perso",
    "lws_domain": true,
    "autorenew": {
      "payment": "aucun",
      "account": ""
    }
  }
}
```

#### Erreurs
```json
// Domaine non trouvé (314)
{
  "code": 314,
  "info": "Provided domain has not been found on your account. You must own this domain to manage it."
}

// Hébergement non fourni (400)
{
  "code": 400,
  "info": "No hosting provided",
  "data": [null]
}
```

---

## 📋 **Obtenir tous les hébergements et domaines**

### GET /hosting/0/list

Obtenir une liste de tous les domaines et leurs hébergements associés gérés par l'utilisateur.

#### Requête
```http
GET /v1/hosting/0/list HTTP/1.1
Host: api.lws.net
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Retrieved all hostings",
  "data": [
    {
      "domain": "exemple.com",
      "date_purchase": "2023-01-01",
      "date_expiration": "2024-01-01",
      "ns1": "ns1.lwsdns.com",
      "ns2": "ns2.lwsdns.com",
      "ns3": "ns3.lwsdns.com",
      "ns4": "ns4.lwsdns.com",
      "owner": 547645,
      "package": "LWS Perso",
      "lws_domain": true,
      "autorenew": {
        "payment": "aucun",
        "account": ""
      }
    }
  ]
}
```

#### Erreurs
```json
// Requête invalide (400)
{
  "code": 400,
  "info": "Invalid request",
  "data": [null]
}
```

---

## 💰 **Obtenir tous les hébergements et leurs prix**

### GET /hosting/0/priceall

Obtenir la liste de tous les forfaits d'hébergement et leurs prix en Euro (€).

#### Requête
```http
GET /v1/hosting/0/priceall HTTP/1.1
Host: api.lws.net
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Retrieved all hostings",
  "data": {
    "LWS Perso": 1.99,
    "LWS Standard": 3.99,
    "LWS Pro": 5.99,
    "LWS Performance": 9.99
  }
}
```

---

## 💵 **Obtenir les prix de renouvellement**

### GET /hosting/:hosting/pricerenew

Obtenir le prix de renouvellement de l'hébergement et du domaine en Euro (€) ainsi que leur statut.

#### Paramètres
- **hosting** (string, required) : Le nom de domaine dont récupérer le prix de renouvellement et le statut

#### Requête
```http
GET /v1/hosting/:hosting/pricerenew HTTP/1.1
Host: api.lws.net
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Retrieved Hosting and Domain renew prices in Euro (€)/month",
  "data": [
    {
      "price": {
        "total": 91.62,
        "hosting": 6.99,
        "domain": 0.75,
        "support": 60,
        "backup": 23.88
      },
      "status": {
        "hosting_status": {
          "expired": 6,
          "expired_info": "L'hébergement a expiré il y a 6 jours",
          "to_renew": false,
          "status": "string",
          "status_info": "string",
          "txt": "string"
        },
        "domain_status": {
          "expired": 4,
          "expired_info": "Le domaine a expiré il y a 4 jours",
          "to_renew": true,
          "status": "quarantine",
          "status_info": "Le domaine est en quarantaine et sera bientôt supprimé",
          "txt": "string"
        }
      }
    }
  ]
}
```

#### Statuts possibles
- **expired** : Nombre de jours d'expiration
- **to_renew** : Nécessite un renouvellement
- **status** : Statut actuel (quarantine, active, etc.)

---

## 🔄 **Activer/désactiver le renouvellement automatique**

### PUT /hosting/:hosting/autorenew

Activer ou désactiver le renouvellement automatique pour un hébergement. Affecte à la fois l'hébergement et le domaine.

#### Paramètres
- **hosting** (string, required) : Le nom de domaine dont modifier les paramètres de renouvellement automatique

#### Body JSON
```json
{
  "enable": true  // true = activer, false = désactiver
}
```

#### Requête
```http
PUT /v1/hosting/:hosting/autorenew HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 20

{
  "enable": true
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Your hosting's auto-renewal settings has been changed",
  "data": true
}
```

#### Erreurs
```json
// Domaine non trouvé (314)
{
  "code": 314,
  "info": "Provided domain has not been found on your account. You must own this domain to manage it."
}

// Statut non fourni (400)
{
  "code": 400,
  "info": "No auto-renewal status provided. Example: true",
  "data": [null]
}
```

---

## 🔄 **Renouveler un hébergement et son domaine**

### POST /hosting/:hosting/renew

**[Différé] [Action payante]** Renouveler l'hébergement et le domaine pour une période supplémentaire. Ne renouvellera que l'hébergement si le domaine n'a pas été acheté chez LWS.

#### Paramètres
- **hosting** (string, required) : Le nom de domaine à renouveler

#### Requête
```http
POST /v1/hosting/:hosting/renew HTTP/1.1
Host: api.lws.net
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Your domain/hosting renewal request has been taken into account",
  "data": {
    "price": 4.99
  }
}
```

#### Erreurs
```json
// Domaine non trouvé (314)
{
  "code": 314,
  "info": "Provided domain has not been found on your account. You must own this domain to manage it."
}

// Hébergement non fourni (400)
{
  "code": 400,
  "info": "No hosting provided",
  "data": [null]
}
```

---

## 📊 **Résumé des Endpoints**

| Method | Endpoint | Description | Action |
|--------|----------|-------------|--------|
| POST | `/hosting` | Acheter hébergement/domaine | **💰 Payant** |
| GET | `/hosting/:hosting` | Informations d'hébergement | Lecture |
| GET | `/hosting/0/list` | Liste tous les hébergements | Lecture |
| GET | `/hosting/0/priceall` | Prix de tous les forfaits | Lecture |
| GET | `/hosting/:hosting/pricerenew` | Prix de renouvellement | Lecture |
| PUT | `/hosting/:hosting/autorenew` | Renouvellement automatique | Modification |
| POST | `/hosting/:hosting/renew` | Renouveler hébergement | **💰 Payant** |

---

## 💡 **Notes importantes**

### Actions payantes
- **POST /hosting** : Débite le compte selon le forfait et le type choisi
- **POST /hosting/:hosting/renew** : Débite le compte selon le prix de renouvellement

### Types d'hébergement disponibles
- **LWS Perso** : 1.99€
- **LWS Standard** : 3.99€
- **LWS Pro** : 5.99€
- **LWS Performance** : 9.99€

### Recommandations
1. Toujours utiliser `GET /hosting/:hosting/pricerenew` avant de renouveler
2. Vérifier le solde avec `GET /contact/0/credit` avant les actions payantes
3. Utiliser le mode test pour les tests d'intégration

---

**✅ Source :** Documentation officielle LWS API  
**📅 Dernière MAJ :** 30 juin 2025  
**🔗 Base URL :** `https://api.lws.net/v1/`  
**💰 Actions payantes :** Achat et renouvellement 