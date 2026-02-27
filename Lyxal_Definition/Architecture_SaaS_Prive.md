# Lyxal Architecture : Le Concept du "SaaS Privé" Souverain

Ce document définit la vision stratégique et technique de Lyxal Solution, alliant l'efficacité d'une infrastructure type "Google" à la souveraineté totale des données grâce au Rust et au fork de SurrealDB.

---

## 1. La vision : "Souveraineté Industrielle"

L'objectif de Lyxal est de proposer une expérience fluide (Cloud OS) pour les entreprises et créateurs d'agents IA, sans les compromis de sécurité et de maintenance des solutions traditionnelles.

| Modèle | Philosophie | Inconvénient |
| :--- | :--- | :--- |
| **Nextcloud** | Silos isolés (Artisanal) | Maintenance complexe, mise à jour difficile, lourd en ressources. |
| **Google** | Instance unique (Industriel) | Zéro souveraineté, données mélangées, dépendance étrangère. |
| **LYXAL** | **Instance unique avec Realms** | **L'efficacité de Google avec l'isolation d'un coffre-fort privé.** |

---

## 2. Le Concept Technique : "SaaS Privé" (Isolation Physique, Code Unique)

L'architecture Lyxal permet de stocker les données d'un client sensible sur une machine physique différente, tout en gardant un logiciel unique pour piloter l'ensemble.

### A. Séparation du "Cerveau" (Code) et du "Corps" (Donnée)
Le code Rust (`lyxal_dav`, `lyxal_email`, `lyxal_agent`) est **apatride (stateless)**. 
*   Il agit comme un pilote universel.
*   Il peut être déployé sur n'importe quel cluster.
*   Il ne contient aucune donnée client, seulement la logique de protocole.

### B. Sharding (Morcellement) par Namespace
Grâce au fork de **SurrealDB** et au moteur **LyxalKV**, le stockage est redirigé intelligemment :
1.  **Client Standard** : Les données sont stockées sur le cluster mutualisé (SSD classiques).
2.  **Client Sensible (Banque, État)** : Les données (le Namespace SurrealDB) sont écrites sur un **serveur physique dédié et chiffré**.
3.  **Le Mapping** : Le backend Lyxal identifie le Namespace et "branche" dynamiquement les tuyaux de lecture/écriture vers la machine physique correspondante. Les données ne touchent jamais le disque dur des autres clients.

### C. Le rôle de Sozu (Routeur Intelligent)
Le proxy **Sozu** (en Rust) agit comme le poste de garde :
*   Il intercepte les requêtes (ex: `dav.ministere.lyxal.fr`).
*   Il route le flux vers une instance isolée du backend si nécessaire.
*   Il garantit que même en mémoire RAM, l'isolation peut être maintenue pour les clients critiques.

---

## 3. Les avantages majeurs de l'approche "Instance Unique"

Contrairement au modèle "un serveur par client" (type Nextcloud), Lyxal conserve un **code source unique** :

1.  **Maintenance Industrielle** : Un seul `git push` met à jour 1000 clients instantanément.
2.  **Économie d'Échelle** : L'empreinte mémoire du Rust permet de gérer des milliers de "Realms" sur une infrastructure réduite.
3.  **Performance Native** : Dans cet écosystème, l'Agent IA (Obot/Goose) accède aux données en mémoire (RAM) via le moteur SurrealDB embedded, sans passer par le réseau internet. C'est 1000x plus rapide qu'une API classique.

---

## 4. Conclusion : La Promesse Lyxal

Vous n'offrez pas un simple logiciel, mais une **Infrastructure de Confiance** :
> *"La simplicité d'un compte unique, la performance du Full Rust, et la garantie physique que votre Namespace SurrealDB est votre propriété exclusive."*

---
*Document de référence généré pour le projet Lyxal Solution.*
