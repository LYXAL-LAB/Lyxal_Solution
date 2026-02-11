🚀 Guide de Performance & Scalabilité
====================================

Le module `Lyxal_Surreal` est conçu pour gérer des charges élevées en environnement Multi-SaaS. Voici comment l'optimiser et le surveiller.

1. Préchauffage (Warmup)
------------------------
Pour éviter que les premiers utilisateurs ne subissent le temps de connexion initial (Handshake WebSocket + Auth), il est recommandé d'utiliser le Warmup au démarrage de votre serveur Node.js / Bun.

**Exemple dans `src/index.ts` (Point d'entrée de l'app) :**

```typescript
import { warmupSurrealConnections, createContext } from "@lyxal/surreal";

const AUTH_CTX = createContext("Lyxal_Auth", "Main");
const CONFIG_CTX = createContext("Lyxal_Config", "Settings");

async function startServer() {
  console.log("🔥 Warming up DB connections...");
  
  // Lance les connexions en parallèle sans bloquer
  await warmupSurrealConnections([AUTH_CTX, CONFIG_CTX]);
  
  console.log("✅ DB Ready. Starting HTTP Server...");
  app.listen(3000);
}

startServer();
```

2. Gestion des Ressources (LRU & Timeouts)
------------------------------------------
Le client gère automatiquement la mémoire :

- **Idle Timeout** : 10 minutes.
  Toute connexion non utilisée pendant 10 minutes est fermée proprement.
  *Impact : Réduit la consommation mémoire sur le serveur et le nombre de sockets ouverts sur la DB.*

- **Health Check Throttling** : 30 secondes.
  Le client ne vérifie la santé de la base (Ping) qu'une fois toutes les 30 secondes maximum par connexion.
  *Impact : Élimine la surcharge réseau inutile sur les requêtes fréquentes.*

3. Monitoring & Observabilité
-----------------------------
Pour surveiller l'état du moteur en production, vous pouvez exposer les métriques du Pool.

*(Note: Fonctionnalité prévue pour l'interface Lyxal Admin)*

**Métriques Clés à surveiller :**
- **Active Connections** : Nombre de contextes chargés en mémoire.
- **Connection Age** : Durée de vie des sockets.
- **Reconnection Rate** : Si ce chiffre grimpe, vérifier la stabilité réseau du cluster SurrealDB.

4. Limites & Dimensionnement
----------------------------
- **Max Connections** : Théoriquement illimité (limité par la RAM du serveur).
- **Context Switching** : Coût nul (O(1)) grâce au Map Pool.
- **Thread Safety** : 100% (Chaque contexte a son propre socket isolé).

