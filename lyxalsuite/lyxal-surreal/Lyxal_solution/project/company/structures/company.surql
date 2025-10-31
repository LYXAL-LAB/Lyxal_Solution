-- ======================================================================
-- TABLE : COMPANY - Extension pour projets
-- cf : entité/company/structures/company.surql
-- ======================================================================

-- Configuration projets
DEFINE FIELD default_project_status_id ON company TYPE option<record<project_status>>;
DEFINE FIELD default_task_status_id ON company TYPE option<record<task_status>>;
DEFINE FIELD default_priority_id ON company TYPE option<record<project_priority>>;

-- Paramètres
DEFINE FIELD project_numbering_auto ON company TYPE bool DEFAULT false;
DEFINE FIELD task_numbering_auto ON company TYPE bool DEFAULT false;

-- Index

DEFINE INDEX idx_company_project_status ON company COLUMNS default_project_status_id;
DEFINE INDEX idx_company_project_task_status ON company COLUMNS default_task_status_id;