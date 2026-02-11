# 📦 Catalogue Complet des Nœuds n8n

> **Date de l'audit**: Janvier 2026  
> **Source**: `n8n-master/packages/nodes-base/nodes/` et `@n8n/nodes-langchain/nodes/`  
> **Total**: 300+ types de nœuds

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Nœuds par catégorie](#nœuds-par-catégorie)
   - [🔄 Core / Flow Control](#-core--flow-control)
   - [📅 Triggers (Déclencheurs)](#-triggers-déclencheurs)
   - [💬 Communication & Messaging](#-communication--messaging)
   - [📧 Email](#-email)
   - [📁 Files & Storage](#-files--storage)
   - [🗄️ Databases](#️-databases)
   - [☁️ Cloud Providers](#️-cloud-providers)
   - [📊 CRM & Sales](#-crm--sales)
   - [📈 Marketing & Analytics](#-marketing--analytics)
   - [🎫 Project Management](#-project-management)
   - [💳 Payments & Finance](#-payments--finance)
   - [🛒 E-Commerce](#-e-commerce)
   - [🔧 Developer Tools](#-developer-tools)
   - [🔐 Security & Identity](#-security--identity)
   - [📝 Content & Documents](#-content--documents)
   - [🤖 AI & Machine Learning](#-ai--machine-learning)
   - [🌐 Web & API](#-web--api)
   - [📞 Voice & SMS](#-voice--sms)
   - [🏠 IoT & Home Automation](#-iot--home-automation)
   - [📡 Autres](#-autres)
3. [Nœuds AI/LangChain](#nœuds-ailangchain)
4. [Résumé statistique](#résumé-statistique)

---

## Vue d'ensemble

n8n propose deux types principaux de nœuds:

| Type | Description | Exemple |
|------|-------------|---------|
| **Trigger** | Déclenche un workflow (entrée) | Webhook, Schedule, Email Trigger |
| **Action** | Effectue une opération (traitement) | HTTP Request, Send Email, Create Record |

### Structure d'un nœud

Chaque nœud possède:
- **displayName**: Nom affiché dans l'UI
- **name**: Identifiant technique (ex: `slack`)
- **description**: Ce que fait le nœud
- **group**: `input` (trigger), `output` (action), `transform`
- **version**: Versioning sémantique

---

## Nœuds par catégorie

---

# 🔄 Core / Flow Control

Nœuds fondamentaux pour le contrôle du flux d'exécution.

| Nœud | Description | Cas d'usage |
|------|-------------|-------------|
| **If** | Condition if/else | Routage conditionnel des données |
| **Switch** | Routage multiple | Choisir parmi plusieurs branches |
| **Merge** | Fusionner des branches | Combiner les résultats de branches parallèles |
| **SplitInBatches** | Découper en lots | Traiter de gros volumes par morceaux |
| **Wait** | Attendre | Pause temporelle ou attente d'événement |
| **NoOp** | Ne rien faire | Placeholder, documentation |
| **StopAndError** | Arrêter avec erreur | Forcer l'échec d'un workflow |
| **Execute Workflow** | Lancer un autre workflow | Modularisation, sous-workflows |
| **Execute Command** | Commande système | Exécuter scripts shell/bash |
| **Execution Data** | Données d'exécution | Accéder aux métadonnées de l'exécution |
| **Error Trigger** | Déclenché sur erreur | Gestion centralisée des erreurs |
| **Code** | Code JavaScript/Python | Logique personnalisée |
| **Function** | JavaScript (deprecated) | Remplacé par Code |
| **FunctionItem** | JavaScript par item (deprecated) | Remplacé par Code |
| **Set** | Définir des valeurs | Ajouter/modifier des champs |
| **RenameKeys** | Renommer des clés | Transformer la structure des données |
| **ItemLists** | Manipuler les listes | Split, concat, limit, sort |
| **Compare Datasets** | Comparer des datasets | Trouver différences entre deux sources |
| **Filter** | Filtrer les données | Exclure des items selon critères |
| **Transform** | Transformer les données | Mapping complexe |
| **Compression** | Compresser/décompresser | Zip, gzip de fichiers |
| **Crypto** | Chiffrer/hasher | SHA, MD5, AES, RSA |
| **DateTime** | Manipuler dates | Parser, formater, calculer |
| **Simulate** | Simuler des données | Tests, démo |
| **Debug Helper** | Aide au debug | Logging, inspection |
| **Sticky Note** | Note visuelle | Documentation dans le canvas |
| **AI Transform** | Transformation IA | Utiliser LLM pour transformer |
| **Time Saved** | Tracker le temps | Métriques d'automatisation |

---

# 📅 Triggers (Déclencheurs)

Nœuds qui démarrent l'exécution d'un workflow.

| Nœud | Description |
|------|-------------|
| **Manual Trigger** | Déclenché manuellement |
| **Schedule Trigger** | Cron/intervalle programmé |
| **Cron** | (deprecated) → Schedule Trigger |
| **Interval** | (deprecated) → Schedule Trigger |
| **Webhook** | Réception HTTP |
| **n8n Trigger** | Événements internes n8n |
| **Workflow Trigger** | Appelé par Execute Workflow |
| **Error Trigger** | Erreur dans un workflow |
| **Local File Trigger** | Surveillance fichier local |
| **SSE Trigger** | Server-Sent Events |
| **Email Read IMAP** | Nouveaux emails (polling) |
| **Form Trigger** | Formulaire web intégré |

### Triggers par service

| Service | Triggers disponibles |
|---------|---------------------|
| **Google** | Calendar, Drive, Gmail, Sheets, Business Profile |
| **Microsoft** | OneDrive, Outlook, Teams |
| **AWS** | SNS |
| **Slack** | (via webhook) |
| **Telegram** | Messages, updates |
| **GitHub** | Webhooks (push, PR, issues) |
| **GitLab** | Webhooks |
| **Stripe** | Webhooks (paiements) |
| **Shopify** | Webhooks (commandes) |
| **HubSpot** | Webhooks |
| **Jira** | Webhooks |
| **Typeform** | Réponses de formulaire |
| **Airtable** | Nouveaux records |
| **Notion** | Changements de page |
| **Discord** | Messages |
| **WhatsApp** | Messages entrants |
| **Facebook** | Lead Ads |

---

# 💬 Communication & Messaging

| Nœud | Description |
|------|-------------|
| **Slack** | Envoyer messages, gérer canaux, utilisateurs |
| **Discord** | Messages, embeds, gestion serveur |
| **Telegram** | Messages, bots, inline queries |
| **WhatsApp** | Business API - messages, templates |
| **Mattermost** | Alternative open-source à Slack |
| **Rocket.Chat** | Messagerie self-hosted |
| **Microsoft Teams** | Messages, canaux, meetings |
| **Matrix** | Messagerie décentralisée |
| **Zulip** | Messagerie en threads |
| **Line** | Messaging app asiatique |
| **Intercom** | Support client |
| **Drift** | Chatbot et live chat |
| **Twake** | Collaboration française |
| **Twist** | Communication asynchrone |

---

# 📧 Email

| Nœud | Description |
|------|-------------|
| **Gmail** | Lire, envoyer, gérer emails Google |
| **Microsoft Outlook** | Email Microsoft 365 |
| **IMAP Email Read** | Lire depuis serveur IMAP |
| **Email Send (SMTP)** | Envoyer via SMTP |
| **SendGrid** | Email transactionnel |
| **Mailchimp** | Marketing email, listes |
| **Mailgun** | API email |
| **Mailjet** | Email & SMS |
| **Mandrill** | Email via Mailchimp |
| **Postmark** | Email transactionnel |
| **Sendy** | Newsletter self-hosted |
| **ConvertKit** | Marketing pour créateurs |
| **MailerLite** | Newsletter simplifiée |
| **Brevo** | Ex-Sendinblue, marketing |
| **GetResponse** | Marketing automation |
| **Iterable** | Marketing multicanal |
| **Customer.io** | Messaging automation |
| **ActiveCampaign** | CRM + email |
| **Emelia** | Cold emailing |
| **Lemlist** | Cold outreach |

---

# 📁 Files & Storage

| Nœud | Description |
|------|-------------|
| **Google Drive** | Fichiers, dossiers, permissions |
| **Microsoft OneDrive** | Stockage Microsoft |
| **Dropbox** | Stockage cloud |
| **Box** | Stockage entreprise |
| **NextCloud** | Cloud self-hosted |
| **FTP** | Transfert FTP/SFTP |
| **SSH** | Commandes distantes |
| **S3** | Amazon S3 & compatibles |
| **Google Cloud Storage** | GCS |
| **Azure Storage** | Blob storage |
| **Read Binary File** | Lire fichier local |
| **Write Binary File** | Écrire fichier local |
| **Move Binary Data** | Convertir base64 ↔ binary |
| **Spreadsheet File** | Lire/écrire Excel, CSV, ODS |
| **Read PDF** | Extraire texte de PDF |
| **Extract from File** | Parser divers formats |
| **Files** | Opérations sur fichiers n8n |

---

# 🗄️ Databases

| Nœud | Description |
|------|-------------|
| **PostgreSQL** | Query, insert, update |
| **MySQL** | Base relationnelle |
| **Microsoft SQL Server** | SQL Server |
| **Oracle** | Oracle Database |
| **MongoDB** | Base NoSQL |
| **Redis** | Cache/queue |
| **Elasticsearch** | Recherche |
| **Supabase** | Postgres + API |
| **Airtable** | Spreadsheet-database |
| **NocoDB** | Airtable open-source |
| **Baserow** | No-code database |
| **Google BigQuery** | Data warehouse |
| **Snowflake** | Cloud data platform |
| **AWS DynamoDB** | NoSQL AWS |
| **Azure Cosmos DB** | Multi-model Azure |
| **Google Firestore** | NoSQL Firebase |
| **Firebase Realtime DB** | Real-time database |
| **CrateDB** | Distributed SQL |
| **QuestDB** | Time series |
| **TimescaleDB** | Time series Postgres |
| **Grist** | Spreadsheet + relations |
| **SeaTable** | Airtable alternative |
| **Stackby** | Spreadsheet DB |
| **QuickBase** | Low-code platform |

---

# ☁️ Cloud Providers

## Google Cloud

| Nœud | Description |
|------|-------------|
| **Google Drive** | Storage |
| **Google Sheets** | Spreadsheets |
| **Google Docs** | Documents |
| **Google Slides** | Presentations |
| **Google Calendar** | Agenda |
| **Google Contacts** | Contacts |
| **Google Tasks** | Tâches |
| **Gmail** | Email |
| **Google Chat** | Messaging workspace |
| **Google BigQuery** | Data warehouse |
| **Google Ads** | Publicité |
| **Google Analytics** | Web analytics |
| **Google Cloud Storage** | Object storage |
| **Google Cloud Natural Language** | NLP |
| **Google Perspective** | Content moderation |
| **Google Translate** | Traduction |
| **Google Books** | API Books |
| **YouTube** | Vidéos, playlists |
| **Google Business Profile** | Fiches entreprise |
| **GSuite Admin** | Administration |
| **Firebase Firestore** | NoSQL |
| **Firebase Realtime Database** | Real-time |

## Microsoft Azure / 365

| Nœud | Description |
|------|-------------|
| **Microsoft Excel** | Spreadsheets |
| **Microsoft OneDrive** | Storage |
| **Microsoft Outlook** | Email |
| **Microsoft Teams** | Collaboration |
| **Microsoft SharePoint** | Intranet |
| **Microsoft To Do** | Tâches |
| **Microsoft Dynamics CRM** | CRM |
| **Microsoft Entra** | Identity (ex-Azure AD) |
| **Microsoft Graph Security** | Security API |
| **Azure Storage** | Blob storage |
| **Azure Cosmos DB** | Multi-model DB |
| **Microsoft SQL Server** | Database |

## Amazon Web Services

| Nœud | Description |
|------|-------------|
| **AWS S3** | Object storage |
| **AWS Lambda** | Serverless functions |
| **AWS SNS** | Notifications |
| **AWS SQS** | Queue |
| **AWS SES** | Email |
| **AWS DynamoDB** | NoSQL |
| **AWS Cognito** | Authentication |
| **AWS IAM** | Permissions |
| **AWS Comprehend** | NLP |
| **AWS Rekognition** | Image analysis |
| **AWS Textract** | OCR |
| **AWS Transcribe** | Speech-to-text |
| **AWS Certificate Manager** | SSL |
| **AWS ELB** | Load balancer |

---

# 📊 CRM & Sales

| Nœud | Description |
|------|-------------|
| **HubSpot** | CRM tout-en-un |
| **Salesforce** | Enterprise CRM |
| **Pipedrive** | CRM commercial |
| **Zoho CRM** | Suite Zoho |
| **Copper** | CRM pour Google |
| **Freshworks CRM** | Freshsales |
| **Microsoft Dynamics** | CRM Microsoft |
| **Agile CRM** | CRM léger |
| **Monica CRM** | CRM personnel |
| **Affinity** | Relationship intelligence |
| **Keap** | Ex-Infusionsoft |
| **Salesmate** | CRM commercial |
| **HighLevel** | Marketing agency |
| **Close** | CRM pour startups |

---

# 📈 Marketing & Analytics

| Nœud | Description |
|------|-------------|
| **Google Analytics** | Web analytics |
| **Segment** | Customer data platform |
| **Mixpanel** | Product analytics |
| **PostHog** | Open-source analytics |
| **Autopilot** | Marketing automation |
| **Mautic** | Open-source marketing |
| **Vero** | Email behavior |
| **Tapfiliate** | Affiliate tracking |
| **LoneScale** | B2B data |
| **Clearbit** | Data enrichment |
| **Hunter** | Email finder |
| **Uplead** | B2B leads |
| **Phantombuster** | Scraping automation |
| **UProc** | Data processing |

---

# 🎫 Project Management

| Nœud | Description |
|------|-------------|
| **Notion** | All-in-one workspace |
| **Asana** | Project management |
| **Trello** | Kanban boards |
| **Jira** | Issue tracking |
| **Linear** | Modern issue tracker |
| **ClickUp** | Productivity platform |
| **Monday.com** | Work OS |
| **Todoist** | Task management |
| **Basecamp** | Team collaboration |
| **Taiga** | Agile open-source |
| **Wekan** | Kanban open-source |
| **Clockify** | Time tracking |
| **Toggl** | Time tracking |
| **Harvest** | Time & invoicing |
| **Flow** | Task management |
| **Workable** | Recruiting |

---

# 💳 Payments & Finance

| Nœud | Description |
|------|-------------|
| **Stripe** | Paiements en ligne |
| **PayPal** | Paiement |
| **Chargebee** | Subscription billing |
| **ProfitWell** | Revenue metrics |
| **Invoice Ninja** | Facturation |
| **Xero** | Comptabilité |
| **QuickBooks** | Comptabilité |
| **Wise** | Transferts internationaux |
| **Paddle** | SaaS billing |
| **Gumroad** | Vente de produits |

---

# 🛒 E-Commerce

| Nœud | Description |
|------|-------------|
| **Shopify** | Plateforme e-commerce |
| **WooCommerce** | WordPress e-commerce |
| **Magento** | E-commerce enterprise |
| **Webflow** | Site + e-commerce |
| **Gumroad** | Vente digitale |
| **Unleashed Software** | Inventory |

---

# 🔧 Developer Tools

| Nœud | Description |
|------|-------------|
| **GitHub** | Repos, issues, PRs |
| **GitLab** | DevOps platform |
| **Bitbucket** | Git Atlassian |
| **Git** | Opérations Git locales |
| **Jenkins** | CI/CD |
| **CircleCI** | CI/CD cloud |
| **Travis CI** | CI/CD |
| **Netlify** | Hosting static |
| **Sentry** | Error monitoring |
| **Grafana** | Monitoring |
| **Splunk** | Log analysis |
| **Rundeck** | Operations automation |
| **NPM** | Package registry |
| **PostBin** | Request debugging |

---

# 🔐 Security & Identity

| Nœud | Description |
|------|-------------|
| **JWT** | Token generation/validation |
| **TOTP** | 2FA codes |
| **LDAP** | Directory services |
| **Okta** | Identity management |
| **Microsoft Entra** | Azure AD |
| **AWS Cognito** | Auth AWS |
| **AWS IAM** | Permissions AWS |
| **Bitwarden** | Password manager |
| **TheHive** | Security incident |
| **MISP** | Threat intelligence |
| **Cortex** | Security automation |
| **UrlScan.io** | URL analysis |
| **Venafi** | Certificate management |
| **Security Scorecard** | Risk assessment |

---

# 📝 Content & Documents

| Nœud | Description |
|------|-------------|
| **Google Docs** | Documents |
| **Google Slides** | Présentations |
| **Notion** | Notes & wikis |
| **Contentful** | Headless CMS |
| **Ghost** | Blogging |
| **WordPress** | CMS |
| **Strapi** | Headless CMS |
| **Storyblok** | Visual CMS |
| **Medium** | Publishing |
| **Coda** | Docs + apps |
| **Markdown** | Parser/converter |
| **HTML** | Parse/generate |
| **XML** | Parse/generate |
| **PDF Read** | Extract text |
| **Edit Image** | Manipulation images |
| **Bannerbear** | Image generation |
| **ApiTemplate.io** | PDF/image templates |
| **Figma** | Design tool |
| **Mindee** | Document AI |
| **DeepL** | Translation |
| **LingvaNex** | Translation |
| **OpenThesaurus** | Synonyms |

---

# 🤖 AI & Machine Learning

## Nœuds principaux

| Nœud | Description |
|------|-------------|
| **OpenAI** | GPT, DALL-E, Whisper |
| **Mistral AI** | LLM européen |
| **Perplexity** | Recherche IA |
| **Humanistic AI** | Personality analysis |
| **Google Cloud Natural Language** | NLP |
| **Google Perspective** | Content moderation |
| **AWS Comprehend** | NLP |
| **AWS Rekognition** | Vision |
| **AWS Textract** | OCR |
| **AWS Transcribe** | Speech-to-text |
| **AI Transform** | Transformation IA générale |

## Package nodes-langchain (IA avancée)

| Catégorie | Description |
|-----------|-------------|
| **agents** | Agents autonomes (ReAct, OpenAI Functions) |
| **chains** | Chaînes LLM (conversation, QA, summarization) |
| **llms** | Connecteurs LLM (OpenAI, Anthropic, Cohere, etc.) |
| **embeddings** | Vecteurs de texte |
| **vector_store** | Bases vectorielles (Pinecone, Qdrant, Weaviate) |
| **document_loaders** | Chargeurs de documents |
| **text_splitters** | Découpage de texte |
| **memory** | Mémoire conversationnelle |
| **retrievers** | Recherche sémantique |
| **rerankers** | Re-ranking de résultats |
| **tools** | Outils pour agents |
| **output_parser** | Parsing de réponses LLM |
| **mcp** | Model Context Protocol |
| **Guardrails** | Validation de sorties IA |
| **Model Selector** | Sélection dynamique de modèle |
| **Tool Executor** | Exécution d'outils |
| **vendors** | Implémentations par fournisseur |

---

# 🌐 Web & API

| Nœud | Description |
|------|-------------|
| **HTTP Request** | Appels REST/HTTP |
| **Webhook** | Réception de requêtes |
| **Respond to Webhook** | Réponse HTTP personnalisée |
| **GraphQL** | Requêtes GraphQL |
| **RSS Feed Read** | Lecture de flux RSS |
| **HTML Extract** | Web scraping |
| **Jina AI** | Web content extraction |
| **Peekalink** | Link preview |
| **Yourls** | URL shortener |

---

# 📞 Voice & SMS

| Nœud | Description |
|------|-------------|
| **Twilio** | SMS, Voice, WhatsApp |
| **Vonage** | Communications API |
| **Plivo** | SMS, Voice |
| **MessageBird** | Omnichannel |
| **Msg91** | SMS India |
| **Mocean** | SMS Malaysia |
| **Sms77** | SMS Germany |
| **Signl4** | Alerting mobile |
| **Pushover** | Notifications push |
| **Pushbullet** | Cross-device push |
| **Pushcut** | iOS automation |
| **Gotify** | Self-hosted push |

---

# 🏠 IoT & Home Automation

| Nœud | Description |
|------|-------------|
| **Home Assistant** | Domotique open-source |
| **Philips Hue** | Éclairage connecté |
| **MQTT** | Protocole IoT |

---

# 📡 Autres Services

| Nœud | Description |
|------|-------------|
| **NASA** | API NASA |
| **OpenWeatherMap** | Météo |
| **CoinGecko** | Crypto prices |
| **Marketstack** | Stock data |
| **HackerNews** | Tech news |
| **Reddit** | Social media |
| **Twitter/X** | Social media |
| **LinkedIn** | Réseau pro |
| **Facebook** | Meta APIs |
| **Spotify** | Musique |
| **Strava** | Fitness |
| **Oura** | Health ring |
| **Beeminder** | Goal tracking |
| **Cal.com** | Scheduling |
| **Calendly** | Scheduling |
| **Acuity Scheduling** | Appointments |
| **Eventbrite** | Events |
| **GoToWebinar** | Webinars |
| **Demio** | Webinars |
| **SurveyMonkey** | Surveys |
| **Typeform** | Forms |
| **JotForm** | Forms |
| **Formstack** | Forms |
| **Form.io** | Form builder |
| **KoBoToolbox** | Field data |
| **Wufoo** | Forms |
| **DHL** | Shipping |
| **Onfleet** | Delivery |
| **Gong** | Revenue intelligence |

---

## Résumé statistique

### Par package

| Package | Nombre de nœuds |
|---------|-----------------|
| **nodes-base** | ~300 |
| **nodes-langchain** | ~50+ |
| **Total** | ~350+ |

### Par catégorie majeure

| Catégorie | Approx. |
|-----------|---------|
| Core/Flow Control | 30 |
| Triggers | 40+ |
| Communication | 20 |
| Email | 25 |
| Files/Storage | 20 |
| Databases | 25 |
| Cloud (Google) | 25 |
| Cloud (Microsoft) | 15 |
| Cloud (AWS) | 17 |
| CRM/Sales | 15 |
| Marketing | 15 |
| Project Management | 20 |
| Payments | 10 |
| E-Commerce | 6 |
| Developer Tools | 15 |
| Security | 15 |
| Content/Docs | 25 |
| AI/ML | 50+ |
| Web/API | 10 |
| Voice/SMS | 15 |
| IoT | 3 |
| Autres | 30 |

---

## Liste alphabétique complète

<details>
<summary>Cliquer pour voir les 303 catégories de nœuds</summary>

```
ActionNetwork, ActiveCampaign, AcuityScheduling, Adalo, Affinity, 
AgileCrm, AiTransform, Airtable, Airtop, Amqp, ApiTemplateIo, Asana, 
Autopilot, Aws, BambooHr, Bannerbear, Baserow, Beeminder, Bitbucket, 
Bitly, Bitwarden, Box, Brandfetch, Brevo, Bubble, Cal, Calendly, 
Chargebee, CircleCi, Cisco, Clearbit, ClickUp, Clockify, Cloudflare, 
Cockpit, Coda, Code, CoinGecko, CompareDatasets, Compression, 
Contentful, ConvertKit, Copper, Cortex, CrateDb, Cron, Crypto, 
CustomerIo, DataTable, DateTime, DebugHelper, DeepL, Demio, Dhl, 
Discord, Discourse, Disqus, Drift, Dropbox, Dropcontact, E2eTest, 
ERPNext, EditImage, Egoi, Elastic, EmailReadImap, EmailSend, Emelia, 
ErrorTrigger, Evaluation, Eventbrite, ExecuteCommand, ExecuteWorkflow, 
ExecutionData, Facebook, FacebookLeadAds, Figma, FileMaker, Files, 
Filter, Flow, Form, FormIo, Formstack, Freshdesk, Freshservice, 
FreshworksCrm, Ftp, Function, FunctionItem, GetResponse, Ghost, 
Git, Github, Gitlab, GoToWebinar, Gong, Google, Gotify, Grafana, 
GraphQL, Grist, Gumroad, HackerNews, HaloPSA, Harvest, HelpScout, 
HighLevel, HomeAssistant, Html, HtmlExtract, HttpRequest, Hubspot, 
HumanticAI, Hunter, ICalendar, If, Intercom, Interval, InvoiceNinja, 
ItemLists, Iterable, Jenkins, JinaAI, Jira, JotForm, Jwt, Kafka, 
Keap, KoBoToolbox, Ldap, Lemlist, Line, Linear, LingvaNex, LinkedIn, 
LocalFileTrigger, LoneScale, MQTT, Magento, Mailcheck, Mailchimp, 
MailerLite, Mailgun, Mailjet, Mandrill, ManualTrigger, Markdown, 
Marketstack, Matrix, Mattermost, Mautic, Medium, Merge, MessageBird, 
Metabase, Microsoft, Mindee, Misp, MistralAI, Mocean, MondayCom, 
MongoDb, MonicaCrm, MoveBinaryData, Msg91, MySql, N8n, 
N8nTrainingCustomerDatastore, N8nTrainingCustomerMessenger, N8nTrigger, 
Nasa, Netlify, Netscaler, NextCloud, NoOp, NocoDB, Notion, Npm, 
Odoo, Okta, OneSimpleApi, Onfleet, OpenAi, OpenThesaurus, 
OpenWeatherMap, Oracle, Orbit, Oura, Paddle, PagerDuty, PayPal, 
Peekalink, Perplexity, Phantombuster, PhilipsHue, Pipedrive, Plivo, 
PostBin, PostHog, Postgres, Postmark, ProfitWell, Pushbullet, 
Pushcut, Pushover, QuestDb, QuickBase, QuickBooks, QuickChart, 
RabbitMQ, Raindrop, ReadBinaryFile, ReadBinaryFiles, ReadPdf, Reddit, 
Redis, RenameKeys, RespondToWebhook, Rocketchat, RssFeedRead, 
Rundeck, S3, Salesforce, Salesmate, Schedule, SeaTable, 
SecurityScorecard, Segment, SendGrid, Sendy, SentryIo, ServiceNow, 
Set, Shopify, Signl4, Simulate, Slack, Sms77, Snowflake, 
SplitInBatches, Splunk, Spotify, SpreadsheetFile, SseTrigger, Ssh, 
Stackby, StickyNote, StopAndError, Storyblok, Strapi, Strava, 
Stripe, Supabase, SurveyMonkey, Switch, SyncroMSP, Taiga, Tapfiliate, 
Telegram, TheHive, TheHiveProject, TimeSaved, TimescaleDb, Todoist, 
Toggl, Totp, Transform, TravisCi, Trello, Twake, Twilio, Twist, 
Twitter, Typeform, UProc, UnleashedSoftware, Uplead, UptimeRobot, 
UrlScanIo, Venafi, Vero, Vonage, Wait, Webflow, Webhook, Wekan, 
WhatsApp, Wise, WooCommerce, Wordpress, Workable, WorkflowTrigger, 
WriteBinaryFile, Wufoo, Xero, Xml, Yourls, Zammad, Zendesk, Zoho, 
Zoom, Zulip
```

</details>

---

## Fichiers sources

- **Nœuds de base**: [`packages/nodes-base/nodes/`](file:///C:/Users/Administrator/Downloads/Lyxal_Solution-main/n8n-master/packages/nodes-base/nodes)
- **Nœuds AI/LangChain**: [`packages/@n8n/nodes-langchain/nodes/`](file:///C:/Users/Administrator/Downloads/Lyxal_Solution-main/n8n-master/packages/@n8n/nodes-langchain/nodes)
- **Credentials**: [`packages/nodes-base/credentials/`](file:///C:/Users/Administrator/Downloads/Lyxal_Solution-main/n8n-master/packages/nodes-base/credentials)
