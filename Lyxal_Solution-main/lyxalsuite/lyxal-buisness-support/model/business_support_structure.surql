DEFINE TABLE project_announcement SCHEMAFULL;
DEFINE FIELD title ON project_announcement TYPE string ASSERT $value != NONE;
DEFINE FIELD project ON project_announcement TYPE record<project>;
DEFINE FIELD date ON project_announcement TYPE datetime;
DEFINE FIELD content ON project_announcement TYPE string;
DEFINE FIELD createdAt ON project_announcement TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON project_announcement TYPE datetime DEFAULT time::now();

DEFINE TABLE app_business_support SCHEMAFULL;
DEFINE FIELD app ON app_business_support TYPE record<app> ASSERT $value != NONE;
DEFINE FIELD providerCompany ON app_business_support TYPE record<company>;
DEFINE FIELD createdAt ON app_business_support TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON app_business_support TYPE datetime DEFAULT time::now();

DEFINE TABLE task_template SCHEMAFULL;
DEFINE FIELD internalDescription ON task_template TYPE string;
DEFINE FIELD createdAt ON task_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON task_template TYPE datetime DEFAULT time::now();
