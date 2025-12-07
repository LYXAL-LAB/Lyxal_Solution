# Cal.com Integrations - Direction d'intégration

## 📥 **Cal.com CONSOMME** (Outbound - Cal.com utilise ces services)

Cal.com se connecte à ces services pour lire/écrire des données ou utiliser leurs fonctionnalités.

### 📅 Calendriers Externes
Cal.com **lit** les disponibilités et **écrit** les événements dans ces calendriers :
- **Google Calendar** (`googlecalendar`) - Sync bidirectionnel
- **Outlook / Office 365** (`office365calendar`, `exchangecalendar`) - Sync bidirectionnel
- **Apple Calendar** (`applecalendar`) - Sync
- **CalDAV** (`caldavcalendar`) - Protocole standard
- **Lark Calendar** (`larkcalendar`)
- **Zoho Calendar** (`zohocalendar`)
- **Feishu Calendar** (`feishucalendar`)

### 🎥 Vidéoconférence
Cal.com **crée** des liens de réunion via ces plateformes :
- **Zoom** (`zoomvideo`) - Création de meetings
- **Google Meet** (`googlevideo`) - Création de meetings
- **Microsoft Teams** (`office365video`) - Création de meetings
- **Daily.co** (`dailyvideo`) - Embedded video
- **Jitsi** (`jitsivideo`)
- **Whereby** (`whereby`)
- **Webex** (`webex`)
- **Huddle01** (`huddle01video`)
- **Tandem** (`tandemvideo`)

### 💳 Paiements
Cal.com **initie** des transactions via :
- **Stripe** (`stripepayment`) - Processeur principal
- **PayPal** (`paypal`)
- **HitPay** (`hitpay`)
- **Alby** (`alby`) - Bitcoin Lightning
- **BTCPay Server** (`btcpayserver`)

### 📊 CRM (Customer Data Push)
Cal.com **envoie** les données de réservation vers :
- **Salesforce** (`salesforce`) - Création de leads/contacts
- **HubSpot** (`hubspot`) - Sync de contacts
- **Pipedrive** (`pipedrive-crm`)
- **Zoho CRM** (`zohocrm`)
- **Close.com** (`closecom`)
- **Attio** (`attio`)

### 📈 Analytics (Event Tracking)
Cal.com **envoie** des événements de tracking vers :
- **Google Analytics 4** (`ga4`)
- **Fathom** (`fathom`)
- **Plausible** (`plausible`)
- **Matomo** (`matomo`)
- **PostHog** (`posthog`)
- **Meta Pixel** (`metapixel`)
- **GTM** (`gtm`)

### 🧠 AI Services
Cal.com **utilise** ces services d'IA :
- **Retell AI** (`retell-ai`) - Voice agents
- **ElevenLabs** (`elevenlabs`) - Text-to-speech
- **Synthflow** (`synthflow`)
- **Bolna** (`bolna`)

### 📧 Messaging (Notifications)
Cal.com **envoie** des notifications via :
- **Telegram** (`telegram`)
- **WhatsApp** (`whatsapp`)
- **Signal** (`signal`)
- **Discord** (`discord`)
- **Sendgrid** (email)

---

## 📤 **Cal.com EST CONSOMMÉ** (Inbound - Ces services utilisent Cal.com)

Cal.com **expose** des webhooks, APIs, ou embeds que ces services consomment.

### 🤖 Automation Platforms (Webhooks)
Ces plateformes **reçoivent** des webhooks de Cal.com :
- **Zapier** (`zapier`) - Déclenche des workflows
- **Make.com** (`make`) - Automation
- **n8n** (`n8n`) - Workflow automation
- **Pipedream** (`pipedream`)

### 🌐 Embed / Widget
Cal.com **est intégré** dans :
- **WordPress** (`wordpress`) - Plugin
- **Framer** (`framer`) - Widget
- **Notion** (potentiellement via embed)

### 🔗 API Platform Consumers
Ces services **appellent l'API** de Cal.com :
- **Raycast** (`raycast`) - Extension desktop
- **Roam** (`roam`) - Note-taking app

---

## 🔄 **BIDIRECTIONNEL** (Sync mutuel)

Ces intégrations ont un flux de données dans les deux sens :

### 📅 Calendar Sync
- **Google Calendar** - Cal.com lit les disponibilités ET écrit les bookings
- **Outlook** - Même logique de sync bidirectionnel

### 🏢 Team Tools
- **Basecamp 3** (`basecamp3`) - Peut recevoir des bookings ET notifier Cal.com
- **Linear** (`linear`) - Création de tickets depuis Cal.com, suivi dans Linear

---

## 🛠️ **UTILITAIRES** (Ni consommé ni consommateur, juste enrichissement)

- **Giphy** (`giphy`) - Ajoute des GIFs aux confirmations
- **QR Code** (`qr_code`) - Génère des QR codes pour les événements
- **Weather** (`weather_in_your_calendar`) - Ajoute la météo
- **Vital** (`vital`) - Health data enrichment
