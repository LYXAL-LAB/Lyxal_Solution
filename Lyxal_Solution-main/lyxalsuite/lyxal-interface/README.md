# 🎯 lyxal-interface

Interface TypeScript **simple** pour récupérer les données de connexion + streaming automatique.

## 🚀 Utilisation

### Interface Directe

```typescript
import { createLyxalInterface } from 'lyxal-interface';

const lyxalInterface = createLyxalInterface();

// 1. Récupère les données de connexion initiales
const data = await lyxalInterface.connect('lyxal-master-001');
console.log('Identité:', data.identity);
console.log('Infrastructure:', data.infrastructure);

// 2. Active le streaming pour les mises à jour automatiques
lyxalInterface.onUpdate = (newData) => {
  console.log('Données mises à jour:', newData);
};

await lyxalInterface.startStreaming();
```

### Hook React

```typescript
import { useLyxalInterface } from 'lyxal-interface';

function MyComponent() {
  const { 
    data, 
    loading, 
    error, 
    isStreaming,
    startStreaming,
    refresh 
  } = useLyxalInterface({
    platformId: 'lyxal-master-001',
    autoStream: true // Active le streaming automatiquement
  });

  if (loading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error.message}</div>;

  return (
    <div>
      <h1>{data?.identity.platform_name}</h1>
      <p>Environnement: {data?.identity.environment}</p>
      <p>Streaming: {isStreaming ? 'Actif' : 'Inactif'}</p>
      <p>Dernière MAJ: {data?.lastUpdate.toLocaleString()}</p>
      
      <button onClick={startStreaming}>
        Activer streaming
      </button>
      <button onClick={refresh}>
        Actualiser
      </button>
    </div>
  );
}
```

## 📋 API

### Types

```typescript
interface ConnectionData {
  identity: SystemIdentity;
  infrastructure: SystemInfrastructure;
  lastUpdate: Date;
}

interface LyxalInterface {
  data: ConnectionData | null;
  isConnected: boolean;
  isStreaming: boolean;
  
  connect(platformId?: string): Promise<ConnectionData>;
  startStreaming(): Promise<void>;
  stopStreaming(): Promise<void>;
  
  onUpdate?: (data: ConnectionData) => void;
}
```

### Hook Options

```typescript
interface UseLyxalInterfaceOptions {
  platformId?: string;  // ID de la plateforme à charger
  autoStream?: boolean; // Active le streaming automatiquement
}
```

## ⚡ Fonctionnement

1. **Connexion initiale** - Récupère `system_identity` et `system_infrastructure`
2. **Streaming automatique** - Live Queries sur les 2 tables
3. **Mises à jour temps réel** - Callback `onUpdate` appelé automatiquement
4. **Nettoyage automatique** - Arrêt des Live Queries au démontage

## 🔗 Dépendances

- `@lyxalsuite/lyxal-surreal` - Client SurrealDB
- `react` - Pour le hook React

C'est tout ! **Simple et efficace.** 