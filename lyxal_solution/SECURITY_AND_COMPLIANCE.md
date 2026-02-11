# Sécurité, Souveraineté et Conformité Européenne

## 1. Souveraineté de la Donnée (GDPR-by-Design)
Lyxal ne se contente pas de respecter le RGPD, il l'automatise.
- **Droit à l'oubli natif** : Le moteur de Flow peut automatiser la purge des données sur toutes les tables (Core + Extensions) et sur les systèmes synchronisés (Sync-Ghost) via une seule commande.
- **Localisation granulaire** : Grâce à `lyxalkv`, Lyxal peut partitionner les données physiquement sur des serveurs spécifiques par Namespace, garantissant que les données sensibles ne quittent jamais le territoire européen.

## 2. Sécurité de niveau "Kernel"
- **Memory Safety** : L'utilisation exclusive de Rust élimine les vulnérabilités de type "buffer overflow", la cause n°1 des failles dans les systèmes GAFAM actuels.
- **Auditabilité Totale** : Grâce à `lyxal_revision`, chaque changement dans le système (donnée ou code de workflow) est versionné, signé et auditable. C'est le socle de la confiance pour les administrations publiques.

## 3. Résilience et Indépendance Technologique
- **Anti-Cloud Act** : En étant auto-hébergeable sur n'importe quel métal nu (Bare Metal) souverain, Lyxal rend les entreprises européennes totalement indépendantes des décisions politiques ou juridiques des pays tiers.
- **Zéro-Dépendance Critique** : Le retrait de RocksDB/TiKV au profit de solutions 100% maîtrisées par Lyxal garantit qu'aucune "backdoor" ou goulot d'étranglement étranger ne peut paralyser le système.

## 4. Certification IA Responsable
- **Traçabilité des Agents** : Chaque action effectuée par une IA via le serveur MCP est logguée avec son contexte de décision. Lyxal est le premier backend capable de dire *pourquoi* une IA a pris une décision automatisée.
