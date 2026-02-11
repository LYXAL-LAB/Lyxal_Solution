# Chiffrement des Credentials dans SurrealDB (comme n8n)

## Vue d'ensemble

Les credentials stockés dans la table `user_service_credential` sont **automatiquement chiffrés dans SurrealDB**, similaire à n8n. Tout le chiffrement est géré directement dans SurrealDB via des fonctions intégrées, sans nécessiter de chiffrement côté application.

**Architecture similaire à n8n :**
- ✅ Chiffrement automatique lors de la création/mise à jour
- ✅ Déchiffrement automatique lors de la récupération
- ✅ Gestion centralisée des clés de chiffrement
- ✅ Support de la rotation des clés


## Quels champs doivent être chiffrés ?

Tous les champs sensibles dans l'objet `credentials` :

### OAuth2
- ✅ `credentials.oauth2.access_token` → **À CHIFFRER**
- ✅ `credentials.oauth2.refresh_token` → **À CHIFFRER**
- ❌ `credentials.oauth2.token_type` → Non sensible (ex: "Bearer")
- ❌ `credentials.oauth2.expires_at` → Non sensible (datetime)
- ❌ `credentials.oauth2.scope` → Non sensible (peut être chiffré si nécessaire)

### API Key
- ✅ `credentials.api_key.key` → **À CHIFFRER**
- ❌ `credentials.api_key.header_name` → Non sensible (ex: "X-API-Key")
- ❌ `credentials.api_key.query_param_name` → Non sensible (ex: "api_key")

### Basic Auth
- ✅ `credentials.basic_auth.username` → **À CHIFFRER**
- ✅ `credentials.basic_auth.password` → **À CHIFFRER**

### Custom
- ✅ Tous les champs de `credentials.custom` → **À CHIFFRER** (selon le contexte)

## Comment ça fonctionne ?

### 1. Configuration du chiffrement

Une table `credential_encryption_config` stocke la configuration de chiffrement :

```surql
CREATE credential_encryption_config SET
    is_active = true,
    algorithm = 'aes256',
    encryption_key = 'votre-cle-de-chiffrement-minimum-32-caracteres',
    key_version = 1;
```

### 2. Chiffrement automatique

Lors de la création ou mise à jour d'une credential, les fonctions `fn::create_user_service_credential` et `fn::update_user_service_credential` chiffrent automatiquement tous les champs sensibles avant stockage.

### 3. Déchiffrement automatique

Pour récupérer les credentials déchiffrés (par exemple pour `fn::execute_tool`), utilisez `fn::get_user_service_credential_decrypted`.

## Utilisation

### Création d'une credential (chiffrement automatique)

```surql
-- Les credentials en clair sont automatiquement chiffrés
LET $result = fn::create_user_service_credential(
    $user_id: 'user123',
    $service_id: 'service:google_sheets',
    $credential_type_id: 'credential_type:google_sheets_oauth2',
    $identity_name: 'Mon compte Google Sheets',
    $credentials: {
        oauth2: {
            access_token: 'ya29.a0AfH6SMB...',
            refresh_token: '1//0gX...',
            token_type: 'Bearer',
            expires_at: <datetime>'2024-12-31T23:59:59Z',
            scope: 'read:user write:message'
        }
    }
);
```

### Récupération d'une credential déchiffrée

```surql
-- Pour utilisation dans fn::execute_tool
LET $credential = fn::get_user_service_credential_decrypted(
    $credential_id: 'user_service_credential:123'
);

-- $credential.credential.credentials contient les données déchiffrées
LET $access_token = $credential.credential.credentials.oauth2.access_token;
```

### Récupération d'une credential (sans données sensibles)

```surql
-- Pour affichage dans l'UI (sans données sensibles)
LET $credentials = fn::get_user_service_credential(
    $user_id: 'user123',
    $service_id: 'service:google_sheets',
    $langue_id: 'fr'
);
```

## Fonctions disponibles

### Chiffrement/Déchiffrement

- `fn::encrypt_credential_value($plaintext)` : Chiffre une valeur unique
- `fn::decrypt_credential_value($encrypted_data, $key_version)` : Déchiffre une valeur unique
- `fn::encrypt_credentials_object($credentials)` : Chiffre un objet credentials complet
- `fn::decrypt_credentials_object($encrypted_credentials)` : Déchiffre un objet credentials complet

### CRUD avec chiffrement automatique

- `fn::create_user_service_credential(...)` : Crée une credential (chiffrement automatique)
- `fn::update_user_service_credential(...)` : Met à jour une credential (chiffrement automatique)
- `fn::get_user_service_credential_decrypted($credential_id)` : Récupère avec déchiffrement
- `fn::get_user_service_credential(...)` : Récupère sans données sensibles

## Gestion de la clé de chiffrement

### Stockage de la clé

La clé de chiffrement est stockée dans la table `credential_encryption_config` :

```surql
-- Créer la configuration initiale
CREATE credential_encryption_config SET
    is_active = true,
    algorithm = 'aes256',
    encryption_key = 'votre-cle-secrete-minimum-32-caracteres-securisee',
    key_version = 1;
```

### Rotation des clés

Pour changer de clé de chiffrement :

1. Créer une nouvelle configuration avec une version supérieure
2. Migrer progressivement les credentials existants

```surql
-- 1. Créer la nouvelle configuration
CREATE credential_encryption_config SET
    is_active = true,
    algorithm = 'aes256',
    encryption_key = 'nouvelle-cle-secrete-minimum-32-caracteres',
    key_version = 2;

-- 2. Migrer les credentials existants (script de migration)
LET $credentials = SELECT * FROM user_service_credential;
FOR $cred IN $credentials {
    -- Déchiffrer avec l'ancienne clé
    LET $decrypted = fn::decrypt_credentials_object($cred.credentials, $key_version: 1);
    -- Chiffrer avec la nouvelle clé
    LET $reencrypted = fn::encrypt_credentials_object($decrypted.decrypted_credentials);
    -- Mettre à jour
    UPDATE $cred.id SET credentials = $reencrypted.encrypted_credentials;
};
```

## Quels champs sont chiffrés ?

### Automatiquement chiffrés

- ✅ `credentials.oauth2.access_token`
- ✅ `credentials.oauth2.refresh_token`
- ✅ `credentials.api_key.key`
- ✅ `credentials.basic_auth.username`
- ✅ `credentials.basic_auth.password`
- ✅ Tous les champs de `credentials.custom`

### Non chiffrés (métadonnées)

- ❌ `credentials.oauth2.token_type` (ex: "Bearer")
- ❌ `credentials.oauth2.expires_at` (datetime)
- ❌ `credentials.oauth2.scope` (peut être chiffré si nécessaire)
- ❌ `credentials.api_key.header_name` (ex: "X-API-Key")
- ❌ `credentials.api_key.query_param_name` (ex: "api_key")

## Algorithme utilisé

**AES-256** via `crypto::aes256::encrypt` et `crypto::aes256::decrypt` (fonctions intégrées de SurrealDB).

## Sécurité

### ⚠️ Important

1. **Protection de la clé** : La clé de chiffrement doit être protégée et jamais exposée
2. **Permissions** : Seuls les admins et le système peuvent gérer la configuration de chiffrement
3. **Rotation régulière** : Roter les clés tous les 3-6 mois
4. **Backup** : Sauvegarder la configuration de chiffrement séparément

### Permissions

- `credential_encryption_config` : Seuls les admins peuvent modifier
- Les fonctions de chiffrement/déchiffrement ont `PERMISSIONS FULL` pour être utilisées par les autres fonctions

## Migration depuis l'ancien système

Si vous aviez des credentials chiffrés côté application :

```surql
-- 1. Déchiffrer avec l'ancienne méthode côté application
-- 2. Réinsérer via fn::create_user_service_credential (sera automatiquement chiffré dans SurrealDB)
```

## Références

- Table : `integrations/database/credentials/user_service_credential.surql`
- Configuration : `integrations/database/credentials/credential_encryption_config.surql`
- Fonctions : `integrations/database/resource/credentials/fn_encrypt_decrypt_credentials.surql`
- Documentation SurrealDB : [Security](https://surrealdb.com/docs/security)

## Notes techniques

**Note importante** : Si votre version de SurrealDB ne supporte pas `crypto::aes256::encrypt` et `crypto::aes256::decrypt`, vous devrez :

1. Créer des fonctions personnalisées via des extensions SurrealDB
2. Ou utiliser une approche hybride avec chiffrement côté application pour ces fonctions spécifiques

Les fonctions créées utilisent ces fonctions crypto intégrées. Vérifiez votre version de SurrealDB avant utilisation.

## Exemples d'implémentation

### Node.js (JavaScript/TypeScript)

```javascript
import crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const KEY_LENGTH = 32; // 256 bits
const IV_LENGTH = 12; // 96 bits
const TAG_LENGTH = 16; // 128 bits

// Récupérer la clé depuis les variables d'environnement
const ENCRYPTION_KEY = Buffer.from(process.env.ENCRYPTION_KEY || '', 'hex');

if (ENCRYPTION_KEY.length !== KEY_LENGTH) {
  throw new Error('ENCRYPTION_KEY doit faire 32 bytes (64 caractères hex)');
}

/**
 * Chiffre une valeur sensible
 * @param {string} plaintext - Texte à chiffrer
 * @returns {string} - Texte chiffré au format base64 (IV:TAG:CIPHERTEXT)
 */
function encryptCredential(plaintext) {
  if (!plaintext) return null;
  
  // Générer un IV aléatoire
  const iv = crypto.randomBytes(IV_LENGTH);
  
  // Créer le cipher
  const cipher = crypto.createCipheriv(ALGORITHM, ENCRYPTION_KEY, iv);
  
  // Chiffrer
  let encrypted = cipher.update(plaintext, 'utf8', 'base64');
  encrypted += cipher.final('base64');
  
  // Récupérer le tag d'authentification
  const tag = cipher.getAuthTag();
  
  // Retourner au format: IV:TAG:CIPHERTEXT (base64)
  return `${iv.toString('base64')}:${tag.toString('base64')}:${encrypted}`;
}

/**
 * Déchiffre une valeur chiffrée
 * @param {string} encryptedData - Texte chiffré au format base64 (IV:TAG:CIPHERTEXT)
 * @returns {string} - Texte déchiffré
 */
function decryptCredential(encryptedData) {
  if (!encryptedData) return null;
  
  try {
    // Parser le format: IV:TAG:CIPHERTEXT
    const parts = encryptedData.split(':');
    if (parts.length !== 3) {
      throw new Error('Format de données chiffrées invalide');
    }
    
    const [ivBase64, tagBase64, ciphertext] = parts;
    const iv = Buffer.from(ivBase64, 'base64');
    const tag = Buffer.from(tagBase64, 'base64');
    
    // Créer le decipher
    const decipher = crypto.createDecipheriv(ALGORITHM, ENCRYPTION_KEY, iv);
    decipher.setAuthTag(tag);
    
    // Déchiffrer
    let decrypted = decipher.update(ciphertext, 'base64', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error) {
    throw new Error(`Erreur de déchiffrement: ${error.message}`);
  }
}

/**
 * Chiffre un objet credentials complet
 * @param {object} credentials - Objet credentials (oauth2, api_key, basic_auth, etc.)
 * @returns {object} - Objet credentials avec valeurs sensibles chiffrées
 */
function encryptCredentialsObject(credentials) {
  if (!credentials) return credentials;
  
  const encrypted = { ...credentials };
  
  // Chiffrer OAuth2
  if (encrypted.oauth2) {
    if (encrypted.oauth2.access_token) {
      encrypted.oauth2.access_token = encryptCredential(encrypted.oauth2.access_token);
    }
    if (encrypted.oauth2.refresh_token) {
      encrypted.oauth2.refresh_token = encryptCredential(encrypted.oauth2.refresh_token);
    }
  }
  
  // Chiffrer API Key
  if (encrypted.api_key?.key) {
    encrypted.api_key.key = encryptCredential(encrypted.api_key.key);
  }
  
  // Chiffrer Basic Auth
  if (encrypted.basic_auth) {
    if (encrypted.basic_auth.username) {
      encrypted.basic_auth.username = encryptCredential(encrypted.basic_auth.username);
    }
    if (encrypted.basic_auth.password) {
      encrypted.basic_auth.password = encryptCredential(encrypted.basic_auth.password);
    }
  }
  
  // Chiffrer Custom (récursif si nécessaire)
  if (encrypted.custom) {
    encrypted.custom = encryptCustomCredentials(encrypted.custom);
  }
  
  return encrypted;
}

/**
 * Déchiffre un objet credentials complet
 * @param {object} encryptedCredentials - Objet credentials chiffré
 * @returns {object} - Objet credentials avec valeurs sensibles déchiffrées
 */
function decryptCredentialsObject(encryptedCredentials) {
  if (!encryptedCredentials) return encryptedCredentials;
  
  const decrypted = { ...encryptedCredentials };
  
  // Déchiffrer OAuth2
  if (decrypted.oauth2) {
    if (decrypted.oauth2.access_token) {
      decrypted.oauth2.access_token = decryptCredential(decrypted.oauth2.access_token);
    }
    if (decrypted.oauth2.refresh_token) {
      decrypted.oauth2.refresh_token = decryptCredential(decrypted.oauth2.refresh_token);
    }
  }
  
  // Déchiffrer API Key
  if (decrypted.api_key?.key) {
    decrypted.api_key.key = decryptCredential(decrypted.api_key.key);
  }
  
  // Déchiffrer Basic Auth
  if (decrypted.basic_auth) {
    if (decrypted.basic_auth.username) {
      decrypted.basic_auth.username = decryptCredential(decrypted.basic_auth.username);
    }
    if (decrypted.basic_auth.password) {
      decrypted.basic_auth.password = decryptCredential(decrypted.basic_auth.password);
    }
  }
  
  // Déchiffrer Custom (récursif si nécessaire)
  if (decrypted.custom) {
    decrypted.custom = decryptCustomCredentials(decrypted.custom);
  }
  
  return decrypted;
}

// Exemple d'utilisation
const credentials = {
  oauth2: {
    access_token: 'ya29.a0AfH6SMB...',
    refresh_token: '1//0gX...',
    token_type: 'Bearer',
    expires_at: '2024-12-31T23:59:59Z',
    scope: 'read:user write:message'
  }
};

// Avant insertion dans SurrealDB
const encryptedCredentials = encryptCredentialsObject(credentials);

// Après récupération depuis SurrealDB
const decryptedCredentials = decryptCredentialsObject(encryptedCredentials);

export { encryptCredential, decryptCredential, encryptCredentialsObject, decryptCredentialsObject };
```

### Python

```python
import os
import base64
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.backends import default_backend

# Récupérer la clé depuis les variables d'environnement
ENCRYPTION_KEY = bytes.fromhex(os.getenv('ENCRYPTION_KEY', ''))

if len(ENCRYPTION_KEY) != 32:
    raise ValueError('ENCRYPTION_KEY doit faire 32 bytes (64 caractères hex)')

def encrypt_credential(plaintext: str) -> str:
    """Chiffre une valeur sensible."""
    if not plaintext:
        return None
    
    # Générer un nonce (IV) aléatoire
    nonce = os.urandom(12)  # 96 bits pour AES-GCM
    
    # Chiffrer
    aesgcm = AESGCM(ENCRYPTION_KEY)
    ciphertext = aesgcm.encrypt(nonce, plaintext.encode('utf-8'), None)
    
    # Retourner au format: NONCE:CIPHERTEXT (base64)
    # Le tag d'authentification est inclus dans le ciphertext par AESGCM
    nonce_b64 = base64.b64encode(nonce).decode('utf-8')
    ciphertext_b64 = base64.b64encode(ciphertext).decode('utf-8')
    
    return f"{nonce_b64}:{ciphertext_b64}"

def decrypt_credential(encrypted_data: str) -> str:
    """Déchiffre une valeur chiffrée."""
    if not encrypted_data:
        return None
    
    try:
        # Parser le format: NONCE:CIPHERTEXT
        parts = encrypted_data.split(':')
        if len(parts) != 2:
            raise ValueError('Format de données chiffrées invalide')
        
        nonce_b64, ciphertext_b64 = parts
        nonce = base64.b64decode(nonce_b64)
        ciphertext = base64.b64decode(ciphertext_b64)
        
        # Déchiffrer
        aesgcm = AESGCM(ENCRYPTION_KEY)
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        
        return plaintext.decode('utf-8')
    except Exception as e:
        raise ValueError(f'Erreur de déchiffrement: {str(e)}')

def encrypt_credentials_object(credentials: dict) -> dict:
    """Chiffre un objet credentials complet."""
    if not credentials:
        return credentials
    
    encrypted = credentials.copy()
    
    # Chiffrer OAuth2
    if 'oauth2' in encrypted and encrypted['oauth2']:
        if 'access_token' in encrypted['oauth2']:
            encrypted['oauth2']['access_token'] = encrypt_credential(encrypted['oauth2']['access_token'])
        if 'refresh_token' in encrypted['oauth2']:
            encrypted['oauth2']['refresh_token'] = encrypt_credential(encrypted['oauth2']['refresh_token'])
    
    # Chiffrer API Key
    if 'api_key' in encrypted and encrypted['api_key']:
        if 'key' in encrypted['api_key']:
            encrypted['api_key']['key'] = encrypt_credential(encrypted['api_key']['key'])
    
    # Chiffrer Basic Auth
    if 'basic_auth' in encrypted and encrypted['basic_auth']:
        if 'username' in encrypted['basic_auth']:
            encrypted['basic_auth']['username'] = encrypt_credential(encrypted['basic_auth']['username'])
        if 'password' in encrypted['basic_auth']:
            encrypted['basic_auth']['password'] = encrypt_credential(encrypted['basic_auth']['password'])
    
    return encrypted

def decrypt_credentials_object(encrypted_credentials: dict) -> dict:
    """Déchiffre un objet credentials complet."""
    if not encrypted_credentials:
        return encrypted_credentials
    
    decrypted = encrypted_credentials.copy()
    
    # Déchiffrer OAuth2
    if 'oauth2' in decrypted and decrypted['oauth2']:
        if 'access_token' in decrypted['oauth2']:
            decrypted['oauth2']['access_token'] = decrypt_credential(decrypted['oauth2']['access_token'])
        if 'refresh_token' in decrypted['oauth2']:
            decrypted['oauth2']['refresh_token'] = decrypt_credential(decrypted['oauth2']['refresh_token'])
    
    # Déchiffrer API Key
    if 'api_key' in decrypted and decrypted['api_key']:
        if 'key' in decrypted['api_key']:
            decrypted['api_key']['key'] = decrypt_credential(decrypted['api_key']['key'])
    
    # Déchiffrer Basic Auth
    if 'basic_auth' in decrypted and decrypted['basic_auth']:
        if 'username' in decrypted['basic_auth']:
            decrypted['basic_auth']['username'] = decrypt_credential(decrypted['basic_auth']['username'])
        if 'password' in decrypted['basic_auth']:
            decrypted['basic_auth']['password'] = decrypt_credential(decrypted['basic_auth']['password'])
    
    return decrypted
```

## Utilisation avec les fonctions SurrealDB

### Création d'une credential

```javascript
import { encryptCredentialsObject } from './encryption';
import { Surreal } from 'surrealdb.js';

const surreal = new Surreal();

// Credentials en clair (depuis le formulaire utilisateur)
const plainCredentials = {
  oauth2: {
    access_token: 'ya29.a0AfH6SMB...',
    refresh_token: '1//0gX...',
    token_type: 'Bearer',
    expires_at: '2024-12-31T23:59:59Z',
    scope: 'read:user write:message'
  }
};

// ⚠️ CHIFFRER avant insertion
const encryptedCredentials = encryptCredentialsObject(plainCredentials);

// Appeler la fonction SurrealDB
await surreal.call('fn::create_user_service_credential', {
  user_id: 'user:123',
  service_id: 'service:google_sheets',
  credential_type_id: 'credential_type:google_sheets_oauth2',
  identity: {
    name: 'Mon compte Google Sheets'
  },
  credentials: encryptedCredentials, // ✅ Déjà chiffré
  is_active: true
});
```

### Récupération et déchiffrement d'une credential

```javascript
import { decryptCredentialsObject } from './encryption';

// Récupérer depuis SurrealDB (les fonctions excluent automatiquement les données sensibles)
const credential = await surreal.call('fn::get_user_service_credential', {
  credential_id: 'user_service_credential:123'
});

// Si vous avez besoin des données sensibles, récupérer directement
const fullCredential = await surreal.query(`
  SELECT * FROM user_service_credential WHERE id = $id AND user_id = $auth.id
`, { id: 'user_service_credential:123' });

// ⚠️ DÉCHIFFRER après récupération
const decryptedCredentials = decryptCredentialsObject(fullCredential[0].credentials);

// Utiliser les credentials déchiffrés pour l'appel API
const response = await fetch('https://api.example.com/data', {
  headers: {
    'Authorization': `Bearer ${decryptedCredentials.oauth2.access_token}`
  }
});
```

## Migration des données existantes

Si vous avez déjà des credentials en clair dans la base de données :

```javascript
// 1. Récupérer toutes les credentials
const credentials = await surreal.query('SELECT * FROM user_service_credential');

// 2. Pour chaque credential, chiffrer et mettre à jour
for (const cred of credentials[0]) {
  const encrypted = encryptCredentialsObject(cred.credentials);
  
  await surreal.query(`
    UPDATE user_service_credential SET credentials = $encrypted WHERE id = $id
  `, {
    id: cred.id,
    encrypted: encrypted
  });
}
```

## Bonnes pratiques

### ✅ À FAIRE

1. **Chiffrer uniquement les données sensibles** : Ne pas chiffrer les métadonnées (`token_type`, `expires_at`, `scope`, etc.)
2. **Utiliser des IV aléatoires** : Générer un nouvel IV à chaque chiffrement
3. **Stockez les clés de manière sécurisée** : Variables d'environnement ou service de gestion de secrets
4. **Loguer les erreurs de déchiffrement** : Pour détecter les problèmes de corruption
5. **Ne jamais logger les credentials** : Ni en clair, ni chiffrés
6. **Tester le chiffrement/déchiffrement** : Dans vos tests unitaires

### ❌ À ÉVITER

1. **Ne pas hardcoder les clés** : Jamais dans le code source
2. **Ne pas utiliser le même IV** : Toujours générer un nouvel IV
3. **Ne pas stocker les clés dans Git** : Même dans `.gitignore`
4. **Ne pas utiliser des algorithmes faibles** : MD5, DES, RC4 sont obsolètes
5. **Ne pas chiffrer les métadonnées** : Cela complique les requêtes et n'apporte rien

## Rotation des clés

Pour changer de clé de chiffrement :

1. **Déchiffrer avec l'ancienne clé**
2. **Chiffrer avec la nouvelle clé**
3. **Mettre à jour les credentials**

```javascript
// Exemple de migration
const OLD_KEY = Buffer.from(process.env.OLD_ENCRYPTION_KEY, 'hex');
const NEW_KEY = Buffer.from(process.env.NEW_ENCRYPTION_KEY, 'hex');

async function rotateKeys() {
  const credentials = await surreal.query('SELECT * FROM user_service_credential');
  
  for (const cred of credentials[0]) {
    // Déchiffrer avec l'ancienne clé
    const decrypted = decryptCredentialsObject(cred.credentials, OLD_KEY);
    
    // Chiffrer avec la nouvelle clé
    const reencrypted = encryptCredentialsObject(decrypted, NEW_KEY);
    
    // Mettre à jour
    await surreal.query(`
      UPDATE user_service_credential SET credentials = $encrypted WHERE id = $id
    `, {
      id: cred.id,
      encrypted: reencrypted
    });
  }
}
```

## Sécurité supplémentaire

### HSM (Hardware Security Module)

Pour les environnements critiques, utilisez un HSM pour stocker les clés de chiffrement :

- **AWS CloudHSM**
- **Azure Dedicated HSM**
- **Google Cloud HSM**

### Enveloppe de chiffrement (Envelope Encryption)

Pour des performances optimales avec de grandes quantités de données :

1. Générer une clé de données (DEK) pour chaque credential
2. Chiffrer la DEK avec la clé principale (KEK)
3. Stocker la DEK chiffrée avec les données

## Références

- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [NIST Guidelines for Cryptography](https://csrc.nist.gov/publications/detail/sp/800-175b/rev-1/final)
- Documentation SurrealDB : [Security](https://surrealdb.com/docs/security)
- Table : `integrations/database/credentials/user_service_credential.surql`

