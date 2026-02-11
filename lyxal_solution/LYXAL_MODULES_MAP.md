# Carte des Modules Lyxal : Architecture Agent-First

Ce document définit la structure des **Primitifs d'Infrastructure** de Lyxal. L'objectif est de fournir un catalogue de capacités que les agents IA de Lyxal peuvent orchestrer de manière autonome, sans dépendance externe, via une interface unique.

---

## 1. Philosophie "Agent-Centric"
Dans l'écosystème Lyxal, l'infrastructure n'est plus une configuration statique mais un ensemble de **réflexes** et de **capacités** pour l'IA :
- **Autonomie** : L'Agent conçoit la topologie (DNS -> CDN -> Server) de lui-même.
- **Isolation** : Aucune sortie vers l'extérieur (Full Stack souverain).
- **Interface Unifiée** : Un seul flux de données pour le contrôle, la facturation et le déploiement.

---

## 2. Catégories & Modules (Les Primitifs)

### A. Domaine : Compute (Le Corps)
*Les ressources de calcul où l'agent exécute la logique métier.*
- **`lyxal_compute`** : Gestion des instances (VM/Serveurs).
- **`lyxal_os`** : Couche d'abstraction système et isolation des processus.
- **`lyxal_executor`** : Moteur d'exécution asynchrone pour les Flows (Rust/WASM).

### B. Domaine : Storage (La Mémoire)
*La persistance des données et de l'état de l'agent.*
- **`lyxalkv`** : Le moteur de stockage clé-valeur natif et atomique.
- **`lyxal_storage`** : Gestion des fichiers et des objets (Object Storage).
- **`lyxal_sync`** : Synchronisation multi-nœuds des données.

### C. Domaine : Edge & Network (Les Réflexes)
*La diffusion, le routage et la protection du trafic.*
- **`lyxal_cdn`** : Distribution de contenu géo-distribuée et cache intelligent.
- **`lyxal_dns`** : Résolution de noms et **DNS Pro** (DNSSEC, protection contre le DDoS, Anycast).
- **`lyxal_domains`** : Enregistrement de domaines et gestion automatisée des **Certificats SSL**. 
    - *Vente de Domaines (Partner: NameSilo)* : Utilisation de l'API NameSilo (ouverte et sandboxée) pour l'achat instantané via Agent IA.
    - *Protocole* : Implémentation des appels `registerDomain` et `checkRegisterAvailability`.
    - *Gestion WHOIS* : Primitifs pour la confidentialité et le cycle de vie du domaine.
- **`lyxal_security_edge`** : Pare-feu applicatif (WAF) et filtrage du trafic malveillant.
- **`lyxal_net`** : Couche réseau bas niveau (protocoles, VPC, tunnels).

### D. Domaine : Identity & Security (La Conscience)
*Contrôle d'accès et définition des entités.*
- **`lyxal_auth`** : Authentification et sessions (JWT, OAuth2).
- **`lyxal_iam`** : Gestion des permissions (Qui peut faire quoi).
- **`lyxal_security`** : Chiffrement et audit des journaux.

---

## 3. L'Interface Unique (Control Plane)
L'Agent interagit avec ces modules via une API unifiée (Unified Control Plane) qui permet de :
1. **Définir** une ressource (ex: `DEFINE BUCKET`).
2. **Mesurer** l'usage (en temps réel pour la facturation).
3. **Auto-réparer** les maillons faibles sans intervention humaine.

---

> [!TIP]
> **Vision 2027** : Le SaaS traditionnel disparaît. L'utilisateur ne loue plus un logiciel, il déploie un **Agent Souverain** sur Lyxal qui génère son propre logiciel et son infrastructure à la volée.
