-- Extensions d'utilisateur pour budget
DEFINE TABLE user_budget SCHEMAFULL;
DEFINE FIELD name ON user_budget TYPE string;
DEFINE FIELD code ON user_budget TYPE string;
DEFINE FIELD login ON user_budget TYPE string;
DEFINE FIELD email ON user_budget TYPE string;
DEFINE FIELD partner ON user_budget TYPE record<partner>;
DEFINE FIELD company ON user_budget TYPE record<company>;
DEFINE FIELD budget_controller_list ON user_budget TYPE array<record<budget_controller>>;
DEFINE FIELD is_budget_manager ON user_budget TYPE bool DEFAULT false;
DEFINE FIELD can_exceed_budget ON user_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_notification_preference ON user_budget TYPE int DEFAULT 1;
DEFINE FIELD budget_exceeded_notification_threshold ON user_budget TYPE decimal DEFAULT 80.0;
DEFINE FIELD created_at ON user_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON user_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON user_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_user_budget_company ON user_budget FIELDS company;
DEFINE INDEX idx_user_budget_login ON user_budget FIELDS login;
DEFINE INDEX idx_user_budget_manager ON user_budget FIELDS is_budget_manager;
DEFINE INDEX idx_user_budget_exceed ON user_budget FIELDS can_exceed_budget;