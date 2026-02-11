# Architecture de la Base de Données Cal.com

## 🏗️ Multi-Tenancy : Shared Database, Shared Schema

### Réponse directe
**Oui**, Cal.com utilise une **seule base de données partagée** pour tous les utilisateurs/organisations, sans isolation physique des données.

L'isolation se fait **uniquement via les relations (foreign keys)** entre tables :
- `userId` pour les données personnelles
- `teamId` pour les équipes
- `organizationId` pour les organisations

## 📊 Architecture Multi-Tenant

```
┌─────────────────────────────────────────┐
│   Base de données PostgreSQL UNIQUE     │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │  User 1  │  │  User 2  │            │
│  │  id: 1   │  │  id: 2   │            │
│  └────┬─────┘  └────┬─────┘            │
│       │             │                   │
│  ┌────▼─────┐  ┌───▼──────┐            │
│  │ Booking  │  │ Booking  │            │
│  │ userId:1 │  │ userId:2 │            │
│  └──────────┘  └──────────┘            │
│                                         │
│  → Toutes les tables sont partagées    │
└─────────────────────────────────────────┘
```

### Mécanisme d'isolation

#### 1. **Row-Level Filtering** (Filtrage applicatif)
Chaque requête doit TOUJOURS inclure le filtre sur `userId` ou `teamId` :

```prisma
// ✅ Correct - Isolation par user
const bookings = await prisma.booking.findMany({
  where: { userId: currentUser.id }
});

// ❌ Dangereux - Récupère TOUS les bookings de TOUS les users
const bookings = await prisma.booking.findMany();
```

#### 2. **Foreign Keys comme barrière**
Exemples du schema :

```prisma
model Booking {
  id     Int   @id
  userId Int?  // FK vers User
  user   User? @relation(fields: [userId], references: [id])
  
  teamId Int?  // FK vers Team (si booking d'équipe)
  // ...
}

model EventType {
  userId Int?           // Propriétaire individuel
  teamId Int?           // Propriétaire équipe
  organizationId Int?   // Niveau organisation
  // ...
}
```

### Niveaux d'isolation

| Niveau | Champ | Usage |
|--------|-------|-------|
| **Utilisateur** | `userId` | Données personnelles (mes bookings, mes event types) |
| **Équipe** | `teamId` | Données partagées par équipe |
| **Organisation** | `organizationId` | Données au niveau org (settings, branding) |
| **Global** | Aucun | Données publiques (apps, features flags) |

## 🚨 Risques de cette architecture

### 1. **Pas de Row-Level Security (RLS)**
PostgreSQL supporte le RLS, mais Cal.com ne l'utilise **pas** nativement. L'isolation repose sur :
- La logique applicative (tRPC, Prisma queries)
- Les middleware de vérification des permissions

### 2. **Fuite de données potentielle**
Si un développeur oublie le `where: { userId }` dans une requête, il peut récupérer les données de **tous** les utilisateurs.

### 3. **Performance**
Sur des tables massives (millions de `Booking`), les index sur `userId`, `teamId` sont **critiques** :

```prisma
model Booking {
  // ...
  @@index([userId])        // Index pour filtrage rapide
  @@index([teamId])
  @@index([eventTypeId])
}
```

## ✅ Avantages de cette architecture

1. **Simplicité** : Une seule base à gérer, pas de sharding
2. **Coût** : Pas besoin de provisionner une DB par client
3. **Maintenance** : Migrations schema uniques
4. **Analytics** : Requêtes cross-tenant faciles

## 🔒 Sécurisation dans Cal.com

### Couches de sécurité

1. **tRPC Middleware** : Vérifie que l'utilisateur connecté a accès à la ressource
2. **Prisma Extensions** : Injection automatique de `userId` dans les queries
3. **RBAC** : Table `RolePermission` pour contrôler les actions
4. **Audit Logs** : `BookingAudit` pour tracer les accès

### Exemple de middleware tRPC

```typescript
// Simplifié
const protectedProcedure = t.procedure.use(async ({ ctx, next }) => {
  if (!ctx.user) throw new Error('Unauthorized');
  
  // Inject userId dans le contexte
  return next({
    ctx: {
      ...ctx,
      userId: ctx.user.id
    }
  });
});
```

## 📦 Comparaison avec d'autres approches

| Approche | Cal.com | Alternative |
|----------|---------|-------------|
| **Shared DB, Shared Schema** | ✅ Oui | Simple, mais risque de fuite |
| **Shared DB, Separate Schemas** | ❌ Non | PostgreSQL schemas par tenant |
| **Separate Databases** | ❌ Non | 1 DB par client (ex: Heroku) |
| **Row-Level Security** | ❌ Non | Isolation au niveau PostgreSQL |

## 🎯 Conclusion

Cal.com utilise un modèle **multi-tenant monolithique** où :
- **Tout est dans la même base de données**
- **L'isolation est UNIQUEMENT applicative** (pas de RLS natif)
- **Chaque query doit filtrer par `userId`/`teamId`/`orgId`**
- **Les foreign keys garantissent la cohérence**, mais pas la confidentialité

Pour Lyxal, si vous forkez cette architecture :
- ⚠️ **Attention** à bien implémenter les filtres dans toutes vos queries
- 💡 **Envisager** d'ajouter PostgreSQL RLS pour plus de sécurité
- 🔍 **Auditer** régulièrement les queries pour éviter les fuites
