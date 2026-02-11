-- =============================================================================================
-- |
-- | Fichier : credential_type_batch12_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 12 des credential types.
-- |
-- | Batch 12 : Forms, Surveys & Scheduling (11 credentials)
-- | Providers : TypeForm, SurveyMonkey, JotForm, Formstack, Calendly, Acuity Scheduling
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- TYPEFORM API
-- =====================================================

RELATE i18n_key:credential_type_typeform_api_name->translation->language:fr SET text = "TypeForm API";
RELATE i18n_key:credential_type_typeform_api_name->translation->language:en SET text = "TypeForm API";
RELATE i18n_key:credential_type_typeform_api_name->translation->language:it SET text = "TypeForm API";
RELATE i18n_key:credential_type_typeform_api_name->translation->language:de SET text = "TypeForm API";
RELATE i18n_key:credential_type_typeform_api_name->translation->language:es SET text = "TypeForm API";

RELATE i18n_key:credential_type_typeform_api_description->translation->language:fr SET text = "Authentification par Personal Access Token pour TypeForm. Plateforme formulaires interactifs pour enquêtes, quizz et collecte données.";
RELATE i18n_key:credential_type_typeform_api_description->translation->language:en SET text = "Personal Access Token authentication for TypeForm. Interactive forms platform for surveys, quizzes, and data collection.";
RELATE i18n_key:credential_type_typeform_api_description->translation->language:it SET text = "Autenticazione tramite Personal Access Token per TypeForm. Piattaforma form interattivi per sondaggi, quiz e raccolta dati.";
RELATE i18n_key:credential_type_typeform_api_description->translation->language:de SET text = "Personal Access Token-Authentifizierung für TypeForm. Interaktive Formularplattform für Umfragen, Quizze und Datenerfassung.";
RELATE i18n_key:credential_type_typeform_api_description->translation->language:es SET text = "Autenticación mediante Personal Access Token para TypeForm. Plataforma formularios interactivos para encuestas, quizzes y recopilación datos.";

RELATE i18n_key:credential_type_typeform_api_tooltip->translation->language:fr SET text = "Pour TypeForm formulaires et enquêtes";
RELATE i18n_key:credential_type_typeform_api_tooltip->translation->language:en SET text = "For TypeForm forms and surveys";
RELATE i18n_key:credential_type_typeform_api_tooltip->translation->language:it SET text = "Per TypeForm form e sondaggi";
RELATE i18n_key:credential_type_typeform_api_tooltip->translation->language:de SET text = "Für TypeForm Formulare und Umfragen";
RELATE i18n_key:credential_type_typeform_api_tooltip->translation->language:es SET text = "Para TypeForm formularios y encuestas";

-- =====================================================
-- TYPEFORM OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_typeform_oauth2_api_name->translation->language:fr SET text = "TypeForm OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_name->translation->language:en SET text = "TypeForm OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_name->translation->language:it SET text = "TypeForm OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_name->translation->language:de SET text = "TypeForm OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_name->translation->language:es SET text = "TypeForm OAuth2";

RELATE i18n_key:credential_type_typeform_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour TypeForm. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_typeform_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for TypeForm. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_typeform_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per TypeForm. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_typeform_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für TypeForm. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_typeform_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para TypeForm. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_typeform_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces TypeForm avec OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_tooltip->translation->language:en SET text = "For third-party TypeForm apps with OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_tooltip->translation->language:it SET text = "Per app terze TypeForm con OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-TypeForm-Apps mit OAuth2";
RELATE i18n_key:credential_type_typeform_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros TypeForm con OAuth2";

-- =====================================================
-- SURVEYMONKEY API
-- =====================================================

RELATE i18n_key:credential_type_surveymonkey_api_name->translation->language:fr SET text = "SurveyMonkey API";
RELATE i18n_key:credential_type_surveymonkey_api_name->translation->language:en SET text = "SurveyMonkey API";
RELATE i18n_key:credential_type_surveymonkey_api_name->translation->language:it SET text = "SurveyMonkey API";
RELATE i18n_key:credential_type_surveymonkey_api_name->translation->language:de SET text = "SurveyMonkey API";
RELATE i18n_key:credential_type_surveymonkey_api_name->translation->language:es SET text = "SurveyMonkey API";

RELATE i18n_key:credential_type_surveymonkey_api_description->translation->language:fr SET text = "Authentification par Access Token pour SurveyMonkey. Leader enquêtes en ligne pour sondages professionnels et feedback client.";
RELATE i18n_key:credential_type_surveymonkey_api_description->translation->language:en SET text = "Access Token authentication for SurveyMonkey. Online survey leader for professional surveys and customer feedback.";
RELATE i18n_key:credential_type_surveymonkey_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per SurveyMonkey. Leader sondaggi online per survey professionali e feedback clienti.";
RELATE i18n_key:credential_type_surveymonkey_api_description->translation->language:de SET text = "Access Token-Authentifizierung für SurveyMonkey. Online-Umfragen-Marktführer für professionelle Umfragen und Kundenfeedback.";
RELATE i18n_key:credential_type_surveymonkey_api_description->translation->language:es SET text = "Autenticación mediante Access Token para SurveyMonkey. Líder encuestas online para sondeos profesionales y feedback cliente.";

RELATE i18n_key:credential_type_surveymonkey_api_tooltip->translation->language:fr SET text = "Pour SurveyMonkey enquêtes et sondages";
RELATE i18n_key:credential_type_surveymonkey_api_tooltip->translation->language:en SET text = "For SurveyMonkey surveys and polls";
RELATE i18n_key:credential_type_surveymonkey_api_tooltip->translation->language:it SET text = "Per SurveyMonkey sondaggi e survey";
RELATE i18n_key:credential_type_surveymonkey_api_tooltip->translation->language:de SET text = "Für SurveyMonkey Umfragen und Befragungen";
RELATE i18n_key:credential_type_surveymonkey_api_tooltip->translation->language:es SET text = "Para SurveyMonkey encuestas y sondeos";

-- =====================================================
-- SURVEYMONKEY OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_surveymonkey_oauth2_api_name->translation->language:fr SET text = "SurveyMonkey OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_name->translation->language:en SET text = "SurveyMonkey OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_name->translation->language:it SET text = "SurveyMonkey OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_name->translation->language:de SET text = "SurveyMonkey OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_name->translation->language:es SET text = "SurveyMonkey OAuth2";

RELATE i18n_key:credential_type_surveymonkey_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour SurveyMonkey. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for SurveyMonkey. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per SurveyMonkey. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für SurveyMonkey. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para SurveyMonkey. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_surveymonkey_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces SurveyMonkey avec OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_tooltip->translation->language:en SET text = "For third-party SurveyMonkey apps with OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_tooltip->translation->language:it SET text = "Per app terze SurveyMonkey con OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-SurveyMonkey-Apps mit OAuth2";
RELATE i18n_key:credential_type_surveymonkey_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros SurveyMonkey con OAuth2";

-- =====================================================
-- JOTFORM API
-- =====================================================

RELATE i18n_key:credential_type_jotform_api_name->translation->language:fr SET text = "JotForm API";
RELATE i18n_key:credential_type_jotform_api_name->translation->language:en SET text = "JotForm API";
RELATE i18n_key:credential_type_jotform_api_name->translation->language:it SET text = "JotForm API";
RELATE i18n_key:credential_type_jotform_api_name->translation->language:de SET text = "JotForm API";
RELATE i18n_key:credential_type_jotform_api_name->translation->language:es SET text = "JotForm API";

RELATE i18n_key:credential_type_jotform_api_description->translation->language:fr SET text = "Authentification par API Key pour JotForm. Créateur formulaires en ligne drag-and-drop pour collecte données et paiements.";
RELATE i18n_key:credential_type_jotform_api_description->translation->language:en SET text = "API Key authentication for JotForm. Drag-and-drop online form builder for data collection and payments.";
RELATE i18n_key:credential_type_jotform_api_description->translation->language:it SET text = "Autenticazione tramite API Key per JotForm. Builder form online drag-and-drop per raccolta dati e pagamenti.";
RELATE i18n_key:credential_type_jotform_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für JotForm. Drag-and-Drop-Online-Formularbaukasten für Datenerfassung und Zahlungen.";
RELATE i18n_key:credential_type_jotform_api_description->translation->language:es SET text = "Autenticación mediante API Key para JotForm. Constructor formularios online drag-and-drop para recopilación datos y pagos.";

RELATE i18n_key:credential_type_jotform_api_tooltip->translation->language:fr SET text = "Pour JotForm créateur formulaires";
RELATE i18n_key:credential_type_jotform_api_tooltip->translation->language:en SET text = "For JotForm form builder";
RELATE i18n_key:credential_type_jotform_api_tooltip->translation->language:it SET text = "Per JotForm builder form";
RELATE i18n_key:credential_type_jotform_api_tooltip->translation->language:de SET text = "Für JotForm Formularbaukasten";
RELATE i18n_key:credential_type_jotform_api_tooltip->translation->language:es SET text = "Para JotForm constructor formularios";

-- =====================================================
-- FORMSTACK API
-- =====================================================

RELATE i18n_key:credential_type_formstack_api_name->translation->language:fr SET text = "Formstack API";
RELATE i18n_key:credential_type_formstack_api_name->translation->language:en SET text = "Formstack API";
RELATE i18n_key:credential_type_formstack_api_name->translation->language:it SET text = "Formstack API";
RELATE i18n_key:credential_type_formstack_api_name->translation->language:de SET text = "Formstack API";
RELATE i18n_key:credential_type_formstack_api_name->translation->language:es SET text = "Formstack API";

RELATE i18n_key:credential_type_formstack_api_description->translation->language:fr SET text = "Authentification par Access Token pour Formstack. Suite workplace productivity pour formulaires, documents et signatures électroniques.";
RELATE i18n_key:credential_type_formstack_api_description->translation->language:en SET text = "Access Token authentication for Formstack. Workplace productivity suite for forms, documents, and e-signatures.";
RELATE i18n_key:credential_type_formstack_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Formstack. Suite produttività workplace per form, documenti e firme elettroniche.";
RELATE i18n_key:credential_type_formstack_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Formstack. Workplace-Produktivitätssuite für Formulare, Dokumente und E-Signaturen.";
RELATE i18n_key:credential_type_formstack_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Formstack. Suite productividad workplace para formularios, documentos y firmas electrónicas.";

RELATE i18n_key:credential_type_formstack_api_tooltip->translation->language:fr SET text = "Pour Formstack formulaires et documents";
RELATE i18n_key:credential_type_formstack_api_tooltip->translation->language:en SET text = "For Formstack forms and documents";
RELATE i18n_key:credential_type_formstack_api_tooltip->translation->language:it SET text = "Per Formstack form e documenti";
RELATE i18n_key:credential_type_formstack_api_tooltip->translation->language:de SET text = "Für Formstack Formulare und Dokumente";
RELATE i18n_key:credential_type_formstack_api_tooltip->translation->language:es SET text = "Para Formstack formularios y documentos";

-- =====================================================
-- FORMSTACK OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_formstack_oauth2_api_name->translation->language:fr SET text = "Formstack OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_name->translation->language:en SET text = "Formstack OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_name->translation->language:it SET text = "Formstack OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_name->translation->language:de SET text = "Formstack OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_name->translation->language:es SET text = "Formstack OAuth2";

RELATE i18n_key:credential_type_formstack_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Formstack. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_formstack_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Formstack. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_formstack_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Formstack. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_formstack_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Formstack. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_formstack_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Formstack. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_formstack_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Formstack avec OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_tooltip->translation->language:en SET text = "For third-party Formstack apps with OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Formstack con OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Formstack-Apps mit OAuth2";
RELATE i18n_key:credential_type_formstack_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Formstack con OAuth2";

-- =====================================================
-- CALENDLY API
-- =====================================================

RELATE i18n_key:credential_type_calendly_api_name->translation->language:fr SET text = "Calendly API";
RELATE i18n_key:credential_type_calendly_api_name->translation->language:en SET text = "Calendly API";
RELATE i18n_key:credential_type_calendly_api_name->translation->language:it SET text = "Calendly API";
RELATE i18n_key:credential_type_calendly_api_name->translation->language:de SET text = "Calendly API";
RELATE i18n_key:credential_type_calendly_api_name->translation->language:es SET text = "Calendly API";

RELATE i18n_key:credential_type_calendly_api_description->translation->language:fr SET text = "Authentification par Personal Access Token pour Calendly. Outil scheduling automatique pour planifier réunions et rendez-vous.";
RELATE i18n_key:credential_type_calendly_api_description->translation->language:en SET text = "Personal Access Token authentication for Calendly. Automated scheduling tool for planning meetings and appointments.";
RELATE i18n_key:credential_type_calendly_api_description->translation->language:it SET text = "Autenticazione tramite Personal Access Token per Calendly. Strumento scheduling automatico per pianificare riunioni e appuntamenti.";
RELATE i18n_key:credential_type_calendly_api_description->translation->language:de SET text = "Personal Access Token-Authentifizierung für Calendly. Automatisiertes Planungstool für Meetings und Termine.";
RELATE i18n_key:credential_type_calendly_api_description->translation->language:es SET text = "Autenticación mediante Personal Access Token para Calendly. Herramienta scheduling automático para planificar reuniones y citas.";

RELATE i18n_key:credential_type_calendly_api_tooltip->translation->language:fr SET text = "Pour Calendly scheduling et rendez-vous";
RELATE i18n_key:credential_type_calendly_api_tooltip->translation->language:en SET text = "For Calendly scheduling and appointments";
RELATE i18n_key:credential_type_calendly_api_tooltip->translation->language:it SET text = "Per Calendly scheduling e appuntamenti";
RELATE i18n_key:credential_type_calendly_api_tooltip->translation->language:de SET text = "Für Calendly Planung und Termine";
RELATE i18n_key:credential_type_calendly_api_tooltip->translation->language:es SET text = "Para Calendly scheduling y citas";

-- =====================================================
-- CALENDLY OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_calendly_oauth2_api_name->translation->language:fr SET text = "Calendly OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_name->translation->language:en SET text = "Calendly OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_name->translation->language:it SET text = "Calendly OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_name->translation->language:de SET text = "Calendly OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_name->translation->language:es SET text = "Calendly OAuth2";

RELATE i18n_key:credential_type_calendly_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Calendly. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_calendly_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Calendly. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_calendly_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Calendly. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_calendly_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Calendly. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_calendly_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Calendly. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_calendly_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Calendly avec OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_tooltip->translation->language:en SET text = "For third-party Calendly apps with OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Calendly con OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Calendly-Apps mit OAuth2";
RELATE i18n_key:credential_type_calendly_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Calendly con OAuth2";

-- =====================================================
-- ACUITY SCHEDULING API
-- =====================================================

RELATE i18n_key:credential_type_acuity_scheduling_api_name->translation->language:fr SET text = "Acuity Scheduling API";
RELATE i18n_key:credential_type_acuity_scheduling_api_name->translation->language:en SET text = "Acuity Scheduling API";
RELATE i18n_key:credential_type_acuity_scheduling_api_name->translation->language:it SET text = "Acuity Scheduling API";
RELATE i18n_key:credential_type_acuity_scheduling_api_name->translation->language:de SET text = "Acuity Scheduling API";
RELATE i18n_key:credential_type_acuity_scheduling_api_name->translation->language:es SET text = "Acuity Scheduling API";

RELATE i18n_key:credential_type_acuity_scheduling_api_description->translation->language:fr SET text = "Authentification par API Key pour Acuity Scheduling (Squarespace). Logiciel scheduling pour rendez-vous clients et paiements.";
RELATE i18n_key:credential_type_acuity_scheduling_api_description->translation->language:en SET text = "API Key authentication for Acuity Scheduling (Squarespace). Scheduling software for client appointments and payments.";
RELATE i18n_key:credential_type_acuity_scheduling_api_description->translation->language:it SET text = "Autenticazione tramite API Key per Acuity Scheduling (Squarespace). Software scheduling per appuntamenti clienti e pagamenti.";
RELATE i18n_key:credential_type_acuity_scheduling_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Acuity Scheduling (Squarespace). Planungssoftware für Kundentermine und Zahlungen.";
RELATE i18n_key:credential_type_acuity_scheduling_api_description->translation->language:es SET text = "Autenticación mediante API Key para Acuity Scheduling (Squarespace). Software scheduling para citas clientes y pagos.";

RELATE i18n_key:credential_type_acuity_scheduling_api_tooltip->translation->language:fr SET text = "Pour Acuity Scheduling rendez-vous clients";
RELATE i18n_key:credential_type_acuity_scheduling_api_tooltip->translation->language:en SET text = "For Acuity Scheduling client appointments";
RELATE i18n_key:credential_type_acuity_scheduling_api_tooltip->translation->language:it SET text = "Per Acuity Scheduling appuntamenti clienti";
RELATE i18n_key:credential_type_acuity_scheduling_api_tooltip->translation->language:de SET text = "Für Acuity Scheduling Kundentermine";
RELATE i18n_key:credential_type_acuity_scheduling_api_tooltip->translation->language:es SET text = "Para Acuity Scheduling citas clientes";

-- =====================================================
-- ACUITY SCHEDULING OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_name->translation->language:fr SET text = "Acuity Scheduling OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_name->translation->language:en SET text = "Acuity Scheduling OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_name->translation->language:it SET text = "Acuity Scheduling OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_name->translation->language:de SET text = "Acuity Scheduling OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_name->translation->language:es SET text = "Acuity Scheduling OAuth2";

RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Acuity Scheduling. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Acuity Scheduling. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Acuity Scheduling. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Acuity Scheduling. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Acuity Scheduling. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Acuity avec OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_tooltip->translation->language:en SET text = "For third-party Acuity apps with OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Acuity con OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Acuity-Apps mit OAuth2";
RELATE i18n_key:credential_type_acuity_scheduling_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Acuity con OAuth2";

-- =============================================================================================

