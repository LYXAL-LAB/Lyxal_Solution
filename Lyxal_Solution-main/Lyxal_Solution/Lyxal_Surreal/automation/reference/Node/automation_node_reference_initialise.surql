-- =================================================================================================
-- |
-- | Fichier : automation_node_reference_initialise.surql
-- | Module : automation
-- | Description : Crée les données de référence pour les nodes.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_reference_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'data_reference', 'start', 'automation_node_reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création des données de référence pour les nodes (basé sur n8n)
    -- ============================================================================================

    -- NOTE: Données extraites des fichiers *.node.ts du repository n8n
    fn::automation_node_resources_create('Action Network', 'actionNetwork.svg', 'None');
    fn::automation_node_resources_create('Active Campaign', 'activeCampaign.dark.svg', 'None');
    fn::automation_node_resources_create('Acuity Scheduling', 'acuityScheduling.png', 'None');
    fn::automation_node_resources_create('Adalo', 'adalo.svg', 'None');
    fn::automation_node_resources_create('Affinity', 'affinity.dark.svg', 'None');
    fn::automation_node_resources_create('Agile Crm', 'agilecrm.png', 'None');
    fn::automation_node_resources_create('Ai Transform', 'aitransform.svg', 'None');
    fn::automation_node_resources_create('Airtable', 'airtable.svg', 'None');
    fn::automation_node_resources_create('Airtop', 'airtop.svg', 'None');
    fn::automation_node_resources_create('Amqp', 'amqp.svg', 'None');
    fn::automation_node_resources_create('Api Template Io', 'apiTemplateIo.svg', 'None');
    fn::automation_node_resources_create('Asana', 'asana.svg', 'None');
    fn::automation_node_resources_create('Automizy', 'automizy.png', 'None');
    fn::automation_node_resources_create('Autopilot', 'autopilot.svg', 'None');
    fn::automation_node_resources_create('Aws Lambda', 'lambda.svg', 'None');
    fn::automation_node_resources_create('Aws Sns', 'lambda.svg', 'None');
    fn::automation_node_resources_create('Bamboo Hr', 'bambooHr.png', 'None');
    fn::automation_node_resources_create('Bannerbear', 'bannerbear.png', 'None');
    fn::automation_node_resources_create('Baserow', 'baserow.svg', 'None');
    fn::automation_node_resources_create('Beeminder', 'beeminder.png', 'None');
    fn::automation_node_resources_create('Bitbucket', 'bitbucket.svg', 'None');
    fn::automation_node_resources_create('Bitly', 'bitly.svg', 'None');
    fn::automation_node_resources_create('Bitwarden', 'bitwarden.svg', 'None');
    fn::automation_node_resources_create('Box', 'box.png', 'None');
    fn::automation_node_resources_create('Brandfetch', 'brandfetch.png', 'None');
    fn::automation_node_resources_create('Brevo', 'brevo.svg', 'None');
    fn::automation_node_resources_create('Bubble', 'bubble.dark.svg', 'None');
    fn::automation_node_resources_create('Cal', 'cal.dark.svg', 'None');
    fn::automation_node_resources_create('Calendly', 'calendly.svg', 'None');
    fn::automation_node_resources_create('Chargebee', 'chargebee.png', 'None');
    fn::automation_node_resources_create('Circle Ci', 'circleCi.dark.svg', 'None');
    fn::automation_node_resources_create('Clearbit', 'clearbit.svg', 'None');
    fn::automation_node_resources_create('Click Up', 'clickup.svg', 'None');
    fn::automation_node_resources_create('Clockify', 'clockify.dark.svg', 'None');
    fn::automation_node_resources_create('Cloudflare', 'cloudflare.svg', 'None');
    fn::automation_node_resources_create('Cockpit', 'cockpit.dark.svg', 'None');
    fn::automation_node_resources_create('Coda', 'coda.svg', 'None');
    fn::automation_node_resources_create('Code', 'code.svg', 'None');
    fn::automation_node_resources_create('Coin Gecko', 'coinGecko.svg', 'None');
    fn::automation_node_resources_create('Compare Datasets', 'compare.svg', 'None');
    fn::automation_node_resources_create('Compression', 'None', 'None');
    fn::automation_node_resources_create('Contentful', 'contentful.png', 'None');
    fn::automation_node_resources_create('Convert Kit', 'convertKit.svg', 'None');
    fn::automation_node_resources_create('Copper', 'copper.svg', 'None');
    fn::automation_node_resources_create('Cortex', 'cortex.svg', 'None');
    fn::automation_node_resources_create('Crate Db', 'cratedb.png', 'None');
    fn::automation_node_resources_create('Cron', 'None', 'None');
    fn::automation_node_resources_create('Crowd Dev', 'crowdDev.dark.svg', 'None');
    fn::automation_node_resources_create('Crypto', 'None', 'None');
    fn::automation_node_resources_create('Customer Io', 'customerio.dark.svg', 'None');
    fn::automation_node_resources_create('Data Table', 'None', 'None');
    fn::automation_node_resources_create('Date Time', 'None', 'None');
    fn::automation_node_resources_create('Debug Helper', 'DebugHelper.dark.svg', 'None');
    fn::automation_node_resources_create('Deep L', 'deepL.dark.svg', 'None');
    fn::automation_node_resources_create('Demio', 'demio.svg', 'None');
    fn::automation_node_resources_create('Dhl', 'dhl.svg', 'None');
    fn::automation_node_resources_create('Discord', 'discord.svg', 'None');
    fn::automation_node_resources_create('Discourse', 'discourse.svg', 'None');
    fn::automation_node_resources_create('Disqus', 'disqus.png', 'None');
    fn::automation_node_resources_create('Drift', 'drift.dark.svg', 'None');
    fn::automation_node_resources_create('Dropbox', 'dropbox.svg', 'None');
    fn::automation_node_resources_create('Dropcontact', 'dropcontact.svg', 'None');
    fn::automation_node_resources_create('ERPNex', 'erpnext.svg', 'None');
    fn::automation_node_resources_create('E2E Test', 'None', 'None');
    fn::automation_node_resources_create('Edit Image', 'None', 'None');
    fn::automation_node_resources_create('Egoi', 'egoi.svg', 'None');
    fn::automation_node_resources_create('Email Read Imap', 'None', 'None');
    fn::automation_node_resources_create('Email Send', 'None', 'None');
    fn::automation_node_resources_create('Emelia', 'emelia.svg', 'None');
    fn::automation_node_resources_create('Error', 'None', 'None');
    fn::automation_node_resources_create('Eventbrite', 'eventbrite.png', 'None');
    fn::automation_node_resources_create('Execute Command', 'None', 'None');
    fn::automation_node_resources_create('Execution Data', 'None', 'None');
    fn::automation_node_resources_create('Facebook Graph Api', 'facebook.svg', 'None');
    fn::automation_node_resources_create('Facebook Lead Ads', 'facebook.svg', 'None');
    fn::automation_node_resources_create('Figma', 'figma.svg', 'None');
    fn::automation_node_resources_create('File Maker', 'filemaker.png', 'None');
    fn::automation_node_resources_create('Filter', 'None', 'None');
    fn::automation_node_resources_create('Flow', 'flow.svg', 'None');
    fn::automation_node_resources_create('Form Io', 'formio.svg', 'None');
    fn::automation_node_resources_create('Form', 'form.svg', 'None');
    fn::automation_node_resources_create('Formstack', 'formstack.svg', 'None');
    fn::automation_node_resources_create('Freshdesk', 'freshdesk.svg', 'None');
    fn::automation_node_resources_create('Freshservice', 'freshservice.svg', 'None');
    fn::automation_node_resources_create('Freshworks Crm', 'freshworksCrm.svg', 'None');
    fn::automation_node_resources_create('Ftp', 'None', 'None');
    fn::automation_node_resources_create('Function Item', 'None', 'None');
    fn::automation_node_resources_create('Function', 'None', 'None');
    fn::automation_node_resources_create('Get Response', 'getResponse.png', 'None');
    fn::automation_node_resources_create('Ghost', 'ghost.svg', 'None');
    fn::automation_node_resources_create('Git', 'git.svg', 'None');
    fn::automation_node_resources_create('Github', 'github.dark.svg', 'None');
    fn::automation_node_resources_create('Gitlab', 'gitlab.svg', 'None');
    fn::automation_node_resources_create('GoToWebinar', 'gotowebinar.svg', 'None');
    fn::automation_node_resources_create('Gong', 'gong.svg', 'None');
    fn::automation_node_resources_create('Gotify', 'gotify.png', 'None');
    fn::automation_node_resources_create('Grafana', 'grafana.svg', 'None');
    fn::automation_node_resources_create('GraphQL', 'graphql.png', 'None');
    fn::automation_node_resources_create('Grist', 'grist.svg', 'None');
    fn::automation_node_resources_create('Gumroad', 'gumroad.png', 'None');
    fn::automation_node_resources_create('Hacker News', 'hackernews.png', 'None');
    fn::automation_node_resources_create('HaloPSA', 'halopsa.svg', 'None');
    fn::automation_node_resources_create('Harvest', 'harvest.png', 'None');
    fn::automation_node_resources_create('Help Scout', 'helpScout.svg', 'None');
    fn::automation_node_resources_create('High Level', 'highLevel.svg', 'None');
    fn::automation_node_resources_create('Home Assistant', 'homeAssistant.svg', 'None');
    fn::automation_node_resources_create('Html Extract', 'None', 'None');
    fn::automation_node_resources_create('Html', 'html.dark.svg', 'None');
    fn::automation_node_resources_create('Http Request', 'httprequest.dark.svg', 'None');
    fn::automation_node_resources_create('Hubspot', 'hubspot.svg', 'None');
    fn::automation_node_resources_create('Humantic Ai', 'humanticai.svg', 'None');
    fn::automation_node_resources_create('Hunter', 'hunter.png', 'None');
    fn::automation_node_resources_create('ICalendar', 'None', 'None');
    fn::automation_node_resources_create('If', 'None', 'None');
    fn::automation_node_resources_create('Intercom', 'intercom.svg', 'None');
    fn::automation_node_resources_create('Interval', 'None', 'None');
    fn::automation_node_resources_create('Invoice Ninja', 'invoiceNinja.svg', 'None');
    fn::automation_node_resources_create('Item Lists', 'itemLists.svg', 'None');
    fn::automation_node_resources_create('Iterable', 'iterable.png', 'None');
    fn::automation_node_resources_create('Jenkins', 'jenkins.svg', 'None');
    fn::automation_node_resources_create('Jina Ai', 'jinaAi.dark.svg', 'None');
    fn::automation_node_resources_create('Jira', 'jira.svg', 'None');
    fn::automation_node_resources_create('Jot Form', 'jotform.png', 'None');
    fn::automation_node_resources_create('Jwt', 'jwt.svg', 'None');
    fn::automation_node_resources_create('Kafka', 'kafka.dark.svg', 'None');
    fn::automation_node_resources_create('Keap', 'keap.png', 'None');
    fn::automation_node_resources_create('Kitemaker', 'kitemaker.dark.svg', 'None');
    fn::automation_node_resources_create('KoBoToolbox', 'koBoToolbox.svg', 'None');
    fn::automation_node_resources_create('Ldap', 'ldap.dark.svg', 'None');
    fn::automation_node_resources_create('Lemlist', 'lemlist.svg', 'None');
    fn::automation_node_resources_create('Line', 'line.png', 'None');
    fn::automation_node_resources_create('Linear', 'linear.svg', 'None');
    fn::automation_node_resources_create('Lingva Nex', 'lingvanex.png', 'None');
    fn::automation_node_resources_create('Linked In', 'linkedin.svg', 'None');
    fn::automation_node_resources_create('Local File', 'None', 'None');
    fn::automation_node_resources_create('Lone Scale', 'loneScale.dark.svg', 'None');
    fn::automation_node_resources_create('Magento2', 'magento.svg', 'None');
    fn::automation_node_resources_create('Mailcheck', 'mailcheck.svg', 'None');
    fn::automation_node_resources_create('Mailchimp', 'mailchimp.dark.svg', 'None');
    fn::automation_node_resources_create('Mailer Lite', 'MailerLite.svg', 'None');
    fn::automation_node_resources_create('Mailgun', 'mailgun.svg', 'None');
    fn::automation_node_resources_create('Mailjet', 'mailjet.svg', 'None');
    fn::automation_node_resources_create('Mandrill', 'mandrill.svg', 'None');
    fn::automation_node_resources_create('Manual', 'None', 'None');
    fn::automation_node_resources_create('Markdown', 'markdown.dark.svg', 'None');
    fn::automation_node_resources_create('Marketstack', 'marketstack.dark.svg', 'None');
    fn::automation_node_resources_create('Matrix', 'matrix.png', 'None');
    fn::automation_node_resources_create('Mattermost', 'mattermost.svg', 'None');
    fn::automation_node_resources_create('Mautic', 'mautic.svg', 'None');
    fn::automation_node_resources_create('Medium', 'medium.png', 'None');
    fn::automation_node_resources_create('Merge', 'merge.svg', 'None');
    fn::automation_node_resources_create('Message Bird', 'messagebird.svg', 'None');
    fn::automation_node_resources_create('Metabase', 'metabase.svg', 'None');
    fn::automation_node_resources_create('Mindee', 'mindee.svg', 'None');
    fn::automation_node_resources_create('Misp', 'misp.svg', 'None');
    fn::automation_node_resources_create('MistralAi', 'mistralAi.svg', 'None');
    fn::automation_node_resources_create('Mocean', 'mocean.dark.svg', 'None');
    fn::automation_node_resources_create('MondayCom', 'mondayCom.svg', 'None');
    fn::automation_node_resources_create('MongoDB', 'mongodb.svg', 'None');
    fn::automation_node_resources_create('MonicaCrm', 'monicaCrm.png', 'None');
    fn::automation_node_resources_create('Move Binary Data', 'None', 'None');
    fn::automation_node_resources_create('Mqtt', 'mqtt.svg', 'None');
    fn::automation_node_resources_create('Msg91', 'msg91.dark.svg', 'None');
    fn::automation_node_resources_create('MySQL', 'mysql.dark.svg', 'None');
    fn::automation_node_resources_create('n8n Trigger', 'n8nTrigger.svg', 'None');
    fn::automation_node_resources_create('N8N', 'n8n.svg', 'None');
    fn::automation_node_resources_create('Nasa', 'nasa.png', 'None');
    fn::automation_node_resources_create('Netlify', 'netlify.svg', 'None');
    fn::automation_node_resources_create('NextCloud', 'nextcloud.svg', 'None');
    fn::automation_node_resources_create('NoOp', 'None', 'None');
    fn::automation_node_resources_create('NocoDB', 'nocodb.svg', 'None');
    fn::automation_node_resources_create('Notion', 'notion.dark.svg', 'None');
    fn::automation_node_resources_create('Npm', 'npm.svg', 'None');
    fn::automation_node_resources_create('Odoo', 'odoo.svg', 'None');
    fn::automation_node_resources_create('Okta', 'Okta.dark.svg', 'None');
    fn::automation_node_resources_create('OneSimpleApi', 'onesimpleapi.svg', 'None');
    fn::automation_node_resources_create('Onfleet', 'Onfleet.svg', 'None');
    fn::automation_node_resources_create('OpenAi', 'openAi.dark.svg', 'None');
    fn::automation_node_resources_create('OpenThesaurus', 'openthesaurus.png', 'None');
    fn::automation_node_resources_create('OpenWeatherMap', 'openWeatherMap.svg', 'None');
    fn::automation_node_resources_create('Orbit', 'orbit.dark.svg', 'None');
    fn::automation_node_resources_create('Oura', 'oura.dark.svg', 'None');
    fn::automation_node_resources_create('Paddle', 'paddle.png', 'None');
    fn::automation_node_resources_create('Pager Duty', 'pagerDuty.svg', 'None');
    fn::automation_node_resources_create('PayPal', 'paypal.svg', 'None');
    fn::automation_node_resources_create('Peekalink', 'peekalink.png', 'None');
    fn::automation_node_resources_create('Perplexity', 'perplexity.dark.svg', 'None');
    fn::automation_node_resources_create('Phantombuster', 'phantombuster.png', 'None');
    fn::automation_node_resources_create('Philips Hue', 'philipshue.png', 'None');
    fn::automation_node_resources_create('Pipedrive', 'pipedrive.svg', 'None');
    fn::automation_node_resources_create('Plivo', 'plivo.svg', 'None');
    fn::automation_node_resources_create('Post Bin', 'postbin.svg', 'None');
    fn::automation_node_resources_create('Post Hog', 'postHog.svg', 'None');
    fn::automation_node_resources_create('Postgres', 'postgres.svg', 'None');
    fn::automation_node_resources_create('Postmark', 'postmark.png', 'None');
    fn::automation_node_resources_create('ProfitWell', 'profitwell.dark.svg', 'None');
    fn::automation_node_resources_create('Pushbullet', 'pushbullet.svg', 'None');
    fn::automation_node_resources_create('Pushcut', 'pushcut.png', 'None');
    fn::automation_node_resources_create('Pushover', 'pushover.svg', 'None');
    fn::automation_node_resources_create('QuestDB', 'questdb.png', 'None');
    fn::automation_node_resources_create('QuickBase', 'quickbase.png', 'None');
    fn::automation_node_resources_create('QuickBooks', 'quickbooks.svg', 'None');
    fn::automation_node_resources_create('QuickChart', 'quickChart.svg', 'None');
    fn::automation_node_resources_create('RabbitMQ', 'rabbitmq.svg', 'None');
    fn::automation_node_resources_create('Raindrop', 'raindrop.svg', 'None');
    fn::automation_node_resources_create('Read Binary File', 'None', 'None');
    fn::automation_node_resources_create('Read Binary Files', 'None', 'None');
    fn::automation_node_resources_create('ReadPDF', 'None', 'None');
    fn::automation_node_resources_create('Reddit', 'reddit.svg', 'None');
    fn::automation_node_resources_create('Redis', 'redis.svg', 'None');
    fn::automation_node_resources_create('Rename Keys', 'None', 'None');
    fn::automation_node_resources_create('Respond To Webhook', 'webhook.dark.svg', 'None');
    fn::automation_node_resources_create('Rocketchat', 'rocketchat.svg', 'None');
    fn::automation_node_resources_create('RSSFeedRead', 'None', 'None');
    fn::automation_node_resources_create('Rundeck', 'rundeck.png', 'None');
    fn::automation_node_resources_create('S3', 's3.png', 'None');
    fn::automation_node_resources_create('Salesforce', 'salesforce.svg', 'None');
    fn::automation_node_resources_create('Salesmate', 'salesmate.png', 'None');
    fn::automation_node_resources_create('Schedule', 'None', 'None');
    fn::automation_node_resources_create('SeaTable', 'seaTable.svg', 'None');
    fn::automation_node_resources_create('SecurityScorecard', 'securityScorecard.svg', 'None');
    fn::automation_node_resources_create('Segment', 'segment.svg', 'None');
    fn::automation_node_resources_create('Send Grid', 'sendGrid.svg', 'None');
    fn::automation_node_resources_create('Sendy', 'sendy.png', 'None');
    fn::automation_node_resources_create('SentryIo', 'sentryio.dark.svg', 'None');
    fn::automation_node_resources_create('ServiceNow', 'servicenow.svg', 'None');
    fn::automation_node_resources_create('Set', 'None', 'None');
    fn::automation_node_resources_create('Shopify', 'shopify.svg', 'None');
    fn::automation_node_resources_create('Signl4', 'signl4.png', 'None');
    fn::automation_node_resources_create('Simulate', 'None', 'None');
    fn::automation_node_resources_create('Slack', 'slack.svg', 'None');
    fn::automation_node_resources_create('Sms77', 'seven.svg', 'None');
    fn::automation_node_resources_create('Snowflake', 'snowflake.svg', 'None');
    fn::automation_node_resources_create('SplitInBatches', 'None', 'None');
    fn::automation_node_resources_create('Splunk', 'splunk.svg', 'None');
    fn::automation_node_resources_create('Spontit', 'spontit.png', 'None');
    fn::automation_node_resources_create('Spotify', 'spotify.svg', 'None');
    fn::automation_node_resources_create('Spreadsheet File', 'None', 'None');
    fn::automation_node_resources_create('Sse', 'None', 'None');
    fn::automation_node_resources_create('Ssh', 'None', 'None');
    fn::automation_node_resources_create('Stackby', 'stackby.png', 'None');
    fn::automation_node_resources_create('Start', 'None', 'None');
    fn::automation_node_resources_create('Sticky Note', 'None', 'None');
    fn::automation_node_resources_create('Stop And Error', 'None', 'None');
    fn::automation_node_resources_create('Storyblok', 'storyblok.svg', 'None');
    fn::automation_node_resources_create('Strapi', 'strapi.svg', 'None');
    fn::automation_node_resources_create('Strava', 'strava.svg', 'None');
    fn::automation_node_resources_create('Stripe', 'stripe.svg', 'None');
    fn::automation_node_resources_create('Supabase', 'supabase.svg', 'None');
    fn::automation_node_resources_create('Survey Monkey', 'surveyMonkey.svg', 'None');
    fn::automation_node_resources_create('Switch', 'None', 'None');
    fn::automation_node_resources_create('Syncro Msp', 'syncromsp.png', 'None');
    fn::automation_node_resources_create('Taiga', 'taiga.svg', 'None');
    fn::automation_node_resources_create('Tapfiliate', 'tapfiliate.svg', 'None');
    fn::automation_node_resources_create('Telegram', 'telegram.svg', 'None');
    fn::automation_node_resources_create('TheHiveProject', 'thehiveproject.svg', 'None');
    fn::automation_node_resources_create('TheHive', 'thehive.svg', 'None');
    fn::automation_node_resources_create('TimescaleDB', 'timescaleDb.dark.svg', 'None');
    fn::automation_node_resources_create('Todoist', 'todoist.svg', 'None');
    fn::automation_node_resources_create('Toggl', 'toggl.png', 'None');
    fn::automation_node_resources_create('Totp', 'None', 'None');
    fn::automation_node_resources_create('Travis Ci', 'travisci.png', 'None');
    fn::automation_node_resources_create('Trello', 'trello.svg', 'None');
    fn::automation_node_resources_create('Twake', 'twake.png', 'None');
    fn::automation_node_resources_create('Twilio', 'twilio.svg', 'None');
    fn::automation_node_resources_create('Twist', 'twist.png', 'None');
    fn::automation_node_resources_create('Twitter', 'x.dark.svg', 'None');
    fn::automation_node_resources_create('Typeform', 'typeform.dark.svg', 'None');
    fn::automation_node_resources_create('UProc', 'uproc.png', 'None');
    fn::automation_node_resources_create('UnleashedSoftware', 'unleashedSoftware.png', 'None');
    fn::automation_node_resources_create('Uplead', 'uplead.png', 'None');
    fn::automation_node_resources_create('UptimeRobot', 'uptimerobot.svg', 'None');
    fn::automation_node_resources_create('UrlScanIo', 'urlScanIo.svg', 'None');
    fn::automation_node_resources_create('Vero', 'vero.svg', 'None');
    fn::automation_node_resources_create('Vonage', 'vonage.dark.svg', 'None');
    fn::automation_node_resources_create('Wait', 'None', 'None');
    fn::automation_node_resources_create('Webflow', 'webflow.svg', 'None');
    fn::automation_node_resources_create('Webhook', 'webhook.dark.svg', 'None');
    fn::automation_node_resources_create('Wekan', 'wekan.svg', 'None');
    fn::automation_node_resources_create('WhatsApp', 'whatsapp.svg', 'None');
    fn::automation_node_resources_create('Wise', 'wise.svg', 'None');
    fn::automation_node_resources_create('WooCommerce', 'wooCommerce.svg', 'None');
    fn::automation_node_resources_create('Wordpress', 'wordpress.svg', 'None');
    fn::automation_node_resources_create('Workable', 'workable.png', 'None');
    fn::automation_node_resources_create('Workflow', 'None', 'None');
    fn::automation_node_resources_create('Write Binary File', 'None', 'None');
    fn::automation_node_resources_create('Wufoo', 'wufoo.png', 'None');
    fn::automation_node_resources_create('Xero', 'xero.svg', 'None');
    fn::automation_node_resources_create('Xml', 'None', 'None');
    fn::automation_node_resources_create('Yourls', 'yourls.png', 'None');
    fn::automation_node_resources_create('Zammad', 'zammad.svg', 'None');
    fn::automation_node_resources_create('Zendesk', 'zendesk.svg', 'None');
    fn::automation_node_resources_create('Zoho Crm', 'zoho.svg', 'None');
    fn::automation_node_resources_create('Zoom', 'zoom.svg', 'None');
    fn::automation_node_resources_create('Zulip', 'zulip.svg', 'None');

    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'data_reference', 'done', 'automation_node_reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise les données de référence pour les nodes."
PERMISSIONS FULL;
