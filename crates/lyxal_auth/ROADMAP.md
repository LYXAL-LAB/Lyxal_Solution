# Feuille de route — `lyxal_auth`

Évolutions à venir. L'état actuel est décrit dans le [`README.md`](README.md) ; les sources et les
décisions du CTO dans [`MODELE_SOURCES.md`](MODELE_SOURCES.md). Chaque lot a son propre plan détaillé,
validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Étape | Contenu | Dépend de |
| :--- | :--- | :--- |
| Dépendances | Passage à SurrealDB 4.0 (alertes `crypto-bigint`, `quick-xml`, `reblessive` corrigées seulement en 4.0), chantier dédié à tout l'espace de travail ; suivi de la crate `rsa` (alerte Marvin, chemin non atteint : vérification de signatures seulement) | — |
| V2 | Connexion par fournisseur externe (OIDC), Lyxal fournisseur OIDC (signature asymétrique à ajouter à `lyxal_crypto`), appareils de confiance, MFA adaptative, consentement, emprunt d'identité encadré, écrans de la console | V1 |
| V3 | SSO SAML, parcours en arbre, SCIM | V2 |
