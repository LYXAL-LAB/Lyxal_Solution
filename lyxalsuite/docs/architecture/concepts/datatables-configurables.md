# DataTables Configurables - Architecture Modulaire

## 🎯 Concept Principal

**Problème résolu** : Comment avoir des tables de données dynamiques qui s'adaptent automatiquement selon :
- Le **workspace** (environnement de travail de l'utilisateur)
- Le **module** activé (CRM, Marketing, Helpdesk, etc.)
- Les **permissions** de l'utilisateur

**Solution** : Un système de datatables configurables qui se base sur des schémas centralisés mais s'adaptent au contexte.

## 📋 Analogie Simple

Imaginez un **restaurant** (workspace) qui peut avoir différents **services** (modules) :
- Service de **réservation** (CRM)
- Service de **livraison** (Marketing)
- Service **après-vente** (Helpdesk)

Chaque service a ses propres **tables de données** mais dans le même restaurant. Les datatables configurables permettent d'afficher automatiquement les bonnes données avec la bonne présentation selon le service utilisé.

## 🏗️ Architecture en 3 Niveaux

### Niveau 1 : **Schémas Centralisés** (Templates)
```
module_datatable_schema
├── lyxal-crm/contacts     (Comment afficher les contacts)
├── lyxal-crm/deals        (Comment afficher les deals)
├── lyxal-marketing/campaigns (Comment afficher les campagnes)
└── lyxal-helpdesk/tickets    (Comment afficher les tickets)
```

### Niveau 2 : **Configuration par Workspace**
```
workspace_module_config
├── workspace_A + lyxal-crm     (CRM activé pour le workspace A)
├── workspace_A + lyxal-marketing (Marketing activé pour le workspace A)
├── workspace_B + lyxal-crm     (CRM activé pour le workspace B)
└── workspace_B + lyxal-helpdesk  (Helpdesk activé pour le workspace B)
```

### Niveau 3 : **Données Isolées par Workspace**
```
Namespace ws_A:
├── contacts (données CRM du workspace A)
├── campaigns (données Marketing du workspace A)

Namespace ws_B:
├── contacts (données CRM du workspace B) 
├── tickets (données Helpdesk du workspace B)
```

## 🔧 Comment ça Fonctionne

### 1. **Définition d'un Schéma de Module**

Un développeur définit comment une table doit être affichée :

```sql
-- Schéma pour les contacts CRM
CREATE module_datatable_schema SET
    module_name = 'lyxal-crm',
    table_name = 'contacts',
    
    -- Comment créer la table en SurrealDB
    table_definition = 'DEFINE TABLE contacts SCHEMAFUL;
DEFINE FIELD first_name ON contacts TYPE string;
DEFINE FIELD last_name ON contacts TYPE string;
DEFINE FIELD email ON contacts TYPE string;',

    -- Comment afficher dans l'interface
    display_config = {
        columns: [
            { field: 'first_name', title: 'Prénom', sortable: true },
            { field: 'last_name', title: 'Nom', sortable: true },
            { field: 'email', title: 'Email', sortable: true }
        ],
        filters: [
            { field: 'status', type: 'select', options: ['lead', 'prospect', 'customer'] }
        ]
    };
```

### 2. **Activation dans un Workspace**

Quand un utilisateur active le module CRM dans son workspace :

```sql
-- Le module CRM est activé pour le workspace "restaurant_paris"
CREATE workspace_module_config SET
    workspace_id = workspace:restaurant_paris,
    module_name = 'lyxal-crm',
    is_enabled = true;
```

**🔄 Automatiquement** (via un EVENT SurrealDB) :
- Une table `ws_restaurant_paris.contacts` est créée
- Une instance de configuration est générée
- La table devient disponible dans l'interface

### 3. **Affichage Automatique**

Dans l'interface React, un simple composant :

```tsx
<ConfigurableDataTable
  workspaceId="restaurant_paris"
  moduleName="lyxal-crm" 
  tableName="contacts"
/>
```

**Récupère automatiquement** :
- La configuration d'affichage (colonnes, filtres)
- Les données du workspace correct (`ws_restaurant_paris.contacts`)
- Les permissions de l'utilisateur
- Les actions disponibles (créer, modifier, supprimer)

## 📊 Exemple Concret : Restaurant

### Workspace "Restaurant Le Bistro"

**Modules activés** : CRM + Marketing

#### Table CRM/Contacts
```
| Prénom | Nom    | Email              | Statut   |
|--------|--------|--------------------|----------|
| Marie  | Martin | marie@email.com    | Client   |
| Paul   | Durand | paul@email.com     | Prospect |
```

#### Table Marketing/Campaigns  
```
| Nom Campagne    | Type     | Statut | Ouvertures |
|-----------------|----------|--------|------------|
| Menu Automne    | Email    | Actif  | 245        |
| Promo Weekend   | SMS      | Fini   | 89         |
```

### Workspace "Restaurant La Table"

**Modules activés** : CRM + Helpdesk

#### Table CRM/Contacts (données différentes)
```
| Prénom | Nom     | Email               | Statut |
|--------|---------|---------------------|--------|
| Sophie | Bernard | sophie@email.com    | Client |
| Luc    | Moreau  | luc@email.com       | Lead   |
```

#### Table Helpdesk/Tickets
```
| Numéro | Client  | Sujet              | Statut    |
|--------|---------|--------------------|-----------| 
| #001   | Sophie  | Problème résa      | Ouvert    |
| #002   | Luc     | Question menu      | Résolu    |
```

## 🛠️ Structure des Fichiers

```
lyxalsuite/
├── lyxal-base/
│   ├── model/
│   │   └── workspace-module-configuration.md    # Tables SurrealDB
│   └── services/
│       └── WorkspaceDataTableService.ts         # Service de gestion
│
├── lyxalkitui/
│   ├── src/components/
│   │   └── ConfigurableDataTable/
│   │       └── ConfigurableDataTable.tsx        # Composant UI
│   └── src/hooks/
│       └── useWorkspaceDataTable.ts             # Hook React
│
└── docs/
    └── architecture/
        └── datatables-configurables.md          # Cette documentation
```

## 🎮 Guide d'Utilisation

### Pour un Développeur de Module

1. **Définir le schéma** de vos tables dans `module_datatable_schema`
2. **Configurer l'affichage** (colonnes, filtres, actions)
3. **Définir les permissions** par table

### Pour un Administrateur de Workspace

1. **Activer/désactiver** les modules souhaités
2. **Personnaliser l'affichage** si nécessaire (masquer des colonnes, etc.)
3. **Gérer les permissions** des utilisateurs

### Pour un Développeur Frontend

1. **Utiliser le composant** `ConfigurableDataTable`
2. **Ou utiliser le hook** `useWorkspaceDataTable` pour plus de contrôle
3. **Personnaliser les actions** (créer, modifier, supprimer)

## 💡 Exemples d'Usage

### Usage Simple
```tsx
// Affichage basique auto-configuré
<ConfigurableDataTable
  workspaceId="mon_workspace"
  moduleName="lyxal-crm"
  tableName="contacts"
/>
```

### Usage Avancé avec Hook
```tsx
function ContactsPage() {
  const {
    data,
    loading,
    createRecord,
    updateRecord,
    deleteRecord
  } = useWorkspaceDataTable({
    workspaceId: 'mon_workspace',
    moduleName: 'lyxal-crm', 
    tableName: 'contacts'
  });

  const handleCreate = (contactData) => {
    createRecord(contactData);
  };

  return (
    <div>
      <button onClick={() => handleCreate({...})}>
        Nouveau Contact
      </button>
      
      <ConfigurableDataTable ... />
    </div>
  );
}
```

### Usage avec Actions Personnalisées
```tsx
<ConfigurableDataTable
  workspaceId="restaurant_paris"
  moduleName="lyxal-crm"
  tableName="contacts"
  onCreate={() => openCreateModal()}
  onEdit={(contact) => openEditModal(contact)}
  onDelete={(contact) => confirmDelete(contact)}
  extraActions={
    <button onClick={exportData}>Exporter</button>
  }
/>
```

## ✅ Avantages

1. **Réutilisabilité** : Un schéma défini une fois, utilisable partout
2. **Isolation** : Chaque workspace a ses propres données
3. **Modularité** : Comme Axelor, activation/désactivation des modules
4. **Automatisation** : Tables créées automatiquement
5. **Flexibilité** : Configuration personnalisable par workspace
6. **Performance** : Optimisé pour SurrealDB avec namespaces

## 🔍 Points Importants

- **Namespace SurrealDB** : `ws_{workspace_id}` pour isoler les données
- **Event-driven** : Provisioning automatique via SurrealDB EVENTS
- **Type Safety** : Interfaces TypeScript complètes
- **Permissions** : Gestion fine par table et action
- **Responsive** : Interface adaptative

## 🚀 Prochaines Étapes

1. Implémenter des **templates de modules** prêts à l'emploi
2. Ajouter l'**export/import** automatique
3. Créer un **éditeur visuel** de configuration
4. Implémenter les **webhooks** pour les synchronisations
5. Ajouter l'**analytics** sur l'utilisation des tables

---

*Cette architecture permet d'avoir un système flexible et puissant tout en gardant la simplicité d'utilisation pour les développeurs et les utilisateurs finaux.* 