# Plan d'Implémentation : DEFINE CONNECTOR

## Phase 1 : Extraction & Analyse (En cours)
- Script d'extraction des métadonnées n8n (URLs, Methods, Params).
- Stockage dans un format JSON intermédiaire pour le futur import.

## Phase 2 : Noyau Lyxal (Rust)
- Modifier `lyxal/core/src/sql/statements/define/connector.rs`.
- Modifier le parser dans `syn/parser/stmt/define.rs`.
- Implémenter le trait `ConnectorRuntime`.

## Phase 3 : Resilience & Sécurité
- Intégrer la logique de Rate Limiting globale.
- Chiffrement des identifiants via le KMS de Lyxal.

## Phase 4 : Déploiement
- Conversion des fichiers `.node.json` en scripts `.surql`.
- Suppression du dossier n8n.