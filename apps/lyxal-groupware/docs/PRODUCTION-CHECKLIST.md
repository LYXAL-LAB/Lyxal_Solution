# Checklist de mise en production — `lyxal-groupware`

- [ ] binaire construit du **même commit** que `lyxal-server` (même socle, mêmes releases) ;
- [ ] même base que `lyxal-server` (`database.endpoint`, `namespace`, `database`) ;
- [ ] identifiants SurrealDB fournis par `LYXAL_GROUPWARE__DATABASE__USERNAME` et
      `LYXAL_GROUPWARE__DATABASE__PASSWORD` (aucun dans les TOML) ; compte non-root ;
- [ ] `LYXAL_ENV=production` ; journal JSON ; `observability.log_client_ip = "network"` ;
- [ ] port HTTP de santé lié à une adresse interne (`127.0.0.1:8090` par défaut) ; `/live`,
      `/ready`, `/health`, `/metrics` supervisés ;
- [ ] écoutes de courrier déclarées une à une ; **port 25 fermé sur Internet avant le lot 5** ;
      pare-feu ouvert pour les seuls ports déclarés ;
- [ ] ports inférieurs à 1024 ouverts par la capacité `CAP_NET_BIND_SERVICE` (systemd :
      `AmbientCapabilities=CAP_NET_BIND_SERVICE`, ou conteneur), le programme tournant sous un
      compte sans droits ;
- [ ] limites (`[limits]`) ajustées au trafic attendu ; plusieurs nœuds : limites par réseau
      multipliées par le nombre de nœuds ;
- [ ] `limits.drain_seconds` inférieur au délai d'arrêt laissé par le superviseur (systemd
      `TimeoutStopSec`, conteneur `stop_grace_period`) ;
- [ ] arrêt `SIGTERM` testé (drainage des connexions) ;
- [ ] certificats TLS déclarés dans `[tls]` (défaut et noms servis) ; fichier de clé en mode
      0600 ou 0400, propriété du compte du service (sinon refus au démarrage) ; renouvellement
      (certbot) vérifié : nouveau certificat servi en moins de `tls.reload_interval_seconds`,
      `/health` sans « dégradé » ; contrôle par `openssl s_client` (TLS implicite et STARTTLS) ;
- [ ] derrière un répartiteur de charge : `proxy_networks` des écoutes limité à ses seules
      adresses, répartiteur réglé pour envoyer l'en-tête PROXY (v1 ou v2) en mode TCP ;
- [ ] licences contrôlées (`cargo deny check licenses`, `scripts/ci/check_agpl_isolation.py`) ;
      offre du code source (AGPL, article 13) tranchée par le CTO.
