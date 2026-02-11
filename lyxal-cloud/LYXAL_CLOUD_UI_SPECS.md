# Spécifications UI : Lyxal Cloud (Control Plane)

Ce document définit les besoins fonctionnels et visuels pour l'interface d'administration "Lyxal Cloud".
Cette interface est distincte de la vue "Données" (Surrealist classique) et sert à piloter l'infrastructure.

## 1. Philosophie : "Le Cockpit Interne"
L'interface doit ressembler à un tableau de bord de pilotage d'infrastructure (type AWS Console ou Kubernetes Dashboard), pas à un éditeur SQL.

*   **Public** : Équipe Interne Lyxal (Administrateurs Système, Ops).
*   **PAS pour les clients finaux** : Les clients utilisent Surrealist en mode "Données" uniquement.
*   **Vibe** : Technique, Temps-réel, Dense en informations.

## 2. Modules Requis

### A. Cluster Overview (Vue d'Ensemble)
*   **Objectif** : Vérifier la santé physique de l'infrastructure.
*   **Composants** :
    *   **Raft Status Widget** : Qui est le Leader ? Combien de nœuds sont en vie (3/3, 2/3) ?
    *   **Resource Gauges** : CPU / RAM / Disque global du cluster.
    *   **Traffic Graph** : Requêtes/seconde globales.
    *   **Log Stream** : Dernières erreurs critiques du Kernel.

### B. Realm Manager (Gestion des Locataires)
*   **Objectif** : Gérer les instances virtuelles (les clients).
*   **Fonctions** :
    *   **Datagrid des Realms** : Liste filtrable (ID, Nom, Plan, Statut, Date création).
    *   **Actions** :
        *   `Create Realm` : Formulaire (Nom, Choix du Plan, Admin initial).
        *   `Suspend/Ban` : Bouton d'urgence pour couper l'accès.
        *   `Delete` : Suppression définitive.
    *   **Détail** : Voir la consommation spécifique d'un Realm (stockage utilisé, bande passante).

### C. Ledger & Billing (Facturation)
*   **Objectif** : Suivre l'argent et la consommation.
*   **Composants** :
    *   **Transactions Feed** : Flux temps-réel des événements facturables (ex: "Realm A: +1Go Stockage").
    *   **Revenue Chart** : Revenus estimés sur la période.
    *   **Unsettled Usage** : Liste des consommations non encore payées.

### D. Plans & Policies (Offres Commerciales)
*   **Objectif** : Définir ce que les clients achètent.
*   **Interface** :
    *   **Plan Editor** : Créer/Modifier un plan (ex: "Starter", "Pro", "Enterprise").
        *   Définir Quotas (Max RAM, Max Connexions).
        *   Définir Prix (Prix/Go, Prix/Req).
    *   **Policy Editor (Avancé)** : Éditeur de code (SurrealQL) pour des règles de sécurité globales.

## 3. Intégration dans Surrealist

L'idée est d'ajouter un **"Admin Mode"** dans la barre latérale existante de Surrealist.

*   **Accès** : Restreint aux utilisateurs ayant le rôle `Owner` ou `Admin` au niveau *Root*.
*   **Navigation** :
    *   `Sidebar` actuelle : Tables, Query, Graphics (Vue Données).
    *   `Admin Sidebar` (Nouveau) : Cluster, Realms, Billing (Vue Infra).

## 4. Données Techniques

Toutes ces vues seront alimentées par des requêtes RPC vers le Kernel `lyxal_os` (qui n'est pas encore actif, d'où l'importance de l'activer prochainement).

Exemple de données attendues :
```json
// GET /api/cluster/status
{
  "leader": "node-abc",
  "nodes": [
    { "id": "node-abc", "role": "Leader", "uptime": 1200 },
    { "id": "node-xyz", "role": "Follower", "uptime": 1200 }
  ]
}
```
