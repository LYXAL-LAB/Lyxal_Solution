# Changelog

## Phase B — 30 octobre 2026 — package0.1.0, API V1 / enc:v2

Rupture autorisée avant production : remplace les alias sensibles, la normalisation
implicite du contexte, le format actifV1, les APIs AAD vide et la mutation du trousseau.
Ajoute types opaques, snapshots, tombstones restaurables, validation de succession,
rotation authentifiée, fichier publié sans remplacement, limites PHC et mémoire contrôlée.
Conserve les primitives RustCrypto et les versions de dépendances identifiées.
Les anciens vecteurs AES/HMAC sont relocalisés dans des tests privés ; RFC4231 cas3
corrigé en conservant le vecteur32bytes supplémentaire. Voir le rapport pour les preuves.
Aucun consommateur adapté, aucune donnée extérieure migrée, aucune publication effectuée.
