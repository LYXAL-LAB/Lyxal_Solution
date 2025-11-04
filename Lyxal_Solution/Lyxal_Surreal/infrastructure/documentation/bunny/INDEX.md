# 📑 Index - Documentation Infrastructure Bunny

**Module** : `infrastructure`  
**Date** : 2025-01-27

---

## 📚 Documentation Disponible

### 🏠 [README.md](./README.md)
**Vue d'ensemble complète du module Infrastructure Bunny**

Contenu :
- Vision et objectifs
- Structure du module
- Domaines principaux (CDN, Storage, DNS, Shield, etc.)
- Synchronisation Bunny ↔ SurrealDB
- Patterns Lyxal appliqués
- Démarrage rapide

---

### 📐 [PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md)
**Patterns et conventions standards Lyxal pour le module Infrastructure**

Contenu :
- Principes fondateurs
- Structure standard des tables
- Règles de nommage
- Internationalisation (i18n)
- Synchronisation avec Bunny API
- Patterns par type de ressource
- Checklist de validation
- Pièges courants et solutions

**À lire en premier** si vous créez de nouvelles tables ou harmonisez des tables existantes.

---

### 🏛️ [ARCHITECTURE.md](./ARCHITECTURE.md)
**Architecture détaillée du module Infrastructure**

Contenu :
- Principes architecturaux
- Structure des domaines
- Flux de synchronisation
- Modèle de données
- Permissions et sécurité
- Monitoring et métriques
- Déploiement et migration
- Intégrations

**À lire** pour comprendre l'architecture globale et les interactions entre composants.

---

### 📊 [TABLES_REFERENCE.md](./TABLES_REFERENCE.md)
**Référence complète de toutes les tables du module**

Contenu :
- Liste exhaustive des tables par domaine
- Structure détaillée de chaque table
- Relations entre tables
- Tableau récapitulatif
- Hiérarchies principales

**À consulter** comme référence lors du développement ou de la maintenance.

---

## 🗺️ Parcours de Lecture Recommandé

### Pour les Développeurs

1. **Commencez par** : [README.md](./README.md)
   - Vue d'ensemble du module
   - Comprendre les objectifs

2. **Ensuite** : [PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md)
   - Apprendre les patterns standards
   - Conventions de nommage

3. **Puis** : [ARCHITECTURE.md](./ARCHITECTURE.md)
   - Comprendre l'architecture
   - Flux de synchronisation

4. **Référence** : [TABLES_REFERENCE.md](./TABLES_REFERENCE.md)
   - Consulter selon besoins
   - Structure des tables

### Pour les Architectes

1. [ARCHITECTURE.md](./ARCHITECTURE.md) - Architecture globale
2. [PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md) - Patterns standards
3. [README.md](./README.md) - Vue d'ensemble
4. [TABLES_REFERENCE.md](./TABLES_REFERENCE.md) - Référence tables

### Pour les DevOps

1. [README.md](./README.md) - Vue d'ensemble
2. [ARCHITECTURE.md](./ARCHITECTURE.md) - Flux de synchronisation
3. [TABLES_REFERENCE.md](./TABLES_REFERENCE.md) - Structure tables
4. [PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md) - Patterns (si création tables)

---

## 🔍 Recherche Rapide

### Par Sujet

| Sujet | Document | Section |
|-------|----------|---------|
| Structure tables | PATTERNS_AND_CONVENTIONS.md | Structure Standard |
| Synchronisation Bunny | ARCHITECTURE.md | Flux de Synchronisation |
| Liste tables | TABLES_REFERENCE.md | Tableau Récapitulatif |
| Patterns i18n | PATTERNS_AND_CONVENTIONS.md | Internationalisation |
| Relations tables | TABLES_REFERENCE.md | Relations Principales |
| Permissions | ARCHITECTURE.md | Permissions et Sécurité |
| Checklist création | PATTERNS_AND_CONVENTIONS.md | Checklist de Validation |

### Par Domaine

| Domaine | Tables | Document |
|---------|--------|----------|
| CDN | `bunny_cdn_zone`, `bunny_pull_zone_model` | TABLES_REFERENCE.md |
| Storage | `bunny_storage_zone_model`, `bunny_storage_object` | TABLES_REFERENCE.md |
| DNS | `bunny_dns_zone`, `bunny_dns_record` | TABLES_REFERENCE.md |
| Shield | `bunny_shield_overview`, `bunny_waf` | TABLES_REFERENCE.md |
| Edge Scripts | `bunny_edge_script_model` | TABLES_REFERENCE.md |
| Video | `bunny_video_library_model` | TABLES_REFERENCE.md |
| Infrastructure | `infrastructure_logs`, `bunny_containers` | TABLES_REFERENCE.md |

---

## 📝 Notes Importantes

### Tables Modèles vs Tables Métier

- **Tables `*_model`** : Mapping direct API Bunny (structure originale)
- **Tables métier** : Structure Lyxal avec patterns `identity`, `metadata`

### Migration Progressive

Le module est en cours d'harmonisation avec les patterns Lyxal. Les nouvelles tables doivent suivre les patterns standards définis dans `PATTERNS_AND_CONVENTIONS.md`.

### Documentation Externe

- **API Bunny** : Fichiers JSON dans `documentation/bunny/`
- **Patterns Knowledge** : `knowledge/documentation/📄 11_Conventions_and_Rules.md`
- **Patterns Studio** : `studio/documentation/README.md`

---

## 🚀 Actions Rapides

### Créer une Nouvelle Table

1. Consulter [PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md)
2. Suivre la structure standard
3. Créer les clés i18n si nécessaire
4. Ajouter à [TABLES_REFERENCE.md](./TABLES_REFERENCE.md)

### Synchroniser avec Bunny

1. Consulter [ARCHITECTURE.md](./ARCHITECTURE.md) - Flux de Synchronisation
2. Implémenter worker de sync
3. Configurer métadonnées `sync.*`

### Harmoniser une Table Existante

1. Consulter [PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md)
2. Identifier écarts avec patterns standards
3. Ajouter blocs `identity`, `metadata`, `sync`
4. Migrer données existantes

---

## 📞 Support

Pour questions ou contributions :
- Consulter la documentation correspondante
- Vérifier les patterns standards Lyxal
- Consulter les modules `knowledge` et `studio` pour exemples

---

**Index Documentation Infrastructure Bunny** 📑✨

