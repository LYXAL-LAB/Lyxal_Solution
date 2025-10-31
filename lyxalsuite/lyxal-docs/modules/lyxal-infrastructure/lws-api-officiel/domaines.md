# LWS API - Domaines (Officiel)

**Base URL :** `https://api.lws.net/v1/`  
**Authentification :** Headers `X-Auth-Login` + `X-Auth-Pass` + `X-Test-Mode`

---

## 📋 **Obtenir les informations d'un domaine**

### GET /domain/:domain

Obtenir des informations détaillées sur le domaine spécifié, comme son propriétaire, son statut, sa zone DNS, et plus encore.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont les informations sont à récupérer (≤ 255 caractères)

#### Requête
```http
GET /v1/domain/:domain HTTP/1.1
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
  "info": "Fetched domain",
  "data": {
    "domain": "exemple.com",
    "dns1": "ns1.lwsdns.com",
    "dns2": "ns2.lwsdns.com",
    "dns3": "ns3.lwsdns.com",
    "dns4": "ns4.lwsdns.com",
    "owner": "358240",
    "redemption": "0",
    "clientHold": "1",
    "clientTransferProhibited": "1",
    "serverHold": "0"
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

// Paramètre manquant (400)
{
  "code": 400,
  "info": "No domain provided"
}

// Erreur serveur (500)
{
  "code": 500,
  "info": "Internal Server Error",
  "data": "string"
}

// Erreur upstream (502)
{
  "code": 502,
  "info": "Invalid response from upstream server",
  "data": {}
}
```

---

## 🌐 **Obtenir tous les TLDs disponibles**

### GET /domain/0/tlds

Obtenir une liste de tous les TLDs disponibles, leurs informations de prix et autres paramètres.

#### Requête
```http
GET /v1/domain/0/tlds HTTP/1.1
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
  "info": "All TLDs fetched",
  "data": [
    {
      "tld": ".fr",
      "transfer_possible": "oui",
      "local_country": "oui",
      "restore_possible": "oui",
      "price_purchase": "6.99",
      "price_purchase_offer": "6.99",
      "price_renew": "8.99",
      "price_restore": "19.99",
      "price_transfer": "4.99",
      "length": "3-63",
      "minimum_period": "1"
    }
  ]
}
```

#### Erreurs
```json
// Aucun TLD trouvé (404)
{
  "code": 404,
  "info": "No TLDs found"
}

// Erreur serveur (500)
{
  "code": 500,
  "info": "Internal Server Error",
  "data": "string"
}
```

---

## 🔍 **Obtenir la zone DNS d'un domaine**

### GET /domain/:domain/zdns

Obtenir la zone DNS pour le domaine spécifié avec tous les enregistrements DNS.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont la zone DNS est à récupérer (≤ 255 caractères)

#### Requête
```http
GET /v1/domain/:domain/zdns HTTP/1.1
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
  "info": "Fetched DNS Zone",
  "data": [
    {
      "id": "568470",
      "type": "AAAA",
      "name": "@",
      "value": "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
      "ttl": 86400
    }
  ]
}
```

---

## ✏️ **Mettre à jour un enregistrement DNS**

### PUT /domain/:domain/zdns

Mettre à jour un enregistrement DNS existant. Si l'enregistrement n'existe pas, il sera ajouté.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont l'enregistrement DNS est à mettre à jour

#### Body JSON
```json
{
  "id": 234851,
  "type": "A",
  "name": "@",
  "value": "192.0.2.1",
  "ttl": 86400
}
```

#### Requête
```http
PUT /v1/domain/:domain/zdns HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 88

{
  "id": 234851,
  "type": "A",
  "name": "@",
  "value": "192.0.2.1",
  "ttl": 86400
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Updated record",
  "data": {
    "id": "568470",
    "type": "AAAA",
    "name": "@",
    "value": "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    "ttl": 86400
  }
}
```

---

## ➕ **Ajouter un enregistrement DNS**

### POST /domain/:domain/zdns

Ajouter un nouvel enregistrement à la zone DNS du domaine.

#### Paramètres
- **domain** (string, required) : Nom de domaine auquel ajouter un enregistrement DNS

#### Body JSON
```json
{
  "type": "A",
  "name": "@",
  "value": "192.0.2.1",
  "ttl": 86400
}
```

#### Requête
```http
POST /v1/domain/:domain/zdns HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 72

{
  "type": "A",
  "name": "@",
  "value": "192.0.2.1",
  "ttl": 86400
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Added a new line in the DNS Zone",
  "data": {
    "id": "568470",
    "type": "AAAA",
    "name": "@",
    "value": "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    "ttl": 86400
  }
}
```

---

## ❌ **Supprimer un enregistrement DNS**

### DELETE /domain/:domain/zdns

Supprimer un enregistrement DNS spécifique de la zone DNS du domaine.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont l'enregistrement DNS est à supprimer

#### Body JSON
```json
{
  "id": 234851
}
```

#### Requête
```http
DELETE /v1/domain/:domain/zdns HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 18

{
  "id": 234851
}
```

#### Réponses
```json
// Succès (200)
{
  "code": 200,
  "info": "Success: Removed record in the DNS Zone",
  "data": 234851
}

// Enregistrement déjà supprimé (201)
{
  "code": 201,
  "info": "The record 234851 does not exist or has already been deleted",
  "data": 234851
}
```

---

## 🔍 **Vérifier la disponibilité d'un domaine**

### GET /domain/:domain/availability

Vérifier si un nom de domaine est disponible pour l'enregistrement.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont la disponibilité doit être vérifiée (≤ 255 caractères)

#### Requête
```http
GET /v1/domain/:domain/availability HTTP/1.1
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
  "info": "Domain is available for registration",
  "data": true
}
```

---

## 🔐 **Demander le code d'autorisation de transfert**

### GET /domain/:domain/authcode

**[Différé]** Demander le code d'autorisation nécessaire pour transférer un domaine. Il sera envoyé par email.

#### Paramètres
- **domain** (string, required) : Nom de domaine pour lequel demander le code d'autorisation (≤ 255 caractères)

#### Requête
```http
GET /v1/domain/:domain/authcode HTTP/1.1
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
  "info": "Your AuthCode request is currently pending. Please check your email for the AuthCode in a few minutes.",
  "data": "pending"
}
```

---

## 🌐 **Mettre à jour les serveurs de noms**

### PUT /domain/:domain/dns

**[Différé]** Mettre à jour les serveurs de noms (NS1-NS4) pour le domaine spécifié.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont les DNS sont à modifier

#### Body JSON
```json
{
  "ns1": "ns1.lwsdns.com",
  "ns2": "ns2.lwsdns.com",
  "ns3": "ns3.lwsdns.com",
  "ns4": "ns4.lwsdns.com"
}
```

#### Requête
```http
PUT /v1/domain/:domain/dns HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 110

{
  "ns1": "ns1.lwsdns.com",
  "ns2": "ns2.lwsdns.com",
  "ns3": "ns3.lwsdns.com",
  "ns4": "ns4.lwsdns.com"
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Your request to change the DNS of the domain is currently pending. If no changes are made after a few minutes, please make sure the nameservers are valid.",
  "data": "pending"
}
```

---

## 🔒 **Mettre à jour la protection de transfert**

### PUT /domain/:domain/clientTransferProhibited

**[Différé]** Activer ou désactiver la protection de transfert pour le domaine spécifié.

#### Paramètres
- **domain** (string, required) : Domaine dont la protection de transfert est à modifier

#### Body JSON
```json
{
  "status": true
}
```

#### Requête
```http
PUT /v1/domain/:domain/clientTransferProhibited HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 20

{
  "status": true
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Your transfer protection status update is currently pending.",
  "data": "pending"
}
```

---

## 🔄 **Créer une redirection de domaine**

### POST /domain/:domain/redirect

Créer une redirection 301 (permanente) ou 302 (temporaire) pour le domaine spécifié.

#### Paramètres
- **domain** (string, required) : Domaine pour lequel créer une redirection

#### Body JSON
```json
{
  "type": 301,
  "redirection": "https://www.example.com"
}
```

#### Requête
```http
POST /v1/domain/:domain/redirect HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 61

{
  "type": 301,
  "redirection": "https://www.example.com"
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Added a new redirection",
  "data": {
    "type": 301,
    "redirection": "https://www.exemple.com"
  }
}
```

---

## 🗑️ **Supprimer une redirection de domaine**

### DELETE /domain/:domain/redirect

Supprimer une redirection existante du domaine spécifié.

#### Paramètres
- **domain** (string, required) : Nom de domaine dont la redirection est à supprimer

#### Requête
```http
DELETE /v1/domain/:domain/redirect HTTP/1.1
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
  "info": "Removed the redirection"
}
```

---

## 📊 **Résumé des Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/domain/:domain` | Informations du domaine |
| GET | `/domain/0/tlds` | Liste des TLDs disponibles |
| GET | `/domain/:domain/zdns` | Zone DNS du domaine |
| PUT | `/domain/:domain/zdns` | Modifier enregistrement DNS |
| POST | `/domain/:domain/zdns` | Ajouter enregistrement DNS |
| DELETE | `/domain/:domain/zdns` | Supprimer enregistrement DNS |
| GET | `/domain/:domain/availability` | Vérifier disponibilité |
| GET | `/domain/:domain/authcode` | Code d'autorisation de transfert |
| PUT | `/domain/:domain/dns` | Mettre à jour serveurs de noms |
| PUT | `/domain/:domain/clientTransferProhibited` | Protection de transfert |
| POST | `/domain/:domain/redirect` | Créer redirection |
| DELETE | `/domain/:domain/redirect` | Supprimer redirection |

---

**✅ Source :** Documentation officielle LWS API  
**📅 Dernière MAJ :** 30 juin 2025  
**🔗 Base URL :** `https://api.lws.net/v1/`