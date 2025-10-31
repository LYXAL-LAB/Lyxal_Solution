-- =============================================================================================
-- |
-- | Fichier : credential_type_batch16_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 16 des credential types.
-- |
-- | Batch 16 : Accounting, Finance, Time Tracking & HR (11 credentials)
-- | Providers : Xero, QuickBooks, Invoice Ninja, ProfitWell, Wise, Harvest, Clockify, Toggl, BambooHR, Workable
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- XERO OAUTH2 API
RELATE i18n_key:credential_type_xero_oauth2_api_name->translation->language:fr SET text = "Xero OAuth2";
RELATE i18n_key:credential_type_xero_oauth2_api_name->translation->language:en SET text = "Xero OAuth2";
RELATE i18n_key:credential_type_xero_oauth2_api_name->translation->language:it SET text = "Xero OAuth2";
RELATE i18n_key:credential_type_xero_oauth2_api_name->translation->language:de SET text = "Xero OAuth2";
RELATE i18n_key:credential_type_xero_oauth2_api_name->translation->language:es SET text = "Xero OAuth2";

RELATE i18n_key:credential_type_xero_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Xero. Plateforme comptabilité cloud leader pour PME avec transactions, contacts et paramètres.";
RELATE i18n_key:credential_type_xero_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Xero. Leading cloud accounting platform for SMEs with transactions, contacts and settings.";
RELATE i18n_key:credential_type_xero_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Xero. Piattaforma contabilità cloud leader per PMI con transazioni, contatti e impostazioni.";
RELATE i18n_key:credential_type_xero_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Xero. Führende Cloud-Buchhaltungsplattform für KMU mit Transaktionen, Kontakten und Einstellungen.";
RELATE i18n_key:credential_type_xero_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Xero. Plataforma contabilidad cloud líder para PYMES con transacciones, contactos y configuración.";

RELATE i18n_key:credential_type_xero_oauth2_api_tooltip->translation->language:fr SET text = "Pour Xero comptabilité cloud";
RELATE i18n_key:credential_type_xero_oauth2_api_tooltip->translation->language:en SET text = "For Xero cloud accounting";
RELATE i18n_key:credential_type_xero_oauth2_api_tooltip->translation->language:it SET text = "Per Xero contabilità cloud";
RELATE i18n_key:credential_type_xero_oauth2_api_tooltip->translation->language:de SET text = "Für Xero Cloud-Buchhaltung";
RELATE i18n_key:credential_type_xero_oauth2_api_tooltip->translation->language:es SET text = "Para Xero contabilidad cloud";

-- QUICKBOOKS OAUTH2 API
RELATE i18n_key:credential_type_quickbooks_oauth2_api_name->translation->language:fr SET text = "QuickBooks OAuth2";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_name->translation->language:en SET text = "QuickBooks OAuth2";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_name->translation->language:it SET text = "QuickBooks OAuth2";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_name->translation->language:de SET text = "QuickBooks OAuth2";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_name->translation->language:es SET text = "QuickBooks OAuth2";

RELATE i18n_key:credential_type_quickbooks_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour QuickBooks Online. Logiciel comptabilité Intuit pour entreprises avec production et sandbox.";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for QuickBooks Online. Intuit accounting software for businesses with production and sandbox.";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per QuickBooks Online. Software contabilità Intuit per aziende con produzione e sandbox.";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für QuickBooks Online. Intuit-Buchhaltungssoftware für Unternehmen mit Produktion und Sandbox.";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para QuickBooks Online. Software contabilidad Intuit para empresas con producción y sandbox.";

RELATE i18n_key:credential_type_quickbooks_oauth2_api_tooltip->translation->language:fr SET text = "Pour QuickBooks comptabilité Intuit";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_tooltip->translation->language:en SET text = "For QuickBooks Intuit accounting";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_tooltip->translation->language:it SET text = "Per QuickBooks contabilità Intuit";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_tooltip->translation->language:de SET text = "Für QuickBooks Intuit-Buchhaltung";
RELATE i18n_key:credential_type_quickbooks_oauth2_api_tooltip->translation->language:es SET text = "Para QuickBooks contabilidad Intuit";

-- INVOICE NINJA API
RELATE i18n_key:credential_type_invoice_ninja_api_name->translation->language:fr SET text = "Invoice Ninja API";
RELATE i18n_key:credential_type_invoice_ninja_api_name->translation->language:en SET text = "Invoice Ninja API";
RELATE i18n_key:credential_type_invoice_ninja_api_name->translation->language:it SET text = "Invoice Ninja API";
RELATE i18n_key:credential_type_invoice_ninja_api_name->translation->language:de SET text = "Invoice Ninja API";
RELATE i18n_key:credential_type_invoice_ninja_api_name->translation->language:es SET text = "Invoice Ninja API";

RELATE i18n_key:credential_type_invoice_ninja_api_description->translation->language:fr SET text = "Authentification par token pour Invoice Ninja. Plateforme facturation open-source avec support v4 et v5.";
RELATE i18n_key:credential_type_invoice_ninja_api_description->translation->language:en SET text = "Token authentication for Invoice Ninja. Open-source invoicing platform with v4 and v5 support.";
RELATE i18n_key:credential_type_invoice_ninja_api_description->translation->language:it SET text = "Autenticazione tramite token per Invoice Ninja. Piattaforma fatturazione open-source con supporto v4 e v5.";
RELATE i18n_key:credential_type_invoice_ninja_api_description->translation->language:de SET text = "Token-Authentifizierung für Invoice Ninja. Open-Source-Rechnungsplattform mit v4- und v5-Unterstützung.";
RELATE i18n_key:credential_type_invoice_ninja_api_description->translation->language:es SET text = "Autenticación mediante token para Invoice Ninja. Plataforma facturación open-source con soporte v4 y v5.";

RELATE i18n_key:credential_type_invoice_ninja_api_tooltip->translation->language:fr SET text = "Pour Invoice Ninja facturation";
RELATE i18n_key:credential_type_invoice_ninja_api_tooltip->translation->language:en SET text = "For Invoice Ninja invoicing";
RELATE i18n_key:credential_type_invoice_ninja_api_tooltip->translation->language:it SET text = "Per Invoice Ninja fatturazione";
RELATE i18n_key:credential_type_invoice_ninja_api_tooltip->translation->language:de SET text = "Für Invoice Ninja Rechnungsstellung";
RELATE i18n_key:credential_type_invoice_ninja_api_tooltip->translation->language:es SET text = "Para Invoice Ninja facturación";

-- PROFITWELL API
RELATE i18n_key:credential_type_profitwell_api_name->translation->language:fr SET text = "ProfitWell API";
RELATE i18n_key:credential_type_profitwell_api_name->translation->language:en SET text = "ProfitWell API";
RELATE i18n_key:credential_type_profitwell_api_name->translation->language:it SET text = "ProfitWell API";
RELATE i18n_key:credential_type_profitwell_api_name->translation->language:de SET text = "ProfitWell API";
RELATE i18n_key:credential_type_profitwell_api_name->translation->language:es SET text = "ProfitWell API";

RELATE i18n_key:credential_type_profitwell_api_description->translation->language:fr SET text = "Authentification par token pour ProfitWell. Plateforme analytics revenus et métriques abonnements pour SaaS.";
RELATE i18n_key:credential_type_profitwell_api_description->translation->language:en SET text = "Token authentication for ProfitWell. Revenue analytics and subscription metrics platform for SaaS.";
RELATE i18n_key:credential_type_profitwell_api_description->translation->language:it SET text = "Autenticazione tramite token per ProfitWell. Piattaforma analytics ricavi e metriche abbonamenti per SaaS.";
RELATE i18n_key:credential_type_profitwell_api_description->translation->language:de SET text = "Token-Authentifizierung für ProfitWell. Umsatzanalyse- und Abonnementmetriken-Plattform für SaaS.";
RELATE i18n_key:credential_type_profitwell_api_description->translation->language:es SET text = "Autenticación mediante token para ProfitWell. Plataforma analytics ingresos y métricas suscripciones para SaaS.";

RELATE i18n_key:credential_type_profitwell_api_tooltip->translation->language:fr SET text = "Pour ProfitWell analytics revenus";
RELATE i18n_key:credential_type_profitwell_api_tooltip->translation->language:en SET text = "For ProfitWell revenue analytics";
RELATE i18n_key:credential_type_profitwell_api_tooltip->translation->language:it SET text = "Per ProfitWell analytics ricavi";
RELATE i18n_key:credential_type_profitwell_api_tooltip->translation->language:de SET text = "Für ProfitWell Umsatzanalyse";
RELATE i18n_key:credential_type_profitwell_api_tooltip->translation->language:es SET text = "Para ProfitWell analytics ingresos";

-- WISE API
RELATE i18n_key:credential_type_wise_api_name->translation->language:fr SET text = "Wise API";
RELATE i18n_key:credential_type_wise_api_name->translation->language:en SET text = "Wise API";
RELATE i18n_key:credential_type_wise_api_name->translation->language:it SET text = "Wise API";
RELATE i18n_key:credential_type_wise_api_name->translation->language:de SET text = "Wise API";
RELATE i18n_key:credential_type_wise_api_name->translation->language:es SET text = "Wise API";

RELATE i18n_key:credential_type_wise_api_description->translation->language:fr SET text = "Authentification par token pour Wise (TransferWise). Transferts argent internationaux avec environnement live et test.";
RELATE i18n_key:credential_type_wise_api_description->translation->language:en SET text = "Token authentication for Wise (TransferWise). International money transfers with live and test environment.";
RELATE i18n_key:credential_type_wise_api_description->translation->language:it SET text = "Autenticazione tramite token per Wise (TransferWise). Trasferimenti denaro internazionali con ambiente live e test.";
RELATE i18n_key:credential_type_wise_api_description->translation->language:de SET text = "Token-Authentifizierung für Wise (TransferWise). Internationale Geldüberweisungen mit Live- und Testumgebung.";
RELATE i18n_key:credential_type_wise_api_description->translation->language:es SET text = "Autenticación mediante token para Wise (TransferWise). Transferencias dinero internacionales con entorno live y test.";

RELATE i18n_key:credential_type_wise_api_tooltip->translation->language:fr SET text = "Pour Wise transferts internationaux";
RELATE i18n_key:credential_type_wise_api_tooltip->translation->language:en SET text = "For Wise international transfers";
RELATE i18n_key:credential_type_wise_api_tooltip->translation->language:it SET text = "Per Wise trasferimenti internazionali";
RELATE i18n_key:credential_type_wise_api_tooltip->translation->language:de SET text = "Für Wise internationale Überweisungen";
RELATE i18n_key:credential_type_wise_api_tooltip->translation->language:es SET text = "Para Wise transferencias internacionales";

-- HARVEST API
RELATE i18n_key:credential_type_harvest_api_name->translation->language:fr SET text = "Harvest API";
RELATE i18n_key:credential_type_harvest_api_name->translation->language:en SET text = "Harvest API";
RELATE i18n_key:credential_type_harvest_api_name->translation->language:it SET text = "Harvest API";
RELATE i18n_key:credential_type_harvest_api_name->translation->language:de SET text = "Harvest API";
RELATE i18n_key:credential_type_harvest_api_name->translation->language:es SET text = "Harvest API";

RELATE i18n_key:credential_type_harvest_api_description->translation->language:fr SET text = "Authentification par token personnel pour Harvest. Time tracking, facturation et suivi dépenses pour équipes.";
RELATE i18n_key:credential_type_harvest_api_description->translation->language:en SET text = "Personal token authentication for Harvest. Time tracking, invoicing and expense tracking for teams.";
RELATE i18n_key:credential_type_harvest_api_description->translation->language:it SET text = "Autenticazione tramite token personale per Harvest. Time tracking, fatturazione e monitoraggio spese per team.";
RELATE i18n_key:credential_type_harvest_api_description->translation->language:de SET text = "Persönliche Token-Authentifizierung für Harvest. Zeiterfassung, Rechnungsstellung und Spesenabrechnung für Teams.";
RELATE i18n_key:credential_type_harvest_api_description->translation->language:es SET text = "Autenticación mediante token personal para Harvest. Time tracking, facturación y seguimiento gastos para equipos.";

RELATE i18n_key:credential_type_harvest_api_tooltip->translation->language:fr SET text = "Pour Harvest time tracking";
RELATE i18n_key:credential_type_harvest_api_tooltip->translation->language:en SET text = "For Harvest time tracking";
RELATE i18n_key:credential_type_harvest_api_tooltip->translation->language:it SET text = "Per Harvest time tracking";
RELATE i18n_key:credential_type_harvest_api_tooltip->translation->language:de SET text = "Für Harvest Zeiterfassung";
RELATE i18n_key:credential_type_harvest_api_tooltip->translation->language:es SET text = "Para Harvest time tracking";

-- HARVEST OAUTH2 API
RELATE i18n_key:credential_type_harvest_oauth2_api_name->translation->language:fr SET text = "Harvest OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_name->translation->language:en SET text = "Harvest OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_name->translation->language:it SET text = "Harvest OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_name->translation->language:de SET text = "Harvest OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_name->translation->language:es SET text = "Harvest OAuth2";

RELATE i18n_key:credential_type_harvest_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Harvest. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_harvest_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Harvest. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_harvest_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Harvest. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_harvest_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Harvest. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_harvest_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Harvest. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_harvest_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Harvest avec OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_tooltip->translation->language:en SET text = "For third-party Harvest apps with OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Harvest con OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Harvest-Apps mit OAuth2";
RELATE i18n_key:credential_type_harvest_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Harvest con OAuth2";

-- CLOCKIFY API
RELATE i18n_key:credential_type_clockify_api_name->translation->language:fr SET text = "Clockify API";
RELATE i18n_key:credential_type_clockify_api_name->translation->language:en SET text = "Clockify API";
RELATE i18n_key:credential_type_clockify_api_name->translation->language:it SET text = "Clockify API";
RELATE i18n_key:credential_type_clockify_api_name->translation->language:de SET text = "Clockify API";
RELATE i18n_key:credential_type_clockify_api_name->translation->language:es SET text = "Clockify API";

RELATE i18n_key:credential_type_clockify_api_description->translation->language:fr SET text = "Authentification par clé API pour Clockify. Time tracker gratuit pour équipes avec workspaces et projets illimités.";
RELATE i18n_key:credential_type_clockify_api_description->translation->language:en SET text = "API key authentication for Clockify. Free time tracker for teams with unlimited workspaces and projects.";
RELATE i18n_key:credential_type_clockify_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Clockify. Time tracker gratuito per team con workspace e progetti illimitati.";
RELATE i18n_key:credential_type_clockify_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Clockify. Kostenloser Time Tracker für Teams mit unbegrenzten Workspaces und Projekten.";
RELATE i18n_key:credential_type_clockify_api_description->translation->language:es SET text = "Autenticación mediante clave API para Clockify. Time tracker gratuito para equipos con workspaces y proyectos ilimitados.";

RELATE i18n_key:credential_type_clockify_api_tooltip->translation->language:fr SET text = "Pour Clockify time tracking gratuit";
RELATE i18n_key:credential_type_clockify_api_tooltip->translation->language:en SET text = "For Clockify free time tracking";
RELATE i18n_key:credential_type_clockify_api_tooltip->translation->language:it SET text = "Per Clockify time tracking gratuito";
RELATE i18n_key:credential_type_clockify_api_tooltip->translation->language:de SET text = "Für Clockify kostenlose Zeiterfassung";
RELATE i18n_key:credential_type_clockify_api_tooltip->translation->language:es SET text = "Para Clockify time tracking gratuito";

-- TOGGL API
RELATE i18n_key:credential_type_toggl_api_name->translation->language:fr SET text = "Toggl API";
RELATE i18n_key:credential_type_toggl_api_name->translation->language:en SET text = "Toggl API";
RELATE i18n_key:credential_type_toggl_api_name->translation->language:it SET text = "Toggl API";
RELATE i18n_key:credential_type_toggl_api_name->translation->language:de SET text = "Toggl API";
RELATE i18n_key:credential_type_toggl_api_name->translation->language:es SET text = "Toggl API";

RELATE i18n_key:credential_type_toggl_api_description->translation->language:fr SET text = "Authentification par email et mot de passe pour Toggl. Time tracker simple et rapide pour freelances et équipes.";
RELATE i18n_key:credential_type_toggl_api_description->translation->language:en SET text = "Email and password authentication for Toggl. Simple and fast time tracker for freelancers and teams.";
RELATE i18n_key:credential_type_toggl_api_description->translation->language:it SET text = "Autenticazione tramite email e password per Toggl. Time tracker semplice e veloce per freelance e team.";
RELATE i18n_key:credential_type_toggl_api_description->translation->language:de SET text = "E-Mail- und Passwort-Authentifizierung für Toggl. Einfacher und schneller Time Tracker für Freelancer und Teams.";
RELATE i18n_key:credential_type_toggl_api_description->translation->language:es SET text = "Autenticación mediante email y contraseña para Toggl. Time tracker simple y rápido para freelancers y equipos.";

RELATE i18n_key:credential_type_toggl_api_tooltip->translation->language:fr SET text = "Pour Toggl time tracking simple";
RELATE i18n_key:credential_type_toggl_api_tooltip->translation->language:en SET text = "For Toggl simple time tracking";
RELATE i18n_key:credential_type_toggl_api_tooltip->translation->language:it SET text = "Per Toggl time tracking semplice";
RELATE i18n_key:credential_type_toggl_api_tooltip->translation->language:de SET text = "Für Toggl einfache Zeiterfassung";
RELATE i18n_key:credential_type_toggl_api_tooltip->translation->language:es SET text = "Para Toggl time tracking simple";

-- BAMBOOHR API
RELATE i18n_key:credential_type_bamboohr_api_name->translation->language:fr SET text = "BambooHR API";
RELATE i18n_key:credential_type_bamboohr_api_name->translation->language:en SET text = "BambooHR API";
RELATE i18n_key:credential_type_bamboohr_api_name->translation->language:it SET text = "BambooHR API";
RELATE i18n_key:credential_type_bamboohr_api_name->translation->language:de SET text = "BambooHR API";
RELATE i18n_key:credential_type_bamboohr_api_name->translation->language:es SET text = "BambooHR API";

RELATE i18n_key:credential_type_bamboohr_api_description->translation->language:fr SET text = "Authentification par clé API pour BambooHR. Logiciel RH et gestion employés pour PME avec base données employés.";
RELATE i18n_key:credential_type_bamboohr_api_description->translation->language:en SET text = "API key authentication for BambooHR. HR software and employee management for SMEs with employee database.";
RELATE i18n_key:credential_type_bamboohr_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per BambooHR. Software HR e gestione dipendenti per PMI con database dipendenti.";
RELATE i18n_key:credential_type_bamboohr_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für BambooHR. HR-Software und Mitarbeiterverwaltung für KMU mit Mitarbeiterdatenbank.";
RELATE i18n_key:credential_type_bamboohr_api_description->translation->language:es SET text = "Autenticación mediante clave API para BambooHR. Software RRHH y gestión empleados para PYMES con base datos empleados.";

RELATE i18n_key:credential_type_bamboohr_api_tooltip->translation->language:fr SET text = "Pour BambooHR gestion RH";
RELATE i18n_key:credential_type_bamboohr_api_tooltip->translation->language:en SET text = "For BambooHR HR management";
RELATE i18n_key:credential_type_bamboohr_api_tooltip->translation->language:it SET text = "Per BambooHR gestione HR";
RELATE i18n_key:credential_type_bamboohr_api_tooltip->translation->language:de SET text = "Für BambooHR HR-Verwaltung";
RELATE i18n_key:credential_type_bamboohr_api_tooltip->translation->language:es SET text = "Para BambooHR gestión RRHH";

-- WORKABLE API
RELATE i18n_key:credential_type_workable_api_name->translation->language:fr SET text = "Workable API";
RELATE i18n_key:credential_type_workable_api_name->translation->language:en SET text = "Workable API";
RELATE i18n_key:credential_type_workable_api_name->translation->language:it SET text = "Workable API";
RELATE i18n_key:credential_type_workable_api_name->translation->language:de SET text = "Workable API";
RELATE i18n_key:credential_type_workable_api_name->translation->language:es SET text = "Workable API";

RELATE i18n_key:credential_type_workable_api_description->translation->language:fr SET text = "Authentification par token pour Workable. Plateforme recrutement et ATS (Applicant Tracking System) pour processus embauche.";
RELATE i18n_key:credential_type_workable_api_description->translation->language:en SET text = "Token authentication for Workable. Recruiting platform and ATS (Applicant Tracking System) for hiring process.";
RELATE i18n_key:credential_type_workable_api_description->translation->language:it SET text = "Autenticazione tramite token per Workable. Piattaforma recruiting e ATS (Applicant Tracking System) per processo assunzione.";
RELATE i18n_key:credential_type_workable_api_description->translation->language:de SET text = "Token-Authentifizierung für Workable. Recruiting-Plattform und ATS (Applicant Tracking System) für Einstellungsprozess.";
RELATE i18n_key:credential_type_workable_api_description->translation->language:es SET text = "Autenticación mediante token para Workable. Plataforma reclutamiento y ATS (Applicant Tracking System) para proceso contratación.";

RELATE i18n_key:credential_type_workable_api_tooltip->translation->language:fr SET text = "Pour Workable recrutement ATS";
RELATE i18n_key:credential_type_workable_api_tooltip->translation->language:en SET text = "For Workable recruiting ATS";
RELATE i18n_key:credential_type_workable_api_tooltip->translation->language:it SET text = "Per Workable recruiting ATS";
RELATE i18n_key:credential_type_workable_api_tooltip->translation->language:de SET text = "Für Workable Recruiting ATS";
RELATE i18n_key:credential_type_workable_api_tooltip->translation->language:es SET text = "Para Workable reclutamiento ATS";

-- =============================================================================================

