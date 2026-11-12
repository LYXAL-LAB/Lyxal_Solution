# Feuille de route — `lyxal_storage`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; les sources et les
décisions de conception par [`MODELE_SOURCES.md`](MODELE_SOURCES.md). Aucune évolution ne démarre
sans `implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3).

| Thème | Évolution |
| :--- | :--- |
| Montée en charge | compteurs de volume tenus à jour par portée et par bucket (aujourd'hui recomptés à chaque écriture quand un quota est réglé) ; listes paginées par la base ; position d'un envoi reprenable tenue sans recompter ses parties |
| Droits | droits par bucket (aujourd'hui un bucket de l'installation, comme celui de l'ingestion, demande `storage.installation.manage`) ; buckets publics (lisibles sans session) |
| Envoi reprenable | taille inconnue au départ, envoi de plusieurs morceaux en parallèle, contrôle d'empreinte par morceau (extensions tus `creation-defer-length`, `concatenation`, `checksum`) ; refus d'un type interdit dès la première partie reçue ; assemblage sans recopie sur S3 |
| Contrôle du contenu | nouvelle analyse des fichiers déjà stockés quand les signatures de l'antivirus changent, avec mise en quarantaine (`fn::storage_object_quarantine`) ; vérification périodique de l'intégrité de tous les fichiers (aujourd'hui à la demande, `StorageService::verify`) |
| Supports | téléchargement par liens signés servis par le support S3 (aujourd'hui tout téléchargement passe par l'hôte) ; retrait actif des envois en plusieurs parties abandonnés sur S3 (aujourd'hui effacés par le service) ; déplacement des fichiers d'un bucket vers un autre support ; identifiants des supports par `lyxal_secrets` ; bascule vers les buckets de SurrealDB quand ils ne seront plus expérimentaux |
| Fichiers | versions d'un fichier ; déduplication par empreinte ; chiffrement des fichiers au repos (soumis au CTO, `.agents/rules/lyxal_standards_and_checklist.md` §11.3) |
