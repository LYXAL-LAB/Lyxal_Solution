# LWS API - Requests/Logs (Officiel)

**Base URL :** `https://api.lws.net/v1/`  
**Authentification :** Headers `X-Auth-Login` + `X-Auth-Pass` + `X-Test-Mode`

---

## 🔍 **Obtenir toutes les requêtes ou une requête spécifique**

### GET /requests

Obtenir toutes les requêtes ou rechercher une requête en attente spécifique. Laissez les paramètres vides pour obtenir toutes les requêtes. Plus il y a de paramètres, plus la recherche sera précise.

#### Query Parameters (optionnels)
- **objet** (string) : Quel point de terminaison a été utilisé pour la requête
- **valeur** (string) : Valeur associée à la requête (généralement {domain} ou {hosting})
- **type** (string) : Sous-type du point de terminaison utilisé

#### Requête
```http
GET /v1/requests HTTP/1.1
Host: api.lws.net
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
```

#### Exemples de requêtes avec filtres
```http
# Toutes les requêtes
GET /v1/requests HTTP/1.1

# Requêtes pour un domaine spécifique
GET /v1/requests?objet=domain&valeur=example.fr HTTP/1.1

# Requêtes DNS pour un domaine
GET /v1/requests?objet=domain&valeur=example.fr&type=dns HTTP/1.1

# Requêtes d'hébergement
GET /v1/requests?objet=hosting HTTP/1.1
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Fetched request(s)",
  "data": [
    {
      "id_revendeur": 245721,
      "date": "2023-01-01",
      "objet": "domain",
      "valeur": "example.fr",
      "type": "dns",
      "retour": "0"
    }
  ]
}
```

#### Structure des données
- **id_revendeur** : ID du revendeur ayant effectué la requête
- **date** : Date de la requête (format YYYY-MM-DD)
- **objet** : Type d'objet (domain, hosting, etc.)
- **valeur** : Valeur cible (nom de domaine, hébergement, etc.)
- **type** : Sous-type de l'opération (dns, authcode, etc.)
- **retour** : Code de retour ("0" = en attente, autres = traité)

#### Erreurs
```json
// Échec de récupération (400)
{
  "code": 400,
  "info": "Failed to fetch requests"
}

// Aucune requête trouvée (404)
{
  "code": 404,
  "info": "No requests found"
}

// Pas de connexion base de données (500)
{
  "code": 500,
  "info": "No database connection"
}

// Réponse invalide de la base (502)
{
  "code": 502,
  "info": "Invalid response from database"
}
```

---

## ⏳ **Obtenir toutes les requêtes en attente**

### GET /requests/pending

Obtenir toutes les requêtes en attente (requêtes qui n'ont pas encore été traitées).

#### Requête
```http
GET /v1/requests/pending HTTP/1.1
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
  "info": "Fetched pending request(s)",
  "data": [
    {
      "id_revendeur": 245721,
      "date": "2023-01-01",
      "objet": "domain",
      "valeur": "example.fr",
      "type": "dns",
      "retour": "0"
    }
  ]
}
```

#### Erreurs
```json
// Échec de récupération (400)
{
  "code": 400,
  "info": "Failed to fetch requests"
}

// Aucune requête en attente (404)
{
  "code": 404,
  "info": "No requests found"
}

// Pas de connexion base de données (500)
{
  "code": 500,
  "info": "No database connection"
}

// Réponse invalide de la base (502)
{
  "code": 502,
  "info": "Invalid response from database"
}
```

---

## 📊 **Résumé des Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/requests` | Obtenir toutes les requêtes (avec filtres optionnels) |
| GET | `/requests/pending` | Obtenir uniquement les requêtes en attente |

---

## 💡 **Cas d'usage typiques**

### 1. Monitoring des opérations différées
```http
# Vérifier si des opérations sont en cours
GET /v1/requests/pending HTTP/1.1
```

### 2. Suivi d'une opération spécifique
```http
# Suivre les changements DNS d'un domaine
GET /v1/requests?objet=domain&valeur=mondomaine.fr&type=dns HTTP/1.1
```

### 3. Audit des opérations
```http
# Voir toutes les opérations récentes
GET /v1/requests HTTP/1.1
```

### 4. Vérification d'état
```http
# Vérifier si une opération d'hébergement est terminée
GET /v1/requests?objet=hosting&valeur=mondomaine.fr HTTP/1.1
```

---

## 🔄 **Types d'opérations trackées**

### Domaines
- **dns** : Changements de serveurs de noms
- **authcode** : Demandes de code d'autorisation
- **transfer** : Transferts de domaines
- **protection** : Modifications de protection

### Hébergements
- **purchase** : Achats d'hébergements
- **renew** : Renouvellements
- **autorenew** : Modifications renouvellement automatique

### Autres
- **mail** : Créations d'adresses email
- **ssl** : Installations de certificats SSL

---

## 💡 **Notes importantes**

### Statuts des requêtes
- **retour: "0"** : Requête en attente de traitement
- **retour: autres** : Requête traitée (succès ou erreur)

### Recommandations
1. Utiliser `/requests/pending` pour un monitoring temps réel
2. Filtrer par `objet` et `valeur` pour un suivi précis
3. Vérifier régulièrement les requêtes différées importantes
4. Gérer les cas où aucune requête n'est trouvée (404)

### Fréquence de polling
- **Opérations critiques** : Toutes les 30 secondes
- **Monitoring général** : Toutes les 2-5 minutes
- **Audit périodique** : Une fois par heure

---

**✅ Source :** Documentation officielle LWS API  
**📅 Dernière MAJ :** 30 juin 2025  
**🔗 Base URL :** `https://api.lws.net/v1/`  
**📝 Section :** Requests/Logs - Suivi des opérations différées 