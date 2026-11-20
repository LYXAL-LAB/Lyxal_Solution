# Feuille de route — `lyxal_auth`

Évolutions à venir. L'état actuel est décrit dans le [`README.md`](README.md) ; les sources et les
décisions du CTO dans [`MODELE_SOURCES.md`](MODELE_SOURCES.md). Chaque lot a son propre plan détaillé,
validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Étape | Contenu | Dépend de |
| :--- | :--- | :--- |
| Mots de passe d'application, suite | Alerte « nouvel appareil » (première connexion depuis un protocole ou une adresse inconnus) et rappel avant expiration, par `lyxal_notification` ; adresses de courrier du compte acceptées comme identifiant (`lyxal_mail` retrouve l'identité puis appelle la même vérification) ; SCRAM-SHA-256 si la décision P6(h) le retient (clé SCRAM calculée à la création, extension PBKDF2 de `lyxal_crypto`, mots de passe existants recréés) ; essais réels des logiciels (mot de passe de 23 caractères avec tirets, majuscule automatique des claviers, nom du logiciel transmis) ; test de concurrence du nombre maximal (deux créations simultanées peuvent le dépasser d'une unité) et des mises à jour concurrentes du journal ; écrans de la console | Programme courrier : lots 4 (adresses), 8 (IMAP, SCRAM), DAV ; essais réels aux lots 21 et 22 |
| Clés d'API | Vérifier que `fn::auth_api_key_create` refuse une liste de permissions vide : la règle `array_of_strings` de `lyxal_core` avec `allow_empty: false` laisse passer `[]` (constaté au lot 1 du programme courrier, corrigé pour les mots de passe d'application par `array_length`) ; corriger la règle du Core si c'est un défaut (validation CTO, §5.7.7) | — |
| Dépendances | Suivi de la crate `rsa` (alerte Marvin, chemin non atteint : vérification de signatures seulement) ; le passage à SurrealDB 4.0 ne la corrige pas et relève de la feuille de route commune ([`docs/14-roadmap/SURREALDB_4.md`](../../docs/14-roadmap/SURREALDB_4.md)) | — |
| V2 | Connexion par fournisseur externe (OIDC), Lyxal fournisseur OIDC (signature asymétrique à ajouter à `lyxal_crypto`), appareils de confiance, MFA adaptative, consentement, emprunt d'identité encadré, écrans de la console | V1 |
| V3 | SSO SAML, parcours en arbre, SCIM | V2 |
