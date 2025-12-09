# Architecture Écosystémique Lyxal : Exploitation des Primitives SurrealDB

**Date :** 08 Décembre 2025  
**Sujet :** Synergies Techniques SurrealDB x Lyxal  
**Objectif :** Maximiser la performance et réduire le code propriétaire en exploitant les briques natives.

---

## 1. Vue d'Ensemble : L'Architecture "Parasite Vertueux"

Au lieu de réinventer la roue (stockage fichier, langage de script, cache), Lyxal va s'appuyer ("parasiter" positivement) sur les composants internes de SurrealDB. Cela réduit la surface de code à maintenir et hérite automatiquement de la robustesse de la base de données.

---

## 2. Exploitation de SurrealKV (Le Moteur de Stockage)

SurrealKV est le Key-Value Store distribué et transactionnel sous-jacent.

### A. Stockage des PDF (Blob Storage)
Plutôt que d'utiliser un File System (FS) ou S3, Lyxal stockera les binaires PDF directement dans le KV.
*   **Structure de Clé :** `lyxal::blobs::{uuid_document}::{version}`
*   **Avantages :**
    *   **Transactions ACID :** Si la génération plante, le fichier partiel n'est jamais commité. Pas de fichiers corrompus "qui traînent".
    *   **Réplication Cluster :** Si SurrealDB est en cluster, les documents sont automatiquement répliqués sur tous les nœuds.
    *   **Performance :** Écriture séquentielle ultra-rapide (Log Structured Merge Tree).

### B. Cache de Compilation (Template Cache)
Les templates PDF sont parsés et compilés en structures binaires optimisées.
*   **Stratégie :** Stocker le résultat de la compilation dans SurrealKV (RAM/Disk).
*   **Gain :** Temps de démarrage de génération < 1ms pour les templates fréquents.

---

## 3. Exploitation de SurrealQL (Le Cerveau Dynamique)

Lyxal abandonne les langages de templating limités (Handlebars, Mustache) pour adopter SurrealQL comme langage de script natif DANS les documents.

### A. "Smart Templates"
Le template PDF n'est plus passif. Il contient de la logique d'accès aux données.
*   **Exemple de syntaxe dans le designer Lyxal :**
    ```surrealql
    // Dans une cellule de tableau PDF
    FOR $line IN (SELECT * FROM order_line WHERE order = $parent.id) {
        RETURN $line.amount * $line.quantity;
    }
    ```
*   **Exécution :** Lyxal exécute ces requêtes à la volée via le contexte interne de la BDD pendant la génération, sans latence réseau.

### B. Fonctions Custom
Lyxal exposera ses primitives au langage SQL :
*   `lyxal::merge(pdf1, pdf2)`
*   `lyxal::sign(pdf, certificat)`
*   `lyxal::extract_text(pdf)`

---

## 4. Exploitation de SurrealML (L'Intelligence Artificielle)

Transformation de Lyxal en plateforme de **Gestion Électronique de Documents Intelligente (GED-IA)**.

### A. Classification & Extraction (OCR)
À l'ingestion d'un PDF externe :
1.  Lyxal extrait le texte/images.
2.  Passe le contenu à un modèle SurrealML (ex: BERT onnx).
3.  Le modèle classifie : "Type: Facture Fournisseur".
4.  Le modèle extrait les métadonnées : "Montant: 500€", "Date: 2025-01-01".

### B. RAG (Retrieval Augmented Generation)
*   Lyxal génère automatiquement les **Embeddings Vectoriels** du contenu des PDF générés.
*   Permet aux utilisateurs de poser des questions en langage naturel sur leur base documentaire : *"Quel est le total des factures du fournisseur Acme en 2024 ?"*.

---

## 5. Exploitation des Live Queries (Temps Réel)

Le flux de distribution des documents devient événementiel.

### Le Flux "Zéro Latence"
1.  Le Client Web s'abonne : `LIVE SELECT * FROM document WHERE status = 'generating'`.
2.  Le Serveur lance la génération asynchrone (Thread Offloading).
3.  Dès que Lyxal écrit le résultat dans SurrealKV, un événement est déclenché.
4.  Le Client reçoit instantanément la notification de fin et le lien de téléchargement (ou le blob direct).
5.  **Expérience Utilisateur :** Feedback immédiat, barre de progression fluide, pas de rechargement de page.

---

## 6. Synthèse Technique

| Composant Surreal | Rôle dans Lyxal | Bénéfice Clé |
| :--- | :--- | :--- |
| **SurrealKV** | File System & Cache | ACID, Réplication, Vitesse |
| **SurrealQL** | Moteur de Template | Logique de données complexe sans code |
| **SurrealML** | Moteur d'Analyse | GED Intelligente & Recherche Sémantique |
| **Live Queries** | Protocole de Transport | UX Temps Réel moderne |

Cette architecture fait de Lyxal non pas un "plugin", mais une **capacité native** de la base de données, indissociable et hautement performante.

