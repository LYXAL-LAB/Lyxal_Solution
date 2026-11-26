# Checklist de mise en production — `lyxal-groupware`

- [ ] binaire construit du **même commit** que `lyxal-server` (même socle, mêmes releases) ;
- [ ] même base que `lyxal-server` (`database.endpoint`, `namespace`, `database`) ;
- [ ] identifiants SurrealDB fournis par `LYXAL_GROUPWARE__DATABASE__USERNAME` et
      `LYXAL_GROUPWARE__DATABASE__PASSWORD` (aucun dans les TOML) ; compte non-root ;
- [ ] clé maîtresse du coffre-fort fournie par `LYXAL_GROUPWARE__SECRETS__MASTER_KEY` avec
      `secrets.master_key_id` : **la même que `LYXAL__SECRETS__MASTER_KEY` de `lyxal-server`**
      (aucune dans les TOML) ; sauvegarde de la clé selon les procédures de `lyxal_secrets`
      (clé perdue : courrier illisible) ; pendant une rotation, l'ancienne clé fournie des deux
      côtés ; sans clé, l'hôte refuse de démarrer dès qu'un bucket chiffré existe
      (`GROUPWARE_MASTER_KEY_MISSING`) ;
- [ ] sections `[secrets]` et `[storage]` identiques à celles de `lyxal-server` (code commun
      `lyxal_host::services`, préfixes `LYXAL__` et `LYXAL_GROUPWARE__`) ;
- [ ] supports de stockage identiques à ceux de `lyxal-server` (`storage.disk.root` sur un
      dossier partagé, ou mêmes supports S3 nommés, clé secrète par l'environnement) ;
      `mail.storage_backend` choisi avant le premier message (fixé à la création du bucket
      `lyxal-mail` de chaque organisation) ; antivirus déclaré comme dans `lyxal-server` ;
- [ ] **`lyxal-server` en service sur la même base** (exigence d'exploitation) : ses tâches
      `storage.cleanup` et `secrets.maintenance` retirent les octets des messages effacés et
      rescellent les clés des fichiers ; sans nœud `lyxal_server` vivant depuis plus de
      10 minutes, la sonde de `lyxal_mail` passe à « dégradé » (« aucun nœud lyxal_server
      vivant… ») : alerte de supervision sur ce message ;
- [ ] `/health` : `lyxal_mail`, `lyxal_secrets` et `lyxal_storage` sans « dégradé » (clé
      maîtresse, supports et `lyxal-server` présents) ; tâche `mail.maintenance` exécutée
      (journal de `lyxal_scheduler`) ;
- [ ] `LYXAL_ENV=production` ; journal JSON ; `observability.log_client_ip = "network"` ;
- [ ] port HTTP de santé lié à une adresse interne (`127.0.0.1:8090` par défaut) ; `/live`,
      `/ready`, `/health`, `/metrics` supervisés ;
- [ ] écoutes de courrier déclarées une à une ; pare-feu ouvert pour les seuls ports déclarés ;
      ports des protocoles pas encore écrits (soumission, IMAP, POP3, ManageSieve) fermés sur
      Internet ;
- [ ] réception SMTP (port 25) : `smtp.hostname` renseigné (nom du MX du domaine, égal au DNS
      inverse de l'adresse publique) ; enregistrement MX publié ; hébergeur qui laisse passer le
      port 25 entrant ; écoute `smtp` en `starttls` avec un certificat couvrant `hostname` ;
      envoi d'essai vers une adresse inconnue (`550 5.1.1`) et vers un domaine extérieur
      (`550 5.7.1`, aucun relais) ;
- [ ] résolveur DNS : résolveur récursif local recommandé (`[dns] servers`), ou
      `/etc/resolv.conf` lisible ; `/health` sans « DNS en panne » ;
- [ ] politique DMARC : `smtp.dmarc_enforce = false` pendant la mise en service si des listes de
      diffusion légitimes sont attendues (aucune vérification ARC avant le lot 7), puis `true` ;
- [ ] antivirus (`[storage.antivirus]`) joignable : sinon chaque message reçu est refusé
      temporairement (`451 4.3.0`) et la sonde de `lyxal_mail` est « dégradé » ;
- [ ] limites SMTP (`[smtp]` : taille, destinataires, messages par session et par réseau,
      erreurs, délais) ajustées au trafic ; supervision des refus et des bannissements
      (`/metrics`, `mail.smtp`) ;
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
