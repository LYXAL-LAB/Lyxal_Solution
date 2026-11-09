# Feuille de route — `lyxal_auth`

Évolutions à venir. L'état actuel est décrit dans le [`README.md`](README.md) ; le programme et
ses décisions dans `implementation_plan.md` à la racine. Chaque lot a son propre plan détaillé,
validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Étape | Contenu | Dépend de |
| :--- | :--- | :--- |
| Lot 7 (plan : `implementation_plan.md`) — purge des supprimés | Purge différée des organisations et identités à l'état `deleted` (données, identifiants, adresses, moyens d'authentification) après un délai de conservation, par le worker de purge | — |
| Dépendances | Passage à SurrealDB 4.0 (alertes `crypto-bigint`, `quick-xml`, `reblessive` corrigées seulement en 4.0), chantier dédié à tout l'espace de travail ; suivi de la crate `rsa` (alerte Marvin, chemin non atteint : vérification de signatures seulement) | — |
| V2 | Connexion par fournisseur externe (OIDC), Lyxal fournisseur OIDC (signature asymétrique à ajouter à `lyxal_crypto`), appareils de confiance, MFA adaptative, consentement, emprunt d'identité encadré, écrans de la console | V1 |
| V3 | SSO SAML, parcours en arbre, SCIM | V2 |
