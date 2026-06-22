-- ============================================================================
-- Lyxal Bridge — Airtable Provider
-- Fichier : datafunction/airtable.surql
-- 
-- 5 opérations CRUD complètes pour l'API Airtable v0
-- Chaque fonction est autonome : auth, construction URL, appel HTTP, trace
-- ============================================================================


CREATE bridge_providers:airtable CONTENT {
    identity: { 
        name: 'airtable',
        documentation_url: 'https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.airtable/'
    },
    affichage: { 
        display_name: 'Airtable',
        icon_url_light: 'packages/nodes-base/nodes/Airtable/airtable.svg',
        icon_url_dark: 'packages/nodes-base/nodes/Airtable/airtable.svg'
    },
    status: { 
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_user_credentials CONTENT {
    provider: bridge_providers:airtable,
    encrypted_data: {
        api_key: 'pat123456789',
        base_id: 'appXYZ',
        table_name: 'Contacts'
    }
};