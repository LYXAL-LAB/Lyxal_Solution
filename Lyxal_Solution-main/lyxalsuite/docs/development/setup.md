# 🛠️ Setup Développement LyxalSuite

## 🎯 Prérequis

### Outils requis
```bash
# Node.js 18+
node --version # v18.0.0+
npm --version  # v8.0.0+

# Git
git --version

# Docker & Docker Compose
docker --version
docker-compose --version

# SurrealDB CLI
surreal version

# Logto CLI (optionnel)
npm install -g @logto/cli
```

### Services externes
- **Stripe** : Compte développeur pour paiements
- **Logto Cloud** : Instance pour authentification
- **AWS S3** : Bucket pour stockage fichiers
- **SendGrid** : API pour emails

## 🚀 Installation rapide

### 1. Clone du repository
```bash
# Clone principal
git clone https://github.com/lyxal/lyxalsuite.git
cd lyxalsuite

# Clone lyxalkitui (frontend centralisé)
git clone https://github.com/lyxal/lyxalkitui.git

# Structure finale
lyxalsuite/
├── backend/           # Backend Node.js modulaire
├── lyxalkitui/       # Frontend React centralisé
├── docs/             # Documentation
└── docker-compose.yml
```

### 2. Configuration environnement
```bash
# Copie des fichiers d'environnement
cp backend/.env.example backend/.env
cp lyxalkitui/.env.example lyxalkitui/.env

# Édition des variables
nano backend/.env
nano lyxalkitui/.env
```

### 3. Démarrage avec Docker
```bash
# Démarrage complet (backend + db + services)
docker-compose up -d

# Vérification services
docker-compose ps
```

## ⚙️ Configuration détaillée

### Backend (.env)
```bash
# === BASE ===
NODE_ENV=development
PORT=3000
API_VERSION=v1

# === DATABASE ===
SURREALDB_URL=ws://localhost:8000/rpc
SURREALDB_USER=root
SURREALDB_PASS=root
SURREALDB_NS=system
SURREALDB_DB=lyxalsuite

# === AUTHENTIFICATION ===
LOGTO_ENDPOINT=https://your-logto-instance.com
LOGTO_MANAGEMENT_API_RESOURCE=https://your-logto-instance.com/api
LOGTO_MANAGEMENT_API_TOKEN=your-management-token

# === JWT ===
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=24h

# === STRIPE ===
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_CONNECT_CLIENT_ID=ca_...

# === AWS S3 ===
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=eu-west-1
AWS_S3_BUCKET=lyxalsuite-files

# === EMAIL ===
SENDGRID_API_KEY=SG.your-sendgrid-key
FROM_EMAIL=noreply@lyxalsuite.com

# === AI ===
OPENAI_API_KEY=sk-your-openai-key
OPENAI_MODEL=gpt-4

# === REDIS (Cache) ===
REDIS_URL=redis://localhost:6379

# === MONITORING ===
SENTRY_DSN=https://your-sentry-dsn
LOG_LEVEL=debug
```

### Frontend (.env)
```bash
# === API ===
VITE_API_URL=http://localhost:3000/api
VITE_API_VERSION=v1

# === LOGTO ===
VITE_LOGTO_ENDPOINT=https://your-logto-instance.com
VITE_LOGTO_APP_ID=your-app-id

# === STRIPE ===
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...

# === FEATURES FLAGS ===
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_ANALYTICS=true
VITE_ENABLE_SAAS_BUILDER=true

# === MONITORING ===
VITE_SENTRY_DSN=https://your-sentry-dsn
VITE_ENVIRONMENT=development
```

## 🗄️ Setup SurrealDB

### 1. Installation locale
```bash
# Installation SurrealDB
curl -sSf https://install.surrealdb.com | sh

# Démarrage serveur
surreal start --log trace --user root --pass root memory

# Ou avec Docker
docker run --rm -p 8000:8000 surrealdb/surrealdb:latest \
  start --log trace --user root --pass root memory
```

### 2. Initialisation base
```bash
# Script d'initialisation
cd backend
npm run db:init

# Ou manuellement
surreal sql --conn http://localhost:8000 --user root --pass root \
  --ns system --db lyxalsuite < scripts/init-db.sql
```

### 3. Structure initiale
```sql
-- scripts/init-db.sql
USE NS system;
USE DB lyxalsuite;

-- Tables système
DEFINE TABLE tenants SCHEMAFULL;
DEFINE FIELD id ON tenants TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON tenants TYPE string ASSERT is::email($value);
DEFINE FIELD name ON tenants TYPE string;
DEFINE FIELD plan ON tenants TYPE string;
DEFINE FIELD created_at ON tenants TYPE datetime DEFAULT time::now();

DEFINE TABLE saas_instances SCHEMAFULL;
DEFINE FIELD id ON saas_instances TYPE string ASSERT $value != NONE;
DEFINE FIELD tenant_id ON saas_instances TYPE string;
DEFINE FIELD domain ON saas_instances TYPE string;
DEFINE FIELD industry ON saas_instances TYPE string;
DEFINE FIELD status ON saas_instances TYPE string DEFAULT 'active';

-- Index pour performances
DEFINE INDEX tenant_email ON tenants FIELDS email UNIQUE;
DEFINE INDEX saas_domain ON saas_instances FIELDS domain UNIQUE;
```

## 🔐 Setup Logto

### 1. Configuration Management API
```bash
# Création application Management API
curl -X POST https://your-logto-instance.com/api/applications \
  -H "Authorization: Bearer your-admin-token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "LyxalSuite Management",
    "type": "MachineToMachine",
    "description": "Management API for LyxalSuite"
  }'
```

### 2. Configuration rôles système
```typescript
// scripts/setup-logto.ts
import { LogtoManagementApi } from '@logto/node';

async function setupLogtoRoles() {
  const api = new LogtoManagementApi({
    endpoint: process.env.LOGTO_ENDPOINT,
    credentials: {
      resource: process.env.LOGTO_MANAGEMENT_API_RESOURCE,
      accessToken: process.env.LOGTO_MANAGEMENT_API_TOKEN
    }
  });
  
  // Création rôles système
  const systemRoles = [
    { name: 'tenant_admin', description: 'Tenant administrator' },
    { name: 'tenant_user', description: 'Tenant user' }
  ];
  
  for (const role of systemRoles) {
    await api.post('roles', role);
  }
  
  console.log('Logto roles created successfully');
}

// Exécution
npm run setup:logto
```

## 📦 Installation modules

### Backend
```bash
cd backend

# Installation dépendances
npm install

# Installation modules LyxalSuite
npm install @lyxal/auth @lyxal/crm @lyxal/analytics @lyxal/ai @lyxal/ecommerce

# Build modules
npm run build

# Tests
npm run test
npm run test:e2e
```

### Frontend
```bash
cd lyxalkitui

# Installation dépendances
npm install

# Installation LyxalKitUI
npm install @lyxal/ui-kit

# Build
npm run build

# Tests
npm run test
npm run test:e2e
```

## 🔄 Workflow développement

### 1. Démarrage services
```bash
# Terminal 1: Base de données
docker-compose up surrealdb redis

# Terminal 2: Backend
cd backend
npm run dev

# Terminal 3: Frontend
cd lyxalkitui  
npm run dev

# Terminal 4: Logto (si local)
npm run logto:dev
```

### 2. Hot reload
```bash
# Backend avec nodemon
npm run dev:watch

# Frontend avec Vite HMR
npm run dev

# Tests en continu
npm run test:watch
```

### 3. Debugging
```bash
# Backend avec debugger
npm run dev:debug

# Frontend avec source maps
npm run dev:debug

# Logs détaillés
DEBUG=lyxalsuite:* npm run dev
```

## 🧪 Tests

### Configuration Jest
```javascript
// backend/jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/test'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/main.ts'
  ],
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts']
};
```

### Tests d'intégration
```typescript
// test/integration/saas-creation.test.ts
describe('SaaS Creation Flow', () => {
  beforeEach(async () => {
    await setupTestDatabase();
    await setupTestLogto();
  });
  
  it('should create SaaS from prompt', async () => {
    const prompt = 'Créer un SaaS pour restaurant';
    
    const response = await request(app)
      .post('/api/saas-builder/create')
      .send({ prompt })
      .expect(201);
      
    expect(response.body.saas_id).toBeDefined();
    expect(response.body.industry).toBe('restaurant');
  });
  
  afterEach(async () => {
    await cleanupTestData();
  });
});
```

## 🚀 Déploiement local

### Build production
```bash
# Backend
cd backend
npm run build
npm run start:prod

# Frontend  
cd lyxalkitui
npm run build
npm run preview
```

### Docker production
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - NODE_ENV=production
    ports:
      - "3000:3000"
      
  frontend:
    build:
      context: ./lyxalkitui
      dockerfile: Dockerfile.prod
    ports:
      - "80:80"
      
  surrealdb:
    image: surrealdb/surrealdb:latest
    command: start --log info --user root --pass root file:///data/database.db
    volumes:
      - surrealdb_data:/data
    ports:
      - "8000:8000"
```

## 🔧 Outils développement

### VS Code extensions
```json
// .vscode/extensions.json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-jest",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "ms-vscode-remote.remote-containers"
  ]
}
```

### Scripts utiles
```json
// package.json scripts
{
  "scripts": {
    "dev": "concurrently \"npm run dev:backend\" \"npm run dev:frontend\"",
    "dev:backend": "cd backend && npm run dev",
    "dev:frontend": "cd lyxalkitui && npm run dev",
    "test:all": "npm run test:backend && npm run test:frontend",
    "build:all": "npm run build:backend && npm run build:frontend",
    "setup": "npm run setup:env && npm run setup:db && npm run setup:logto",
    "reset": "npm run reset:db && npm run reset:cache"
  }
}
```

### Makefile
```makefile
# Makefile
.PHONY: setup dev test build clean

setup:
	@echo "Setting up LyxalSuite development environment..."
	cp backend/.env.example backend/.env
	cp lyxalkitui/.env.example lyxalkitui/.env
	docker-compose up -d surrealdb redis
	cd backend && npm install
	cd lyxalkitui && npm install
	npm run db:init

dev:
	@echo "Starting development servers..."
	docker-compose up -d surrealdb redis
	concurrently "cd backend && npm run dev" "cd lyxalkitui && npm run dev"

test:
	@echo "Running all tests..."
	cd backend && npm test
	cd lyxalkitui && npm test

build:
	@echo "Building for production..."
	cd backend && npm run build
	cd lyxalkitui && npm run build

clean:
	@echo "Cleaning up..."
	docker-compose down -v
	cd backend && rm -rf dist node_modules
	cd lyxalkitui && rm -rf dist node_modules
```

## 📚 Documentation développeur

### Génération docs API
```bash
# Swagger/OpenAPI
npm run docs:generate

# TypeDoc
npm run docs:typedoc

# Storybook (composants)
cd lyxalkitui
npm run storybook
```

### Contribution
```bash
# Pre-commit hooks
npm install -g husky
husky install

# Conventional commits
npm install -g @commitlint/cli @commitlint/config-conventional

# Linting
npm run lint
npm run lint:fix
```

---

**🛠️ Setup complet pour développer efficacement sur LyxalSuite** 