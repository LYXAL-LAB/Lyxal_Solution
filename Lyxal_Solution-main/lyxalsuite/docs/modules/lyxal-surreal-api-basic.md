# 🔗 API Reference Rapide - Architecture Bicéphale

## 🏢 Instance SaaS
- `createSaaS(id, config)` - Créer instance SaaS
- `useSaaS(id)` - Naviguer vers instance SaaS
- `saasExists(id)` - Vérifier existence

## 🗂️ Workspaces  
- `createWorkspace(saasId, workspaceId, modules)` - Créer workspace
- `useWorkspace(saasId, workspaceId)` - Naviguer vers workspace
- `workspaceExists(saasId, workspaceId)` - Vérifier existence

## 📦 Modules
- `installModuleInWorkspace(saasId, workspaceId, module)` - Installer module
- `getWorkspaceModules(saasId, workspaceId)` - Lister modules

## 🛡️ Middlewares
- `saasMiddleware` - Validation instance SaaS
- `workspaceMiddleware` - Validation workspace complet
- `autoProvisionSaaSMiddleware` - Auto-création SaaS
- `autoProvisionWorkspaceMiddleware` - Auto-création workspace

## 📊 Headers HTTP
- `X-SaaS-ID` - Identifiant instance SaaS (requis)
- `X-Workspace-ID` - Identifiant workspace (optionnel pour SaaS seul)
- `X-SaaS-DisplayName` - Nom d'affichage SaaS
- `X-SaaS-Plan` - Plan SaaS (starter/pro/enterprise)

## ⚡ Performance
- Cache TTL intelligent
- Monitoring requêtes
- Métriques performance

Pour plus de détails, voir [API-REFERENCE.md](./API-REFERENCE.md) 