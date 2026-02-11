# LWS API - Schemas/Modèles de données (Officiel)

**Base URL :** `https://api.lws.net/v1/`  
**Documentation :** Structures de données utilisées dans l'API LWS

---

## 📝 **Request**
**Usage :** Logs et suivi des requêtes différées

```json
{
  "id_revendeur": 245721,        // ID du revendeur qui a fait la demande
  "date": "2023-01-01",          // Date de création de la demande
  "objet": "domain",             // Point de terminaison utilisé
  "valeur": "example.fr",        // Valeur associée ({domain} ou {hosting})
  "type": "dns",                 // Sous-type du point de terminaison
  "retour": "0"                  // Statut (NULL = en cours, autre = code erreur)
}
```

---

## 👤 **ContactAdd**
**Usage :** Création d'un nouveau contact

```json
{
  "company": "Ma Société",           // Nom de l'entreprise (optionnel)
  "lastname": "Dupont",              // Nom de famille (required)
  "firstname": "Jean",               // Prénom (required)
  "address": "1 rue de la Paix",     // Adresse postale (required)
  "postal": "75000",                 // Code postal (required)
  "city": "Paris",                   // Ville (required)
  "country": "FR",                   // Pays (required)
  "phone": "0033612345678",          // Format international ^00\d{1,3}\d{6,12}$
  "email": "exemple@monsite.fr",     // Adresse email (required)
  "password": "motdepasse"           // Mot de passe (required)
}
```

---

## 👤 **ContactGet**
**Usage :** Réponse des informations de contact

```json
{
  "company": "Ma Société",           // Nom de l'entreprise
  "lastname": "Dupont",              // Nom de famille
  "firstname": "Jean",               // Prénom
  "address": "1 rue de la Paix",     // Adresse postale
  "postal": "75000",                 // Code postal
  "city": "Paris",                   // Ville
  "country": "France",               // Pays (nom complet en réponse)
  "phone": "0033612345678",          // Téléphone format international
  "email": "exemple@monsite.fr",     // Adresse email
  "is_company": true,                // true = entreprise, false = particulier
  "credit": 0                        // Solde du crédit
}
```

---

## 👤 **ContactPut**
**Usage :** Mise à jour d'un contact (champs optionnels)

```json
{
  "address": "1 rue de la Paix",     // Adresse postale
  "postal": "75000",                 // Code postal
  "city": "Paris",                   // Ville
  "country": "FR",                   // Pays
  "phone": "0033612345678",          // Format international ^00\d{1,3}\d{6,12}$
  "password": "motdepasse"           // Mot de passe
}
```

---

## 🌐 **DNSZoneRow**
**Usage :** Enregistrement DNS dans une zone

```json
{
  "id": "568470",                                            // ID pour DELETE/PUT
  "type": "AAAA",                                           // A, AAAA, CNAME, MX, NS, TXT, SRV, SPF, CAA
  "name": "@",                                              // Nom du champ
  "value": "2001:0db8:85a3:0000:0000:8a2e:0370:7334",     // Valeur du champ
  "ttl": 86400                                              // 86400, 43200, 21600, 7200, 3600, 1800, 900
}
```

### Types DNS supportés
- **A** : Adresse IPv4
- **AAAA** : Adresse IPv6
- **CNAME** : Alias canonique
- **MX** : Serveur de messagerie
- **NS** : Serveur de noms
- **TXT** : Texte arbitraire
- **SRV** : Service
- **SPF** : Sender Policy Framework
- **CAA** : Certificate Authority Authorization

---

## 🌍 **DomainGet**
**Usage :** Informations d'un domaine

```json
{
  "domain": "exemple.com",           // Nom de domaine
  "dns1": "ns1.lwsdns.com",         // Premier DNS
  "dns2": "ns2.lwsdns.com",         // Deuxième DNS
  "dns3": "ns3.lwsdns.com",         // Troisième DNS
  "dns4": "ns4.lwsdns.com",         // Quatrième DNS
  "owner": "358240",                // ID du propriétaire
  "redemption": "0",                // 1 = période récupération, 0 = normal
  "clientHold": "1",                // 1 = actif, 0 = inactif (expiré)
  "clientTransferProhibited": "1",  // 1 = transfert interdit, 0 = autorisé
  "serverHold": "0"                 // 1 = bloqué registraire, 0 = actif
}
```

### Statuts de domaine
- **redemption** : "1" = récupération possible, "0" = statut normal
- **clientHold** : "1" = actif, "0" = inactif (généralement expiré)
- **clientTransferProhibited** : "1" = transfert verrouillé, "0" = transfert autorisé
- **serverHold** : "1" = bloqué par registraire, "0" = actif

---

## 🔄 **DomainRedirect**
**Usage :** Redirection de domaine

```json
{
  "type": 301,                           // 301 = permanent, 302 = temporaire
  "redirection": "https://www.exemple.com" // URL de destination
}
```

---

## 🏷️ **DomainTlds**
**Usage :** Informations sur les TLDs disponibles

```json
{
  "tld": ".fr",                    // Extension de domaine
  "transfer_possible": "oui",      // Transfert possible (oui/non)
  "local_country": "oui",          // Réservé à un pays (oui/non)
  "restore_possible": "oui",       // Restauration possible (oui/non)
  "price_purchase": "6.99",        // Prix d'achat (€)
  "price_purchase_offer": "6.99",  // Prix d'achat avec offre (€)
  "price_renew": "8.99",          // Prix de renouvellement (€)
  "price_restore": "19.99",       // Prix de restauration (€)
  "price_transfer": "4.99",       // Prix de transfert (€)
  "length": "3-63",               // Longueur autorisée (caractères)
  "minimum_period": "1"           // Période minimale (années)
}
```

---

## 📊 **HostingDetails**
**Usage :** Statuts détaillés d'hébergement et domaine

```json
{
  "hosting_status": {
    "expired": 6,                                              // Jours d'expiration (-1 si non expiré)
    "expired_info": "L'hébergement a expiré il y a 6 jours",  // Description expiration
    "to_renew": false,                                         // Nécessite renouvellement
    "status": "string",                                        // Statut actuel
    "status_info": "string",                                   // Info statut
    "txt": "string"                                           // Statut non géré
  },
  "domain_status": {
    "expired": 4,                                             // Jours d'expiration (-1 si non expiré)
    "expired_info": "Le domaine a expiré il y a 4 jours",    // Description expiration
    "to_renew": true,                                         // Nécessite renouvellement
    "status": "quarantine",                                   // Statut actuel
    "status_info": "Le domaine est en quarantaine et sera bientôt supprimé", // Info statut
    "txt": "string"                                          // Statut non géré
  }
}
```

### Statuts possibles
- **expired** : -1 = non expiré, >0 = nombre de jours d'expiration
- **to_renew** : true = doit être renouvelé, false = pas besoin
- **status** : "active", "quarantine", "expired", etc.

---

## 🏠 **HostingGet**
**Usage :** Informations d'hébergement

```json
{
  "domain": "exemple.com",          // Nom du domaine
  "date_purchase": "2023-01-01",    // Date d'achat
  "date_expiration": "2024-01-01",  // Date d'expiration
  "ns1": "ns1.lwsdns.com",         // Premier serveur de noms
  "ns2": "ns2.lwsdns.com",         // Deuxième serveur de noms
  "ns3": "ns3.lwsdns.com",         // Troisième serveur de noms
  "ns4": "ns4.lwsdns.com",         // Quatrième serveur de noms
  "owner": 547645,                  // Propriétaire (ID contact)
  "package": "LWS Perso",          // Type de forfait
  "lws_domain": true,               // Domaine acheté chez LWS (true/false)
  "autorenew": {
    "payment": "aucun",             // Mode de paiement auto-renew
    "account": ""                   // Compte de paiement
  }
}
```

---

## 🛒 **HostingPost**
**Usage :** Achat d'hébergement

```json
{
  "package": "LWS Perso",    // Forfait à acheter
  "domain": "exemple.com",   // Domaine à associer
  "owner": 565487,           // Propriétaire (ID contact)
  "type": "buy",             // buy/host/transfer
  "period": 12               // Période en mois
}
```

### Types d'achat
- **buy** : Acheter hébergement + domaine
- **host** : Hébergement uniquement (domaine déjà possédé)
- **transfer** : Transfert de domaine + hébergement

---

## 💰 **HostingPrice**
**Usage :** Détail des prix de renouvellement

```json
{
  "total": 91.62,     // Prix total (€)
  "hosting": 6.99,    // Prix hébergement seul (€)
  "domain": 0.75,     // Prix domaine seul (€)
  "support": 60,      // Prix Support Technique (€)
  "backup": 23.88     // Prix Sauvegarde (€)
}
```

---

## 💳 **Transaction**
**Usage :** Historique des transactions

```json
{
  "id": 0,                           // ID de la transaction
  "id_revendeur": 547645,           // Propriétaire du compte
  "price": 35.88,                   // Prix de la transaction (€)
  "timestamp": "2023-01-01 12:00:00", // Date et heure
  "request": {                       // Détails de la transaction
    "action": "POST /hosting",
    "type": "buy",
    "package": "LWS Starter",
    "domain": "mondomaine.fr"
  },
  "product": "mondomaine.fr"        // Objet de l'achat
}
```

---

## 📊 **Résumé des Schémas**

| Schéma | Usage | Section API |
|--------|-------|-------------|
| **Request** | Logs des requêtes différées | Requests |
| **ContactAdd** | Création de contact | Contacts |
| **ContactGet** | Lecture de contact | Contacts |
| **ContactPut** | Mise à jour de contact | Contacts |
| **DNSZoneRow** | Enregistrement DNS | Domaines |
| **DomainGet** | Informations de domaine | Domaines |
| **DomainRedirect** | Redirection de domaine | Domaines |
| **DomainTlds** | Extensions disponibles | Domaines |
| **HostingDetails** | Statuts détaillés | Hébergement |
| **HostingGet** | Informations d'hébergement | Hébergement |
| **HostingPost** | Achat d'hébergement | Hébergement |
| **HostingPrice** | Prix de renouvellement | Hébergement |
| **Transaction** | Historique des achats | Contacts |

---

## 💡 **Notes importantes**

### Validation des données
- **Phone** : Regex obligatoire `^00\d{1,3}\d{6,12}$`
- **Email** : Format email valide requis
- **TTL DNS** : Valeurs autorisées uniquement
- **Types DNS** : Liste fermée de types supportés

### Gestion des erreurs
- **NULL vs "0"** : Attention aux types dans `retour` et statuts
- **Dates** : Format YYYY-MM-DD pour les dates, YYYY-MM-DD HH:MM:SS pour timestamps
- **Booléens** : Parfois représentés en string ("0"/"1")

### Recommandations
1. Valider les données avant envoi selon ces schémas
2. Parser correctement les types de réponse
3. Gérer les champs optionnels
4. Vérifier les contraintes de validation

---

**✅ Source :** Documentation officielle LWS API  
**📅 Dernière MAJ :** 30 juin 2025  
**🔗 Base URL :** `https://api.lws.net/v1/`  
**📋 Section :** Schémas/Modèles de données 