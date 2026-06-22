# Analyse des Nœuds Utilitaires n8n

Ce document répertorie les nœuds n8n qui ne sont pas des **Bridges** (APIs externes), mais des outils de logique ou de transformation interne.

## 1. Logique et Flux (Flow Control)
Gestion de la structure de l'exécution interne.

| Nœud | Description |
| :--- | :--- |
| **If** | Branchement conditionnel |
| **Switch** | Branchement multiple |
| **Merge** | Fusion de plusieurs branches |
| **Wait** | Temporisation (pause) |
| **NoOp** | Ne fait rien (organisation) |
| **StopAndError** | Arrêt du flux avec erreur personnalisée |

## 2. Transformation de Données (Data Utility)
Manipulation des types de données (String, Number, Date, JSON).

| Nœud | Description |
| :--- | :--- |
| **DateTime** | Calculs et formatage de dates |
| **Code / Function** | Exécution de scripts (JS) pour transformer la donnée |
| **ItemLists** | Manipulation de listes (Split, Sort, Filter, Aggregate) |
| **Set** | Création ou modification de variables de contexte |
| **HtmlExtract / Html** | Parsing et manipulation de contenu HTML |
| **Xml** | Conversion JSON <-> XML |
| **Markdown** | Conversion Markdown <-> HTML |
| **CompareDatasets** | Comparaison entre deux ensembles de données |

## 3. Fichiers et Binaire (Binary Utility)
Gestion des fichiers en mémoire sans appel API externe.

| Nœud | Description |
| :--- | :--- |
| **Files** | Manipulation globale de fichiers |
| **Compression** | Gzip, Zip, Unzip |
| **EditImage** | Redimensionnement, rotation d'images |
| **Read/WriteBinaryFile** | Lecture/Écriture sur le système de fichiers local |
| **MoveBinaryData** | Conversion Binaire <-> JSON |
| **ReadPdf** | Extraction de texte depuis un PDF |
| **SpreadsheetFile** | Conversion Excel/CSV <-> JSON |

## 4. Sécurité et Système (System Utility)
| Nœud | Description |
| :--- | :--- |
| **Crypto** | Hashage (MD5, SHA), HMAC, Chiffrement |
| **ExecuteCommand** | Exécution d'une commande shell locale |
| **ExecuteWorkflow** | Appel d'un autre workflow interne |

## 5. Triggers Internes (Points d'entrée)
| Nœud | Description |
| :--- | :--- |
| **Cron / Schedule** | Planification temporelle |
| **ManualTrigger** | Exécution manuelle |
| **ErrorTrigger** | Gestion globale des erreurs de workflow |
| **WorkflowTrigger** | Appel entrant depuis un autre workflow |

---

### Note pour Lyxal Bridge :
Ces nœuds ne possèdent généralement pas de `base_url` ni de `credentials` externes. Dans l'architecture Lyxal, ils devraient être implémentés comme des fonctions natives (Rust ou SurrealDB) plutôt que via le processus d'invocation réseau du Bridge.
