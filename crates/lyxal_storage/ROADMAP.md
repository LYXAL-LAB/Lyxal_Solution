# Feuille de route — `lyxal_storage`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme, ses
décisions (S1 à S6) et le détail des lots dans `implementation_plan.md` à la racine. Chaque lot a
son propre plan détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| 3 | Hôte : routes d'envoi et de téléchargement en flux, limites, lecture partielle | `apps/lyxal-server` |
| 4 | Support S3 et compatibles, Bunny Storage en référence ; identifiants par l'environnement de l'hôte | `lyxal_storage`, `apps/lyxal-server` |
| 5 | Contrôle du contenu : type réel du fichier, antivirus optionnel, quarantaine | `lyxal_storage` |
| 6 | Envoi reprenable (protocole tus 1.0) | `lyxal_storage`, `apps/lyxal-server` |
| 7 | Bascule de l'ingestion : fichier source d'un lot conservé par `lyxal_storage` | `lyxal_pipeline_ingestion` |
| 8 | Clôture : audit, documentation | docs |
| Plus tard | Vérification périodique de l'intégrité de tous les fichiers (aujourd'hui à la demande, `StorageService::verify`) ; déplacement des fichiers d'un bucket vers un autre support ; buckets publics (lisibles sans session) ; versions d'un fichier ; déduplication par empreinte ; chiffrement des fichiers au repos (soumis au CTO, §11.3) ; identifiants des supports par `lyxal_secrets` ; bascule vers les buckets de SurrealDB quand ils ne seront plus expérimentaux | |
