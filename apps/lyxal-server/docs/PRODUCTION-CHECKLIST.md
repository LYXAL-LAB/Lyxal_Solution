# Checklist de mise en production

- [ ] identifiants SurrealDB fournis par `LYXAL__DATABASE__USERNAME` et `LYXAL__DATABASE__PASSWORD` (aucun dans les TOML) ;
- [ ] compte SurrealDB non-root ;
- [ ] TLS placé devant le serveur ou directement intégré ;
- [ ] CORS limité aux origines réelles ;
- [ ] `LYXAL_ENV=production` ;
- [ ] logs JSON activés ;
- [ ] sauvegarde SurrealDB testée ;
- [ ] migrations testées sur une copie de production ;
- [ ] limites de corps et de concurrence ajustées ;
- [ ] timeouts ajustés ;
- [ ] endpoints `/live`, `/ready`, `/health` supervisés ;
- [ ] arrêt `SIGTERM` testé ;
- [ ] dépendances auditées avec `cargo audit` ;
- [ ] licences contrôlées avec `cargo deny` ;
- [ ] doublons inspectés avec `cargo tree -d` ;
- [ ] tests du workspace exécutés ;
- [ ] binaire reproductible et signé ;
- [ ] version renseignée (le `CHANGELOG.md` est créé à la première version livrée, `AGENTS.md` §0).
