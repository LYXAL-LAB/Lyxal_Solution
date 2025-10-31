 # 🏗️ Architecture LyxalSuite - Documentation

*Index de navigation pour toute la documentation architecturale*

---

## 📋 **Vue d'Ensemble**

Cette documentation couvre l'architecture complète de LyxalSuite, organisée de manière hiérarchique pour une navigation optimale.

---

## 🗂️ **Structure de la Documentation**

### **📄 Points d'Entrée**
- **[Overview](./overview.md)** - Vue d'ensemble générale de l'architecture
- **[Architecture Reference](./architecture-reference.md)** - Référence technique bicéphale

---

### **🏗️ Architecture Core**
- **[Backend Modulaire](./core/backend-modules.md)** - Architecture backend modulaire
- **[Multi-Tenancy](./core/multi-tenancy.md)** - Architecture multi-tenant B2B2C
- **[Standards de Développement](./core/development-standards.md)** - Guidelines et standards

---

### **💡 Concepts Spécialisés**
- **[DataTables Configurables](./concepts/datatables-configurables.md)** - Système de tables dynamiques

---

### **🚀 Déploiement & Opérations**
- **[Déploiement SaaS](./deployment/saas-deployment.md)** - Processus de génération et déploiement

---

## 🎯 **Guide de Lecture Recommandé**

### **Pour les Nouveaux Développeurs**
1. Commencer par **[Overview](./overview.md)** pour comprendre la vision globale
2. Lire **[Architecture Reference](./architecture-reference.md)** pour les concepts bicéphales
3. Approfondir avec **[Backend Modulaire](./core/backend-modules.md)**
4. Consulter **[Standards](./core/development-standards.md)** avant de développer

### **Pour les Architectes**
1. **[Architecture Reference](./architecture-reference.md)** - Patterns techniques
2. **[Multi-Tenancy](./core/multi-tenancy.md)** - Isolation et hiérarchie
3. **[Déploiement SaaS](./deployment/saas-deployment.md)** - Processus automatisés

### **Pour les Product Managers**
1. **[Overview](./overview.md)** - Modèle business et technique
2. **[DataTables Configurables](./concepts/datatables-configurables.md)** - Fonctionnalités utilisateur

---

## 🔄 **Maintenance Documentation**

Cette documentation suit les **[Standards de Développement](./core/development-standards.md)** pour :
- ✅ Cohérence des formats
- ✅ Navigation claire
- ✅ Mise à jour régulière
- ✅ Versioning documenté

---

## 🎯 **Architecture Levels**

LyxalSuite utilise une **architecture bicéphale** :

- **🏢 INVESTOR_LEVEL** : Vision globale, namespace `catalog`
- **👨‍💻 DEVELOPER_LEVEL** : SaaS spécifique, namespace `{saas_id}`

Voir **[Architecture Reference](./architecture-reference.md)** pour les détails complets.

---

*Cette documentation évolue avec LyxalSuite. Consultez les [Standards](./core/development-standards.md) pour contribuer.*