-- ======================================================================
-- TABLE : USER - Extension pour projets
-- cf : entité/user/structures/user.surql
-- ======================================================================

-- Projet actif (comme dans Axelor)
DEFINE FIELD active_project ON user TYPE option<record<project>>;
DEFINE FIELD is_include_sub_projects ON user TYPE bool DEFAULT false;

-- Configuration projet
DEFINE FIELD default_project_id ON user TYPE option<record<project>>;
DEFINE FIELD project_preferences ON user TYPE string;

-- Paramètres de vue
DEFINE FIELD preferred_task_view ON user TYPE string DEFAULT "list";
DEFINE FIELD show_completed_tasks ON user TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_user_active_project ON user COLUMNS active_project;
DEFINE INDEX idx_user_default_project ON user COLUMNS default_project_id;