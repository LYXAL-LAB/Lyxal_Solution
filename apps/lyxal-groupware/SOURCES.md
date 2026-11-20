# `lyxal-groupware` — provenance des sources

Registre de provenance de l'hôte (décisions F4 et P2 du programme courrier). Les sources figées,
la méthode et le rapport du tri du code propriétaire de Stalwart sont décrits dans
[`crates/lyxal_mail/SOURCES.md`](../../crates/lyxal_mail/SOURCES.md) (§1 et §2). **Règle : tout
élément porté d'un projet extérieur est inscrit ici**, dans le même changement que le code.

Le paquet déclare `license = "AGPL-3.0-only"`. Le code de Stalwart est pris sous l'option
`AGPL-3.0-only` de sa double licence ; aucune partie `LicenseRef-SEL` n'est utilisée (les
fichiers lus ne contiennent plus aucun extrait propriétaire après le tri, constaté). Texte de la
licence : `crates/lyxal_mail/LICENSES/AGPL-3.0-only.txt`.

## Éléments portés

| Élément de Lyxal | Projet | Commit | Licence | Chemin d'origine | Nature | Lot |
| :--- | :--- | :--- | :--- | :--- | :--- | :- |
| `src/net/bind.rs` (liaison des sockets, repli IPv4, contrôle de l'adresse liée, file d'attente, keepalive) | Stalwart | `3adead9` | `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue | `crates/common/src/config/server/listener.rs`, `crates/common/src/network/listen.rs` (`TcpListener::listen`, `is_bound_to`, `SocketOpts`) | porté (`SO_REUSEPORT`, `TOS`, `TTL` et tampons non repris ; `IPV6_V6ONLY` quand l'IPv4 est liée sur le même port) | 3 |
| `src/net/listener.rs` (boucle d'acceptation) | Stalwart | `3adead9` | idem | `crates/common/src/network/listen.rs` (`Listener::spawn`) | porté (boucle dans un `LyxalWorker`, arrêt par `CancellationToken`, sessions dans un `JoinSet` drainées puis abandonnées) | 3 |
| `src/net/tls.rs` (poignée de main TLS sous délai, mise à niveau STARTTLS) | Stalwart | `3adead9` | `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue | `crates/common/src/network/mod.rs` (`TcpAcceptor::Tls`, `SessionResult::UpgradeTls`) | porté (configuration `rustls` par `lyxal_crypto::tls_server_config` seulement ; ALPN par écoute ; mise à niveau offerte par le trait `TlsUpgrade` de `lyxal_mail`) | 3 |
| `src/net/proxy.rs` (PROXY protocol) | Stalwart | `3adead9` | idem | `crates/common/src/network/listen.rs` (lecture de l'en-tête par `proxy-header`, depuis `proxy_networks` seulement) | modèle (aucun code repris ; bibliothèque `proxy-header` 0.1.3, MIT) | 3 |
| `src/net/accept.rs` (pipeline d'acceptation) | Stalwart ; Mox | `3adead9` ; `b32f0de` | idem ; MIT | Stalwart `crates/common/src/network/listen.rs` (`build_session`) ; Mox `smtpserver/server.go` (ordre cadence puis connexions ouvertes) | modèle | 3 |

Chaque fichier porté garde son en-tête `SPDX-FileCopyrightText` d'origine, déclare
`SPDX-License-Identifier: AGPL-3.0-only` et décrit ses modifications pour Lyxal OS. Les autres
fichiers sont écrits pour Lyxal OS. Le code commun aux hôtes vient de `crates/lyxal_host`, qui ne
reçoit jamais de code porté.
