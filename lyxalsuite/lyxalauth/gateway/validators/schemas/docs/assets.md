# Documentation des schémas de validation pour les assets

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux assets dans l'API Gateway.

## assetUploadSchema

Ce schéma valide le téléchargement d'un fichier d'asset.

### Structure

```typescript
{
  file: File // Instance de File obligatoire
}
```

### Validation

- `file`: Doit être une instance valide de la classe `File`

### Exemple d'utilisation

```typescript
import { assetUploadSchema, AssetUpload } from '../validators/schemas/assetSchemas';

// Dans un middleware ou une route Hono
const formData = await c.req.formData();
const file = formData.get('file') as File;

try {
  // Validation du schéma
  const validatedData = assetUploadSchema.parse({ file });
  
  // Utilisation des données validées
  const uploadResult = await assetService.uploadAsset(validatedData);
  
  return c.json(uploadResult, 201);
} catch (error) {
  // Gestion des erreurs de validation
  return c.json({ error: error.message }, 400);
}
```

## Bonnes pratiques

1. Toujours utiliser le type `AssetUpload` (généré via `z.infer`) pour typer les données validées
2. Gérer les erreurs de validation et retourner des messages d'erreur clairs
3. Utiliser la fonction `validateAssetUpload` du module `validators/assetValidation.ts` pour une validation intégrée avec la journalisation 