# 📡 Spécification : Monitoring du Moteur Lyxal_Surreal

## 1. Objectif
L'interface d'administration (**Lyxal Admin**) ne doit pas gérer la base de données directement, mais elle doit être capable de **surveiller** l'état du moteur backend `Lyxal_Surreal`.

Ce document sert de référence pour l'implémentation future du tableau de bord de santé (Health Dashboard).

---

## 2. Métriques à Surveiller

Le module `Lyxal_Surreal` (optimisé "Enterprise-Grade") gère un pool de connexions intelligent. L'UI devra pouvoir afficher :

### A. État du Pool de Connexions
*   **Connexions actives** : Combien de contextes (Namespace/Database) sont ouverts ?
*   **Détail par contexte** :
    *   `CRM` (Connecté ✅ - Dernière activité : 2s)
    *   `AUTH` (Connecté ✅ - Dernière activité : 150ms)
    *   `LOGS` (Inactif 💤 - Fermé par Idle Timeout)
*   **Ressources** : Mémoire utilisée par les connexions WebSocket.

### B. Santé des Services (Health Check)
*   Afficher un statut global : 🟢 **OPERATIONAL** / 🟠 **DEGRADED** / 🔴 **DOWN**.
*   Latence moyenne vers SurrealDB (en ms).
*   Dernière vérification (timestamp).

---

## 3. Implémentation Technique

L'Admin UI ne doit pas "taper" dans la base pour tester. Elle doit interroger le module `Lyxal_Surreal`.

### Étape 1 : Exposer les métriques (Backend)
Il faudra ajouter une méthode publique dans `Lyxal_Surreal` (fichier `surrealClient.ts`) pour exporter l'état du pool :

```typescript
// Exemple de signature future dans surrealClient.ts
export function getPoolStats() {
  return Array.from(clientPool.entries()).map(([key, entry]) => ({
    context: key,
    lastUsed: entry.lastUsed,
    age: Date.now() - entry.lastUsed,
    isHealthy: true // baser sur lastHealthCheck
  }));
}
```

### Étape 2 : API Endpoint (Middleware)
Créer une route API (ex: `/api/system/health`) dans votre serveur API principal qui appelle `getPoolStats()` et renvoie le JSON à l'Admin UI.

### Étape 3 : Interface Admin (Frontend)
Dans `Lyxal_Admin`, créer un widget "System Status" :
1.  Appel périodique à `/api/system/health`.
2.  Visualisation sous forme de liste ou de graphiques (ex: feux tricolores).
3.  Bouton "Force Reconnect" (appelant `reconnectClient` côté backend) pour les cas d'urgence.

---

## 4. Pourquoi pas d'UI directe dans le module ?
*   **Séparation des responsabilités** : `Lyxal_Surreal` est un moteur (infrastructure). `Lyxal_Admin` est le tableau de bord (présentation).
*   **Sécurité** : Le moteur ne doit pas exposer d'interface web publique. Seule l'API authentifiée de l'Admin doit pouvoir lire ces stats.

---

## 5. Rappel des Optimisations Actuelles (à monitorer)
*   **Idle Timeout** : 10 minutes (les connexions disparaissent du monitoring si inutilisées).
*   **Health Throttle** : 30 secondes (les stats de santé ne se mettent à jour que toutes les 30s max).

