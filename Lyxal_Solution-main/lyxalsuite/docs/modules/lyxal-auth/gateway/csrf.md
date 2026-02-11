# Rapport d'Implémentation: Protection CSRF

## Objectif
Implémentation d'un middleware de protection contre les attaques CSRF (Cross-Site Request Forgery) pour sécuriser les routes sensibles de l'API, particulièrement les routes POST, PUT, DELETE et PATCH.

## Solution Implémentée

### Fichier: `middleware/csrfProtection.ts`

Nous avons implémenté un système de protection CSRF basé sur le pattern "double submit cookie" avec les caractéristiques suivantes:

1. **Token unique**: Génération d'un token CSRF aléatoire et sécurisé via `crypto.randomBytes(32)`
2. **Double soumission**: Le token est stocké à la fois dans un cookie et attendu dans un header HTTP
3. **Comparaison sécurisée**: Utilisation de `crypto.timingSafeEqual()` pour éviter les attaques par timing
4. **Cookies sécurisés**: Utilisation des attributs modernes de sécurité pour les cookies:
   - `httpOnly`: Empêche l'accès au cookie via JavaScript
   - `secure`: Limite l'envoi du cookie aux connexions HTTPS
   - `sameSite: 'Lax'`: Protection contre CSRF tout en permettant la navigation normale

### Fonctionnement du middleware

Le middleware se compose de deux parties principales:

1. **`csrfTokenInjector()`**: 
   - S'exécute sur les requêtes GET
   - Génère un nouveau token CSRF
   - Stocke le token dans un cookie sécurisé
   - Renvoie le token dans l'en-tête `X-CSRF-Token` pour que le frontend puisse le récupérer

2. **`csrfProtection()`**:
   - S'exécute sur les requêtes mutables (POST, PUT, DELETE, PATCH)
   - Récupère le token depuis le cookie
   - Récupère le token depuis l'en-tête `X-CSRF-Token`
   - Compare les deux tokens de manière sécurisée
   - Rejette la requête avec un code 403 si les tokens ne correspondent pas

3. **`csrfMiddleware()`**:
   - Combine les deux fonctions ci-dessus pour une utilisation simplifiée

## Intégration

Le middleware a été intégré dans l'application principale (`index.ts`) de manière globale:

```typescript
// Protection CSRF globale
app.use('*', csrfMiddleware());
```

De plus, nous avons ajouté l'en-tête `X-CSRF-Token` à la liste des en-têtes autorisés dans la configuration CORS:

```typescript
app.use('*', cors({
  // ...
  allowHeaders: ['Content-Type', 'Authorization', 'X-API-Key', 'X-CSRF-Token'],
  credentials: true
}));
```

## Compatibilité avec les frontends modernes

Cette implémentation est compatible avec les frontends modernes car:

1. **SameSite=Lax**: Permet la navigation normale tout en bloquant les requêtes cross-site automatiques
2. **Secure**: Garantit que les cookies ne sont envoyés que sur HTTPS
3. **En-tête X-CSRF-Token**: Facilement accessible par les frameworks frontend modernes

### Exemple d'utilisation côté client (React)

```javascript
// Exemple de fonction pour récupérer le token CSRF
async function fetchWithCSRF(url, method, data) {
  // Pour les requêtes GET, récupérer le token CSRF
  if (method === 'GET' || !window.csrfToken) {
    const response = await fetch('/api/some-endpoint', {
      credentials: 'include' // Important pour recevoir les cookies
    });
    // Récupérer le token depuis l'en-tête
    window.csrfToken = response.headers.get('X-CSRF-Token');
  }
  
  // Pour les requêtes mutables, inclure le token dans l'en-tête
  return fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': window.csrfToken
    },
    credentials: 'include', // Important pour envoyer les cookies
    body: data ? JSON.stringify(data) : undefined
  });
}
```

## Avantages de l'implémentation

1. **Sécurité renforcée**: Protection efficace contre les attaques CSRF
2. **Compatibilité moderne**: Utilisation des meilleures pratiques actuelles (SameSite, Secure)
3. **Transparence**: Erreurs explicites en cas d'échec de validation
4. **Performance**: Vérifications légères avec impact minimal sur les performances

## Limitations et améliorations futures

1. **Rotation des tokens**: Implémenter une rotation automatique des tokens après utilisation
2. **Expiration configurable**: Permettre de configurer la durée de vie des tokens
3. **Liste blanche**: Exempter certaines routes de la vérification CSRF si nécessaire

## Conclusion

Cette implémentation répond aux exigences de sécurité en protégeant efficacement l'API contre les attaques CSRF, tout en restant compatible avec les frontends modernes grâce à l'utilisation des attributs de cookie SameSite et Secure. 