-- =============================================================================================
-- |
-- | Fichier : credential_type_batch10_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 10 des credential types.
-- |
-- | Batch 10 : Productivity & Project Management (14 credentials)
-- | Providers : Airtable, Asana, ClickUp, Monday.com, Notion, Todoist, Trello
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 210 traductions (42 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- AIRTABLE API
-- =====================================================

RELATE i18n_key:credential_type_airtable_api_name->translation->language:fr SET text = "Airtable API";
RELATE i18n_key:credential_type_airtable_api_name->translation->language:en SET text = "Airtable API";
RELATE i18n_key:credential_type_airtable_api_name->translation->language:it SET text = "Airtable API";
RELATE i18n_key:credential_type_airtable_api_name->translation->language:de SET text = "Airtable API";
RELATE i18n_key:credential_type_airtable_api_name->translation->language:es SET text = "Airtable API";

RELATE i18n_key:credential_type_airtable_api_description->translation->language:fr SET text = "Authentification par API key pour Airtable. Base de données tableur flexible pour organiser données, projets et workflows collaboratifs.";
RELATE i18n_key:credential_type_airtable_api_description->translation->language:en SET text = "API key authentication for Airtable. Flexible spreadsheet database for organizing data, projects, and collaborative workflows.";
RELATE i18n_key:credential_type_airtable_api_description->translation->language:it SET text = "Autenticazione tramite API key per Airtable. Database foglio di calcolo flessibile per organizzare dati, progetti e workflow collaborativi.";
RELATE i18n_key:credential_type_airtable_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Airtable. Flexible Tabellenkalkulations-Datenbank zum Organisieren von Daten, Projekten und kollaborativen Workflows.";
RELATE i18n_key:credential_type_airtable_api_description->translation->language:es SET text = "Autenticación mediante API key para Airtable. Base datos hoja cálculo flexible para organizar datos, proyectos y workflows colaborativos.";

RELATE i18n_key:credential_type_airtable_api_tooltip->translation->language:fr SET text = "Pour bases Airtable et gestion données";
RELATE i18n_key:credential_type_airtable_api_tooltip->translation->language:en SET text = "For Airtable bases and data management";
RELATE i18n_key:credential_type_airtable_api_tooltip->translation->language:it SET text = "Per basi Airtable e gestione dati";
RELATE i18n_key:credential_type_airtable_api_tooltip->translation->language:de SET text = "Für Airtable-Basen und Datenverwaltung";
RELATE i18n_key:credential_type_airtable_api_tooltip->translation->language:es SET text = "Para bases Airtable y gestión datos";

-- =====================================================
-- AIRTABLE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_airtable_oauth2_api_name->translation->language:fr SET text = "Airtable OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_name->translation->language:en SET text = "Airtable OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_name->translation->language:it SET text = "Airtable OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_name->translation->language:de SET text = "Airtable OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_name->translation->language:es SET text = "Airtable OAuth2";

RELATE i18n_key:credential_type_airtable_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Airtable. Pour applications tierces avec authentification utilisateur et accès multi-base.";
RELATE i18n_key:credential_type_airtable_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Airtable. For third-party applications with user authentication and multi-base access.";
RELATE i18n_key:credential_type_airtable_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Airtable. Per applicazioni terze con autenticazione utente e accesso multi-base.";
RELATE i18n_key:credential_type_airtable_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Airtable. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Base-Zugriff.";
RELATE i18n_key:credential_type_airtable_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Airtable. Para aplicaciones terceros con autenticación usuario y acceso multi-base.";

RELATE i18n_key:credential_type_airtable_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Airtable avec OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_tooltip->translation->language:en SET text = "For third-party Airtable apps with OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Airtable con OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Airtable-Apps mit OAuth2";
RELATE i18n_key:credential_type_airtable_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Airtable con OAuth2";

-- =====================================================
-- AIRTABLE TOKEN API
-- =====================================================

RELATE i18n_key:credential_type_airtable_token_api_name->translation->language:fr SET text = "Airtable Token";
RELATE i18n_key:credential_type_airtable_token_api_name->translation->language:en SET text = "Airtable Token";
RELATE i18n_key:credential_type_airtable_token_api_name->translation->language:it SET text = "Airtable Token";
RELATE i18n_key:credential_type_airtable_token_api_name->translation->language:de SET text = "Airtable Token";
RELATE i18n_key:credential_type_airtable_token_api_name->translation->language:es SET text = "Airtable Token";

RELATE i18n_key:credential_type_airtable_token_api_description->translation->language:fr SET text = "Authentification par Personal Access Token pour Airtable. Méthode recommandée moderne avec scopes granulaires.";
RELATE i18n_key:credential_type_airtable_token_api_description->translation->language:en SET text = "Personal Access Token authentication for Airtable. Modern recommended method with granular scopes.";
RELATE i18n_key:credential_type_airtable_token_api_description->translation->language:it SET text = "Autenticazione tramite Personal Access Token per Airtable. Metodo moderno consigliato con scope granulari.";
RELATE i18n_key:credential_type_airtable_token_api_description->translation->language:de SET text = "Personal Access Token-Authentifizierung für Airtable. Moderne empfohlene Methode mit granularen Scopes.";
RELATE i18n_key:credential_type_airtable_token_api_description->translation->language:es SET text = "Autenticación mediante Personal Access Token para Airtable. Método moderno recomendado con scopes granulares.";

RELATE i18n_key:credential_type_airtable_token_api_tooltip->translation->language:fr SET text = "Recommandé pour Airtable avec token personnel";
RELATE i18n_key:credential_type_airtable_token_api_tooltip->translation->language:en SET text = "Recommended for Airtable with personal token";
RELATE i18n_key:credential_type_airtable_token_api_tooltip->translation->language:it SET text = "Consigliato per Airtable con token personale";
RELATE i18n_key:credential_type_airtable_token_api_tooltip->translation->language:de SET text = "Empfohlen für Airtable mit persönlichem Token";
RELATE i18n_key:credential_type_airtable_token_api_tooltip->translation->language:es SET text = "Recomendado para Airtable con token personal";

-- =====================================================
-- ASANA API
-- =====================================================

RELATE i18n_key:credential_type_asana_api_name->translation->language:fr SET text = "Asana API";
RELATE i18n_key:credential_type_asana_api_name->translation->language:en SET text = "Asana API";
RELATE i18n_key:credential_type_asana_api_name->translation->language:it SET text = "Asana API";
RELATE i18n_key:credential_type_asana_api_name->translation->language:de SET text = "Asana API";
RELATE i18n_key:credential_type_asana_api_name->translation->language:es SET text = "Asana API";

RELATE i18n_key:credential_type_asana_api_description->translation->language:fr SET text = "Authentification par Personal Access Token pour Asana. Outil gestion projet pour organiser tâches, équipes et workflows.";
RELATE i18n_key:credential_type_asana_api_description->translation->language:en SET text = "Personal Access Token authentication for Asana. Project management tool for organizing tasks, teams, and workflows.";
RELATE i18n_key:credential_type_asana_api_description->translation->language:it SET text = "Autenticazione tramite Personal Access Token per Asana. Strumento gestione progetti per organizzare task, team e workflow.";
RELATE i18n_key:credential_type_asana_api_description->translation->language:de SET text = "Personal Access Token-Authentifizierung für Asana. Projektmanagement-Tool zum Organisieren von Aufgaben, Teams und Workflows.";
RELATE i18n_key:credential_type_asana_api_description->translation->language:es SET text = "Autenticación mediante Personal Access Token para Asana. Herramienta gestión proyectos para organizar tareas, equipos y workflows.";

RELATE i18n_key:credential_type_asana_api_tooltip->translation->language:fr SET text = "Pour gestion projet Asana et tâches";
RELATE i18n_key:credential_type_asana_api_tooltip->translation->language:en SET text = "For Asana project management and tasks";
RELATE i18n_key:credential_type_asana_api_tooltip->translation->language:it SET text = "Per gestione progetti Asana e task";
RELATE i18n_key:credential_type_asana_api_tooltip->translation->language:de SET text = "Für Asana-Projektmanagement und Aufgaben";
RELATE i18n_key:credential_type_asana_api_tooltip->translation->language:es SET text = "Para gestión proyectos Asana y tareas";

-- =====================================================
-- ASANA OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_asana_oauth2_api_name->translation->language:fr SET text = "Asana OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_name->translation->language:en SET text = "Asana OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_name->translation->language:it SET text = "Asana OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_name->translation->language:de SET text = "Asana OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_name->translation->language:es SET text = "Asana OAuth2";

RELATE i18n_key:credential_type_asana_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Asana. Pour applications tierces avec authentification utilisateur et accès multi-workspace.";
RELATE i18n_key:credential_type_asana_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Asana. For third-party applications with user authentication and multi-workspace access.";
RELATE i18n_key:credential_type_asana_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Asana. Per applicazioni terze con autenticazione utente e accesso multi-workspace.";
RELATE i18n_key:credential_type_asana_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Asana. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Workspace-Zugriff.";
RELATE i18n_key:credential_type_asana_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Asana. Para aplicaciones terceros con autenticación usuario y acceso multi-workspace.";

RELATE i18n_key:credential_type_asana_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Asana avec OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_tooltip->translation->language:en SET text = "For third-party Asana apps with OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Asana con OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Asana-Apps mit OAuth2";
RELATE i18n_key:credential_type_asana_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Asana con OAuth2";

-- =====================================================
-- CLICKUP API
-- =====================================================

RELATE i18n_key:credential_type_clickup_api_name->translation->language:fr SET text = "ClickUp API";
RELATE i18n_key:credential_type_clickup_api_name->translation->language:en SET text = "ClickUp API";
RELATE i18n_key:credential_type_clickup_api_name->translation->language:it SET text = "ClickUp API";
RELATE i18n_key:credential_type_clickup_api_name->translation->language:de SET text = "ClickUp API";
RELATE i18n_key:credential_type_clickup_api_name->translation->language:es SET text = "ClickUp API";

RELATE i18n_key:credential_type_clickup_api_description->translation->language:fr SET text = "Authentification par API Token pour ClickUp. Plateforme productivité tout-en-un pour tâches, docs, objectifs et time tracking.";
RELATE i18n_key:credential_type_clickup_api_description->translation->language:en SET text = "API Token authentication for ClickUp. All-in-one productivity platform for tasks, docs, goals, and time tracking.";
RELATE i18n_key:credential_type_clickup_api_description->translation->language:it SET text = "Autenticazione tramite API Token per ClickUp. Piattaforma produttività all-in-one per task, doc, obiettivi e time tracking.";
RELATE i18n_key:credential_type_clickup_api_description->translation->language:de SET text = "API-Token-Authentifizierung für ClickUp. All-in-One-Produktivitätsplattform für Aufgaben, Dokumente, Ziele und Zeiterfassung.";
RELATE i18n_key:credential_type_clickup_api_description->translation->language:es SET text = "Autenticación mediante API Token para ClickUp. Plataforma productividad todo-en-uno para tareas, docs, objetivos y time tracking.";

RELATE i18n_key:credential_type_clickup_api_tooltip->translation->language:fr SET text = "Pour ClickUp productivité et tâches";
RELATE i18n_key:credential_type_clickup_api_tooltip->translation->language:en SET text = "For ClickUp productivity and tasks";
RELATE i18n_key:credential_type_clickup_api_tooltip->translation->language:it SET text = "Per ClickUp produttività e task";
RELATE i18n_key:credential_type_clickup_api_tooltip->translation->language:de SET text = "Für ClickUp-Produktivität und Aufgaben";
RELATE i18n_key:credential_type_clickup_api_tooltip->translation->language:es SET text = "Para ClickUp productividad y tareas";

-- =====================================================
-- CLICKUP OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_clickup_oauth2_api_name->translation->language:fr SET text = "ClickUp OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_name->translation->language:en SET text = "ClickUp OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_name->translation->language:it SET text = "ClickUp OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_name->translation->language:de SET text = "ClickUp OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_name->translation->language:es SET text = "ClickUp OAuth2";

RELATE i18n_key:credential_type_clickup_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour ClickUp. Pour applications tierces avec authentification utilisateur et accès multi-workspace.";
RELATE i18n_key:credential_type_clickup_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for ClickUp. For third-party applications with user authentication and multi-workspace access.";
RELATE i18n_key:credential_type_clickup_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per ClickUp. Per applicazioni terze con autenticazione utente e accesso multi-workspace.";
RELATE i18n_key:credential_type_clickup_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für ClickUp. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Workspace-Zugriff.";
RELATE i18n_key:credential_type_clickup_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para ClickUp. Para aplicaciones terceros con autenticación usuario y acceso multi-workspace.";

RELATE i18n_key:credential_type_clickup_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces ClickUp avec OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_tooltip->translation->language:en SET text = "For third-party ClickUp apps with OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_tooltip->translation->language:it SET text = "Per app terze ClickUp con OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-ClickUp-Apps mit OAuth2";
RELATE i18n_key:credential_type_clickup_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros ClickUp con OAuth2";

-- =====================================================
-- MONDAY.COM API
-- =====================================================

RELATE i18n_key:credential_type_monday_com_api_name->translation->language:fr SET text = "Monday.com API";
RELATE i18n_key:credential_type_monday_com_api_name->translation->language:en SET text = "Monday.com API";
RELATE i18n_key:credential_type_monday_com_api_name->translation->language:it SET text = "Monday.com API";
RELATE i18n_key:credential_type_monday_com_api_name->translation->language:de SET text = "Monday.com API";
RELATE i18n_key:credential_type_monday_com_api_name->translation->language:es SET text = "Monday.com API";

RELATE i18n_key:credential_type_monday_com_api_description->translation->language:fr SET text = "Authentification par API Token pour Monday.com. Work OS pour gérer projets, workflows et collaboration équipe avec tableaux visuels.";
RELATE i18n_key:credential_type_monday_com_api_description->translation->language:en SET text = "API Token authentication for Monday.com. Work OS for managing projects, workflows, and team collaboration with visual boards.";
RELATE i18n_key:credential_type_monday_com_api_description->translation->language:it SET text = "Autenticazione tramite API Token per Monday.com. Work OS per gestire progetti, workflow e collaborazione team con board visivi.";
RELATE i18n_key:credential_type_monday_com_api_description->translation->language:de SET text = "API-Token-Authentifizierung für Monday.com. Work OS zum Verwalten von Projekten, Workflows und Team-Zusammenarbeit mit visuellen Boards.";
RELATE i18n_key:credential_type_monday_com_api_description->translation->language:es SET text = "Autenticación mediante API Token para Monday.com. Work OS para gestionar proyectos, workflows y colaboración equipo con tableros visuales.";

RELATE i18n_key:credential_type_monday_com_api_tooltip->translation->language:fr SET text = "Pour Monday.com Work OS et tableaux";
RELATE i18n_key:credential_type_monday_com_api_tooltip->translation->language:en SET text = "For Monday.com Work OS and boards";
RELATE i18n_key:credential_type_monday_com_api_tooltip->translation->language:it SET text = "Per Monday.com Work OS e board";
RELATE i18n_key:credential_type_monday_com_api_tooltip->translation->language:de SET text = "Für Monday.com Work OS und Boards";
RELATE i18n_key:credential_type_monday_com_api_tooltip->translation->language:es SET text = "Para Monday.com Work OS y tableros";

-- =====================================================
-- MONDAY.COM OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_monday_com_oauth2_api_name->translation->language:fr SET text = "Monday.com OAuth2";
RELATE i18n_key:credential_type_monday_com_oauth2_api_name->translation->language:en SET text = "Monday.com OAuth2";
RELATE i18n_key:credential_type_monday_com_oauth2_api_name->translation->language:it SET text = "Monday.com OAuth2";
RELATE i18n_key:credential_type_monday_com_oauth2_api_name->translation->language:de SET text = "Monday.com OAuth2";
RELATE i18n_key:credential_type_monday_com_oauth2_api_name->translation->language:es SET text = "Monday.com OAuth2";

RELATE i18n_key:credential_type_monday_com_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Monday.com. Pour applications marketplace avec authentification utilisateur et accès multi-board.";
RELATE i18n_key:credential_type_monday_com_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Monday.com. For marketplace applications with user authentication and multi-board access.";
RELATE i18n_key:credential_type_monday_com_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Monday.com. Per applicazioni marketplace con autenticazione utente e accesso multi-board.";
RELATE i18n_key:credential_type_monday_com_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Monday.com. Für Marketplace-Anwendungen mit Benutzer-Authentifizierung und Multi-Board-Zugriff.";
RELATE i18n_key:credential_type_monday_com_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Monday.com. Para aplicaciones marketplace con autenticación usuario y acceso multi-board.";

RELATE i18n_key:credential_type_monday_com_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps marketplace Monday.com";
RELATE i18n_key:credential_type_monday_com_oauth2_api_tooltip->translation->language:en SET text = "For Monday.com marketplace apps";
RELATE i18n_key:credential_type_monday_com_oauth2_api_tooltip->translation->language:it SET text = "Per app marketplace Monday.com";
RELATE i18n_key:credential_type_monday_com_oauth2_api_tooltip->translation->language:de SET text = "Für Monday.com-Marketplace-Apps";
RELATE i18n_key:credential_type_monday_com_oauth2_api_tooltip->translation->language:es SET text = "Para apps marketplace Monday.com";

-- =====================================================
-- NOTION API
-- =====================================================

RELATE i18n_key:credential_type_notion_api_name->translation->language:fr SET text = "Notion API";
RELATE i18n_key:credential_type_notion_api_name->translation->language:en SET text = "Notion API";
RELATE i18n_key:credential_type_notion_api_name->translation->language:it SET text = "Notion API";
RELATE i18n_key:credential_type_notion_api_name->translation->language:de SET text = "Notion API";
RELATE i18n_key:credential_type_notion_api_name->translation->language:es SET text = "Notion API";

RELATE i18n_key:credential_type_notion_api_description->translation->language:fr SET text = "Authentification par Internal Integration Token pour Notion. Workspace tout-en-un pour notes, docs, wikis et bases de données.";
RELATE i18n_key:credential_type_notion_api_description->translation->language:en SET text = "Internal Integration Token authentication for Notion. All-in-one workspace for notes, docs, wikis, and databases.";
RELATE i18n_key:credential_type_notion_api_description->translation->language:it SET text = "Autenticazione tramite Internal Integration Token per Notion. Workspace all-in-one per note, doc, wiki e database.";
RELATE i18n_key:credential_type_notion_api_description->translation->language:de SET text = "Internal Integration Token-Authentifizierung für Notion. All-in-One-Workspace für Notizen, Dokumente, Wikis und Datenbanken.";
RELATE i18n_key:credential_type_notion_api_description->translation->language:es SET text = "Autenticación mediante Internal Integration Token para Notion. Workspace todo-en-uno para notas, docs, wikis y bases datos.";

RELATE i18n_key:credential_type_notion_api_tooltip->translation->language:fr SET text = "Pour Notion workspace et bases connaissance";
RELATE i18n_key:credential_type_notion_api_tooltip->translation->language:en SET text = "For Notion workspace and knowledge bases";
RELATE i18n_key:credential_type_notion_api_tooltip->translation->language:it SET text = "Per Notion workspace e basi conoscenza";
RELATE i18n_key:credential_type_notion_api_tooltip->translation->language:de SET text = "Für Notion-Workspace und Wissensdatenbanken";
RELATE i18n_key:credential_type_notion_api_tooltip->translation->language:es SET text = "Para Notion workspace y bases conocimiento";

-- =====================================================
-- NOTION OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_notion_oauth2_api_name->translation->language:fr SET text = "Notion OAuth2";
RELATE i18n_key:credential_type_notion_oauth2_api_name->translation->language:en SET text = "Notion OAuth2";
RELATE i18n_key:credential_type_notion_oauth2_api_name->translation->language:it SET text = "Notion OAuth2";
RELATE i18n_key:credential_type_notion_oauth2_api_name->translation->language:de SET text = "Notion OAuth2";
RELATE i18n_key:credential_type_notion_oauth2_api_name->translation->language:es SET text = "Notion OAuth2";

RELATE i18n_key:credential_type_notion_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Notion. Pour intégrations publiques avec authentification utilisateur et accès multi-workspace.";
RELATE i18n_key:credential_type_notion_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Notion. For public integrations with user authentication and multi-workspace access.";
RELATE i18n_key:credential_type_notion_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Notion. Per integrazioni pubbliche con autenticazione utente e accesso multi-workspace.";
RELATE i18n_key:credential_type_notion_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Notion. Für öffentliche Integrationen mit Benutzer-Authentifizierung und Multi-Workspace-Zugriff.";
RELATE i18n_key:credential_type_notion_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Notion. Para integraciones públicas con autenticación usuario y acceso multi-workspace.";

RELATE i18n_key:credential_type_notion_oauth2_api_tooltip->translation->language:fr SET text = "Pour intégrations publiques Notion";
RELATE i18n_key:credential_type_notion_oauth2_api_tooltip->translation->language:en SET text = "For public Notion integrations";
RELATE i18n_key:credential_type_notion_oauth2_api_tooltip->translation->language:it SET text = "Per integrazioni pubbliche Notion";
RELATE i18n_key:credential_type_notion_oauth2_api_tooltip->translation->language:de SET text = "Für öffentliche Notion-Integrationen";
RELATE i18n_key:credential_type_notion_oauth2_api_tooltip->translation->language:es SET text = "Para integraciones públicas Notion";

-- =====================================================
-- TODOIST API
-- =====================================================

RELATE i18n_key:credential_type_todoist_api_name->translation->language:fr SET text = "Todoist API";
RELATE i18n_key:credential_type_todoist_api_name->translation->language:en SET text = "Todoist API";
RELATE i18n_key:credential_type_todoist_api_name->translation->language:it SET text = "Todoist API";
RELATE i18n_key:credential_type_todoist_api_name->translation->language:de SET text = "Todoist API";
RELATE i18n_key:credential_type_todoist_api_name->translation->language:es SET text = "Todoist API";

RELATE i18n_key:credential_type_todoist_api_description->translation->language:fr SET text = "Authentification par API Token pour Todoist. App gestion tâches personnelles pour organiser to-dos, projets et productivité.";
RELATE i18n_key:credential_type_todoist_api_description->translation->language:en SET text = "API Token authentication for Todoist. Personal task management app for organizing to-dos, projects, and productivity.";
RELATE i18n_key:credential_type_todoist_api_description->translation->language:it SET text = "Autenticazione tramite API Token per Todoist. App gestione task personali per organizzare to-do, progetti e produttività.";
RELATE i18n_key:credential_type_todoist_api_description->translation->language:de SET text = "API-Token-Authentifizierung für Todoist. Persönliche Aufgabenverwaltungs-App zum Organisieren von To-Dos, Projekten und Produktivität.";
RELATE i18n_key:credential_type_todoist_api_description->translation->language:es SET text = "Autenticación mediante API Token para Todoist. App gestión tareas personales para organizar to-dos, proyectos y productividad.";

RELATE i18n_key:credential_type_todoist_api_tooltip->translation->language:fr SET text = "Pour Todoist tâches et productivité";
RELATE i18n_key:credential_type_todoist_api_tooltip->translation->language:en SET text = "For Todoist tasks and productivity";
RELATE i18n_key:credential_type_todoist_api_tooltip->translation->language:it SET text = "Per Todoist task e produttività";
RELATE i18n_key:credential_type_todoist_api_tooltip->translation->language:de SET text = "Für Todoist-Aufgaben und Produktivität";
RELATE i18n_key:credential_type_todoist_api_tooltip->translation->language:es SET text = "Para Todoist tareas y productividad";

-- =====================================================
-- TODOIST OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_todoist_oauth2_api_name->translation->language:fr SET text = "Todoist OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_name->translation->language:en SET text = "Todoist OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_name->translation->language:it SET text = "Todoist OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_name->translation->language:de SET text = "Todoist OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_name->translation->language:es SET text = "Todoist OAuth2";

RELATE i18n_key:credential_type_todoist_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Todoist. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_todoist_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Todoist. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_todoist_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Todoist. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_todoist_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Todoist. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_todoist_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Todoist. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_todoist_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Todoist avec OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_tooltip->translation->language:en SET text = "For third-party Todoist apps with OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Todoist con OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Todoist-Apps mit OAuth2";
RELATE i18n_key:credential_type_todoist_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Todoist con OAuth2";

-- =====================================================
-- TRELLO API
-- =====================================================

RELATE i18n_key:credential_type_trello_api_name->translation->language:fr SET text = "Trello API";
RELATE i18n_key:credential_type_trello_api_name->translation->language:en SET text = "Trello API";
RELATE i18n_key:credential_type_trello_api_name->translation->language:it SET text = "Trello API";
RELATE i18n_key:credential_type_trello_api_name->translation->language:de SET text = "Trello API";
RELATE i18n_key:credential_type_trello_api_name->translation->language:es SET text = "Trello API";

RELATE i18n_key:credential_type_trello_api_description->translation->language:fr SET text = "Authentification par API Key et Token pour Trello. Outil Kanban pour organiser projets avec boards, listes et cartes visuelles.";
RELATE i18n_key:credential_type_trello_api_description->translation->language:en SET text = "API Key and Token authentication for Trello. Kanban tool for organizing projects with boards, lists, and visual cards.";
RELATE i18n_key:credential_type_trello_api_description->translation->language:it SET text = "Autenticazione tramite API Key e Token per Trello. Strumento Kanban per organizzare progetti con board, liste e card visive.";
RELATE i18n_key:credential_type_trello_api_description->translation->language:de SET text = "API-Schlüssel- und Token-Authentifizierung für Trello. Kanban-Tool zum Organisieren von Projekten mit Boards, Listen und visuellen Karten.";
RELATE i18n_key:credential_type_trello_api_description->translation->language:es SET text = "Autenticación mediante API Key y Token para Trello. Herramienta Kanban para organizar proyectos con tableros, listas y tarjetas visuales.";

RELATE i18n_key:credential_type_trello_api_tooltip->translation->language:fr SET text = "Pour Trello Kanban et gestion boards";
RELATE i18n_key:credential_type_trello_api_tooltip->translation->language:en SET text = "For Trello Kanban and board management";
RELATE i18n_key:credential_type_trello_api_tooltip->translation->language:it SET text = "Per Trello Kanban e gestione board";
RELATE i18n_key:credential_type_trello_api_tooltip->translation->language:de SET text = "Für Trello Kanban und Board-Verwaltung";
RELATE i18n_key:credential_type_trello_api_tooltip->translation->language:es SET text = "Para Trello Kanban y gestión tableros";

-- =============================================================================================

