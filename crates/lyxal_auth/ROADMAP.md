# Feuille de route — `lyxal_auth`

Évolutions à venir. L'état actuel est décrit dans le [`README.md`](README.md) ; le programme et
ses décisions dans `implementation_plan.md` à la racine. Chaque lot a son propre plan détaillé,
validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Étape | Contenu | Dépend de |
| :--- | :--- | :--- |
| Lot 2 bis | Partie e-mail de `lyxal_notification` (consomme `auth.invitation.created`, puis les événements du lot 3) | lot 2 |
| Lot 3 | Mots de passe (`lyxal_crypto::password`), parcours (inscription sur invitation ou par administrateur, connexion, vérification d'adresse, récupération, changement d'adresse), émission des sessions et jetons (JWT HS256, renouvellement à usage unique), accès `DEFINE ACCESS lyxal_auth`, anti-force-brute, actions imposées, applications et comptes de service, clés d'API, routes HTTP `/auth/*`, premier administrateur par commande de l'hôte, rattachement automatique par domaine, purge (`LyxalWorker`) | lot 2 bis |
| Lot 4 | Double facteur : TOTP (`lyxal_crypto::totp`), passkeys (`webauthn-rs`), codes de secours, montée en assurance (AAL2) | lot 3 |
| Lot 5 | Bascule de `lyxal_catalogue` et `lyxal_pipeline_ingestion` sur `fn::auth_has_permission` ; suppression de leurs sessions propres et de l'accès `lyxal_catalogue_sync` | lot 3 |
| Lot 6 | Clôture : audit `lyxal-audit`, revue OWASP ASVS niveau 2 | lots 3 à 5 |
| V2 | Connexion par fournisseur externe (OIDC), Lyxal fournisseur OIDC (signature asymétrique à ajouter à `lyxal_crypto`), appareils de confiance, MFA adaptative, consentement, emprunt d'identité encadré, écrans de la console | V1 |
| V3 | SSO SAML, parcours en arbre, SCIM | V2 |
