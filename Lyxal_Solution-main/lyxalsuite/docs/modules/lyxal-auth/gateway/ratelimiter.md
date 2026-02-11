# Rapport d'Implémentation: Rate Limiting

## Objectif
Implémentation d'un middleware de limitation de débit (rate limiting) pour protéger l'API contre les attaques par déni de service (DoS/DDoS) et les abus.

## Solution Implémentée

### Fichier: `middlewares/rateLimiter.ts`

Nous avons implémenté un système de rate limiting basé sur la mémoire locale avec les caractéristiques suivantes:

1. **Stockage en mémoire**: Utilisation d'une `Map` pour stocker les compteurs par IP ou clé API
2. **Nettoyage automatique**: Suppression périodique des entrées expirées pour éviter les fuites de mémoire
3. **Identification flexible**: Support de l'identification par IP ou par clé API via un générateur de clé configurable
4. **En-têtes standards**: Ajout des en-têtes HTTP standards pour le rate limiting:
   - `X-RateLimit-Limit`: Nombre maximum de requêtes autorisées
   - `X-RateLimit-Remaining`: Nombre de requêtes restantes
   - `X-RateLimit-Reset`: Timestamp Unix de réinitialisation
   - `Retry-After`: Secondes à attendre avant de réessayer

### Types de limiteurs implémentés

1. **`mutationRateLimiter`**: Limité à 30 requêtes par minute
   - Appliqué aux méthodes mutables: POST, PUT, DELETE, PATCH
   - Protection contre les modifications abusives

2. **`authRateLimiter`**: Limité à 20 requêtes par 5 minutes
   - Appliqué aux routes d'authentification sensibles
   - Protection contre les attaques par force brute

3. **`apiRateLimiter`**: Limité à 120 requêtes par minute
   - Disponible pour les routes API générales
   - Non appliqué par défaut

## Intégration

Le middleware a été intégré dans l'application principale (`index.ts`) de deux manières:

1. **Routes d'authentification spécifiques**:
   ```typescript
   app.use('/api/auth/login', authRateLimiter());
   app.use('/api/auth/register', authRateLimiter());
   app.use('/api/auth/password/reset', authRateLimiter());
   ```

2. **Toutes les méthodes mutables**:
   ```typescript
   app.use('*', async (c, next) => {
     const method = c.req.method;
     if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
       return mutationRateLimiter()(c, next);
     }
     await next();
   });
   ```

## Avantages de l'implémentation

1. **Simplicité**: Solution légère sans dépendance externe
2. **Flexibilité**: Paramètres configurables selon les besoins
3. **Transparence**: En-têtes HTTP informant le client des limites
4. **Défense en profondeur**: Différentes limites selon la sensibilité des routes

## Limitations et améliorations futures

1. **Stockage distribué**: Pour les environnements multi-instances, un stockage Redis serait préférable
2. **Règles dynamiques**: Ajuster les limites en fonction du comportement des utilisateurs
3. **Surveillance**: Ajouter des métriques pour suivre les tentatives de dépassement des limites
4. **Liste blanche**: Permettre d'exempter certaines IPs ou clés API des limitations

## Conclusion

Cette implémentation répond aux exigences de sécurité en limitant efficacement les requêtes abusives tout en restant flexible et légère. Elle constitue une première ligne de défense contre les attaques DoS/DDoS et les abus d'API. 