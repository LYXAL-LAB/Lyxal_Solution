# Architecture Réseau de Lyxal Network

## Vision et Philosophie

**Lyxal Network** est le système nerveux distribué de la plateforme Lyxal. Il est conçu pour être une brique purement **réseau**, agnostique de la logique métier, et modulaire à l'extrême.

L'objectif est de fournir une "Table Périodique des Éléments Réseau" où chaque composant (Transport, Protocole, Sécurité) est isolé, interchangeable et standardisé. Cette architecture permet à une Intelligence Artificielle ou à un développeur d'assembler rapidement des topologies réseau complexes en combinant ces briques élémentaires.

---

## Structure Modulaire

L'architecture est divisée en couches fonctionnelles strictes. Chaque couche a une responsabilité unique.

### 1. Fondations (`foundations/`)
*L'ADN du réseau. Ces composants définissent "qui" communique et "comment" on l'adresse.*

*   **`core/`** : Les traits abstraits et interfaces que tous les module doivent implémenter (`Transport`, `StreamMuxer`, `Protocol`). C'est le contrat légal du système.
*   **`identity/`** : Gestion de l'identité cryptographique des pairs (`PeerId`, paires de clés Ed25519/RSA/Secp256k1).
*   **`multiaddr/`** : Système d'adressage universel composable (ex: `/ip4/127.0.0.1/tcp/8080/ws`).
*   **`swarm/`** : Le chef d'orchestre qui gère l'état global, les connexions actives et le dispatch des événements.

### 2. Transports (`transports/`)
*Les tuyaux physiques. Couche responsable de déplacer des octets d'un point A à un point B.*

*   **`tcp/`** : Transport fiable standard, universellement supporté.
*   **`udp/`** : Transport non-fiable rapide (base pour QUIC/WebRTC).
*   **`quic/`** : Transport moderne sur UDP, faible latence, chiffrement natif.
*   **`webrtc/`** : Transport P2P navigateur-compatible, traversée NAT native via ICE.
*   **`websocket/`** : Tunneling TCP compatible navigateur/serveur.

### 3. Sécurité (`security/`)
*La protection des tuyaux. Couche responsable de l'authentification et du chiffrement.*

*   **`noise/`** : Framework de protocole de chiffrement moderne (inspiré de Signal), performant et formellement vérifié.
*   **`tls/`** : Standard de sécurité du web (TLS 1.3).
*   **`psk/`** : Pre-Shared Key pour réseaux privés (Clusters fermés).
*   **`plaintext/`** : Mode sans chiffrement (Debug/Tests uniquement).

### 4. Multiplexing (`multiplexing/`)
*Optimisation des tuyaux. Permet plusieurs conversations simultanées sur une seule connexion.*

*   **`yamux/`** : Multiplexeur simple et robuste développé par Hashicorp.
*   **`mplex/`** : Multiplexeur historique (maintenance).
*   **`quic-mux/`** : Multiplexage natif offert par le protocole QUIC.

### 5. Connectivité & NAT (`connectivity/`)
*Franchir les obstacles. Outils pour traverser les pare-feux et routeurs.*

*   **`nat-traversal/`** :
    *   **STUN** : Découverte de son IP publique.
    *   **TURN** : Relais de trafic si P2P impossible.
    *   **ICE** : Orchestration de la meilleure route possible.
    *   **Hole Punching** : Techniques pour percer les NATs.
    *   **AutoNAT** : Service de détection automatique de l'accessibilité.
*   **`relay/`** : Protocole Circuit Relay v2 pour relayer le trafic via un tiers.

### 6. Découverte (`discovery/`)
*L'annuaire dynamique. Comment trouver d'autres pairs dans le réseau.*

*   **`mdns/`** : Découverte locale (LAN) sans configuration (ZeroConf).
*   **`kad-dht/`** : Table de Hachage Distribuée (Kademlia) pour la découverte à l'échelle mondiale.
*   **`rendezvous/`** : Points de rencontre pour pairs derrière des NATs stricts.
*   **`gossip-discovery/`** : Découverte organique par propagation de rumeur.

### 7. Messagerie (`messaging/`)
*Échanger des données. Les patrons de communication applicatifs.*

*   **`gossipsub/`** : Pub/Sub maillé efficace pour la diffusion de messages (ex: Blockchains).
*   **`floodsub/`** : Diffusion par inondation simple.
*   **`request-response/`** : RPC direct un-à-un optimisé.
*   **`direct-stream/`** : Flux de données brut continu.

### 8. Moteurs Internes (`engines/`)
*Les blocs moteurs bruts. Implémentations bas niveau de protocoles standards.*

*   **`webrtc-rs/`** : Stack WebRTC complète (ICE, DTLS, SCTP, RTP, RTCP).
*   **Autres moteurs futurs** : (ex: Consensus RAFT, implémentations WASM, etc.)

---

## 📂 Proposition d'Arborescence Complète

Voici à quoi ressemble la structure de fichiers concrète du projet `lyxal_network` :

```text
lyxal_network/
│
├── foundations/           (ou core/)
│   ├── core/              (Traits abstraits)
│   ├── identity/          (PeerId, Keys)
│   ├── multiaddr/         (Parsing adresses)
│   └── swarm/             (Orchestrateur)
│
├── transports/            (Couche 1-4)
│   ├── tcp/
│   ├── udp/
│   ├── quic/
│   ├── webrtc/
│   └── websocket/
│
├── security/              (Sécurité)
│   ├── noise/
│   ├── tls/
│   ├── psk/
│   └── plaintext/
│
├── multiplexing/          (Muxers)
│   ├── yamux/
│   └── mplex/
│
├── connectivity/          (NAT & Relais)
│   ├── nat-traversal/
│   │   ├── stun/
│   │   ├── turn/
│   │   └── ice/
│   └── relay/
│
├── discovery/             (Découverte)
│   ├── mdns/
│   ├── kad-dht/
│   └── rendezvous/
│
├── messaging/             (Protocols App)
│   ├── gossipsub/
│   ├── floodsub/
│   └── request-response/
│
└── engines/               (Moteurs Bas Niveau)
    └── webrtc-rs/         (Le fork WebRTC complet)
```

---

## Principes de Développement

1.  **Isolation Stricte** : `lyxal_network` ne connaît PAS le contenu des données (vidéo, JSON, binaire). Il ne fait que les transporter.
2.  **Extensibilité** : Pour ajouter le Bluetooth, on crée juste un dossier dans `transports/bluetooth/` qui implémente le trait `Transport`. Le reste du système n'a pas besoin de changer.
3.  **Composition** : Une application Lyxal est définie par sa composition.
    *   *Exemple Chat:* TCP + Noise + Yamux + GossipSub.
    *   *Exemple Video Conf:* WebRTC + Noise + PubSub.
4.  **Auditabilité** : La structure permet de voir immédiatement les manques ("Il manque un transport Tor dans `transports/`").

---

## Intégration dans l'Écosystème Lyxal

`lyxal_network` est la couche 0.
- **`lyxal_media`** utilisera `lyxal_network` pour transporter les flux RTP.
- **`lyxal_compute`** utilisera `lyxal_network` pour distribuer les tâches de calcul.
- **`lyxal_db`** utilisera `lyxal_network` pour la réplication et le consensus de données.

Cette séparation garantit que le code réseau reste pur, maintenable et hautement performant.
