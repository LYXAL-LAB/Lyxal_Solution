 # 🔧 Configurations Centralisées LyxalSuite

Ce dossier contient toutes les configurations partagées pour maintenir la cohérence à travers tous les modules de LyxalSuite.

## 📁 Structure

```
.config/
├── tsconfig.base.json        # Configuration TypeScript de base
├── tsconfig.react.json       # Configuration pour modules React
├── tsconfig.node.json        # Configuration pour modules Node.js/backend
├── jest.config.base.js       # Configuration Jest partagée
├── eslint.config.base.js     # Configuration ESLint partagée
├── tsconfig.projects.json    # Références de tous les projets
└── README.md                 # Ce fichier
```

## 🎯 Utilisation

### **TypeScript - Modules React**
```json
{
  "extends": "../.config/tsconfig.react.json",
  "compilerOptions": {
    "baseUrl": "src"
  }
}
```

### **TypeScript - Modules Node.js**
```json
{
  "extends": "../.config/tsconfig.node.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

### **Jest - Tests**
```json
{
  "scripts": {
    "test": "jest --config ../.config/jest.config.base.js",
    "test:watch": "jest --config ../.config/jest.config.base.js --watch"
  }
}
```

### **ESLint - Linting**
```json
{
  "scripts": {
    "lint": "eslint . --config ../.config/eslint.config.base.js",
    "lint:fix": "eslint . --config ../.config/eslint.config.base.js --fix"
  }
}
```

## ✅ **Avantages**

### **Cohérence**
- **Même configuration TypeScript** pour tous les modules
- **Standards de code identiques** via ESLint
- **Tests uniformes** avec Jest

### **Maintenance**
- **Un seul endroit** pour modifier les règles
- **Mise à jour globale** en changeant un fichier
- **Évite les duplications** et incohérences

### **Simplicité**
- **Fichiers de configuration légers** dans chaque module
- **Héritage clair** via `extends`
- **Réduction drastique** du code dupliqué

## 🚀 **Migration d'un Module**

### **Avant (Dupliqué)**
```json
// package.json - 50+ lignes de devDependencies
{
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "typescript": "^5.0.0"
    // ... +20 autres
  }
}

// tsconfig.json - 40+ lignes de configuration
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM"],
    "strict": true,
    // ... +30 autres options
  }
}
```

### **Après (Centralisé)**
```json
// package.json - Seulement les dépendances spécifiques
{
  "dependencies": {
    "react-router-dom": "^6.8.0",
    "recharts": "^2.8.0"
  }
}

// tsconfig.json - Héritage simple
{
  "extends": "../.config/tsconfig.react.json",
  "compilerOptions": {
    "baseUrl": "src"
  }
}
```

## 📊 **Impact**

### **Réduction de Code**
- **package.json** : 50+ lignes → 5-10 lignes
- **tsconfig.json** : 40+ lignes → 5-8 lignes
- **jest.config.js** : 30+ lignes → Supprimé (utilise centralisé)

### **Maintenance**
- **Mise à jour TypeScript** : 1 fichier au lieu de 15+
- **Nouvelle règle ESLint** : 1 fichier au lieu de 15+
- **Configuration Jest** : 1 fichier au lieu de 8+

### **Cohérence**
- **Builds identiques** sur tous les modules
- **Standards de code unifiés**
- **Tests cohérents**

---

**Créé le :** 25/06/2025  
**Dernière mise à jour :** 25/06/2025  
**Impact :** 🚀 RÉVOLUTIONNAIRE sur la maintenabilité