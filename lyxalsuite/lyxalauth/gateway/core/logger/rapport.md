# Rapport d'Implémentation: Logging Structuré

## Objectif
Implémentation d'un système de journalisation structuré avec format JSON, identifiants de requête uniques (UUID) et organisation des logs par niveau et par tag pour améliorer la traçabilité et faciliter l'analyse des logs.

## Solution Implémentée

### Fichier: `core/logger/structuredLogger.ts`

Nous avons implémenté un système de journalisation structuré avec les caractéristiques suivantes:

1. **Format JSON structuré**: Chaque entrée de log est formatée en JSON avec une structure cohérente:
   ```json
   {
     "timestamp": "2025-05-23T14:28:30.123Z",
     "level": "info",
     "message": "Requête traitée avec succès",
     "requestId": "550e8400-e29b-41d4-a716-446655440000",
     "tag": "http",
     "data": { ... }
   }
   ```

2. **Identifiant unique par requête**: 
   - Génération d'UUID v4 pour chaque requête HTTP
   - Propagation de l'identifiant dans tous les logs liés à la même requête
   - Exposition dans l'en-tête `X-Request-ID` pour le suivi côté client

3. **Organisation des logs par niveau et par tag**:
   - Niveaux: `debug`, `info`, `warn`, `error`
   - Tags: permettent de catégoriser les logs (http, auth, db, event, etc.)

4. **API de journalisation enrichie**:
   - Méthodes standard: `logger.debug()`, `logger.info()`, `logger.warn()`, `logger.error()`
   - Méthodes spécialisées: 
     - `logger.event()` pour les événements métier
     - `logger.audit()` pour les actions de sécurité
     - `logger.perf()` pour les métriques de performance

### Architecture du système de logging

Le système se compose de trois éléments principaux:

1. **Contexte global de logging**:
   - Stocke le `requestId` de la requête en cours
   - Permet la propagation de l'identifiant à travers les appels asynchrones

2. **Middleware d'identification des requêtes**:
   - Génère un UUID unique pour chaque requête
   - L'ajoute aux en-têtes de réponse
   - Le définit dans le contexte global

3. **Middleware de journalisation des requêtes**:
   - Enregistre le début et la fin de chaque requête
   - Mesure le temps d'exécution
   - Capture les détails de la requête et de la réponse

## Intégration

Le système a été intégré dans l'application principale (`index.ts`):

```typescript
// Middleware d'identification des requêtes (doit être en premier)
app.use('*', requestIdMiddleware());

// Middleware de journalisation structurée
app.use('*', requestLoggerMiddleware());
```

Les appels de log directs ont été remplacés par les méthodes du logger structuré:

```typescript
// Avant
console.error('Erreur non gérée:', err);

// Après
structuredLogger.error(`Erreur non gérée: ${err.message}`, 'error', { 
  name: err.name,
  stack: err.stack,
  path: c.req.path,
  method: c.req.method
});
```

## Exemples de logs générés

### Démarrage du serveur
```json
{
  "timestamp": "2025-05-23T14:28:00.000Z",
  "level": "info",
  "message": "Serveur démarré sur le port 3000 en mode development",
  "tag": "server"
}
```

### Début de requête
```json
{
  "timestamp": "2025-05-23T14:28:30.123Z",
  "level": "info",
  "message": "GET /api/auth/users - Début",
  "requestId": "550e8400-e29b-41d4-a716-446655440000",
  "tag": "http",
  "data": {
    "method": "GET",
    "path": "/api/auth/users",
    "query": { "limit": "10" },
    "headers": { ... }
  }
}
```

### Fin de requête
```json
{
  "timestamp": "2025-05-23T14:28:30.456Z",
  "level": "info",
  "message": "GET /api/auth/users - Terminé en 333ms",
  "requestId": "550e8400-e29b-41d4-a716-446655440000",
  "tag": "http",
  "data": {
    "method": "GET",
    "path": "/api/auth/users",
    "status": 200,
    "duration": 333
  }
}
```

### Événement métier
```json
{
  "timestamp": "2025-05-23T14:28:30.234Z",
  "level": "info",
  "message": "Utilisateur connecté",
  "requestId": "550e8400-e29b-41d4-a716-446655440000",
  "tag": "event",
  "data": {
    "eventName": "user.login",
    "userId": "123456"
  }
}
```

## Avantages de l'implémentation

1. **Structuration des données**: Format JSON facilement analysable par des outils
2. **Traçabilité améliorée**: Suivi complet des requêtes grâce aux identifiants uniques
3. **Catégorisation**: Organisation des logs par niveau et par tag
4. **Sécurité**: Intégration avec le masquage des données sensibles
5. **Métriques de performance**: Mesure automatique du temps d'exécution des requêtes

## Limitations et améliorations futures

1. **Rotation des logs**: Ajouter un mécanisme de rotation des fichiers de log
2. **Niveaux configurables**: Permettre de configurer le niveau minimum de log à afficher
3. **Exportation**: Ajouter des adaptateurs pour des services de logging externes
4. **Compression**: Compresser les logs pour économiser de l'espace disque

## Conclusion

Cette implémentation répond aux exigences de logging structuré en fournissant un format JSON cohérent, des identifiants de requête uniques et une organisation claire des logs par niveau et par tag. Le système est à la fois puissant et flexible, permettant une analyse efficace des logs et une meilleure traçabilité des requêtes. 