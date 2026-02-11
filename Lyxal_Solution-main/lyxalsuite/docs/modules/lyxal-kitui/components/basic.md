# 🧩 Composants de base

Cette section couvre les composants fondamentaux de LyxalKitUI : Button, Input, Badge, et autres éléments essentiels.

## 🔘 Button

Le composant Button est l'élément interactif principal de l'interface utilisateur.

### Utilisation de base

```tsx
import { Button } from '@lyxal/ui-kit';

function MyComponent() {
  return (
    <Button variant="primary" onClick={() => console.log('Cliqué!')}>
      Cliquez-moi
    </Button>
  );
}
```

### Variantes

```tsx
<div className="space-x-2">
  <Button variant="primary">Primary</Button>
  <Button variant="secondary">Secondary</Button>
  <Button variant="outline">Outline</Button>
  <Button variant="ghost">Ghost</Button>
  <Button variant="destructive">Destructive</Button>
</div>
```

### Tailles

```tsx
<div className="space-x-2">
  <Button size="sm">Small</Button>
  <Button size="md">Medium</Button>
  <Button size="lg">Large</Button>
  <Button size="xl">Extra Large</Button>
</div>
```

### États et options

```tsx
<div className="space-y-2">
  <Button loading>Chargement...</Button>
  <Button disabled>Désactivé</Button>
  <Button fullWidth>Pleine largeur</Button>
  <Button icon={<PlusIcon />}>Avec icône</Button>
</div>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `variant` | `'primary' \| 'secondary' \| 'outline' \| 'ghost' \| 'destructive'` | `'primary'` | Style du bouton |
| `size` | `'sm' \| 'md' \| 'lg' \| 'xl'` | `'md'` | Taille du bouton |
| `loading` | `boolean` | `false` | Affiche un indicateur de chargement |
| `disabled` | `boolean` | `false` | Désactive le bouton |
| `fullWidth` | `boolean` | `false` | Étend le bouton sur toute la largeur |
| `icon` | `ReactNode` | - | Icône à afficher |
| `onClick` | `() => void` | - | Fonction appelée au clic |

## 📝 Input

Composant de saisie de texte avec support des labels, erreurs et différents types.

### Utilisation de base

```tsx
import { Input } from '@lyxal/ui-kit';

function MyForm() {
  const [email, setEmail] = useState('');
  
  return (
    <Input
      label="Adresse email"
      type="email"
      value={email}
      onChange={(e) => setEmail(e.target.value)}
      placeholder="votre@email.com"
    />
  );
}
```

### Types d'input

```tsx
<div className="space-y-4">
  <Input label="Texte" type="text" />
  <Input label="Email" type="email" />
  <Input label="Mot de passe" type="password" />
  <Input label="Nombre" type="number" />
  <Input label="Téléphone" type="tel" />
  <Input label="URL" type="url" />
  <Input label="Date" type="date" />
</div>
```

### États et validation

```tsx
<div className="space-y-4">
  <Input 
    label="Champ requis" 
    required 
    error="Ce champ est obligatoire"
  />
  <Input 
    label="Champ valide" 
    value="test@example.com"
    helperText="Format d'email valide"
  />
  <Input 
    label="Champ désactivé" 
    disabled 
    value="Non modifiable"
  />
</div>
```

### Avec icônes

```tsx
<div className="space-y-4">
  <Input 
    label="Recherche" 
    icon={<SearchIcon />}
    placeholder="Rechercher..."
  />
  <Input 
    label="Mot de passe" 
    type="password"
    icon={<LockIcon />}
  />
</div>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `label` | `string` | - | Label du champ |
| `type` | `string` | `'text'` | Type HTML de l'input |
| `value` | `string` | - | Valeur contrôlée |
| `onChange` | `(e: ChangeEvent) => void` | - | Callback de changement |
| `placeholder` | `string` | - | Texte d'aide |
| `error` | `string` | - | Message d'erreur |
| `helperText` | `string` | - | Texte d'aide |
| `required` | `boolean` | `false` | Champ obligatoire |
| `disabled` | `boolean` | `false` | Champ désactivé |
| `icon` | `ReactNode` | - | Icône à afficher |

## 🏷️ Badge

Composant pour afficher des étiquettes, statuts ou compteurs.

### Utilisation de base

```tsx
import { Badge } from '@lyxal/ui-kit';

function StatusDisplay() {
  return (
    <div className="space-x-2">
      <Badge variant="primary">Nouveau</Badge>
      <Badge variant="success">Actif</Badge>
      <Badge variant="warning">En attente</Badge>
      <Badge variant="error">Erreur</Badge>
    </div>
  );
}
```

### Variantes

```tsx
<div className="space-x-2">
  <Badge variant="primary">Primary</Badge>
  <Badge variant="secondary">Secondary</Badge>
  <Badge variant="success">Success</Badge>
  <Badge variant="warning">Warning</Badge>
  <Badge variant="error">Error</Badge>
  <Badge variant="info">Info</Badge>
  <Badge variant="outline">Outline</Badge>
</div>
```

### Tailles

```tsx
<div className="space-x-2">
  <Badge size="sm">Small</Badge>
  <Badge size="md">Medium</Badge>
  <Badge size="lg">Large</Badge>
</div>
```

### Avec compteur

```tsx
<div className="space-x-2">
  <Badge variant="primary">Messages 5</Badge>
  <Badge variant="error">Erreurs 12</Badge>
  <Badge variant="success">✓ Validé</Badge>
</div>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `variant` | `'primary' \| 'secondary' \| 'success' \| 'warning' \| 'error' \| 'info' \| 'outline'` | `'primary'` | Style du badge |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | Taille du badge |
| `children` | `ReactNode` | - | Contenu du badge |

## 📝 Textarea

Composant de saisie de texte multiligne.

### Utilisation de base

```tsx
import { Textarea } from '@lyxal/ui-kit';

function CommentForm() {
  const [comment, setComment] = useState('');
  
  return (
    <Textarea
      label="Commentaire"
      value={comment}
      onChange={(e) => setComment(e.target.value)}
      placeholder="Écrivez votre commentaire..."
      rows={4}
    />
  );
}
```

### Avec validation

```tsx
<Textarea
  label="Description"
  required
  error={description.length < 10 ? "Minimum 10 caractères" : ""}
  helperText={`${description.length}/500 caractères`}
  maxLength={500}
/>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `label` | `string` | - | Label du champ |
| `value` | `string` | - | Valeur contrôlée |
| `onChange` | `(e: ChangeEvent) => void` | - | Callback de changement |
| `placeholder` | `string` | - | Texte d'aide |
| `rows` | `number` | `3` | Nombre de lignes |
| `error` | `string` | - | Message d'erreur |
| `helperText` | `string` | - | Texte d'aide |
| `required` | `boolean` | `false` | Champ obligatoire |
| `disabled` | `boolean` | `false` | Champ désactivé |

## ⚡ Loader

Composant d'indicateur de chargement.

### Utilisation de base

```tsx
import { Loader } from '@lyxal/ui-kit';

function LoadingComponent() {
  return (
    <div className="flex justify-center">
      <Loader />
    </div>
  );
}
```

### Variantes

```tsx
<div className="space-x-4">
  <Loader variant="spinner" />
  <Loader variant="dots" />
  <Loader variant="pulse" />
  <Loader variant="bars" />
</div>
```

### Tailles

```tsx
<div className="space-x-4">
  <Loader size="sm" />
  <Loader size="md" />
  <Loader size="lg" />
  <Loader size="xl" />
</div>
```

### Avec texte

```tsx
<div className="text-center space-y-2">
  <Loader size="lg" />
  <p className="text-sm text-base-content/70">Chargement en cours...</p>
</div>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `variant` | `'spinner' \| 'dots' \| 'pulse' \| 'bars'` | `'spinner'` | Type d'animation |
| `size` | `'sm' \| 'md' \| 'lg' \| 'xl'` | `'md'` | Taille du loader |
| `color` | `string` | - | Couleur personnalisée |

## 🎛️ Toggle

Composant d'interrupteur on/off.

### Utilisation de base

```tsx
import { Toggle } from '@lyxal/ui-kit';

function SettingsPanel() {
  const [notifications, setNotifications] = useState(true);
  
  return (
    <Toggle
      checked={notifications}
      onChange={setNotifications}
      label="Activer les notifications"
    />
  );
}
```

### Variantes

```tsx
<div className="space-y-4">
  <Toggle label="Toggle par défaut" />
  <Toggle label="Toggle désactivé" disabled />
  <Toggle label="Toggle avec description" 
          description="Cette option active les notifications push" />
</div>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `checked` | `boolean` | `false` | État du toggle |
| `onChange` | `(checked: boolean) => void` | - | Callback de changement |
| `label` | `string` | - | Label du toggle |
| `description` | `string` | - | Description optionnelle |
| `disabled` | `boolean` | `false` | Toggle désactivé |

## ✅ Checkbox

Composant de case à cocher.

### Utilisation de base

```tsx
import { Checkbox } from '@lyxal/ui-kit';

function PreferencesForm() {
  const [acceptTerms, setAcceptTerms] = useState(false);
  
  return (
    <Checkbox
      checked={acceptTerms}
      onChange={setAcceptTerms}
    >
      J'accepte les conditions d'utilisation
    </Checkbox>
  );
}
```

### Groupe de checkboxes

```tsx
import { CheckboxGroup } from '@lyxal/ui-kit';

function InterestsForm() {
  const [interests, setInterests] = useState([]);
  
  const options = [
    { value: 'tech', label: 'Technologie' },
    { value: 'design', label: 'Design' },
    { value: 'business', label: 'Business' }
  ];
  
  return (
    <CheckboxGroup
      label="Centres d'intérêt"
      options={options}
      value={interests}
      onChange={setInterests}
    />
  );
}
```

### Props Checkbox

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `checked` | `boolean` | `false` | État de la checkbox |
| `onChange` | `(checked: boolean) => void` | - | Callback de changement |
| `children` | `ReactNode` | - | Label de la checkbox |
| `disabled` | `boolean` | `false` | Checkbox désactivée |
| `error` | `string` | - | Message d'erreur |

## 🎨 Exemples d'intégration

### Formulaire complet

```tsx
function ContactForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
    newsletter: false,
    urgent: false
  });

  return (
    <div className="max-w-md mx-auto space-y-6">
      <h2 className="text-2xl font-bold">Contact</h2>
      
      <Input
        label="Nom complet"
        value={formData.name}
        onChange={(e) => setFormData({...formData, name: e.target.value})}
        required
      />
      
      <Input
        label="Email"
        type="email"
        value={formData.email}
        onChange={(e) => setFormData({...formData, email: e.target.value})}
        required
      />
      
      <Textarea
        label="Message"
        value={formData.message}
        onChange={(e) => setFormData({...formData, message: e.target.value})}
        rows={4}
        required
      />
      
      <div className="space-y-2">
        <Checkbox
          checked={formData.newsletter}
          onChange={(checked) => setFormData({...formData, newsletter: checked})}
        >
          S'abonner à la newsletter
        </Checkbox>
        
        <Toggle
          checked={formData.urgent}
          onChange={(checked) => setFormData({...formData, urgent: checked})}
          label="Message urgent"
        />
      </div>
      
      <div className="flex gap-2">
        <Button variant="outline" fullWidth>
          Annuler
        </Button>
        <Button variant="primary" fullWidth>
          Envoyer
        </Button>
      </div>
      
      {formData.urgent && (
        <Badge variant="warning" size="sm">
          ⚡ Message marqué comme urgent
        </Badge>
      )}
    </div>
  );
}
```

---

**Prochaine étape :** Découvrez les [composants de formulaire avancés](./forms.md) ! 