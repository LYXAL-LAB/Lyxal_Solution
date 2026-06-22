# Architecture : Lyxal Connector (Outbound)

## Concept
Remplacer le moteur n8n par un système de connecteurs génériques pilotés par des métadonnées (Data-driven) intégrés directement dans le binaire Rust de Lyxal.

## Composants Clés
1. **Parser LyxalQL** : Extension du parser pour supporter `DEFINE CONNECTOR`.
2. **Executor HTTP Générique** : Utilisation de `reqwest` avec un moteur de templating pour les URLs et les payloads.
3. **Gestionnaire d'Auth** : Pont entre les `DEFINE ACCESS` de Lyxal et les headers HTTP.
4. **Scheduler de Resilience** : Logique de Retry avec backoff exponentiel et Rate Limiting (Token Bucket).

## Avantages
- Performance native Rust.
- Zéro dépendance externe par node (pas de SDK Google, Slack, etc.).
- Gestion de la backpressure via les curseurs de la DB.