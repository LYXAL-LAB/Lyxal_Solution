# LWS API - Email (Officiel)

**Base URL :** `https://api.lws.net/v1/`  
**Authentification :** Headers `X-Auth-Login` + `X-Auth-Pass` + `X-Test-Mode`

---

## ➕ **Créer une nouvelle adresse email**

### POST /mail/:mail

Créer une nouvelle adresse email sur votre compte. Assurez-vous d'avoir suffisamment de quotas pour créer une nouvelle adresse email.

#### Paramètres
- **mail** (email, required) : Adresse email à créer

#### Body JSON (required)
```json
{
  "password": "string"  // Mot de passe pour le compte email
}
```

#### Requête
```http
POST /v1/mail/:mail HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: <X-Auth-Login>
X-Auth-Pass: <X-Auth-Pass>
X-Test-Mode: <X-Test-Mode>
Content-Length: 26

{
  "password": "string"
}
```

#### Exemple concret
```http
POST /v1/mail/user@example.com HTTP/1.1
Host: api.lws.net
Content-Type: application/json
Accept: application/json
X-Auth-Login: 699626
X-Auth-Pass: n3HFRaU5Kbgq26mXzGfMATE7rcd4pPjwW0NoOC9ikQut8hxDIZ
X-Test-Mode: false
Content-Length: 32

{
  "password": "motdepasse123"
}
```

#### Réponse Succès (200)
```json
{
  "code": 200,
  "info": "Created a new email address",
  "data": "user@example.com"
}
```

#### Erreurs
```json
// Erreur générique (400)
{
  "code": 400,
  "info": "string",
  "data": {}
}
```

---

## 📊 **Résumé des Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/mail/:mail` | Créer une nouvelle adresse email |

---

## 💡 **Notes importantes**

### Prérequis
- Avoir suffisamment de **quotas email** disponibles sur votre hébergement
- Le domaine doit être **géré par votre compte** LWS
- Le domaine doit être **configuré pour recevoir des emails**

### Recommandations
1. Vérifier les quotas disponibles avant de créer des adresses
2. Utiliser des mots de passe sécurisés pour les comptes email
3. Tester avec le mode test avant la création en production

### Limitations
- La documentation fournie ne montre qu'un seul endpoint
- Il pourrait y avoir d'autres endpoints (GET, PUT, DELETE) non documentés dans cette section
- Les détails d'erreur semblent généralistes

---

**✅ Source :** Documentation officielle LWS API  
**📅 Dernière MAJ :** 30 juin 2025  
**🔗 Base URL :** `https://api.lws.net/v1/`  
**📧 Section :** Email - Documentation partielle 