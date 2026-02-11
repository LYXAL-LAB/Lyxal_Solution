🧾 État des lieux du module Marketing
1. ✅ Ce qui existe déjà (Axelor → SurrealDB)
Domaine fonctionnel	Entités présentes dans la BDD	Couverture
Campagnes marketing	campaign, campaign_type	✅ Oui
Gestion des cibles	target_list, partnerSet, leadSet, partnerFilterList, leadQuery	✅ Oui
Rappels & relances	campaign_reminder, durationTypeSelect, assignToSelect	✅ Oui
Participants	campaign_attendee, relatedToSelect, relatedToSelectId	✅ Oui
Événements liés (CRM)	crm_event (extension)	✅ Oui

➡️ Bilan : module marketing opérationnel avec gestion multicanale (emails), cibles multiples (leads, partenaires), rappels, événements et segmentation.

2. 🔧 Améliorations à projeter pour ton modèle SaaS
Objectif métier	Composant à ajouter	Niveau de transformation	Type
Suivi précis des interactions	marketing_log, email_open, click_log	🟢 Simple	Graphe relationnel
Campagnes multicanales	channel_type, sms_template, webhook	🟢 Simple	Extension fonctionnelle
Gestion des assets marketing	marketing_asset, download_log	🟢 Simple	Fonctionnalité annexe
Gestion de formulaires	marketing_form, form_submission	🟡 Moyenne	Nouvelle entité
Objectifs de campagne	marketing_goal, conversion_step	🟡 Moyenne	Business logique
Marketing Automation	marketing_workflow, trigger, action	🔴 Structurant	Système d’automation
Scoring des leads	marketing_score, lead_score_event	🟡 Moyenne	Comportement/IA
Tracking avancé multi-visite	tracking_session, visit_log, source	🔴 Structurant	Tracking web complet

3. 🧱 Architecture modulaire recommandée
Pour une intégration SaaS LYXAL, structure recommandée :

lyxalsuite/
└── lyxalmarketing/
    ├── gateway/
    │   └── routes/campaign.ts, reminder.ts, attendee.ts, ...
    ├── sdk/
    │   └── marketingClient.ts, useCampaigns(), useTargetLists(), ...
    ├── model/
    │   └── surreal/campaign.surql.ts, reminder.surql.ts, ...
    ├── ui/
    │   └── CampaignCard.tsx, TargetListTable.tsx
    ├── interface/
    │   └── pages/, views/, builders/
    └── config/
        └── enums.ts, types.ts, scoring.ts, sequences.ts

✅ Ce modèle te permet :
Génération d’un SaaS marketing automatisé

Activation ou non des options comme : scoring, workflows, formulaires

Intégration directe dans tes IA ou assistants (via sdk/)

Réutilisation de composants UI globaux avec thèmes CSS dynamiques