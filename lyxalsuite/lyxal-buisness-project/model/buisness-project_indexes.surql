-- Index sur le nom du projet pour recherche rapide
DEFINE INDEX idx_project_name ON TABLE project COLUMNS name;

-- Index sur le code du projet
DEFINE INDEX idx_project_code ON TABLE project COLUMNS code;

-- Index sur le client (customer)
DEFINE INDEX idx_project_customer ON TABLE project COLUMNS customer;

-- Index sur le dossier projet
DEFINE INDEX idx_project_folder ON TABLE project COLUMNS projectFolder;

-- Index sur le statut de la tâche
DEFINE INDEX idx_task_status ON TABLE project_task COLUMNS statusSelect;

-- Index sur le lien tâche/projet
DEFINE INDEX idx_task_project ON TABLE project_task COLUMNS project;

-- Index sur le produit lié à la tâche
DEFINE INDEX idx_task_product ON TABLE project_task COLUMNS product;

-- Index sur le statut du projet de facturation
DEFINE INDEX idx_invoicing_project_status ON TABLE invoicing_project COLUMNS statusSelect;
