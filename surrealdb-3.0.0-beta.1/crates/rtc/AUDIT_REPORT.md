# Lyxal RTC: Rapport d'Audit Complet & Architecture

**Date :** 22 Janvier 2026
**Version Audité :** surrealdb-3.0.0-beta.1/crates/rtc
**Scope :** Architecture, Qualité Code, Comparaison "Google Grade", Intégration.

---

## 1. Résumé Exécutif

Le module `crates/rtc` est une implémentation **moderne, performante et saine** de la stack WebRTC, écrite en Rust pur. Contrairement aux wrappers classiques autour de la librairie C++ de Google (`libwebrtc`), Lyxal RTC utilise une architecture **"Sans-IO"**, découplant totalement la machine à états protocolaire de la couche réseau.

** Verdict Global :**
*   🟢 **Architecture Serveur (SFU)** : Excellente. Supérieure à Google libwebrtc pour la scalabilité serveur.
*   🟡 **Robustesse Réseau (3G/4G)** : Moyenne. Manque d'algorithmes avancés (BWE, FEC) pour gérer les réseaux très dégradés.
*   🔴 **Intégration Actuelle** : Inexistante. Le moteur est isolé et le serveur principal utilise un code "bouchon" (Mock).

---

## 2. Analyse Architecturale

L'espace de travail est divisé en trois strates logiques :

### A. Le Cœur : `rtc/` (Sans-IO Stack)
C'est le moteur pur. Chaque protocole est isolé dans sa propre crate.
*   **Approche** : Les fonctions prennent des `bytes` en entrée et retournent des `bytes` ou des états. Aucune socket, aucun thread, aucun `async` en dur.
*   **Composants** : `rtc-ice` (Connectivité), `rtc-dtls` (Sécurité), `rtc-srtp` (Chiffrement média), `rtc-sctp` (Data Channels).
*   **Avantage** : Testabilité maximale et portabilité (peut tourner dans un thread dédié, un actor system, ou même en WASM).

### B. L'API Standard : `webrtc/` (Async Wrapper)
Une surcouche compatible `Tokio` qui assemble les briques Sans-IO pour fournir une API familière aux développeurs WebRTC (`RTCPeerConnection`, `MediaStream`).
*   Sert de "Client SDK" ou de base pour des nœuds simples.

### C. Le Serveur : `sfu/` (Lyxal Media Engine)
L'application critique pour les besoins "Google Meet" ou "WhatsApp".
*   Utilise le framework **`retty`** pour gérer un pipeline d'I/O asynchrone haute performance.
*   **ServerStates** : Gestion centralisée des sessions et des routes.
*   **GatewayHandler** : Routeur de paquets. Actuellement configuré en mode "Broadcast" (envoi à tous).
*   **Auto-Négociation** : Détection dynamique des nouveaux flux et reconfiguration des pairs (Transeivers `SendOnly`).

---

## 3. Comparatif : Lyxal vs "Google Grade"

Nous comparons ici avec `libwebrtc` (utilisé par Chrome/Meet).

| Critère | Google (libwebrtc) | Lyxal RTC | Analyse |
| :--- | :--- | :--- | :--- |
| **Architecture** | Monolithique C++, Threading complexe | **Modulaire Rust, Sans-IO** | **Lyxal gagne** sur le serveur. Plus sûr (Memory Safety), plus scalable. |
| **Congestion Control** | Très Avancé (GCC, Trendline, BBR) | **Basique** (TWCC Mechanism) | **Google gagne**. Lyxal a les sondes (TWCC) mais pas le "cerveau" qui régule le débit finement. |
| **Correction Erreur** | Avancée (ULPFEC, RED, RTX) | **Partielle** (NACK, RTX) | **Google gagne**. Manque critique de FEC pour la faible latence sur réseaux instables. |
| **Simulcast/SVC** | Support Complet | **Support Structurel** | Lyxal a les structures de données mais pas encore la logique dynamique de bascule de qualité. |

**Conclusion "Grade"** :
*   Pour un réseau Fibre/Wifi Stable : **Grade A (Google Level)**.
*   Pour un réseau Mobile/Instable : **Grade C**.

---

## 4. Analyse des Cas d'Usage (Readiness)

### 📹 Cas "Google Meet" (Visioconférence)
*   **État** : Fonctionnel en "Laboratoire".
*   **Manque** : L'intégration dans `surrealdb-server`. Actuellement, le serveur officiel utilise un Mock.
*   **Risque** : Explosion de la bande passante sans Simulcast (si 10 personnes parlent en HD).

### 💬 Cas "WhatsApp" (Messagerie & VoIP)
*   **État** : Prêt.
*   **Force** : Le support **SCTP/DataChannels** est implémenté. Cela permet d'envoyer des messages textes/états avec une latence quasi-nulle (<100ms) sans passer par la base de données.
*   **VoIP** : Idem que Google Meet, attention à la qualité sur mobile.

### 🤖 Cas "Agent IA" (Real-time Voice)
*   **État** : Faisable.
*   **Mécanisme** : Créer un "Endpoint Virtuel" dans le SFU qui injecte/extrait l'audio via un pipe vers le modèle IA.
*   **Performance** : L'architecture Sans-IO est idéale pour minimiser la latence de traitement (Buffer -> IA -> Buffer).

---

## 5. Feuille de Route d'Intégration (Roadmap)

Pour passer du code source à un produit utilisable dans SurrealDB :

1.  **Phase 1 : Câblage (Immédiat)**
    *   Supprimer le code "Mock" dans `crates/server/src/rtc/sfu.rs`.
    *   Importer la crate `rtc` et connecter les sockets UDP du serveur au `GatewayHandler`.

2.  **Phase 2 : Robustesse (Moyen Terme)**
    *   Implémenter un contrôleur de bande passante simple (réduire la qualité si perte de paquets > 5%).
    *   Activer le Simulcast (High/Low streams).

3.  **Phase 3 : Fonctionnalités Agentiques (Long Terme)**
    *   API `join_as_agent()` pour permettre aux LLM de se connecter directement au flux RTP.

---

*Document généré par l'Unité Antigravity - Audit Lyxal.*
