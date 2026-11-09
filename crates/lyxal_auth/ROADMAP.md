# Feuille de route — `lyxal_auth`

Évolutions à venir. L'état actuel est décrit dans le [`README.md`](README.md) ; le programme et
ses décisions dans `implementation_plan.md` à la racine. Chaque lot a son propre plan détaillé,
validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Étape | Contenu | Dépend de |
| :--- | :--- | :--- |
| Lot 5 | Bascule de `lyxal_catalogue` et `lyxal_pipeline_ingestion` sur `fn::auth_has_permission` ; suppression de leurs sessions propres et de l'accès `lyxal_catalogue_sync` | — |
| Lot 6 | Clôture : audit `lyxal-audit`, revue OWASP ASVS niveau 2, suivi de la crate `rsa` (version préliminaire tirée par `webauthn-rs` 0.6) | lot 5 |
| V2 | Connexion par fournisseur externe (OIDC), Lyxal fournisseur OIDC (signature asymétrique à ajouter à `lyxal_crypto`), appareils de confiance, MFA adaptative, consentement, emprunt d'identité encadré, écrans de la console | V1 |
| V3 | SSO SAML, parcours en arbre, SCIM | V2 |
