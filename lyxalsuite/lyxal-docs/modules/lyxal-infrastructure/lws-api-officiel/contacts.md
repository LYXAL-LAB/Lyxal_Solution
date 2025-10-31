# LWS API - Contacts (Officiel)

**Base URL :** `https://api.lws.net/v1/`  
**Authentification :** Headers `X-Auth-Login` + `X-Auth-Pass` + `X-Test-Mode`

---

## ➕ **Créer un nouveau contact**

### POST /contact

Créer un nouveau contact géré par votre compte, qui pourra être utilisé pour se connecter aux services. Laisser le champ société vide créera un contact individuel.

#### Body JSON (required)
```json
{
  "company": "Ma Société",        // Nom de l'entreprise (optionnel)
  "lastname": "Dupont",           // Nom de famille (required)
  "firstname": "Jean",            // Prénom (required)
  "address": "1 rue de la Paix",  // Adresse postale (required)
  "postal": "75000",              // Code postal (required)
  "city": "Paris",                // Ville (required)
  "country": "FR",                // Pays (required)
  "phone": "0033612345678",       // Numéro au format international (required)
  "email": "exemple@monsite.fr",  // Adresse email (required)
  "password": "motdepasse"        // Mot de passe (required)
}
```

#### Validation
- **phone** : Regex `^00\d{1,3}\d{6,12}$` (format international obligatoire)
- **email** : Format email valide

#### Requête
```http
POST /v1/contact HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 257

{
  "company": "Ma Société",
  "lastname": "Dupont",
  "firstname": "Jean",
  "address": "1 rue de la Paix",
  "postal": "75000",
  "city": "Paris",
  "country": "FR",
  "phone": "0033612345678",
  "email": "exemple@monsite.fr",
  "password": "motdepasse"
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Contact successfully created",
  "data": "367228"  // ID du contact créé
}
```

#### Erreurs
```json
// Validation échouée (400)
{
  "code": 400,
  "info": {
    "email": "Invalid email address format. Example: example@mysite.fr",
    "phone": "Required field"
  },
  "data": {
    "email": "Email regex pattern",
    "phone": "Phone number regex pattern"
  }
}

// Erreur serveur (500)
{
  "code": 500,
  "info": "Internal Server Error",
  "data": "Details on the error"
}
```

---

## 🔍 **Récupérer un contact**

### GET /contact/:contact

Récupérer les informations d'un contact en utilisant son ID. Seuls les contacts gérés par l'utilisateur peuvent être récupérés.

#### Paramètres
- **contact** (integer, required) : ID du contact à rechercher

#### Requête
```http
GET /v1/contact/:contact HTTP/1.1
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
  "info": "Contact fetched",
  "data": {
    "company": "Ma Société",
    "lastname": "Dupont",
    "firstname": "Jean",
    "address": "1 rue de la Paix",
    "postal": "75000",
    "city": "Paris",
    "country": "France",
    "phone": "0033612345678",
    "email": "exemple@monsite.fr",
    "is_company": true,
    "credit": 0
  }
}
```

#### Erreurs
```json
// Contact non fourni (400)
{
  "code": 400,
  "info": "No contact provided"
}
```

---

## ✏️ **Mettre à jour un contact**

### PUT /contact/:contact

Mettre à jour les informations d'un contact existant. Seuls les champs fournis seront mis à jour.

#### Paramètres
- **contact** (integer, required) : ID du contact à mettre à jour

#### Body JSON (optionnel)
```json
{
  "address": "1 rue de la Paix",
  "postal": "75000",
  "city": "Paris",
  "country": "FR",
  "phone": "0033612345678",    // Regex: ^00\d{1,3}\d{6,12}$
  "password": "motdepasse"
}
```

#### Requête
```http
PUT /v1/contact/:contact HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 150

{
  "address": "1 rue de la Paix",
  "postal": "75000",
  "city": "Paris",
  "country": "FR",
  "phone": "0033612345678",
  "password": "motdepasse"
}
```

#### Réponses
```json
// Mise à jour réussie (200)
{
  "code": 200,
  "info": "Updated contact information",
  "data": {
    "address": "1 rue de la Paix",
    "postal": "75000",
    "city": "Paris",
    "country": "FR",
    "phone": "0033612345678",
    "password": "motdepasse"
  }
}

// Rien à mettre à jour (201)
{
  "code": 201,
  "info": "Nothing to update"
}

// Validation échouée (400)
{
  "code": 400,
  "info": "Invalid input",
  "data": {
    "city": "Invalid field, refer to the associated regex for more details"
  }
}
```

---

## 💰 **Récupérer le solde du compte prépayé**

### GET /contact/0/credit

Récupérer le solde restant du compte prépayé de l'utilisateur actuel.

#### Requête
```http
GET /v1/contact/0/credit HTTP/1.1
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
  "info": "Remaining credits fetched",
  "data": 4200.5  // Solde en euros
}
```

---

## 📋 **Obtenir tous les contacts gérés**

### GET /contact/0/list

Récupérer un tableau associatif [ID => {données}] de tous les contacts gérés par l'utilisateur.

#### Requête
```http
GET /v1/contact/0/list HTTP/1.1
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
  "info": "Customer list fetched",
  "data": [
    [
      {
        "company": "Ma Société",
        "lastname": "Dupont",
        "firstname": "Jean",
        "address": "1 rue de la Paix",
        "postal": "75000",
        "city": "Paris",
        "country": "France",
        "phone": "0033612345678",
        "email": "exemple@monsite.fr",
        "is_company": true,
        "credit": 0
      }
    ]
  ]
}
```

#### Erreurs
```json
// Aucun contact trouvé (404)
{
  "code": 404,
  "info": "No contacts could be fetched",
  "data": [null]
}
```

---

## 🛒 **Obtenir l'historique des achats**

### GET /contact/purchase/history

Récupérer toutes les transactions effectuées par l'utilisateur via l'API (achats, renouvellements, etc.).

#### Requête
```http
GET /v1/contact/purchase/history HTTP/1.1
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
  "info": "Purchase history fetched",
  "data": [
    [
      {
        "id": 0,
        "id_revendeur": 547645,
        "price": 35.88,
        "timestamp": "2023-01-01 12:00:00",
        "request": {
          "action": "POST /hosting",
          "type": "buy",
          "package": "LWS Starter",
          "domain": "mondomaine.fr"
        },
        "product": "mondomaine.fr"
      }
    ]
  ]
}
```

#### Erreurs
```json
// Historique non trouvé (400)
{
  "code": 400,
  "info": "Could not find the seller's purchase history"
}

// Non autorisé (401)
{
  "code": 401,
  "info": "Unauthorized access to the API. Please specify X-Auth-Pass and X-Auth-Login to proceed."
}
```

---

## 🧪 **[TEST] Ajouter du crédit à un contact**

### PUT /contact/:contact/credit

**[Uniquement en environnement de test]** Ajouter du crédit à un contact donné. Ne fonctionne qu'à des fins de test.

#### Paramètres
- **contact** (integer, required) : ID LWS du contact auquel ajouter du crédit

#### Body JSON
```json
{
  "amount": 100  // Montant du crédit à ajouter
}
```

#### Requête
```http
PUT /v1/contact/:contact/credit HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: true
Content-Length: 17

{
  "amount": 100
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Credit added successfully",
  "data": 100  // Nouveau solde
}
```

#### Erreurs
```json
// Montant manquant (400)
{
  "code": 400,
  "info": "No amount specified"
}
```

---

## 🧪 **[TEST] Ajouter du crédit au compte revendeur**

### PUT /contact/reseller/credit

**[Uniquement en environnement de test]** Ajouter du crédit à votre compte revendeur (compte API). Ne fonctionne qu'à des fins de test.

#### Body JSON
```json
{
  "amount": 100  // Montant du crédit à ajouter
}
```

#### Requête
```http
PUT /v1/contact/reseller/credit HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: true
Content-Length: 17

{
  "amount": 100
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Credit added successfully",
  "data": 100  // Nouveau solde
}
```

---

## 📊 **Résumé des Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/contact` | Créer un nouveau contact |
| GET | `/contact/:contact` | Récupérer un contact |
| PUT | `/contact/:contact` | Mettre à jour un contact |
| GET | `/contact/0/credit` | Solde du compte prépayé |
| GET | `/contact/0/list` | Liste des contacts gérés |
| GET | `/contact/purchase/history` | Historique des achats |
| PUT | `/contact/:contact/credit` | **[TEST]** Ajouter crédit à un contact |
| PUT | `/contact/reseller/credit` | **[TEST]** Ajouter crédit au revendeur |

---

**✅ Source :** Documentation officielle LWS API  
**📅 Dernière MAJ :** 30 juin 2025  
**🔗 Base URL :** `https://api.lws.net/v1/`  
**🧪 Test Mode :** Endpoints de crédit uniquement en mode test