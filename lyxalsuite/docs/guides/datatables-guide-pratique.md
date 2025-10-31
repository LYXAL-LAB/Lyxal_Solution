# Guide Pratique - DataTables Configurables

## 🎯 Objectif de ce Guide

Ce guide vous explique **concrètement** comment utiliser les datatables configurables dans LyxalSuite, avec des exemples réels et du code prêt à utiliser.

## 📋 Cas d'Usage Types

### Cas 1 : Module CRM - Gestion des Contacts
### Cas 2 : Module Marketing - Gestion des Campagnes  
### Cas 3 : Module Helpdesk - Gestion des Tickets

---

## 🏗️ ÉTAPE 1 : Configuration Initiale du Module

### Créer le Schéma d'un Module

**Exemple : Module CRM avec table Contacts**

```sql
-- 1. Définir le schéma de la table contacts
CREATE module_datatable_schema SET
    id = 'mds_crm_contacts',
    module_name = 'lyxal-crm',
    table_name = 'contacts',
    
    -- Définition SurrealDB de la table
    table_definition = '
DEFINE TABLE contacts SCHEMAFUL;
DEFINE FIELD id ON contacts TYPE string;
DEFINE FIELD first_name ON contacts TYPE string ASSERT $value != NONE;
DEFINE FIELD last_name ON contacts TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON contacts TYPE string ASSERT string::matches($value, "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
DEFINE FIELD phone ON contacts TYPE string;
DEFINE FIELD company ON contacts TYPE string;
DEFINE FIELD status ON contacts TYPE string ASSERT $value IN ["lead", "prospect", "customer"];
DEFINE FIELD created_at ON contacts TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contacts TYPE datetime DEFAULT time::now();
DEFINE INDEX contacts_email_idx ON contacts FIELDS email UNIQUE;',

    -- Structure des champs pour validation
    fields_schema = {
        id: { type: 'string', required: true, primary: true },
        first_name: { type: 'string', required: true, searchable: true },
        last_name: { type: 'string', required: true, searchable: true },
        email: { type: 'email', required: true, unique: true },
        phone: { type: 'phone', required: false },
        company: { type: 'string', required: false, searchable: true },
        status: { 
            type: 'enum', 
            values: ['lead', 'prospect', 'customer'], 
            default: 'lead',
            required: true
        },
        created_at: { type: 'datetime', required: false },
        updated_at: { type: 'datetime', required: false }
    },

    -- Configuration de l'affichage dans l'interface
    display_config = {
        columns: [
            { 
                field: 'first_name', 
                title: 'Prénom', 
                sortable: true, 
                width: 120 
            },
            { 
                field: 'last_name', 
                title: 'Nom', 
                sortable: true, 
                width: 120 
            },
            { 
                field: 'email', 
                title: 'Email', 
                sortable: true, 
                width: 200,
                type: 'email'
            },
            { 
                field: 'phone', 
                title: 'Téléphone', 
                sortable: false, 
                width: 130,
                type: 'phone'
            },
            { 
                field: 'company', 
                title: 'Société', 
                sortable: true, 
                width: 150 
            },
            { 
                field: 'status', 
                title: 'Statut', 
                sortable: true, 
                width: 100,
                type: 'badge'
            },
            { 
                field: 'created_at', 
                title: 'Créé le', 
                sortable: true, 
                width: 110,
                type: 'date'
            }
        ],
        filters: [
            {
                field: 'status',
                type: 'select',
                options: ['lead', 'prospect', 'customer'],
                placeholder: 'Filtrer par statut'
            },
            {
                field: 'company',
                type: 'text',
                placeholder: 'Filtrer par société'
            }
        ],
        page_size: 50,
        enable_export: true,
        enable_import: true
    },

    -- Champs utilisables pour filtres, tri et recherche
    filterable_fields = ['status', 'company', 'created_at'],
    sortable_fields = ['first_name', 'last_name', 'email', 'company', 'status', 'created_at'],
    searchable_fields = ['first_name', 'last_name', 'email', 'company'],

    -- Permissions par défaut pour cette table
    table_permissions = {
        read: ['crm.contacts.read', 'crm.*'],
        write: ['crm.contacts.write', 'crm.*'],
        delete: ['crm.contacts.delete', 'crm.*'],
        export: ['crm.contacts.export', 'crm.*'],
        import: ['crm.contacts.import', 'crm.*']
    };
```

---

## 🏢 ÉTAPE 2 : Activer le Module dans un Workspace

### Activation Automatique

```typescript
// Dans votre application
import WorkspaceDataTableService from '@lyxalsuite/lyxal-base/services/WorkspaceDataTableService';

const service = new WorkspaceDataTableService();

// Activer le module CRM pour le workspace "restaurant_paris"
await service.enableModuleInWorkspace(
    'restaurant_paris',
    'lyxal-crm', 
    'user_admin_123'
);
```

**Ce qui se passe automatiquement :**
1. Une configuration `workspace_module_config` est créée
2. Un EVENT SurrealDB se déclenche
3. Une table `ws_restaurant_paris.contacts` est créée avec le bon schéma
4. Une instance `workspace_datatable_instance` est générée

---

## 🎨 ÉTAPE 3 : Utiliser dans l'Interface

### Utilisation Simple

```tsx
import React from 'react';
import ConfigurableDataTable from '@lyxalsuite/lyxal-kitui/components/ConfigurableDataTable';

function ContactsPage() {
    return (
        <div style={{ padding: 24 }}>
            <ConfigurableDataTable
                workspaceId="restaurant_paris"
                moduleName="lyxal-crm"
                tableName="contacts"
                title="Gestion des Contacts"
            />
        </div>
    );
}
```

**Résultat :** Une table complète avec :
- ✅ Colonnes configurées automatiquement
- ✅ Filtres par statut et société
- ✅ Recherche dans prénom, nom, email, société
- ✅ Tri sur toutes les colonnes configurées
- ✅ Pagination avec 50 éléments par page
- ✅ Actions créer/modifier/supprimer (selon permissions)

### Utilisation Avancée avec Actions Personnalisées

```tsx
import React, { useState } from 'react';
import { Modal, Form, Input, Select, message } from 'antd';
import ConfigurableDataTable from '@lyxalsuite/lyxal-kitui/components/ConfigurableDataTable';
import { useWorkspaceDataTable } from '@lyxalsuite/lyxal-kitui/hooks/useWorkspaceDataTable';

function ContactsPageAdvanced() {
    const [form] = Form.useForm();
    const [isModalVisible, setIsModalVisible] = useState(false);
    const [editingContact, setEditingContact] = useState(null);

    // Hook pour la gestion des données
    const {
        data,
        loading,
        createRecord,
        updateRecord,
        deleteRecord,
        refresh
    } = useWorkspaceDataTable({
        workspaceId: 'restaurant_paris',
        moduleName: 'lyxal-crm',
        tableName: 'contacts'
    });

    // Gestion de la création
    const handleCreate = () => {
        setEditingContact(null);
        form.resetFields();
        setIsModalVisible(true);
    };

    // Gestion de l'édition
    const handleEdit = (contact) => {
        setEditingContact(contact);
        form.setFieldsValue(contact);
        setIsModalVisible(true);
    };

    // Gestion de la suppression
    const handleDelete = (contact) => {
        Modal.confirm({
            title: 'Confirmer la suppression',
            content: `Supprimer ${contact.first_name} ${contact.last_name} ?`,
            onOk: () => deleteRecord(contact.id)
        });
    };

    // Gestion de la modal
    const handleModalOk = async () => {
        try {
            const values = await form.validateFields();
            
            if (editingContact) {
                await updateRecord(editingContact.id, values);
            } else {
                await createRecord(values);
            }
            
            setIsModalVisible(false);
            form.resetFields();
        } catch (error) {
            console.error('Erreur:', error);
        }
    };

    return (
        <div style={{ padding: 24 }}>
            <ConfigurableDataTable
                workspaceId="restaurant_paris"
                moduleName="lyxal-crm"
                tableName="contacts"
                title="Gestion des Contacts"
                onCreate={handleCreate}
                onEdit={handleEdit}
                onDelete={handleDelete}
                onRowClick={(contact) => {
                    // Navigation vers le détail
                    console.log('Voir détail:', contact);
                }}
                extraActions={
                    <button onClick={refresh}>
                        Actualiser
                    </button>
                }
            />

            {/* Modal de création/édition */}
            <Modal
                title={editingContact ? 'Modifier' : 'Nouveau Contact'}
                open={isModalVisible}
                onOk={handleModalOk}
                onCancel={() => setIsModalVisible(false)}
            >
                <Form form={form} layout="vertical">
                    <Form.Item 
                        name="first_name" 
                        label="Prénom"
                        rules={[{ required: true }]}
                    >
                        <Input />
                    </Form.Item>
                    
                    <Form.Item 
                        name="last_name" 
                        label="Nom"
                        rules={[{ required: true }]}
                    >
                        <Input />
                    </Form.Item>
                    
                    <Form.Item 
                        name="email" 
                        label="Email"
                        rules={[
                            { required: true },
                            { type: 'email' }
                        ]}
                    >
                        <Input />
                    </Form.Item>
                    
                    <Form.Item name="phone" label="Téléphone">
                        <Input />
                    </Form.Item>
                    
                    <Form.Item name="company" label="Société">
                        <Input />
                    </Form.Item>
                    
                    <Form.Item 
                        name="status" 
                        label="Statut"
                        rules={[{ required: true }]}
                    >
                        <Select>
                            <Select.Option value="lead">Lead</Select.Option>
                            <Select.Option value="prospect">Prospect</Select.Option>
                            <Select.Option value="customer">Client</Select.Option>
                        </Select>
                    </Form.Item>
                </Form>
            </Modal>
        </div>
    );
}

export default ContactsPageAdvanced;
```

---

## 📊 ÉTAPE 4 : Exemples Supplémentaires

### Exemple 2 : Module Marketing - Campagnes

```sql
-- Schéma pour les campagnes marketing
CREATE module_datatable_schema SET
    id = 'mds_marketing_campaigns',
    module_name = 'lyxal-marketing',
    table_name = 'campaigns',
    
    table_definition = '
DEFINE TABLE campaigns SCHEMAFUL;
DEFINE FIELD id ON campaigns TYPE string;
DEFINE FIELD name ON campaigns TYPE string ASSERT $value != NONE;
DEFINE FIELD type ON campaigns TYPE string ASSERT $value IN ["email", "sms", "social", "print"];
DEFINE FIELD status ON campaigns TYPE string ASSERT $value IN ["draft", "active", "paused", "completed"];
DEFINE FIELD start_date ON campaigns TYPE datetime;
DEFINE FIELD end_date ON campaigns TYPE datetime;
DEFINE FIELD budget ON campaigns TYPE number;
DEFINE FIELD target_audience ON campaigns TYPE string;
DEFINE FIELD metrics ON campaigns TYPE object;
DEFINE FIELD created_at ON campaigns TYPE datetime DEFAULT time::now();',

    display_config = {
        columns: [
            { field: 'name', title: 'Nom de la campagne', sortable: true, width: 200 },
            { field: 'type', title: 'Type', sortable: true, width: 100, type: 'badge' },
            { field: 'status', title: 'Statut', sortable: true, width: 120, type: 'badge' },
            { field: 'start_date', title: 'Début', sortable: true, width: 110, type: 'date' },
            { field: 'end_date', title: 'Fin', sortable: true, width: 110, type: 'date' },
            { field: 'budget', title: 'Budget', sortable: true, width: 100, type: 'number' }
        ],
        filters: [
            { field: 'type', type: 'select', options: ['email', 'sms', 'social', 'print'] },
            { field: 'status', type: 'select', options: ['draft', 'active', 'paused', 'completed'] }
        ]
    };
```

### Utilisation dans l'Interface

```tsx
function CampaignsPage() {
    return (
        <ConfigurableDataTable
            workspaceId="restaurant_paris"
            moduleName="lyxal-marketing"
            tableName="campaigns"
            title="Campagnes Marketing"
            onCreate={() => console.log('Nouvelle campagne')}
        />
    );
}
```

### Exemple 3 : Module Helpdesk - Tickets

```sql
-- Schéma pour les tickets helpdesk
CREATE module_datatable_schema SET
    id = 'mds_helpdesk_tickets',
    module_name = 'lyxal-helpdesk',
    table_name = 'tickets',
    
    display_config = {
        columns: [
            { field: 'number', title: 'N°', sortable: true, width: 80 },
            { field: 'subject', title: 'Sujet', sortable: true, width: 250 },
            { field: 'priority', title: 'Priorité', sortable: true, width: 100, type: 'badge' },
            { field: 'status', title: 'Statut', sortable: true, width: 120, type: 'badge' },
            { field: 'assigned_to', title: 'Assigné à', sortable: true, width: 130 },
            { field: 'created_at', title: 'Créé le', sortable: true, width: 110, type: 'date' }
        ],
        filters: [
            { field: 'priority', type: 'select', options: ['low', 'medium', 'high', 'urgent'] },
            { field: 'status', type: 'select', options: ['open', 'in_progress', 'resolved', 'closed'] }
        ]
    };
```

---

## 🔧 ÉTAPE 5 : Personnalisation par Workspace

### Masquer des Colonnes pour un Workspace Spécifique

```sql
-- Masquer la colonne "budget" pour le workspace "petit_restaurant"
UPDATE workspace_datatable_instance 
SET hidden_fields = ['budget']
WHERE workspace_id = workspace:petit_restaurant 
  AND module_name = 'lyxal-marketing' 
  AND table_name = 'campaigns';
```

### Personnaliser l'Affichage

```sql
-- Changer la taille de page par défaut
UPDATE workspace_datatable_instance 
SET custom_display_config = {
    page_size: 25,
    enable_export: false
}
WHERE workspace_id = workspace:petit_restaurant;
```

---

## 🎯 Cas d'Usage Réels

### Restaurant avec CRM + Marketing

```tsx
function RestaurantDashboard() {
    return (
        <div>
            {/* Section Clients */}
            <h2>Gestion des Clients</h2>
            <ConfigurableDataTable
                workspaceId="restaurant_paris"
                moduleName="lyxal-crm"
                tableName="contacts"
            />

            {/* Section Campagnes */}
            <h2>Campagnes Marketing</h2>
            <ConfigurableDataTable
                workspaceId="restaurant_paris"
                moduleName="lyxal-marketing"
                tableName="campaigns"
            />
        </div>
    );
}
```

### Consultant avec CRM + Helpdesk

```tsx
function ConsultantDashboard() {
    return (
        <div>
            {/* Section Prospects */}
            <ConfigurableDataTable
                workspaceId="consultant_dupont"
                moduleName="lyxal-crm"
                tableName="contacts"
                title="Mes Prospects"
            />

            {/* Section Support Client */}
            <ConfigurableDataTable
                workspaceId="consultant_dupont"
                moduleName="lyxal-helpdesk"
                tableName="tickets"
                title="Tickets Support"
            />
        </div>
    );
}
```

---

## ✅ Checklist de Mise en Place

### Pour Créer un Nouveau Module

- [ ] Définir les schémas dans `module_datatable_schema`
- [ ] Configurer l'affichage (colonnes, filtres)
- [ ] Définir les permissions
- [ ] Tester l'activation dans un workspace
- [ ] Créer les composants d'interface si nécessaire

### Pour Utiliser un Module Existant

- [ ] Activer le module dans le workspace
- [ ] Utiliser `ConfigurableDataTable` ou `useWorkspaceDataTable`
- [ ] Personnaliser les actions si nécessaire
- [ ] Configurer les permissions utilisateurs

### Pour Déboguer

- [ ] Vérifier que le module est activé : `SELECT * FROM workspace_module_config`
- [ ] Vérifier que les tables sont créées : `SELECT * FROM workspace_datatable_instance`
- [ ] Tester les permissions utilisateur
- [ ] Vérifier les logs d'erreur

---

## 🚀 Points d'Amélioration

1. **Templates de modules** prêts à l'emploi
2. **Interface d'administration** pour configurer visuellement
3. **Import/Export** automatique des configurations
4. **Versioning** des schémas
5. **Analytics** d'utilisation des tables

---

*Ce guide couvre les cas d'usage les plus courants. Pour des besoins spécifiques, consultez la documentation technique complète.* 