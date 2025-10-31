# LyxalAuth

Module d'authentification centralisé pour LYXAL Suite.

## Architecture

LyxalAuth est structuré selon une architecture hexagonale, avec trois composants principaux:

1. **Gateway**: Point d'entrée unique et sécurisé pour toutes les opérations d'authentification
2. **SDK Core**: Couche de base partagée contenant types, utilitaires et fonctions communes
3. **SDK Frontend**: Client pour les applications web communiquant avec la Gateway
4. **SDK Backend**: Client pour les applications serveur communiquant avec la Gateway

## Installation

```bash
# Installation du package
npm install @lyxalsuite/lyxalauth
```

## Configuration

### Gateway

Créez un fichier `.env` basé sur le modèle `env.example` à la racine du projet:

```bash
# Copier le fichier d'exemple
cp env.example .env
# Éditer avec vos paramètres
nano .env
```

### SDK Frontend

```typescript
import { AuthClient } from '@lyxalsuite/lyxalauth/sdk/frontend';

const authClient = new AuthClient({
  gatewayUrl: 'https://auth-gateway.example.com'
});

// Connexion utilisateur
const session = await authClient.login({
  email: 'user@example.com',
  password: '********'
});

// Avec React
import { AuthProvider, useAuth } from '@lyxalsuite/lyxalauth/sdk/frontend';

function App() {
  return (
    <AuthProvider options={{ gatewayUrl: 'https://auth-gateway.example.com' }}>
      <ProtectedPage />
    </AuthProvider>
  );
}

function ProtectedPage() {
  const { user, isAuthenticated, logout } = useAuth();
  
  if (!isAuthenticated) {
    return <div>Please login</div>;
  }
  
  return (
    <div>
      <h1>Welcome, {user.name}</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

### SDK Backend

```typescript
import { AuthClient, createAuthMiddleware } from '@lyxalsuite/lyxalauth/sdk/backend';
import express from 'express';

const app = express();

// Client d'authentification
const authClient = new AuthClient({
  gatewayUrl: 'https://auth-gateway.example.com',
  apiKey: 'your-api-key'
});

// Middleware d'authentification
const authMiddleware = createAuthMiddleware({
  gatewayUrl: 'https://auth-gateway.example.com',
  remoteVerification: true
});

// Middleware pour les routes protégées
app.get('/protected', authMiddleware, (req, res) => {
  res.json({ message: `Hello, ${req.auth.userId}` });
});

// Vérifier un token programmatiquement
app.post('/verify', async (req, res) => {
  const { token } = req.body;
  const isValid = await authClient.verifyToken(token);
  res.json({ valid: isValid });
});
```

## Démarrage de la Gateway

```bash
# Développement
npm run dev

# Production
npm run build
npm start
```

## Documentation de l'API

La documentation de l'API est disponible dans le dossier `gateway/Documentation/API`.

## Rapports détaillés

Pour une documentation plus détaillée sur chaque composant:

- [Rapport SDK Core](sdk/core/rapport.md)
- [Rapport SDK Frontend](sdk/frontend/rapport.md)
- [Rapport SDK Backend](sdk/backend/rapport.md)
- [Rapport Gateway](gateway/rapport.md)

## Sécurité

Ce module implémente plusieurs couches de sécurité:

- Cookies HTTP-only pour les tokens côté frontend
- Vérification des tokens via la Gateway
- Middleware configurable pour la validation des tokens
- Support des clés API pour les communications serveur-à-serveur
- Protection contre les attaques courantes (CSRF, XSS, etc.)

## Développement

```bash
# Installation des dépendances
npm install

# Lancement des tests
npm test

# Vérification du code
npm run lint

# Formattage du code
npm run format
``` 