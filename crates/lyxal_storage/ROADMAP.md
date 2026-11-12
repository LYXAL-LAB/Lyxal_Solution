# Feuille de route — `lyxal_storage`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme, ses
décisions (S1 à S6) et le détail des lots dans `implementation_plan.md` à la racine. Chaque lot a
son propre plan détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| 8 | Clôture : audit, documentation | docs |
| Plus tard | Droits par bucket (aujourd'hui un bucket de l'installation, comme celui de l'ingestion, demande `storage.installation.manage`) ; Envoi reprenable : taille inconnue au départ, envoi de plusieurs morceaux en parallèle, contrôle d'empreinte par morceau (extensions tus `creation-defer-length`, `concatenation`, `checksum`), refus d'un type interdit dès la première partie reçue, assemblage sans recopie sur S3 ; Nouvelle analyse des fichiers déjà stockés quand les signatures de l'antivirus changent, avec mise en quarantaine (`fn::storage_object_quarantine`) ; Téléchargement par liens signés servis par le support S3 (aujourd'hui tout téléchargement passe par l'hôte) ; retrait actif des envois en plusieurs parties abandonnés sur S3 (aujourd'hui effacés par le service) ; vérification périodique de l'intégrité de tous les fichiers (aujourd'hui à la demande, `StorageService::verify`) ; déplacement des fichiers d'un bucket vers un autre support ; buckets publics (lisibles sans session) ; versions d'un fichier ; déduplication par empreinte ; chiffrement des fichiers au repos (soumis au CTO, §11.3) ; identifiants des supports par `lyxal_secrets` ; bascule vers les buckets de SurrealDB quand ils ne seront plus expérimentaux | |
