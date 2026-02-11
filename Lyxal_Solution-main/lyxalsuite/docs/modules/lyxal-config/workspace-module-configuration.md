# Configuration Modules Workspace

Datatable : Base + Extensions par Module

## Architecture Modulaire par Workspace

Un workspace reçoit tous les modules disponibles mais peut activer/désactiver chacun d'entre eux. Chaque module définit ses propres tables dans le namespace du workspace.

### Tables de Configuration

#### 1. **workspace_module_config** - Configuration globale des modules par workspace

```sql
DEFINE TABLE workspace_module_config SCHEMAFUL;

-- Identifiants
DEFINE FIELD id ON workspace_module_config TYPE string;
DEFINE FIELD workspace_id ON workspace_module_config TYPE record(workspace);
DEFINE FIELD module_name ON workspace_module_config TYPE string ASSERT $value != NONE;

-- Configuration du module
DEFINE FIELD is_enabled ON workspace_module_config TYPE bool DEFAULT true;
DEFINE FIELD version ON workspace_module_config TYPE string;
DEFINE FIELD config_schema ON workspace_module_config TYPE object;

-- Permissions par défaut du module
DEFINE FIELD default_permissions ON workspace_module_config TYPE array<string>;
DEFINE FIELD restricted_permissions ON workspace_module_config TYPE array<string>;

-- Metadata
DEFINE FIELD installed_at ON workspace_module_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON workspace_module_config TYPE datetime DEFAULT time::now();
DEFINE FIELD installed_by ON workspace_module_config TYPE record(user);

-- Index
DEFINE INDEX workspace_module_unique_idx ON workspace_module_config FIELDS workspace_id, module_name UNIQUE;
```

#### 2. **module_datatable_schema** - Schémas des tables par module

```sql
DEFINE TABLE module_datatable_schema SCHEMAFUL;

-- Identifiants
DEFINE FIELD id ON module_datatable_schema TYPE string;
DEFINE FIELD module_name ON module_datatable_schema TYPE string ASSERT $value != NONE;
DEFINE FIELD table_name ON module_datatable_schema TYPE string ASSERT $value != NONE;

-- Schéma de la table
DEFINE FIELD table_definition ON module_datatable_schema TYPE string;
DEFINE FIELD fields_schema ON module_datatable_schema TYPE object;
DEFINE FIELD relations ON module_datatable_schema TYPE array<object>;
DEFINE FIELD indexes ON module_datatable_schema TYPE array<object>;

-- Configuration d'affichage
DEFINE FIELD display_config ON module_datatable_schema TYPE object;
DEFINE FIELD filterable_fields ON module_datatable_schema TYPE array<string>;
DEFINE FIELD sortable_fields ON module_datatable_schema TYPE array<string>;
DEFINE FIELD searchable_fields ON module_datatable_schema TYPE array<string>;

-- Permissions par table
DEFINE FIELD table_permissions ON module_datatable_schema TYPE object;

-- Metadata
DEFINE FIELD created_at ON module_datatable_schema TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON module_datatable_schema TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX module_table_unique_idx ON module_datatable_schema FIELDS module_name, table_name UNIQUE;
```

#### 3. **workspace_datatable_instance** - Instances des tables par workspace

```sql
DEFINE TABLE workspace_datatable_instance SCHEMAFUL;

-- Identifiants
DEFINE FIELD id ON workspace_datatable_instance TYPE string;
DEFINE FIELD workspace_id ON workspace_datatable_instance TYPE record(workspace);
DEFINE FIELD module_name ON workspace_datatable_instance TYPE string;
DEFINE FIELD table_name ON workspace_datatable_instance TYPE string;

-- Configuration spécifique au workspace
DEFINE FIELD namespace_name ON workspace_datatable_instance TYPE string;
DEFINE FIELD table_full_name ON workspace_datatable_instance TYPE string;
DEFINE FIELD is_created ON workspace_datatable_instance TYPE bool DEFAULT false;
DEFINE FIELD creation_status ON workspace_datatable_instance TYPE string;

-- Surcharges de configuration
DEFINE FIELD custom_fields ON workspace_datatable_instance TYPE object;
DEFINE FIELD hidden_fields ON workspace_datatable_instance TYPE array<string>;
DEFINE FIELD custom_display_config ON workspace_datatable_instance TYPE object;

-- Permissions spécifiques
DEFINE FIELD workspace_permissions ON workspace_datatable_instance TYPE object;

-- Statistiques
DEFINE FIELD record_count ON workspace_datatable_instance TYPE number DEFAULT 0;
DEFINE FIELD last_accessed ON workspace_datatable_instance TYPE datetime;

-- Metadata
DEFINE FIELD created_at ON workspace_datatable_instance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON workspace_datatable_instance TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX workspace_table_unique_idx ON workspace_datatable_instance FIELDS workspace_id, module_name, table_name UNIQUE;
DEFINE INDEX workspace_namespace_idx ON workspace_datatable_instance FIELDS namespace_name;
```

## Configuration par Module

### Exemple : Module CRM

```sql
-- Configuration du module CRM
CREATE workspace_module_config SET
    id = 'wmc_crm_ws_main',
    workspace_id = workspace:ws_main,
    module_name = 'lyxal-crm',
    is_enabled = true,
    version = '1.0.0',
    config_schema = {
        features: {
            lead_scoring: true,
            email_integration: true,
            campaign_management: false
        },
        limits: {
            max_contacts: 10000,
            max_deals: 1000
        }
    },
    default_permissions = ['crm.contacts.read', 'crm.deals.read'],
    restricted_permissions = ['crm.admin.*'];
```

### Service de Configuration DataTable

```typescript
interface DataTableConfig {
  workspace_id: string;
  module_name: string;
  table_name: string;
  schema: TableSchema;
  display: DisplayConfig;
  permissions: PermissionConfig;
}

class WorkspaceDataTableService {
  
  async getModuleConfig(workspaceId: string, moduleName: string): Promise<DataTableConfig[]> {
    const query = `
      SELECT * FROM workspace_datatable_instance 
      WHERE workspace_id = $workspace AND module_name = $module
    `;
    
    return await this.surrealClient.query(query, {
      workspace: workspaceId,
      module: moduleName
    });
  }
  
  async provisionModuleTables(workspaceId: string, moduleName: string): Promise<void> {
    const schemas = await this.getModuleSchemas(moduleName);
    await this.createWorkspaceNamespace(workspaceId);
    
    for (const schema of schemas) {
      await this.createTableInWorkspace(workspaceId, schema);
    }
  }
}
```

## Provisioning automatique

```sql
DEFINE EVENT provision_module_tables ON TABLE workspace_module_config 
WHEN $event = "CREATE" AND $after.is_enabled = true THEN {
  
  LET $schemas = (SELECT * FROM module_datatable_schema WHERE module_name = $after.module_name);
  
  FOR $schema IN $schemas {
    LET $instance_id = "wdi_" + $schema.table_name + "_" + $after.workspace_id;
    LET $namespace = "ws_" + string::replace($after.workspace_id, "workspace:", "");
    
    CREATE workspace_datatable_instance SET
      id = $instance_id,
      workspace_id = $after.workspace_id,
      module_name = $schema.module_name,
      table_name = $schema.table_name,
      namespace_name = $namespace,
      table_full_name = $namespace + "." + $schema.table_name,
      is_created = false,
      creation_status = "pending";
  };
};
```

## Architecture Finale

```
LyxalSuite (Global)
├── Module Schemas (Centralisés)
│   ├── lyxal-crm
│   ├── lyxal-marketing
│   └── lyxal-helpdesk
│
├── Workspace A (Namespace: ws_a)
│   ├── Tables CRM: contacts, deals
│   ├── Tables Marketing: campaigns
│   └── Tables Helpdesk: tickets
│
└── Workspace B (Namespace: ws_b)
    └── (Même structure, données isolées)
```

Cette architecture respecte la structure SurrealDB basée sur les tables tout en permettant une configuration modulaire flexible comme Axelor. 