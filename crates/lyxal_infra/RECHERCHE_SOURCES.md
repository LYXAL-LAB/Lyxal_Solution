# `lyxal_infra` (proposé) — recherches pour le plan

Recherches faites le 27 novembre 2026 pour `implementation_plan.md` (même dossier). Le dossier ne
contient que ces deux documents : aucun code avant la validation du plan par le CTO
(`.agents/AGENTS.md` §3).

**Méthode.** Le site de Scaleway (`www.scaleway.com`), `docs.rs` et `api.ovh.com` ne sont pas
joignables depuis la session de travail : leurs pages n'ont été vues qu'à travers des résultats
de moteur de recherche (extraits courts). Les faits techniques précis (chemins d'API, champs)
viennent donc des **sources publiques lues directement** : le SDK Go officiel de Scaleway
(`scaleway/scaleway-sdk-go`, Apache-2.0, fichiers générés depuis la spécification de l'API), la
bibliothèque `dns-update` de Stalwart Labs (Apache-2.0 OR MIT), lego (MIT), external-dns
(Apache-2.0), DNSControl (MIT) et octoDNS (MIT), lus sur leur branche principale au
27 novembre 2026. Rien n'a été appelé chez Scaleway, OVHcloud ou Bunny : aucun compte n'était
disponible. Ce qui reste à confirmer est repris au §15 du plan.

---

## 1. Scaleway

### 1.1. Authentification, organisation, projets

* Une clé d'API est un couple *access key* (identifiant `SCW…`) / *secret key* (UUID). Les appels
  portent la clé secrète dans l'en-tête `X-Auth-Token` (exemple de la documentation :
  `curl https://api.scaleway.com/domain/v2beta1/dns-zones/… -H "X-Auth-Token: $SCW_SECRET_KEY"`).
  Source : [API Domains and DNS](https://www.scaleway.com/en/developers/api/domains-and-dns/)
  (extrait du moteur de recherche) ; SDK Go, `scw/`.
* Une clé appartient à un utilisateur IAM ou à une **application IAM** ; ses droits viennent des
  **politiques** attachées à cette application, faites de *permission sets* portant sur un projet
  ou sur l'organisation. Exemples de noms : `InstancesFullAccess`, `DomainsDNSReadOnly`,
  `DomainsDNSFullAccess` (portée projet). Sources :
  [Permission sets](https://www.scaleway.com/en/docs/iam/reference-content/permission-sets/),
  [IAM API](https://www.scaleway.com/en/developers/api/iam/),
  [exemple Qovery](https://www.qovery.com/docs/getting-started/security-and-compliance/scaleway-iam-permissions).
  **Non vérifié** : le contenu exact de `DomainsDNSFullAccess` (autorise-t-il l'achat de domaines
  par `buy-domains` ?) et l'existence d'un jeu plus fin pour le DNS inverse des IP.
* Les ressources DNS appartiennent à un **projet** (`project_id` de chaque zone) ; l'API Domains
  est globale (pas de région dans le chemin) ; l'API Instances est par **zone** de disponibilité
  (`fr-par-1`…), l'API IPAM par **région** (`fr-par`, `nl-ams`, `pl-waw`). Source : SDK Go
  (chemins ci-dessous).

### 1.2. Domains and DNS (`/domain/v2beta1`, version **bêta**)

Chemins relevés dans `api/domain/v2beta1/domain_sdk.go` du SDK Go
([fichier](https://github.com/scaleway/scaleway-sdk-go/blob/master/api/domain/v2beta1/domain_sdk.go)) :

| Usage | Méthode et chemin |
| :--- | :--- |
| Zones : liste, création, modification, suppression | `GET` / `POST /domain/v2beta1/dns-zones` ; `PATCH` / `DELETE /domain/v2beta1/dns-zones/{dns_zone}` |
| Enregistrements : liste (paginée, filtres `name`, `type`, `id`, `page`, `page_size`) | `GET /domain/v2beta1/dns-zones/{dns_zone}/records` |
| Enregistrements : modification groupée | `PATCH /domain/v2beta1/dns-zones/{dns_zone}/records` |
| Enregistrements : tout effacer | `DELETE /domain/v2beta1/dns-zones/{dns_zone}/records` |
| Serveurs de noms de la zone | `GET` / `PUT …/dns-zones/{dns_zone}/nameservers` |
| Export et import d'une zone brute | `GET` / `POST …/dns-zones/{dns_zone}/raw` |
| Versions de zone (100 au plus, la plus ancienne retirée), différence, restauration | `GET …/dns-zones/{dns_zone}/versions`, `GET …/dns-zones/version/{id}/diff`, `POST …/version/{id}/restore` |
| Domaine externe (zone hébergée chez Scaleway pour un domaine acheté ailleurs) | `POST /domain/v2beta1/external-domains`, `DELETE …/external-domains/{domain}` |
| Achat, renouvellement, transfert d'un domaine | `POST /domain/v2beta1/buy-domains`, `…/renew-domains`, `…/domains/transfer-domains` |
| Disponibilité d'un nom | `GET /domain/v2beta1/search-domains` (10 noms au plus) |
| DNSSEC du domaine | `POST …/domains/{domain}/enable-dnssec`, `…/disable-dnssec` |

* **Modification groupée** (`UpdateDNSZoneRecordsRequest`) : `changes` (liste ; chacune contient
  exactement un de `add`, `set`, `delete`, `clear`), `return_all_records`,
  `disallow_new_zone_creation` (« la création de la zone cible est désactivée par défaut »),
  `serial` facultatif. `set` et `delete` désignent leur cible par `id` **ou** par `id_fields`
  (`name`, `type`, `data` et `ttl` facultatifs). « All edits will be versioned. »
* **Enregistrement** (`Record`) : `id`, `name` (relatif à la zone), `type`, `data`, `ttl`,
  `priority`, **`comment`** (facultatif), et des réglages « intelligents » (GeoIP, service HTTP,
  pondération, vues) que Lyxal n'utilise pas.
* **Types** : A, AAAA, CNAME, TXT, SRV, TLSA, MX, NS, PTR, CAA, ALIAS, LOC, SSHFP, HINFO, RP, URI,
  DS, NAPTR, DNAME, SVCB, HTTPS.
* **Zone** (`DNSZone`) : `domain`, `subdomain`, `ns`, `ns_default`, `ns_master`, `status`
  (`active`, `pending`, `error`, `locked`), `message`, `updated_at`, `project_id`.
* **Serveurs de noms** par défaut : `ns0.dom.scw.cloud`, `ns1.dom.scw.cloud` ; un domaine externe
  est d'abord validé (enregistrement TXT), puis ses serveurs de noms sont changés **chez son
  bureau d'enregistrement** par une personne. Sources :
  [Add an external domain](https://www.scaleway.com/en/docs/domains-and-dns/how-to/add-external-domain/),
  [FAQ](https://www.scaleway.com/en/docs/faq/domains-and-dns).
* **Achat** (`RegistrarAPIBuyDomainsRequest`) : `domains`, `duration_in_years`, `project_id`,
  contacts propriétaire, administratif et technique (identifiant d'un contact existant ou contact
  nouveau, avec extensions propres à `.fr` / `.eu`). Engage une dépense.
* **Écriture des données** (lue dans `dns-update`, fournisseur Scaleway) : MX écrit
  `"<priorité> <cible>."` avec `priority` renseigné ; TXT écrit **entre guillemets**, guillemets
  intérieurs échappés ; `disallow_new_zone_creation: true` à chaque `PATCH`. **Non vérifié** :
  découpage d'un TXT de plus de 255 octets (clé DKIM RSA de 2 048 bits) et nom de l'apex (`""`
  ou `@`).
* **Propagation** : aucune durée publiée ; la documentation montre le statut de zone `active`
  une fois les serveurs de noms en place. La vérification se fait donc en interrogeant les
  serveurs faisant autorité.

### 1.3. Instances : IP flexibles, DNS inverse, groupes de sécurité, SMTP

Chemins relevés dans `api/instance/v1/instance_sdk.go`
([fichier](https://github.com/scaleway/scaleway-sdk-go/blob/master/api/instance/v1/instance_sdk.go)) :

| Usage | Méthode et chemin |
| :--- | :--- |
| Serveurs : liste, création, lecture, modification, actions | `GET` / `POST /instance/v1/zones/{zone}/servers`, `GET` / `PATCH` / `DELETE …/servers/{id}`, `POST …/servers/{id}/action` |
| IP flexibles : liste, réservation, lecture, modification (dont **`reverse`**), libération | `GET` / `POST /instance/v1/zones/{zone}/ips`, `GET` / `PATCH` / `DELETE …/ips/{ip}` |
| Groupes de sécurité et règles | `…/security_groups`, `…/security_groups/{id}/rules` |

* `UpdateIPRequest` : `reverse` (« reverse domain name », valeur effaçable), `tags`, `server`.
  Types d'IP : `routed_ipv4`, `routed_ipv6`.
* **IPAM** (`api/ipam/v1/ipam_sdk.go`) : `PATCH /ipam/v1/regions/{region}/ips/{ip_id}` avec
  `reverses: [{ hostname, address }]` — nécessaire pour l'**IPv6** (la console ne règle que la
  première adresse d'un /64). Sources : SDK Go ;
  [Set IP reverse (IPAM)](https://www.scaleway.com/en/docs/ipam/api-cli/set-ip-reverse/).
* **Préalable du DNS inverse** : un enregistrement A (ou AAAA) qui pointe vers l'adresse doit
  exister ; la documentation annonce jusqu'à 24 heures pour la prise en compte ; le nom par défaut
  `*.pub.instances.scw.cloud` nuit à la délivrabilité. Sources :
  [Configure reverse DNS (Instances)](https://www.scaleway.com/en/docs/instances/how-to/configure-reverse-dns/),
  [Elastic Metal](https://www.scaleway.com/en/docs/elastic-metal/how-to/configure-reverse-dns-flexible-ip/).
* **SMTP** : les ports SMTP sortants (25, 465, 587) sont bloqués par défaut sur les Instances ;
  on les ouvre en cochant « Enable SMTP » dans le groupe de sécurité, après **vérification
  d'identité** du compte. Sources :
  [Send emails from your Instance](https://www.scaleway.com/en/docs/instances/how-to/send-emails-from-your-instance/),
  [Elastic Metal : enable SMTP](https://www.scaleway.com/en/docs/elastic-metal/how-to/enable-smtp/),
  [témoignage](https://blog.wirelessmoves.com/?p=13855).
  Dans l'API, le champ `enable_default_security` du groupe de sécurité porte ce blocage, avec ce
  commentaire du SDK : « true if SMTP is blocked on IPv4 and IPv6. **This feature is read only,
  please open a support ticket if you need to make it configurable.** » **Conclusion : l'état se
  lit par API, il ne se change pas par API.**

### 1.4. Erreurs et limites de débit

* Corps d'erreur (`scw/errors.go`) : `message`, `type`, `resource`, `fields`, code HTTP. Types
  reconnus : `invalid_arguments` (détail par champ : `unknown`, `required`, `format`,
  `constraint`), `quotas_exceeded`, `transient_state`, `not_found`, `locked`,
  `permissions_denied`, `out_of_stock`, `resource_expired`, `denied_authentication` (`jwt`,
  `api_key`, `expired`…), `precondition_failed`, `unknown_resource`, `invalid_request_error`.
* **Limites de débit** : aucune valeur publiée pour les API Domains, Instances ou IPAM (seules
  les API d'IA générative et le stockage objet en publient). Un dépassement répond `429`. Sources :
  [rate limits (IA générative)](https://www.scaleway.com/en/docs/generative-apis/reference-content/rate-limits/),
  [quotas d'organisation](https://www.scaleway.com/en/docs/organizations-and-projects/organization/organization-quotas/),
  [catalogue apis.io](https://apis.io/rate-limits/scaleway/scaleway-rate-limits/) (source
  secondaire). Le client de Lyxal se limite donc lui-même et respecte `429` et `Retry-After`.

### 1.5. Région Europe

Toutes les régions de Scaleway sont en Europe : Paris (`fr-par`), Amsterdam (`nl-ams`), Varsovie
(`pl-waw`) ; l'API publique est servie par `api.scaleway.com`.

---

## 2. Fournisseurs futurs (en bref)

### 2.1. OVHcloud

* Points d'entrée : `https://eu.api.ovh.com/1.0` (Europe), `https://ca.api.ovh.com/1.0`,
  `https://api.us.ovhcloud.com/1.0`. DNS : `GET` / `POST /domain/zone/{zone}/record`,
  `GET` / `PUT` / `DELETE …/record/{id}`, puis **`POST /domain/zone/{zone}/refresh`** obligatoire
  pour publier. Source : `dns-update`, `src/providers/ovh.rs` ; lego, `providers/dns/ovh/ovh.go`.
* **Authentification historique** : en-têtes `X-Ovh-Application`, `X-Ovh-Consumer`,
  `X-Ovh-Timestamp`, `X-Ovh-Signature` = `"$1$" + SHA-1(secret+consumer+méthode+url+corps+horodatage)`
  (même source). **SHA-1 n'est pas offert par `lyxal_crypto`** (seule la vérification
  HMAC-SHA1 l'est) : cette voie exigerait une extension cryptographique.
* **Comptes de service OAuth2** (flux *client credentials*), utilisables avec les API v1 et v2 :
  jeton demandé à `https://www.ovh.com/auth/oauth2/token` (Europe), droits par politiques IAM.
  Aucune primitive cryptographique nouvelle. Sources :
  [Authenticate with a service account](https://docs.ovhcloud.com/en/guides/account-and-service-management/account-information/authenticate-api-with-service-account),
  [Manage service accounts](https://docs.ovhcloud.com/en/guides/manage-and-operate/api/manage-service-account).
* DNS inverse : `POST /ip/{bloc}/reverse` (`ipReverse`, `reverse`) — **de mémoire, non vérifié**
  (aucune source joignable) ; OVHcloud exige aussi un enregistrement direct correspondant.
* Limites de débit de l'API Public Cloud :
  [API rate limits](https://docs.ovhcloud.com/en/guides/public-cloud/cross-functional/api-rate-limits).

### 2.2. Bunny DNS

* `https://api.bunny.net`, en-tête `AccessKey` ; zones `GET /dnszone`, enregistrements
  `PUT /dnszone/{zoneId}/records` (ajout), `POST …/records/{id}` (modification),
  `DELETE …/records/{id}` ; types numériques (A = 0, AAAA = 1, CNAME = 2, TXT = 3, MX = 4,
  SRV = 8, CAA = 9, NS = 12, TLSA = 15). Limites : 5 000 enregistrements par zone, 500 zones par
  compte ; `429` en cas d'excès, sans chiffre publié. Bunny n'héberge pas d'IP de serveur : pas
  de DNS inverse. Sources : [API Bunny](https://docs.bunny.net/reference),
  [Add DNS record](https://docs.bunny.net/api-reference/core/dns-zone/add-dns-record),
  [DNS limits](https://docs.bunny.net/dns/limits.md) ; `dns-update`, `src/providers/bunny.rs`.
* Un ancien prototype Lyxal (`Lyxal_Solution-main/Lyxal_Solution/Lyxal_Surreal/infrastructure/`,
  tables `bunny_*`, worker en Go) existe dans le dépôt ; il est antérieur aux standards actuels et
  n'est pas repris.

---

## 3. Projets libres de référence (idées reprises, aucun code copié)

| Projet | Licence | Idée reprise dans le plan |
| :--- | :--- | :--- |
| [DNSControl](https://github.com/StackExchange/dnscontrol) | MIT | État désiré déclaré, calcul d'un écart puis application ; [`NO_PURGE`](https://github.com/StackExchange/dnscontrol/blob/main/documentation/language-reference/domain-modifiers/NO_PURGE.md) (ne jamais effacer ce qu'on n'a pas créé) et [`IGNORE`](https://github.com/StackExchange/dnscontrol/blob/main/documentation/language-reference/domain-modifiers/IGNORE.md) (partager une zone avec un autre système sans boucle de réécriture). Lyxal applique l'équivalent de `NO_PURGE` à toute zone, par défaut et sans réglage. |
| [octoDNS](https://github.com/octodns/octodns) | MIT | **Seuils de sécurité** d'un plan (`octodns/provider/plan.py`) : refus d'un plan qui modifie ou supprime plus de 30 % des enregistrements existants quand la zone en compte au moins 10 (`MAX_SAFE_UPDATE_PCENT`, `MAX_SAFE_DELETE_PCENT`, `MIN_EXISTING_RECORDS`), sauf forçage. |
| [external-dns](https://github.com/kubernetes-sigs/external-dns) | Apache-2.0 | **Registre de propriété** : marquer ce que le programme possède pour ne jamais toucher le reste ([TXT registry](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/registry/txt.md)). Lyxal garde le registre **dans sa base** (et une marque dans le champ `comment` quand le fournisseur en a un) plutôt que dans des TXT supplémentaires qui encombrent la zone. Mode « plan seulement » (`--dry-run`). |
| [lego](https://github.com/go-acme/lego) | MIT | Un fournisseur par service derrière une interface minimale ; attente de la propagation en interrogeant les serveurs **faisant autorité** avant de déclarer un enregistrement publié. |
| [`dns-update`](https://github.com/stalwartlabs/dns-update) (Stalwart Labs) | Apache-2.0 OR MIT | Forme exacte des appels Scaleway, OVHcloud, Bunny (lue pour le plan). Licence compatible ; **non retenue comme dépendance** : interface impérative sans notion de propriété, plus de 70 fournisseurs inutiles, TLS et cryptographie propres (`ring` ou `aws-lc-rs`, `rustls`, signature SHA-1 d'OVHcloud), contraires au §11.3. |

Aucun de ces projets n'est sous licence incompatible ; aucun fichier n'est copié. Si un extrait de
`dns-update` (MIT) était transposé à l'écriture, il serait inscrit dans un `SOURCES.md` du module.
