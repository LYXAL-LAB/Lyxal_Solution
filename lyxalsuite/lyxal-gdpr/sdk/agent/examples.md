# Exemples d'utilisation de GdprAgent pour un agent IA

Ce document présente des exemples concrets d'utilisation de l'interface `GdprAgent` pour intégrer les fonctionnalités GDPR dans un agent IA.

## 1. Initialisation de l'agent

```typescript
import { createGdprAgent } from 'lyxalgdpr/sdk/agent';

// Création de l'agent avec l'URL de base de l'API
const gdprAgent = createGdprAgent('https://api.example.com');
```

## 2. Création d'une demande d'accès

```typescript
async function handleAccessRequest(userId, email) {
  try {
    // Créer une demande d'accès aux données
    const request = await gdprAgent.createAccessRequest(
      userId,
      email,
      'Demande générée par un agent IA suite à une demande utilisateur'
    );
    
    return `Demande d'accès créée avec succès (ID: ${request.id})`;
  } catch (error) {
    return `Erreur lors de la création de la demande: ${error.message}`;
  }
}
```

## 3. Création d'une demande d'effacement

```typescript
async function handleErasureRequest(userId, email) {
  try {
    // Créer une demande d'effacement des données
    const request = await gdprAgent.createErasureRequest(
      userId,
      email,
      'Demande de suppression générée par un agent IA'
    );
    
    return `Demande d'effacement créée avec succès (ID: ${request.id})`;
  } catch (error) {
    return `Erreur lors de la création de la demande: ${error.message}`;
  }
}
```

## 4. Recherche des demandes existantes

```typescript
async function checkExistingRequests(email) {
  try {
    // Rechercher les demandes existantes pour cet email
    const requests = await gdprAgent.findRequestsByEmail(email);
    
    if (requests.length === 0) {
      return "Aucune demande GDPR existante pour cet email.";
    }
    
    return `${requests.length} demande(s) trouvée(s) pour cet email:\n` +
      requests.map(req => {
        const type = req.typeSelect === 0 ? "Accès" : "Effacement";
        const status = ["Reçue", "Confirmée", "Envoyée", "Annulée"][parseInt(req.statusSelect)];
        return `- ${type} (${status}) créée le ${new Date(req.requestDateT).toLocaleDateString()}`;
      }).join('\n');
  } catch (error) {
    return `Erreur lors de la recherche des demandes: ${error.message}`;
  }
}
```

## 5. Génération d'un rapport de conformité

```typescript
async function generateComplianceReport() {
  try {
    const report = await gdprAgent.getComplianceReport();
    
    return `
Rapport de conformité GDPR:
---------------------------
Nombre total de demandes: ${report.totalRequests}
Demandes en attente: ${report.pendingRequests}
Demandes traitées: ${report.completedRequests}
Demandes en retard: ${report.overdueRequests}

Répartition par type:
- Accès: ${report.requestsByType.access}
- Effacement: ${report.requestsByType.erasure}

Répartition par statut:
- Reçues: ${report.requestsByStatus.received}
- Confirmées: ${report.requestsByStatus.confirmed}
- Envoyées: ${report.requestsByStatus.sent}
- Annulées: ${report.requestsByStatus.canceled}
`;
  } catch (error) {
    return `Erreur lors de la génération du rapport: ${error.message}`;
  }
}
```

## 6. Mise à jour du statut d'une demande

```typescript
async function updateRequestStatus(requestId, newStatus) {
  try {
    const statusMap = {
      "reçue": "0",
      "confirmée": "1",
      "envoyée": "2",
      "annulée": "3"
    };
    
    const statusCode = statusMap[newStatus.toLowerCase()] || newStatus;
    
    await gdprAgent.updateRequestStatus(
      requestId, 
      statusCode as '0' | '1' | '2' | '3',
      `Statut mis à jour par un agent IA le ${new Date().toISOString()}`
    );
    
    return `Statut de la demande ${requestId} mis à jour avec succès`;
  } catch (error) {
    return `Erreur lors de la mise à jour du statut: ${error.message}`;
  }
}
```

## 7. Création d'une réponse à une demande

```typescript
async function createResponse(requestId, email, isAccessRequest, data) {
  try {
    let response;
    
    if (isAccessRequest) {
      // Pour une demande d'accès, on peut spécifier un ID de fichier
      response = await gdprAgent.createAccessResponse(
        requestId,
        email,
        data.fileId // ID optionnel du fichier contenant les données
      );
    } else {
      // Pour une demande d'effacement, on fournit un résumé de l'anonymisation
      response = await gdprAgent.createErasureResponse(
        requestId,
        email,
        `${data.count || 'Toutes les'} données ont été anonymisées avec succès.`
      );
    }
    
    return `Réponse créée avec succès (ID: ${response.id})`;
  } catch (error) {
    return `Erreur lors de la création de la réponse: ${error.message}`;
  }
}
```

## 8. Extraction des logs d'audit pour vérification

```typescript
async function auditLogsSummary() {
  try {
    const logs = await gdprAgent.getAuditLogs();
    
    return `
Résumé des dernières activités d'audit GDPR:
-------------------------------------------
${logs.slice(0, 5).map(log => {
  return `- ${log.id}: ${log.modelLog} (${log.numberOfrecords} enregistrements)`;
}).join('\n')}
${logs.length > 5 ? `\n... et ${logs.length - 5} autres activités` : ''}
`;
  } catch (error) {
    return `Erreur lors de l'extraction des logs: ${error.message}`;
  }
}
``` 