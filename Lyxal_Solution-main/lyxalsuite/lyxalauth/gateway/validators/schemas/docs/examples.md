 # Exemples d'utilisation des schémas

## Account

### updateAccountCenterSettingsSchema

Ce schéma valide les données pour la mise à jour des paramètres du centre de compte.

#### Exemple de validation réussie

```typescript
import { updateAccountCenterSettingsSchema } from '../validators/schemas/accountSchemas';

// Exemple de données valides
const validSettings = {
  uriTemplate: 'https://account.example.com/{tenant}',
  privateUriTemplate: 'https://private.example.com/{tenant}',
  branding: {
    logoUrl: 'https://cdn.example.com/logo.png',
    darkLogoUrl: 'https://cdn.example.com/logo-dark.png',
    appName: { fr: 'Mon Application', en: 'My Application' }
  },
  customCssEnabled: true,
  languageInfo: {
    autoDetect: true,
    fallbackLanguage: 'fr'
  }
};

// Validation
try {
  const validated = updateAccountCenterSettingsSchema.parse(validSettings);
  console.log('Validation réussie', validated);
} catch (error) {
  console.error('Erreur de validation', error);
}
```

#### Traitement des erreurs

```typescript
import { updateAccountCenterSettingsSchema } from '../validators/schemas/accountSchemas';

// Exemple de données invalides
const invalidSettings = {
  uriTemplate: 'not-a-url', // URL invalide
  branding: {
    logoUrl: 'also-invalid',
    appName: { fr: '' } // Chaîne vide non autorisée
  }
};

// Validation sûre qui ne lance pas d'exception
const result = updateAccountCenterSettingsSchema.safeParse(invalidSettings);

if (result.success) {
  console.log('Données valides', result.data);
} else {
  console.error('Erreurs de validation:');
  result.error.errors.forEach(err => {
    console.error(`- ${err.path.join('.')}: ${err.message}`);
  });
}
```