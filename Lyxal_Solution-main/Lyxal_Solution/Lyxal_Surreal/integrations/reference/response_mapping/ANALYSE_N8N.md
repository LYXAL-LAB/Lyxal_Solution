# 📊 Analyse : Response Mapping dans n8n

## 🔍 Comment n8n gère les réponses API

### 1️⃣ **Exemple Slack** : Réponse brute + extraction simple

```typescript
// Dans GenericFunctions.ts
const response = await this.helpers.requestWithAuthentication.call(
    this,
    credentialType,
    options,
);

// Transformation simple : renommer un champ
if (response.ts !== undefined) {
    Object.assign(response, { message_timestamp: response.ts });
    delete response.ts;
}

return response; // Retour de la réponse complète
```

**Dans SlackV2.node.ts** :
```typescript
// Appel API
responseData = await slackApiRequest.call(this, 'POST', '/conversations.create', body, qs);

// Extraction d'un sous-objet
responseData = responseData.channel; // On ne garde que le champ 'channel'

// Ou pour une liste :
responseData = await slackApiRequest.call(this, 'GET', '/conversations.list', {}, qs);
responseData = responseData.channels; // On ne garde que le tableau 'channels'
```

---

### 2️⃣ **Exemple Google Sheets** : Mapping complexe de champs

```typescript
// L'utilisateur peut choisir entre 3 modes :
const dataMode = this.getNodeParameter('columns.mappingMode', 0);

if (dataMode === 'autoMapInputData') {
    // Mode 1 : Auto-mapping des colonnes par nom
    inputData = await autoMapInputData.call(this, range, sheet, items, options);
} else {
    // Mode 2 : Mapping manuel défini par l'utilisateur
    inputData = mapFields.call(this, items.length);
}

// Retour des données transformées
return returnData.map((item, index) => {
    return {
        json: entry,
        pairedItem: { item: index }
    };
});
```

---

### 3️⃣ **Exemple GitHub** : Transformation de tableaux

```typescript
// Transformation d'un tableau d'objets en tableau de valeurs simples
body.labels = labels.map((data) => data.label);
body.assignees = assignees.map((data) => data.assignee);

// Dans les mises à jour :
if (body.labels !== undefined) {
    body.labels = (body.labels as IDataObject[]).map((data) => data.label);
}
```

---

### 4️⃣ **Exemple Airtable** : Extraction avec pagination

```typescript
// Fonction helper pour récupérer TOUTES les pages
export async function slackApiRequestAllItems(
    this: IExecuteFunctions,
    propertyName: string,
    method: string,
    endpoint: string,
    body: any = {},
    query: IDataObject = {},
): Promise<any> {
    const returnData: IDataObject[] = [];
    let responseData;
    
    do {
        responseData = await slackApiRequest.call(this, method, endpoint, body, query);
        query.cursor = get(responseData, 'response_metadata.next_cursor');
        
        // Extraction du tableau de résultats
        returnData.push.apply(
            returnData,
            (responseData[propertyName].matches as IDataObject[]) ??
            responseData[propertyName],
        );
    } while (
        responseData.response_metadata?.next_cursor !== undefined &&
        responseData.response_metadata.next_cursor !== ''
    );
    
    return returnData;
}
```

---

## 🎯 Patterns de Response Mapping identifiés

### **Pattern 1 : Retour brut**
```typescript
responseData = await apiRequest.call(this, 'GET', '/endpoint');
// Aucune transformation, on retourne tout
```

### **Pattern 2 : Extraction d'un sous-objet**
```typescript
responseData = await apiRequest.call(this, 'GET', '/endpoint');
responseData = responseData.channel; // Extraction d'un champ
```

### **Pattern 3 : Extraction d'un tableau**
```typescript
responseData = await apiRequest.call(this, 'GET', '/endpoint');
responseData = responseData.items; // Extraction d'un tableau
```

### **Pattern 4 : Transformation de tableau**
```typescript
responseData = responseData.members.map((member: string) => ({ member }));
// Transformation de ['user1', 'user2'] vers [{member: 'user1'}, {member: 'user2'}]
```

### **Pattern 5 : Renommage de champs**
```typescript
if (response.ts !== undefined) {
    Object.assign(response, { message_timestamp: response.ts });
    delete response.ts;
}
```

### **Pattern 6 : Pagination automatique**
```typescript
// Récupérer toutes les pages automatiquement
responseData = await apiRequestAllItems.call(this, 'items', 'GET', '/endpoint');
```

---

## ❌ **Pourquoi l'extraction 1:1 est IMPOSSIBLE**

### 1. **Code TypeScript dynamique**
- Les transformations sont **hardcodées en TypeScript** dans les fichiers `.node.ts`
- Aucune définition JSON/déclarative
- Logique métier complexe (conditions, boucles, transformations)

### 2. **Variations par opération**
- Chaque opération (create, update, get, list) peut avoir **sa propre logique**
- Exemple Slack :
  - `channel.create` → `responseData.channel`
  - `channel.list` → `responseData.channels`
  - `channel.members` → `responseData.members.map(...)`

### 3. **Pas de structure uniforme**
Certains services :
- Retournent la réponse brute
- Extraient 1 champ
- Extraient plusieurs champs
- Transforment les données
- Appliquent la pagination
- Combinent plusieurs appels API

### 4. **Logique métier spécifique**
```typescript
// Exemple : logique conditionnelle complexe
if (nodeVersion < 4 || dataMode === 'autoMapInputData') {
    return items.map((item, index) => {
        item.pairedItem = { item: index };
        return item;
    });
} else {
    const returnData: INodeExecutionData[] = [];
    for (const [index, entry] of inputData.entries()) {
        returnData.push({
            json: entry,
            pairedItem: { item: index }
        });
    }
    return returnData;
}
```

---

## 🤔 **Estimation quantitative**

Si on essayait d'extraire les response mappings de n8n :

- **2,436 tools** (opérations)
- Chaque tool a **son propre code** de traitement de réponse
- **Complexité variable** :
  - 30% : Retour brut (pas de mapping)
  - 40% : Extraction simple d'1-2 champs
  - 20% : Transformations de tableaux
  - 10% : Logique complexe (pagination, conditions, etc.)

**Données extractibles** : ~0%
- Aucune définition déclarative
- Tout est en code TypeScript procédural
- Impossible de générer des seeds sans **interpréter et réexécuter** le code TypeScript

---

## ✅ **Conclusion**

### **Response Mapping dans n8n :**
❌ **PAS extractible en 1:1**
- Logique hardcodée en TypeScript
- Pas de définition JSON/déclarative
- Trop de variations et de complexité

### **Recommandation pour Lyxal :**
1. ✅ **Créer le schéma** `response_mapping` (structure vide conforme)
2. ✅ **Documenter** les patterns identifiés (ce document)
3. ❌ **NE PAS créer de seeds** inventés
4. 💡 **Stratégie future** : Remplir progressivement au fur et à mesure des intégrations Lyxal

---

## 📚 **Patterns à implémenter dans Lyxal**

Pour `response_mapping`, voici les champs qui seraient utiles :

```surql
CREATE response_mapping:example SET
    tool_id = tool:slack_channel_create,
    mapping_type = 'extract_field', -- 'raw' | 'extract_field' | 'extract_array' | 'transform' | 'pagination'
    source_path = 'channel', -- Chemin JSON vers les données (ex: 'data.items[*]')
    transformations = [
        { action: 'rename', from: 'ts', to: 'message_timestamp' },
        { action: 'map_array', field: 'members', transform: '{ member: $value }' }
    ],
    pagination = {
        enabled: true,
        cursor_path: 'response_metadata.next_cursor',
        items_path: 'items'
    };
```

Ces patterns pourront être **créés manuellement** quand Lyxal implémentera chaque intégration.

