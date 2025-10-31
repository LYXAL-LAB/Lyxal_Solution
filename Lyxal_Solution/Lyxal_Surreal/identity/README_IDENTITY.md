# 🆔 Module Identity - Table Utilisateurs Lyxal

## 📂 Structure des Fichiers

```
identity/
├── database/
│   ├── identity.surql                    ❌ Version originale (à corriger)
│   ├── identity_CORRECTED.surql          ✅ Version corrigée (utiliser celle-ci)
│   ├── identity_status.surql             ✅ Table des statuts
│   ├── identity_functions.surql          ✅ NOUVEAU - Fonctions utilitaires
│   └── identity_scopes.surql             ✅ NOUVEAU - Authentification
│
└── reference/
    └── identity_status/
        ├── identity_status_seeds.surql         ✅ Données statuts
        ├── identity_status_i18n_keys.surql     ✅ Clés i18n
        └── identity_status_i18n_translations.surql  ✅ Traductions (FR, EN, ES, DE, IT)
```

---

## 🚀 Ordre d'Exécution des Scripts

### Phase 1 : Tables de Base

```sql
-- 1. Table identity_status (DOIT ÊTRE CRÉÉE EN PREMIER)
@identity/database/identity_status.surql

-- 2. Table identity (utilisateurs)
@identity/database/identity_CORRECTED.surql  -- ⚠️ Utiliser la version CORRIGÉE

-- 3. Fonctions utilitaires
@identity/database/identity_functions.surql

-- 4. Scopes d'authentification
@identity/database/identity_scopes.surql
```

### Phase 2 : Données de Référence

```sql
-- 5. Clés i18n pour les statuts
@identity/reference/identity_status/identity_status_i18n_keys.surql

-- 6. Seeds des statuts
@identity/reference/identity_status/identity_status_seeds.surql

-- 7. Traductions (5 langues)
@identity/reference/identity_status/identity_status_i18n_translations.surql
```

---

## 🔧 Commandes d'Exécution

### Option 1 : Via SurrealDB CLI

```bash
# Se connecter
surreal sql --endpoint http://localhost:8000 --user root --pass root

# Utiliser le namespace
USE NAMESPACE lyxal_solution;
USE DATABASE main;

# Exécuter les scripts dans l'ordre
-- Copier/coller le contenu de chaque fichier dans l'ordre ci-dessus
```

### Option 2 : Via Script Shell

```bash
# Créer un script d'initialisation
cat > init_identity.sh << 'EOF'
#!/bin/bash

SURREAL_URL="http://localhost:8000"
SURREAL_USER="root"
SURREAL_PASS="root"

echo "🚀 Initialisation module Identity..."

# Phase 1
echo "📊 Création tables..."
surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/database/identity_status.surql

surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/database/identity_CORRECTED.surql

surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/database/identity_functions.surql

surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/database/identity_scopes.surql

# Phase 2
echo "📝 Import données de référence..."
surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/reference/identity_status/identity_status_i18n_keys.surql

surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/reference/identity_status/identity_status_seeds.surql

surreal import --endpoint $SURREAL_URL --user $SURREAL_USER --pass $SURREAL_PASS \
  identity/reference/identity_status/identity_status_i18n_translations.surql

echo "✅ Module Identity initialisé avec succès !"
EOF

chmod +x init_identity.sh
./init_identity.sh
```

---

## 📊 Structure de la Table `identity`

### Champs Principaux

```sql
identity {
  lyxal_id: string,                    // ID unique (ex: jean_dupont_abc123)
  email: string,                       // Email (unique)
  password_hash: string,               // Argon2 hash
  first_name: string,                  // Prénom
  last_name: string,                   // Nom
  full_name: string,                   // Calculé automatiquement
  avatar: option<string>,              // URL avatar
  status: record<identity_status>,     // Lien vers identity_status
  email_verified: bool,                // Email vérifié
  email_verification_token: option<string>,
  email_verification_expires: option<datetime>,
  last_login: option<datetime>,
  last_login_ip: option<string>,
  language: string,                    // fr, en, es, de, it
  timezone: string,                    // Europe/Paris
  created_at: datetime,
  updated_at: datetime
}
```

### Statuts Disponibles

```
created     → Compte créé (défaut)
verified    → Email vérifié
active      → Compte actif (après première connexion)
pending     → En attente
suspended   → Compte suspendu
deleted     → Compte supprimé
archived    → Compte archivé
expired     → Compte expiré
```

---

## 💻 Utilisation des Fonctions

### 1. Création Utilisateur

```sql
-- Appel de la fonction
LET $result = fn::create_identity(
  'jean@example.com',       -- email
  'Password123!',           -- password
  'Jean',                   -- first_name
  'Dupont',                 -- last_name
  'fr'                      -- language (optionnel)
);

-- Résultat :
-- {
--   success: true,
--   user: { lyxal_id: 'jean_dupont_abc123', ... },
--   verification_token: 'xxx'
-- }
```

### 2. Vérification Email

```sql
-- Appel de la fonction
LET $result = fn::verify_email(
  'jean_dupont_abc123',     -- lyxal_id
  'verification_token_xxx'  -- token
);

-- Résultat :
-- { success: true }
```

### 3. Authentification

```sql
-- Appel de la fonction
LET $result = fn::authenticate_identity(
  'jean@example.com',       -- email
  'Password123!',           -- password
  '192.168.1.1'            -- ip (optionnel)
);

-- Résultat :
-- {
--   success: true,
--   user: {
--     lyxal_id: 'jean_dupont_abc123',
--     email: 'jean@example.com',
--     first_name: 'Jean',
--     last_name: 'Dupont',
--     ...
--   }
-- }
```

---

## 🎨 Utilisation Frontend (React + SurrealDB.js)

### Installation

```bash
npm install surrealdb.js
```

### Inscription

```typescript
import { Surreal } from 'surrealdb.js';

const db = new Surreal();

async function signup(email: string, password: string, firstName: string, lastName: string) {
  await db.connect('ws://localhost:8000/rpc');
  
  try {
    const token = await db.signup({
      namespace: 'lyxal_solution',
      database: 'main',
      scope: 'lyxal_user',
      email: email,
      password: password,
      first_name: firstName,
      last_name: lastName,
      language: 'fr'
    });
    
    console.log('✅ Inscription réussie', token);
    return { success: true, token };
  } catch (error) {
    console.error('❌ Erreur inscription', error);
    return { success: false, error };
  }
}
```

### Connexion

```typescript
async function signin(email: string, password: string) {
  await db.connect('ws://localhost:8000/rpc');
  
  try {
    const token = await db.signin({
      namespace: 'lyxal_solution',
      database: 'main',
      scope: 'lyxal_user',
      email: email,
      password: password,
      ip: window.location.hostname  // Optionnel
    });
    
    console.log('✅ Connexion réussie', token);
    
    // Récupérer infos utilisateur
    const user = await db.query('SELECT * FROM identity WHERE email = $email', {
      email: email
    });
    
    return { success: true, token, user: user[0] };
  } catch (error) {
    console.error('❌ Erreur connexion', error);
    return { success: false, error };
  }
}
```

### Vérification Email

```typescript
async function verifyEmail(lyxalId: string, token: string) {
  const result = await db.query(`
    SELECT * FROM fn::verify_email($lyxal_id, $token)
  `, {
    lyxal_id: lyxalId,
    token: token
  });
  
  if (result[0].success) {
    console.log('✅ Email vérifié');
  } else {
    console.error('❌ Token invalide ou expiré');
  }
  
  return result[0];
}
```

---

## ✅ Points Forts de Votre Implémentation

### 1. ⭐ Système i18n Professionnel
- 5 langues supportées
- Structure complète (clés + traductions)
- Séparation propre des responsabilités

### 2. ✅ Organisation des Fichiers
- Structure claire `/database` et `/reference`
- Séparation seeds, i18n, tables

### 3. ✅ Table de Référence `identity_status`
- Statuts externalisés
- Avec métadonnées (color, sort_order)
- Évolutif et maintenable

---

## ⚠️ Points à Corriger

### 1. Fichier `identity.surql`
- ❌ Lignes 56-71 : Références à `lyxal_users` au lieu de `identity`
- ❌ Ligne 21 : Validation password_hash incorrecte
- ❌ Manque champ `lyxal_id`
- ❌ Manque champs de sécurité

**Solution** : Utiliser `identity_CORRECTED.surql`

### 2. Manque Fonctions et Scopes
- ❌ Pas de fonctions utilitaires
- ❌ Pas de scopes d'authentification

**Solution** : Utiliser `identity_functions.surql` et `identity_scopes.surql`

---

## 🎯 Prochaines Étapes

### Phase 1 : Correction et Test (Maintenant)
- [ ] Utiliser `identity_CORRECTED.surql`
- [ ] Exécuter tous les scripts dans l'ordre
- [ ] Tester création utilisateur
- [ ] Tester connexion

### Phase 2 : Table Profils (Prochaine)
- [ ] Créer table `identity_profile` (profils personnel/professionnel)
- [ ] Namespace par profil
- [ ] Switch entre profils

### Phase 3 : Sécurité Avancée
- [ ] Table `identity_mfa` (2FA)
- [ ] Table `identity_session` (sessions actives)
- [ ] Table `identity_login_attempts` (protection brute-force)

---

## 📚 Ressources

- [SurrealDB Docs](https://surrealdb.com/docs)
- [SurrealDB.js](https://surrealdb.com/docs/integration/libraries/nodejs)
- [Argon2](https://en.wikipedia.org/wiki/Argon2)

---

**Version** : 1.0  
**Date** : 2024-01-20  
**Statut** : ✅ Prêt pour utilisation (après corrections)

