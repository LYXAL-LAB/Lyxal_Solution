# Feuille de route — `lyxal_storage`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme, ses
décisions (S1 à S6) et le détail des lots dans `implementation_plan.md` à la racine. Chaque lot a
son propre plan détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| 5 | Contrôle du contenu : type réel du fichier, antivirus optionnel, quarantaine ; affichage direct des images et des PDF dans le navigateur (aujourd'hui tout fichier est proposé à l'enregistrement) | `lyxal_storage`, `apps/lyxal-server` |
| 6 | Envoi reprenable (protocole tus 1.0) | `lyxal_storage`, `apps/lyxal-server` |
| 7 | Bascule de l'ingestion : fichier source d'un lot conservé par `lyxal_storage` | `lyxal_pipeline_ingestion` |
| 8 | Clôture : audit, documentation | docs |
| Plus tard | Téléchargement par liens signés servis par le support S3 (aujourd'hui tout téléchargement passe par l'hôte) ; retrait actif des envois en plusieurs parties abandonnés sur S3 (aujourd'hui effacés par le service) ; vérification périodique de l'intégrité de tous les fichiers (aujourd'hui à la demande, `StorageService::verify`) ; déplacement des fichiers d'un bucket vers un autre support ; buckets publics (lisibles sans session) ; versions d'un fichier ; déduplication par empreinte ; chiffrement des fichiers au repos (soumis au CTO, §11.3) ; identifiants des supports par `lyxal_secrets` ; bascule vers les buckets de SurrealDB quand ils ne seront plus expérimentaux | |
