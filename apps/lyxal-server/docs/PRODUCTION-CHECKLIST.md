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
- [ ] timeouts ajustés (dont `http.transfer_idle_timeout_seconds`, délai d'inactivité d'un
      transfert de fichier et d'écriture d'une connexion) ;
- [ ] sections `[secrets]` et `[storage]` identiques à celles de `lyxal-groupware` quand il
      partage la base (même clé maîtresse du coffre-fort, mêmes supports nommés) ; au moins un
      nœud `lyxal-server` toujours en service : il exécute `storage.cleanup` et
      `secrets.maintenance` pour toute la base, courrier compris ;
- [ ] endpoints `/live`, `/ready`, `/health` supervisés ;
- [ ] arrêt `SIGTERM` testé ;
- [ ] dépendances auditées avec `cargo audit` ;
- [ ] licences contrôlées avec `cargo deny` ;
- [ ] doublons inspectés avec `cargo tree -d` ;
- [ ] tests du workspace exécutés ;
- [ ] binaire reproductible et signé ;
- [ ] version renseignée (le `CHANGELOG.md` est créé à la première version livrée, `AGENTS.md` §0).
