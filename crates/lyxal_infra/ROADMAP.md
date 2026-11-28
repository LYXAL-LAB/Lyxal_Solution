# Feuille de route — `lyxal_infra`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le plan validé par
le CTO est [`implementation_plan.md`](implementation_plan.md) (découpage : §11). Aucune évolution
hors de ce plan ne démarre sans `implementation_plan.md` validé par le CTO
(`.agents/AGENTS.md` §3).

| Lot | Contenu |
| :-: | :--- |
| **1b** | Fournisseurs (plan §5) : traits `DnsProvider` / `HostingProvider`, `ProviderError`, `ProviderRegistry` ; client HTTP à adresses fixes (`reqwest`, TLS par `lyxal_crypto::tls_client_config(WebPki)`, seau à jetons par compte, `Retry-After`, recul exponentiel) ; adaptateur Scaleway (`/domain/v2beta1`, forme canonique, découpe des TXT à 255 octets, marque `lyxal:<clé>`) ; identifiants `ScalewayCredentials` lus dans `lyxal_secrets` (`SecretString`, `Debug` masqué) ; faux fournisseur HTTP ; `Reconciler` (une passe, plan §3.2, sur les fonctions du worker déjà en place) ; vérification sur les serveurs faisant autorité (`hickory-resolver`, rattachement à la zone parente) ; handlers des tâches `infra.zone_reconcile` et `infra.tick` ; planifications créées à l'installation ; `InfraModule`, `InfraHealthCheck` (`fn::infra_health`), `InfraMetrics` ; hébergement dans `lyxal-server` (`build.rs`, `src/modules/infra.rs`, section `[infra]`) ; essais de bout en bout |
| **2** | Intégration du courrier (plan §8) : `lyxal_mail` déclare MX, SPF, DKIM et DMARC de ses domaines par `fn::infra_records_declare` ; `lyxal-groupware` installe les fichiers SurrealQL de `lyxal_infra` |
| **3** | DNS inverse et inventaire (plan §9) : tables `infra_ip`, `infra_server`, `fn::infra_ip_reverse_declare`, `fn::infra_ip_list`, `fn::infra_server_list`, codes `INFRA_IP_*`, lecture du blocage SMTP |

Points ouverts, à trancher par le CTO :

* **Forme canonique d'une IPv6** : aucune primitive de `lyxal_core` ne met une adresse IPv6 en
  forme compressée (RFC 5952) ; la déclaration n'en contrôle que la validité et la casse. Une
  valeur déclarée non compressée (`2001:db8:0:0::1`) ne serait jamais égale à la valeur
  canonique relue chez l'hébergeur. Besoin d'extension du Core signalé (par exemple
  `fn::sanitize_ip`), non contourné localement.
* **Coût de la photo d'une grande zone** : 5 000 lignes contrôlées une par une par
  `fn::validation_fields_execute` prennent environ 9 s ; le plan lui-même est rapide (0,4 s).
  Si la mesure réelle l'impose, le contrôle par lots (`fn::validation_checks_report`,
  `.agents/AGENTS.md` §5.7.8) demande une décision du CTO.
* Reportés par le plan (§13) : MTA-STS et TLS-RPT, défi ACME DNS-01, défi `_lyxal-challenge`,
  fournisseurs OVHcloud et Bunny DNS, domaines externes, rotation automatique de la clé,
  comptes par organisation, DNSSEC et TLSA, écran d'administration et routes `/infra/*`.
