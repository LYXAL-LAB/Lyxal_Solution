# Plan de Restructuration : Lyxal Network

Ce document définit la stratégie de migration vers une architecture modulaire et souveraine pour le noyau réseau de Lyxal.

## 🎯 Objectifs
1. **Désassemblage** : Séparer les moteurs de protocoles (Engines) des implémentations complètes.
2. **Standardisation** : Utiliser des noms de dossiers basés sur les RFC (ex: ice, dtls, srtp).
3. **Internalisation** : Réduire la dépendance aux crates externes non maîtrisés.

## 📂 Structure cible

```text
lyxal_network/
├── engines/               # Moteurs de protocoles purs (bas niveau)
│   ├── webrtc/            # webrtc-rs components (ice, dtls, stun, etc.)
│   └── crypto/            # noise, tls, plaintext
├── implementations/       # Stacks complètes
│   ├── webrtc/            # RTCPeerConnection orchestré
│   └── sfu/               # Selective Forwarding Unit
├── transports/            # Adaptateurs physiques (libp2p)
│   ├── tcp, quic, webrtc, websocket
├── security/              # Upgrades de canaux sécurisés
│   └── noise, tls, pnet
└── foundations/           # Core traits, Identity, Multiaddr
```

## 🏗 Phases d'exécution
1. **Phase 1** : Création de la nouvelle arborescence.
2. **Phase 2** : Migration des composants WebRTC.
3. **Phase 3** : Isolation des briques cryptographiques.
4. **Phase 4** : Mise à jour des dépendances et compilation globale du noyau.
