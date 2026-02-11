# 📁 Documentation n8n

Documentation complète de n8n: base de données et nœuds.

## Fichiers

| Fichier | Description |
|---------|-------------|
| [DATABASE_AUDIT.md](./n8n/DATABASE_AUDIT.md) | Audit complet avec toutes les tables et colonnes |
| [TABLES_INDEX.md](./n8n/TABLES_INDEX.md) | Index rapide de toutes les tables |
| [NODES_CATALOG.md](./n8n/NODES_CATALOG.md) | Catalogue de tous les types de nœuds |
| [LYXAL_FLOW_BLUEPRINT.md](./LYXAL_FLOW_BLUEPRINT.md) | Blueprint pour le moteur de flow Rust natif |
| [MULTITENANCY_ARCHITECTURE.md](./MULTITENANCY_ARCHITECTURE.md) | Architecture multi-tenancy n8n vs Lyxal |

## Résumé

- **50 tables** au total
- **14 catégories** fonctionnelles
- **3 bases de données** supportées : SQLite, PostgreSQL, MySQL/MariaDB
- **ORM** : TypeORM

## Catégories

1. **Identité & Auth** (8 tables) - Utilisateurs, rôles, permissions
2. **Workflows** (6 tables) - Définitions des automatisations
3. **Exécutions** (6 tables) - Historique des lancements
4. **Projets** (6 tables) - Espaces de travail partagés
5. **Credentials** (1 table) - Identifiants sécurisés
6. **Tags** (4 tables) - Catégorisation
7. **Variables** (3 tables) - Configuration
8. **Binary Data** (1 table) - Fichiers
9. **Tests** (2 tables) - Validation (Enterprise)
10. **OAuth/MCP** (5 tables) - Authentification API
11. **ChatHub** (3 tables) - Conversations IA
12. **DataTables** (2 tables) - Données structurées
13. **Packages** (2 tables) - Extensions npm
14. **Logs** (1 table) - Streaming (Enterprise)

## Source

Analyse basée sur le code source : `n8n-master/packages/@n8n/db/src/entities/`
