-- =============================================================================================
-- |
-- | Fichier : credential_type_batch5_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 5 des credential types.
-- |
-- | Batch 5 : Top Development (12 credentials)
-- | Providers : GitHub, GitLab, Jira, Bitbucket, Jenkins, CircleCI, Travis CI
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 180 traductions (36 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- GITHUB API
-- =====================================================

RELATE i18n_key:credential_type_github_api_name->translation->language:fr SET text = "GitHub API";
RELATE i18n_key:credential_type_github_api_name->translation->language:en SET text = "GitHub API";
RELATE i18n_key:credential_type_github_api_name->translation->language:it SET text = "GitHub API";
RELATE i18n_key:credential_type_github_api_name->translation->language:de SET text = "GitHub API";
RELATE i18n_key:credential_type_github_api_name->translation->language:es SET text = "GitHub API";

RELATE i18n_key:credential_type_github_api_description->translation->language:fr SET text = "Authentification par token pour GitHub API. Permet de gérer repositories, issues, pull requests et automatiser workflows de développement.";
RELATE i18n_key:credential_type_github_api_description->translation->language:en SET text = "Token-based authentication for GitHub API. Allows managing repositories, issues, pull requests, and automating development workflows.";
RELATE i18n_key:credential_type_github_api_description->translation->language:it SET text = "Autenticazione basata su token per GitHub API. Consente di gestire repository, issue, pull request e automatizzare flussi di lavoro di sviluppo.";
RELATE i18n_key:credential_type_github_api_description->translation->language:de SET text = "Token-basierte Authentifizierung für GitHub API. Ermöglicht die Verwaltung von Repositories, Issues, Pull Requests und die Automatisierung von Entwicklungsworkflows.";
RELATE i18n_key:credential_type_github_api_description->translation->language:es SET text = "Autenticación basada en token para GitHub API. Permite gestionar repositorios, issues, pull requests y automatizar flujos desarrollo.";

RELATE i18n_key:credential_type_github_api_tooltip->translation->language:fr SET text = "Pour gestion code source et CI/CD GitHub";
RELATE i18n_key:credential_type_github_api_tooltip->translation->language:en SET text = "For source code management and GitHub CI/CD";
RELATE i18n_key:credential_type_github_api_tooltip->translation->language:it SET text = "Per gestione codice sorgente e CI/CD GitHub";
RELATE i18n_key:credential_type_github_api_tooltip->translation->language:de SET text = "Für Quellcode-Verwaltung und GitHub CI/CD";
RELATE i18n_key:credential_type_github_api_tooltip->translation->language:es SET text = "Para gestión código fuente y CI/CD GitHub";

-- =====================================================
-- GITHUB OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_github_oauth2_api_name->translation->language:fr SET text = "GitHub OAuth2";
RELATE i18n_key:credential_type_github_oauth2_api_name->translation->language:en SET text = "GitHub OAuth2";
RELATE i18n_key:credential_type_github_oauth2_api_name->translation->language:it SET text = "GitHub OAuth2";
RELATE i18n_key:credential_type_github_oauth2_api_name->translation->language:de SET text = "GitHub OAuth2";
RELATE i18n_key:credential_type_github_oauth2_api_name->translation->language:es SET text = "GitHub OAuth2";

RELATE i18n_key:credential_type_github_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour GitHub API. Permet d'accéder à GitHub avec authentification utilisateur pour intégrations GitHub Apps.";
RELATE i18n_key:credential_type_github_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for GitHub API. Allows accessing GitHub with user authentication for GitHub Apps integrations.";
RELATE i18n_key:credential_type_github_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per GitHub API. Consente di accedere a GitHub con autenticazione utente per integrazioni GitHub Apps.";
RELATE i18n_key:credential_type_github_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für GitHub API. Ermöglicht den Zugriff auf GitHub mit Benutzerauthentifizierung für GitHub Apps-Integrationen.";
RELATE i18n_key:credential_type_github_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para GitHub API. Permite acceder GitHub con autenticación usuario para integraciones GitHub Apps.";

RELATE i18n_key:credential_type_github_oauth2_api_tooltip->translation->language:fr SET text = "Pour GitHub Apps et authentification utilisateur";
RELATE i18n_key:credential_type_github_oauth2_api_tooltip->translation->language:en SET text = "For GitHub Apps and user authentication";
RELATE i18n_key:credential_type_github_oauth2_api_tooltip->translation->language:it SET text = "Per GitHub Apps e autenticazione utente";
RELATE i18n_key:credential_type_github_oauth2_api_tooltip->translation->language:de SET text = "Für GitHub Apps und Benutzerauthentifizierung";
RELATE i18n_key:credential_type_github_oauth2_api_tooltip->translation->language:es SET text = "Para GitHub Apps y autenticación usuario";

-- =====================================================
-- GITLAB API
-- =====================================================

RELATE i18n_key:credential_type_gitlab_api_name->translation->language:fr SET text = "GitLab API";
RELATE i18n_key:credential_type_gitlab_api_name->translation->language:en SET text = "GitLab API";
RELATE i18n_key:credential_type_gitlab_api_name->translation->language:it SET text = "GitLab API";
RELATE i18n_key:credential_type_gitlab_api_name->translation->language:de SET text = "GitLab API";
RELATE i18n_key:credential_type_gitlab_api_name->translation->language:es SET text = "GitLab API";

RELATE i18n_key:credential_type_gitlab_api_description->translation->language:fr SET text = "Authentification par token pour GitLab API. Permet de gérer projects, merge requests, CI/CD pipelines dans GitLab (cloud ou self-hosted).";
RELATE i18n_key:credential_type_gitlab_api_description->translation->language:en SET text = "Token-based authentication for GitLab API. Allows managing projects, merge requests, CI/CD pipelines in GitLab (cloud or self-hosted).";
RELATE i18n_key:credential_type_gitlab_api_description->translation->language:it SET text = "Autenticazione basata su token per GitLab API. Consente di gestire progetti, merge request, pipeline CI/CD in GitLab (cloud o self-hosted).";
RELATE i18n_key:credential_type_gitlab_api_description->translation->language:de SET text = "Token-basierte Authentifizierung für GitLab API. Ermöglicht die Verwaltung von Projekten, Merge Requests, CI/CD-Pipelines in GitLab (Cloud oder selbst gehostet).";
RELATE i18n_key:credential_type_gitlab_api_description->translation->language:es SET text = "Autenticación basada en token para GitLab API. Permite gestionar proyectos, merge requests, pipelines CI/CD en GitLab (cloud o auto-alojado).";

RELATE i18n_key:credential_type_gitlab_api_tooltip->translation->language:fr SET text = "Pour DevOps GitLab et CI/CD pipelines";
RELATE i18n_key:credential_type_gitlab_api_tooltip->translation->language:en SET text = "For GitLab DevOps and CI/CD pipelines";
RELATE i18n_key:credential_type_gitlab_api_tooltip->translation->language:it SET text = "Per DevOps GitLab e pipeline CI/CD";
RELATE i18n_key:credential_type_gitlab_api_tooltip->translation->language:de SET text = "Für GitLab DevOps und CI/CD-Pipelines";
RELATE i18n_key:credential_type_gitlab_api_tooltip->translation->language:es SET text = "Para DevOps GitLab y pipelines CI/CD";

-- =====================================================
-- GITLAB OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_gitlab_oauth2_api_name->translation->language:fr SET text = "GitLab OAuth2";
RELATE i18n_key:credential_type_gitlab_oauth2_api_name->translation->language:en SET text = "GitLab OAuth2";
RELATE i18n_key:credential_type_gitlab_oauth2_api_name->translation->language:it SET text = "GitLab OAuth2";
RELATE i18n_key:credential_type_gitlab_oauth2_api_name->translation->language:de SET text = "GitLab OAuth2";
RELATE i18n_key:credential_type_gitlab_oauth2_api_name->translation->language:es SET text = "GitLab OAuth2";

RELATE i18n_key:credential_type_gitlab_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour GitLab API. Permet d'accéder à GitLab avec authentification utilisateur pour intégrations applications.";
RELATE i18n_key:credential_type_gitlab_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for GitLab API. Allows accessing GitLab with user authentication for application integrations.";
RELATE i18n_key:credential_type_gitlab_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per GitLab API. Consente di accedere a GitLab con autenticazione utente per integrazioni applicazioni.";
RELATE i18n_key:credential_type_gitlab_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für GitLab API. Ermöglicht den Zugriff auf GitLab mit Benutzerauthentifizierung für Anwendungsintegrationen.";
RELATE i18n_key:credential_type_gitlab_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para GitLab API. Permite acceder GitLab con autenticación usuario para integraciones aplicaciones.";

RELATE i18n_key:credential_type_gitlab_oauth2_api_tooltip->translation->language:fr SET text = "Pour applications GitLab et auth utilisateur";
RELATE i18n_key:credential_type_gitlab_oauth2_api_tooltip->translation->language:en SET text = "For GitLab applications and user auth";
RELATE i18n_key:credential_type_gitlab_oauth2_api_tooltip->translation->language:it SET text = "Per applicazioni GitLab e auth utente";
RELATE i18n_key:credential_type_gitlab_oauth2_api_tooltip->translation->language:de SET text = "Für GitLab-Anwendungen und Benutzer-Auth";
RELATE i18n_key:credential_type_gitlab_oauth2_api_tooltip->translation->language:es SET text = "Para aplicaciones GitLab y auth usuario";

-- =====================================================
-- JIRA SOFTWARE CLOUD API
-- =====================================================

RELATE i18n_key:credential_type_jira_software_cloud_api_name->translation->language:fr SET text = "Jira Software Cloud";
RELATE i18n_key:credential_type_jira_software_cloud_api_name->translation->language:en SET text = "Jira Software Cloud";
RELATE i18n_key:credential_type_jira_software_cloud_api_name->translation->language:it SET text = "Jira Software Cloud";
RELATE i18n_key:credential_type_jira_software_cloud_api_name->translation->language:de SET text = "Jira Software Cloud";
RELATE i18n_key:credential_type_jira_software_cloud_api_name->translation->language:es SET text = "Jira Software Cloud";

RELATE i18n_key:credential_type_jira_software_cloud_api_description->translation->language:fr SET text = "Authentification pour Jira Software Cloud (Atlassian). Permet de gérer issues, sprints, boards Agile et automatiser workflows de projet.";
RELATE i18n_key:credential_type_jira_software_cloud_api_description->translation->language:en SET text = "Authentication for Jira Software Cloud (Atlassian). Allows managing issues, sprints, Agile boards, and automating project workflows.";
RELATE i18n_key:credential_type_jira_software_cloud_api_description->translation->language:it SET text = "Autenticazione per Jira Software Cloud (Atlassian). Consente di gestire issue, sprint, board Agile e automatizzare flussi di lavoro progetto.";
RELATE i18n_key:credential_type_jira_software_cloud_api_description->translation->language:de SET text = "Authentifizierung für Jira Software Cloud (Atlassian). Ermöglicht die Verwaltung von Issues, Sprints, Agile Boards und die Automatisierung von Projektworkflows.";
RELATE i18n_key:credential_type_jira_software_cloud_api_description->translation->language:es SET text = "Autenticación para Jira Software Cloud (Atlassian). Permite gestionar issues, sprints, boards Agile y automatizar flujos proyecto.";

RELATE i18n_key:credential_type_jira_software_cloud_api_tooltip->translation->language:fr SET text = "Pour gestion projet Agile et suivi issues";
RELATE i18n_key:credential_type_jira_software_cloud_api_tooltip->translation->language:en SET text = "For Agile project management and issue tracking";
RELATE i18n_key:credential_type_jira_software_cloud_api_tooltip->translation->language:it SET text = "Per gestione progetto Agile e tracciamento issue";
RELATE i18n_key:credential_type_jira_software_cloud_api_tooltip->translation->language:de SET text = "Für Agile-Projektmanagement und Issue-Tracking";
RELATE i18n_key:credential_type_jira_software_cloud_api_tooltip->translation->language:es SET text = "Para gestión proyecto Agile y seguimiento issues";

-- =====================================================
-- JIRA SOFTWARE SERVER API
-- =====================================================

RELATE i18n_key:credential_type_jira_software_server_api_name->translation->language:fr SET text = "Jira Software Server";
RELATE i18n_key:credential_type_jira_software_server_api_name->translation->language:en SET text = "Jira Software Server";
RELATE i18n_key:credential_type_jira_software_server_api_name->translation->language:it SET text = "Jira Software Server";
RELATE i18n_key:credential_type_jira_software_server_api_name->translation->language:de SET text = "Jira Software Server";
RELATE i18n_key:credential_type_jira_software_server_api_name->translation->language:es SET text = "Jira Software Server";

RELATE i18n_key:credential_type_jira_software_server_api_description->translation->language:fr SET text = "Authentification Basic Auth pour Jira Software Server (self-hosted). Permet de gérer issues dans installations Jira on-premise.";
RELATE i18n_key:credential_type_jira_software_server_api_description->translation->language:en SET text = "Basic Auth authentication for Jira Software Server (self-hosted). Allows managing issues in on-premise Jira installations.";
RELATE i18n_key:credential_type_jira_software_server_api_description->translation->language:it SET text = "Autenticazione Basic Auth per Jira Software Server (self-hosted). Consente di gestire issue in installazioni Jira on-premise.";
RELATE i18n_key:credential_type_jira_software_server_api_description->translation->language:de SET text = "Basic Auth-Authentifizierung für Jira Software Server (selbst gehostet). Ermöglicht die Verwaltung von Issues in On-Premise-Jira-Installationen.";
RELATE i18n_key:credential_type_jira_software_server_api_description->translation->language:es SET text = "Autenticación Basic Auth para Jira Software Server (auto-alojado). Permite gestionar issues en instalaciones Jira on-premise.";

RELATE i18n_key:credential_type_jira_software_server_api_tooltip->translation->language:fr SET text = "Pour Jira self-hosted et on-premise";
RELATE i18n_key:credential_type_jira_software_server_api_tooltip->translation->language:en SET text = "For self-hosted and on-premise Jira";
RELATE i18n_key:credential_type_jira_software_server_api_tooltip->translation->language:it SET text = "Per Jira self-hosted e on-premise";
RELATE i18n_key:credential_type_jira_software_server_api_tooltip->translation->language:de SET text = "Für selbst gehostetes und On-Premise-Jira";
RELATE i18n_key:credential_type_jira_software_server_api_tooltip->translation->language:es SET text = "Para Jira auto-alojado y on-premise";

-- =====================================================
-- JIRA SOFTWARE SERVER PAT API
-- =====================================================

RELATE i18n_key:credential_type_jira_software_server_pat_api_name->translation->language:fr SET text = "Jira Software Server PAT";
RELATE i18n_key:credential_type_jira_software_server_pat_api_name->translation->language:en SET text = "Jira Software Server PAT";
RELATE i18n_key:credential_type_jira_software_server_pat_api_name->translation->language:it SET text = "Jira Software Server PAT";
RELATE i18n_key:credential_type_jira_software_server_pat_api_name->translation->language:de SET text = "Jira Software Server PAT";
RELATE i18n_key:credential_type_jira_software_server_pat_api_name->translation->language:es SET text = "Jira Software Server PAT";

RELATE i18n_key:credential_type_jira_software_server_pat_api_description->translation->language:fr SET text = "Authentification par Personal Access Token pour Jira Software Server. Plus sécurisé que Basic Auth pour installations self-hosted.";
RELATE i18n_key:credential_type_jira_software_server_pat_api_description->translation->language:en SET text = "Personal Access Token authentication for Jira Software Server. More secure than Basic Auth for self-hosted installations.";
RELATE i18n_key:credential_type_jira_software_server_pat_api_description->translation->language:it SET text = "Autenticazione tramite Personal Access Token per Jira Software Server. Più sicuro di Basic Auth per installazioni self-hosted.";
RELATE i18n_key:credential_type_jira_software_server_pat_api_description->translation->language:de SET text = "Personal Access Token-Authentifizierung für Jira Software Server. Sicherer als Basic Auth für selbst gehostete Installationen.";
RELATE i18n_key:credential_type_jira_software_server_pat_api_description->translation->language:es SET text = "Autenticación mediante Personal Access Token para Jira Software Server. Más seguro que Basic Auth para instalaciones auto-alojadas.";

RELATE i18n_key:credential_type_jira_software_server_pat_api_tooltip->translation->language:fr SET text = "Pour Jira Server avec sécurité renforcée (PAT)";
RELATE i18n_key:credential_type_jira_software_server_pat_api_tooltip->translation->language:en SET text = "For Jira Server with enhanced security (PAT)";
RELATE i18n_key:credential_type_jira_software_server_pat_api_tooltip->translation->language:it SET text = "Per Jira Server con sicurezza migliorata (PAT)";
RELATE i18n_key:credential_type_jira_software_server_pat_api_tooltip->translation->language:de SET text = "Für Jira Server mit erhöhter Sicherheit (PAT)";
RELATE i18n_key:credential_type_jira_software_server_pat_api_tooltip->translation->language:es SET text = "Para Jira Server con seguridad mejorada (PAT)";

-- =====================================================
-- BITBUCKET API
-- =====================================================

RELATE i18n_key:credential_type_bitbucket_api_name->translation->language:fr SET text = "Bitbucket API";
RELATE i18n_key:credential_type_bitbucket_api_name->translation->language:en SET text = "Bitbucket API";
RELATE i18n_key:credential_type_bitbucket_api_name->translation->language:it SET text = "Bitbucket API";
RELATE i18n_key:credential_type_bitbucket_api_name->translation->language:de SET text = "Bitbucket API";
RELATE i18n_key:credential_type_bitbucket_api_name->translation->language:es SET text = "Bitbucket API";

RELATE i18n_key:credential_type_bitbucket_api_description->translation->language:fr SET text = "Authentification Basic Auth pour Bitbucket API (Atlassian). Permet de gérer repositories Git, pull requests et pipelines CI/CD Bitbucket.";
RELATE i18n_key:credential_type_bitbucket_api_description->translation->language:en SET text = "Basic Auth authentication for Bitbucket API (Atlassian). Allows managing Git repositories, pull requests, and Bitbucket CI/CD pipelines.";
RELATE i18n_key:credential_type_bitbucket_api_description->translation->language:it SET text = "Autenticazione Basic Auth per Bitbucket API (Atlassian). Consente di gestire repository Git, pull request e pipeline CI/CD Bitbucket.";
RELATE i18n_key:credential_type_bitbucket_api_description->translation->language:de SET text = "Basic Auth-Authentifizierung für Bitbucket API (Atlassian). Ermöglicht die Verwaltung von Git-Repositories, Pull Requests und Bitbucket CI/CD-Pipelines.";
RELATE i18n_key:credential_type_bitbucket_api_description->translation->language:es SET text = "Autenticación Basic Auth para Bitbucket API (Atlassian). Permite gestionar repositorios Git, pull requests y pipelines CI/CD Bitbucket.";

RELATE i18n_key:credential_type_bitbucket_api_tooltip->translation->language:fr SET text = "Pour gestion code Bitbucket et CI/CD";
RELATE i18n_key:credential_type_bitbucket_api_tooltip->translation->language:en SET text = "For Bitbucket code management and CI/CD";
RELATE i18n_key:credential_type_bitbucket_api_tooltip->translation->language:it SET text = "Per gestione codice Bitbucket e CI/CD";
RELATE i18n_key:credential_type_bitbucket_api_tooltip->translation->language:de SET text = "Für Bitbucket-Code-Verwaltung und CI/CD";
RELATE i18n_key:credential_type_bitbucket_api_tooltip->translation->language:es SET text = "Para gestión código Bitbucket y CI/CD";

-- =====================================================
-- BITBUCKET ACCESS TOKEN API
-- =====================================================

RELATE i18n_key:credential_type_bitbucket_access_token_api_name->translation->language:fr SET text = "Bitbucket Access Token";
RELATE i18n_key:credential_type_bitbucket_access_token_api_name->translation->language:en SET text = "Bitbucket Access Token";
RELATE i18n_key:credential_type_bitbucket_access_token_api_name->translation->language:it SET text = "Bitbucket Access Token";
RELATE i18n_key:credential_type_bitbucket_access_token_api_name->translation->language:de SET text = "Bitbucket Access Token";
RELATE i18n_key:credential_type_bitbucket_access_token_api_name->translation->language:es SET text = "Bitbucket Access Token";

RELATE i18n_key:credential_type_bitbucket_access_token_api_description->translation->language:fr SET text = "Authentification par Access Token pour Bitbucket API. Plus sécurisé que Basic Auth pour intégrations Bitbucket.";
RELATE i18n_key:credential_type_bitbucket_access_token_api_description->translation->language:en SET text = "Access Token authentication for Bitbucket API. More secure than Basic Auth for Bitbucket integrations.";
RELATE i18n_key:credential_type_bitbucket_access_token_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Bitbucket API. Più sicuro di Basic Auth per integrazioni Bitbucket.";
RELATE i18n_key:credential_type_bitbucket_access_token_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Bitbucket API. Sicherer als Basic Auth für Bitbucket-Integrationen.";
RELATE i18n_key:credential_type_bitbucket_access_token_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Bitbucket API. Más seguro que Basic Auth para integraciones Bitbucket.";

RELATE i18n_key:credential_type_bitbucket_access_token_api_tooltip->translation->language:fr SET text = "Pour Bitbucket avec sécurité renforcée";
RELATE i18n_key:credential_type_bitbucket_access_token_api_tooltip->translation->language:en SET text = "For Bitbucket with enhanced security";
RELATE i18n_key:credential_type_bitbucket_access_token_api_tooltip->translation->language:it SET text = "Per Bitbucket con sicurezza migliorata";
RELATE i18n_key:credential_type_bitbucket_access_token_api_tooltip->translation->language:de SET text = "Für Bitbucket mit erhöhter Sicherheit";
RELATE i18n_key:credential_type_bitbucket_access_token_api_tooltip->translation->language:es SET text = "Para Bitbucket con seguridad mejorada";

-- =====================================================
-- JENKINS API
-- =====================================================

RELATE i18n_key:credential_type_jenkins_api_name->translation->language:fr SET text = "Jenkins API";
RELATE i18n_key:credential_type_jenkins_api_name->translation->language:en SET text = "Jenkins API";
RELATE i18n_key:credential_type_jenkins_api_name->translation->language:it SET text = "Jenkins API";
RELATE i18n_key:credential_type_jenkins_api_name->translation->language:de SET text = "Jenkins API";
RELATE i18n_key:credential_type_jenkins_api_name->translation->language:es SET text = "Jenkins API";

RELATE i18n_key:credential_type_jenkins_api_description->translation->language:fr SET text = "Authentification pour Jenkins API. Serveur d'automatisation CI/CD open-source pour builds, tests et déploiements automatisés.";
RELATE i18n_key:credential_type_jenkins_api_description->translation->language:en SET text = "Authentication for Jenkins API. Open-source CI/CD automation server for automated builds, tests, and deployments.";
RELATE i18n_key:credential_type_jenkins_api_description->translation->language:it SET text = "Autenticazione per Jenkins API. Server di automazione CI/CD open-source per build, test e deployment automatizzati.";
RELATE i18n_key:credential_type_jenkins_api_description->translation->language:de SET text = "Authentifizierung für Jenkins API. Open-Source-CI/CD-Automatisierungsserver für automatisierte Builds, Tests und Bereitstellungen.";
RELATE i18n_key:credential_type_jenkins_api_description->translation->language:es SET text = "Autenticación para Jenkins API. Servidor automatización CI/CD open-source para builds, tests y despliegues automatizados.";

RELATE i18n_key:credential_type_jenkins_api_tooltip->translation->language:fr SET text = "Pour CI/CD Jenkins et pipelines build";
RELATE i18n_key:credential_type_jenkins_api_tooltip->translation->language:en SET text = "For Jenkins CI/CD and build pipelines";
RELATE i18n_key:credential_type_jenkins_api_tooltip->translation->language:it SET text = "Per CI/CD Jenkins e pipeline build";
RELATE i18n_key:credential_type_jenkins_api_tooltip->translation->language:de SET text = "Für Jenkins CI/CD und Build-Pipelines";
RELATE i18n_key:credential_type_jenkins_api_tooltip->translation->language:es SET text = "Para CI/CD Jenkins y pipelines build";

-- =====================================================
-- CIRCLECI API
-- =====================================================

-- =====================================================
-- TRAVIS CI API
-- =====================================================

RELATE i18n_key:credential_type_travis_ci_api_name->translation->language:fr SET text = "Travis CI API";
RELATE i18n_key:credential_type_travis_ci_api_name->translation->language:en SET text = "Travis CI API";
RELATE i18n_key:credential_type_travis_ci_api_name->translation->language:it SET text = "Travis CI API";
RELATE i18n_key:credential_type_travis_ci_api_name->translation->language:de SET text = "Travis CI API";
RELATE i18n_key:credential_type_travis_ci_api_name->translation->language:es SET text = "Travis CI API";

RELATE i18n_key:credential_type_travis_ci_api_description->translation->language:fr SET text = "Authentification par token pour Travis CI API. Plateforme CI/CD historique pour projets open-source avec intégration GitHub.";
RELATE i18n_key:credential_type_travis_ci_api_description->translation->language:en SET text = "Token-based authentication for Travis CI API. Historic CI/CD platform for open-source projects with GitHub integration.";
RELATE i18n_key:credential_type_travis_ci_api_description->translation->language:it SET text = "Autenticazione basata su token per Travis CI API. Piattaforma CI/CD storica per progetti open-source con integrazione GitHub.";
RELATE i18n_key:credential_type_travis_ci_api_description->translation->language:de SET text = "Token-basierte Authentifizierung für Travis CI API. Historische CI/CD-Plattform für Open-Source-Projekte mit GitHub-Integration.";
RELATE i18n_key:credential_type_travis_ci_api_description->translation->language:es SET text = "Autenticación basada en token para Travis CI API. Plataforma CI/CD histórica para proyectos open-source con integración GitHub.";

RELATE i18n_key:credential_type_travis_ci_api_tooltip->translation->language:fr SET text = "Pour CI/CD projets open-source et GitHub";
RELATE i18n_key:credential_type_travis_ci_api_tooltip->translation->language:en SET text = "For CI/CD open-source projects and GitHub";
RELATE i18n_key:credential_type_travis_ci_api_tooltip->translation->language:it SET text = "Per CI/CD progetti open-source e GitHub";
RELATE i18n_key:credential_type_travis_ci_api_tooltip->translation->language:de SET text = "Für CI/CD Open-Source-Projekte und GitHub";
RELATE i18n_key:credential_type_travis_ci_api_tooltip->translation->language:es SET text = "Para CI/CD proyectos open-source y GitHub";

-- =============================================================================================

