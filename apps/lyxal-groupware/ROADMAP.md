# Feuille de route — `lyxal-groupware`

Évolutions à venir de l'hôte. L'état actuel est décrit dans le [`README.md`](README.md). Aucune
étape ne démarre sans ordre du CTO et plan validé (`.agents/AGENTS.md` §3). Le programme est
décrit par `implementation_plan.md` à la racine du dépôt.

| Étape | Thème | Plan ou lot |
| :--- | :--- | :--- |
| 1 | TLS implicite, STARTTLS, certificats et rechargement, PROXY protocol | lot 3, partie 3c (`implementation_plan.md` de ce dossier) |
| 2 | Réception SMTP, résolveur DNS, liste de blocage et bannissement | lot 5 |
| 3 | Envoi et dépôt authentifié (587, 465) | lot 6 |
| 4 | IMAP | lot 8 |
| 5 | POP3 | lot 9 |
| 6 | ManageSieve (dernier protocole : retrait de `UnavailableHandler`) | lot 10 |
| 7 | JMAP et découverte `/.well-known/…` sur le port HTTP | lot 12 |
| 8 | Certificats de `lyxal_secrets`, ACME, échéances, OCSP | lot 13 |
| 9 | DAV (agendas, contacts) ; séparation du port public et du port interne de santé | lot 15 |
| 10 | Durcissement, charge, essais réels | lots 21, 22 |

## 1. TLS et PROXY (3c)

Critères d'acceptation (plan du lot 3, §6.4 à §6.6) :

- [ ] modes `starttls` et `implicit` acceptés par la configuration, avec les règles G7 (implicite
      pour 465, 993, 995 ; STARTTLS pour 25, 587, 143, 110, 4190 ; `none` seulement pour `smtp`) ;
      écoute TLS sans certificat refusée ;
- [ ] configuration TLS fabriquée par `lyxal_crypto::tls_server_config` sur un seul
      `TlsCertificateStore`, `tokio-rustls` pour la poignée de main sous délai (30 s) ; refus en
      écoute implicite sans poignée de main ;
- [ ] `TlsUpgrade` implémenté par l'hôte et offert aux sessions des écoutes `starttls` ;
      `TlsState` renseigné ;
- [ ] certificats par fichiers PEM, clé lisible par d'autres refusée, worker `mail.tls_reload`
      (relecture si l'empreinte BLAKE3 change, ancien certificat gardé si le nouveau est
      invalide, sonde « dégradé ») ; code `GROUPWARE_TLS_CERTIFICATE_INVALID` ;
- [ ] PROXY v1 et v2 exigé depuis `proxy_networks`, jamais lu ailleurs, sous délai (5 s) ;
      mesures des en-têtes refusés et des poignées de main en échec ;
- [ ] port HTTP servable derrière PROXY ou TLS (`lyxal_host::http::serve_connection`).

## 2. Points relevés au lot 3

* **Offre du code source (AGPL, article 13)** : le moyen de proposer le source aux utilisateurs
  d'un service réseau modifié relève du CTO (décision F2) ; rien n'est codé.
* **Avant d'héberger des handlers d'événements ou des tâches** : un seul handler par type
  d'événement et par processus (`lyxal_event`) ; files du planificateur réservées à un hôte
  (`crates/lyxal_runtime/ROADMAP.md`).
* **Limites partagées entre nœuds** : compteurs par réseau en mémoire et par nœud ; modèle
  partagé à décider au lot 5 ou au lot 21 selon les mesures.
* **Essai de supervision** : une écoute dont la boucle échoue est redémarrée par le runtime sur
  la même socket (sockets gardées hors du worker) ; aucun cas d'échec ne peut être provoqué de
  l'extérieur au lot 3, l'essai viendra avec le premier cas réel.
