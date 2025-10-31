# Documentation du Module GDPR - Lyxal Gateway

## Introduction

Le module GDPR (General Data Protection Regulation) de Lyxal Gateway permet de gérer les demandes liées aux droits des utilisateurs concernant leurs données personnelles. Il offre des fonctionnalités pour :

- Créer et gérer des demandes d'accès aux données
- Créer et gérer des demandes d'effacement des données
- Générer des réponses aux demandes GDPR
- Suivre les activités d'audit
- Gérer les processus d'anonymisation

## Architecture

Le module lyxalgdpr s'intègre parfaitement avec les autres composants de Lyxal Gateway :

- **Gateway** : API REST pour la gestion des demandes GDPR
- **SDK Backend** : Hooks pour les applications backend
- **SDK Frontend** : Hooks React pour les applications frontend
- **SDK Agent** : Interface spécifique pour les agents IA

## Installation

```bash
npm install lyxalgdpr
```

## Utilisation

### Backend

Pour utiliser le client GDPR dans une application backend Node.js :

```typescript
import { GdprClient } from 'lyxalgdpr/sdk/backend';
import { HttpClient } from 'lyxalbase/sdk/httpClient';

// Initialisation du client
const httpClient = new HttpClient('https://api.votredomaine.com');
const gdprClient = new GdprClient(httpClient);

// Création d'une demande d'accès aux données
const request = await gdprClient.createRequest({
  typeSelect: 0, // 0 = Accès, 1 = Effacement
  modelId: 123, // ID de l'utilisateur
  modelSelect: 'user',
  requestDateT: new Date(),
  dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
  statusSelect: 1, // En attente
  gdprRequestOrigin: 'gdpr_request_origin:backend'
});
```

Vous pouvez également utiliser les hooks pour simplifier les opérations courantes :

```typescript
import { createGdprHooks } from 'lyxalgdpr/sdk/backend/hooks';
import { GdprClient } from 'lyxalgdpr/sdk/backend';
import { HttpClient } from 'lyxalbase/sdk/httpClient';

// Initialisation
const httpClient = new HttpClient('https://api.votredomaine.com');
const gdprClient = new GdprClient(httpClient);
const gdprHooks = createGdprHooks(gdprClient);

// Utilisation des hooks
const createAccessRequest = gdprHooks.useCreateAccessRequest('123', 'user@example.com');
const request = await createAccessRequest();
```

### Frontend (React)

Pour intégrer GDPR dans une application React :

```typescript
import { useCreateAccessRequest, useListRequests } from 'lyxalgdpr/sdk/frontend/hooks';
import { GdprRequestForm, GdprRequestList } from 'lyxalgdpr/sdk/frontend/components';

// Dans votre composant React
function GdprManagementPage() {
  // Utilisation des hooks
  const { createAccessRequest, loading, error } = useCreateAccessRequest();
  const { requests, listRequests } = useListRequests();
  
  // Gestion d'une soumission de formulaire
  const handleSubmit = async (userId, email, comment) => {
    try {
      const request = await createAccessRequest(userId, email, comment);
      console.log('Demande créée :', request);
    } catch (err) {
      console.error('Erreur :', err);
    }
  };
  
  return (
    <div>
      <h1>Gestion GDPR</h1>
      
      {/* Utilisation des composants prêts à l'emploi */}
      <GdprRequestForm 
        userId="123"
        email="user@example.com"
        onSuccess={(id) => console.log(`Demande ${id} créée`)}
      />
      
      <GdprRequestList
        autoRefresh={true}
        refreshInterval={30000}
        onViewRequest={(id) => console.log(`Afficher détails de ${id}`)}
      />
    </div>
  );
}
```

### Agent IA

Pour intégrer les fonctionnalités GDPR dans un agent IA :

```typescript
import { createGdprAgent } from 'lyxalgdpr/sdk/agent';

// Création de l'agent avec l'URL de base de l'API
const gdprAgent = createGdprAgent('https://api.example.com');

// Recherche des demandes existantes pour un utilisateur
const requests = await gdprAgent.findRequestsByEmail('user@example.com');

// Génération d'un rapport de conformité
const report = await gdprAgent.getComplianceReport();
console.log(`Demandes en attente : ${report.pendingRequests}`);
console.log(`Demandes en retard : ${report.overdueRequests}`);
```

## Types de données

### Demandes GDPR

Les demandes GDPR peuvent être de deux types :
- **Access (0)** : Demande d'accès aux données personnelles
- **Erasure (1)** : Demande d'effacement des données personnelles

### Statuts

Les statuts possibles pour une demande sont :
- **0** : Reçue
- **1** : Confirmée
- **2** : Envoyée
- **3** : Annulée

## Sécurité et performances

Le module GDPR implémente plusieurs mécanismes de sécurité :

- **Rate Limiting** : Limite le nombre de requêtes par IP (5 requêtes/minute)
- **Authentification** : Toutes les routes sont protégées par authentification
- **Journalisation** : Toutes les actions sont enregistrées dans des logs d'audit

## Migration et mise à jour

Pour mettre à jour le module :

```bash
npm update lyxalgdpr
```

Pour migrer les données de SurrealDB :

```
surrealdb import -e prod -u root -p password lyxalgdpr/model/gdpr_structure.surql
```

## Configuration

Pour utiliser le client GDPR dans votre application backend :

```typescript
import { GdprClient } from 'lyxalgdpr/sdk';

// Initialisation du client
const gdprClient = new GdprClient({
  baseUrl: 'https://api.votredomaine.com',
  apiKey: 'votre-api-key'
});
```

## Exemples d'utilisation

### Création d'une demande GDPR

```typescript
import { GdprClient, RequestType } from 'lyxalgdpr/sdk';

// Initialisation
const gdprClient = new GdprClient({
  baseUrl: 'https://api.votredomaine.com',
  apiKey: 'votre-api-key'
});

// Création d'une demande d'accès
async function createAccessRequest(userId: string, email: string) {
  try {
    const request = await gdprClient.createRequest({
      typeSelect: RequestType.ACCESS,
      requestDateT: new Date(),
      dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
      statusSelect: 1, // En attente
      modelId: userId,
      modelSelect: 'user',
      requestComment: 'Demande d\'accès aux données personnelles',
      label: `Demande d'accès - ${email}`,
      gdprRequestOrigin: 'web_form'
    });
    
    console.log('Demande créée avec succès:', request.id);
    return request;
  } catch (error) {
    console.error('Erreur lors de la création de la demande:', error);
    throw error;
  }
}
```

### Génération d'une réponse GDPR

```typescript
import { GdprClient, ResponseType } from 'lyxalgdpr/sdk';

// Initialisation
const gdprClient = new GdprClient({
  baseUrl: 'https://api.votredomaine.com',
  apiKey: 'votre-api-key'
});

// Création d'une réponse à une demande d'accès
async function createAccessResponse(requestId: string, userData: any, email: string) {
  try {
    // Conversion des données utilisateur en fichier JSON
    const dataBlob = new Blob([JSON.stringify(userData, null, 2)], {
      type: 'application/json'
    });
    
    // Création d'un objet File à partir du Blob
    const dataFile = new File([dataBlob], 'user_data.json', {
      type: 'application/json'
    });
    
    // Envoi de la réponse
    const response = await gdprClient.createResponse(requestId, {
      typeSelect: ResponseType.ACCESS,
      sendingDateT: new Date(),
      responseEmailAddress: email,
      dataFile: dataFile
    });
    
    console.log('Réponse créée avec succès:', response.id);
    return response;
  } catch (error) {
    console.error('Erreur lors de la création de la réponse:', error);
    throw error;
  }
}
```

### Lecture des logs d'audit

```typescript
import { GdprClient } from 'lyxalgdpr/sdk';

// Initialisation
const gdprClient = new GdprClient({
  baseUrl: 'https://api.votredomaine.com',
  apiKey: 'votre-api-key'
});

// Récupération des logs d'audit
async function getAuditLogs(filters?: { startDate?: Date; endDate?: Date; userId?: string }) {
  try {
    const logs = await gdprClient.listAuditLogs(filters);
    console.log(`${logs.length} logs récupérés`);
    return logs;
  } catch (error) {
    console.error('Erreur lors de la récupération des logs:', error);
    throw error;
  }
}
```

## Bonnes pratiques

1. **Sécurité**: Toujours utiliser les middlewares de sécurité fournis (authRequired, rateLimit, errorHandler)
2. **Délais**: Respecter les délais légaux pour répondre aux demandes GDPR (30 jours maximum)
3. **Logs**: Conserver des logs d'audit détaillés pour toutes les opérations GDPR
4. **Validation**: Vérifier l'identité du demandeur avant de fournir des données personnelles

## Références

- [Documentation complète de l'API](https://docs.votredomaine.com/api/gdpr)
- [Règlement Général sur la Protection des Données (RGPD)](https://gdpr-info.eu/) 