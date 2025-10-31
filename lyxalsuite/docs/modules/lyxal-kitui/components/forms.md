# 📋 Composants de formulaire

Cette section couvre les composants de formulaire avancés de LyxalKitUI pour créer des interfaces de saisie complexes et intuitives.

## 📝 Form

Le composant Form fournit une structure et une gestion d'état pour vos formulaires.

### Utilisation de base

```tsx
import { Form, FormGroup } from '@lyxal/ui-kit';

function MyForm() {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Logique de soumission
  };

  return (
    <Form onSubmit={handleSubmit} className="space-y-6">
      <FormGroup>
        <Input label="Nom" required />
      </FormGroup>
      
      <FormGroup>
        <Input label="Email" type="email" required />
      </FormGroup>
      
      <Button type="submit" variant="primary">
        Envoyer
      </Button>
    </Form>
  );
}
```

### Groupes de champs

```tsx
<Form className="space-y-6">
  <FormFieldset legend="Informations personnelles">
    <FormGroupRow>
      <Input label="Prénom" />
      <Input label="Nom" />
    </FormGroupRow>
    
    <FormGroup>
      <Input label="Email" type="email" />
    </FormGroup>
  </FormFieldset>
  
  <FormDivider />
  
  <FormFieldset legend="Adresse">
    <FormGroup>
      <Input label="Rue" />
    </FormGroup>
    
    <FormGroupRow>
      <Input label="Ville" />
      <Input label="Code postal" />
    </FormGroupRow>
  </FormFieldset>
  
  <FormActions>
    <Button variant="outline">Annuler</Button>
    <Button variant="primary" type="submit">Sauvegarder</Button>
  </FormActions>
</Form>
```

### Props Form

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `onSubmit` | `(e: FormEvent) => void` | - | Gestionnaire de soumission |
| `className` | `string` | - | Classes CSS personnalisées |
| `children` | `ReactNode` | - | Contenu du formulaire |

## 📅 DatePicker

Composant de sélection de date avec calendrier intégré.

### Utilisation de base

```tsx
import { DatePicker } from '@lyxal/ui-kit';

function EventForm() {
  const [startDate, setStartDate] = useState<Date | null>(null);
  
  return (
    <DatePicker
      label="Date de début"
      value={startDate}
      onChange={setStartDate}
      placeholder="Sélectionner une date"
    />
  );
}
```

### Plage de dates

```tsx
function BookingForm() {
  const [dateRange, setDateRange] = useState<{start: Date | null, end: Date | null}>({
    start: null,
    end: null
  });
  
  return (
    <div className="space-y-4">
      <DatePicker
        label="Date d'arrivée"
        value={dateRange.start}
        onChange={(date) => setDateRange({...dateRange, start: date})}
        minDate={new Date()}
      />
      
      <DatePicker
        label="Date de départ"
        value={dateRange.end}
        onChange={(date) => setDateRange({...dateRange, end: date})}
        minDate={dateRange.start || new Date()}
      />
    </div>
  );
}
```

### Avec restrictions

```tsx
<DatePicker
  label="Date de naissance"
  value={birthDate}
  onChange={setBirthDate}
  maxDate={new Date()} // Pas de date future
  yearRange={[1900, new Date().getFullYear()]}
  format="dd/MM/yyyy"
/>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `label` | `string` | - | Label du champ |
| `value` | `Date \| null` | `null` | Date sélectionnée |
| `onChange` | `(date: Date \| null) => void` | - | Callback de changement |
| `placeholder` | `string` | - | Texte d'aide |
| `minDate` | `Date` | - | Date minimum |
| `maxDate` | `Date` | - | Date maximum |
| `format` | `string` | `'MM/dd/yyyy'` | Format d'affichage |
| `disabled` | `boolean` | `false` | Champ désactivé |

## 🔢 InputOTP

Composant de saisie de code OTP (One-Time Password).

### Utilisation de base

```tsx
import { InputOTP } from '@lyxal/ui-kit';

function VerificationForm() {
  const [otp, setOtp] = useState('');
  
  return (
    <div className="space-y-4">
      <h3>Vérification par SMS</h3>
      <p className="text-sm text-base-content/70">
        Entrez le code à 6 chiffres envoyé au +33 6 ** ** ** 42
      </p>
      
      <InputOTP
        length={6}
        value={otp}
        onChange={setOtp}
        onComplete={(code) => {
          console.log('Code complet:', code);
          // Vérifier le code
        }}
      />
      
      <Button 
        variant="primary" 
        disabled={otp.length !== 6}
        fullWidth
      >
        Vérifier
      </Button>
    </div>
  );
}
```

### Différentes configurations

```tsx
<div className="space-y-6">
  {/* Code à 4 chiffres */}
  <InputOTP
    label="Code PIN"
    length={4}
    type="numeric"
    secure // Masque les caractères
  />
  
  {/* Code alphanumérique */}
  <InputOTP
    label="Code de confirmation"
    length={8}
    type="alphanumeric"
    placeholder="Entrez le code"
  />
  
  {/* Avec séparateurs */}
  <InputOTP
    label="Code de licence"
    length={12}
    separator="-"
    groupSize={4} // XXXX-XXXX-XXXX
  />
</div>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `length` | `number` | `6` | Nombre de caractères |
| `value` | `string` | `''` | Valeur du code |
| `onChange` | `(value: string) => void` | - | Callback de changement |
| `onComplete` | `(value: string) => void` | - | Appelé quand le code est complet |
| `type` | `'numeric' \| 'alphanumeric' \| 'alpha'` | `'numeric'` | Type de caractères acceptés |
| `secure` | `boolean` | `false` | Masque les caractères |
| `separator` | `string` | - | Séparateur entre groupes |
| `groupSize` | `number` | - | Taille des groupes |

## 🎛️ ToggleGroup

Composant pour créer des groupes d'options mutuellement exclusives.

### Utilisation de base

```tsx
import { ToggleGroup, ToggleGroupItem } from '@lyxal/ui-kit';

function PreferencesForm() {
  const [alignment, setAlignment] = useState('left');
  
  return (
    <div className="space-y-4">
      <label className="block text-sm font-medium">Alignement du texte</label>
      
      <ToggleGroup value={alignment} onValueChange={setAlignment}>
        <ToggleGroupItem value="left">
          <AlignLeftIcon />
          Gauche
        </ToggleGroupItem>
        <ToggleGroupItem value="center">
          <AlignCenterIcon />
          Centre
        </ToggleGroupItem>
        <ToggleGroupItem value="right">
          <AlignRightIcon />
          Droite
        </ToggleGroupItem>
      </ToggleGroup>
    </div>
  );
}
```

### Sélection multiple

```tsx
function ToolbarForm() {
  const [formatting, setFormatting] = useState(['bold']);
  
  return (
    <ToggleGroup 
      type="multiple" 
      value={formatting} 
      onValueChange={setFormatting}
    >
      <ToggleGroupItem value="bold">
        <BoldIcon />
      </ToggleGroupItem>
      <ToggleGroupItem value="italic">
        <ItalicIcon />
      </ToggleGroupItem>
      <ToggleGroupItem value="underline">
        <UnderlineIcon />
      </ToggleGroupItem>
    </ToggleGroup>
  );
}
```

### Variantes

```tsx
<div className="space-y-4">
  {/* Variante outline */}
  <ToggleGroup variant="outline">
    <ToggleGroupItem value="sm">S</ToggleGroupItem>
    <ToggleGroupItem value="md">M</ToggleGroupItem>
    <ToggleGroupItem value="lg">L</ToggleGroupItem>
  </ToggleGroup>
  
  {/* Variante solid */}
  <ToggleGroup variant="solid" size="lg">
    <ToggleGroupItem value="grid">
      <GridIcon />
    </ToggleGroupItem>
    <ToggleGroupItem value="list">
      <ListIcon />
    </ToggleGroupItem>
  </ToggleGroup>
</div>
```

### Props ToggleGroup

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `type` | `'single' \| 'multiple'` | `'single'` | Type de sélection |
| `value` | `string \| string[]` | - | Valeur(s) sélectionnée(s) |
| `onValueChange` | `(value: string \| string[]) => void` | - | Callback de changement |
| `variant` | `'default' \| 'outline' \| 'solid'` | `'default'` | Style du groupe |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | Taille des éléments |

## 🎯 Combobox

Composant de sélection avec recherche et autocomplétion.

### Utilisation de base

```tsx
import { Combobox } from '@lyxal/ui-kit';

function CountrySelector() {
  const [selectedCountry, setSelectedCountry] = useState(null);
  
  const countries = [
    { value: 'fr', label: 'France' },
    { value: 'us', label: 'États-Unis' },
    { value: 'de', label: 'Allemagne' },
    { value: 'es', label: 'Espagne' },
    { value: 'it', label: 'Italie' }
  ];
  
  return (
    <Combobox
      label="Pays"
      options={countries}
      value={selectedCountry}
      onChange={setSelectedCountry}
      placeholder="Rechercher un pays..."
      searchable
    />
  );
}
```

### Avec création d'options

```tsx
function TagSelector() {
  const [tags, setTags] = useState([]);
  const [availableTags, setAvailableTags] = useState([
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue.js' },
    { value: 'angular', label: 'Angular' }
  ]);
  
  return (
    <Combobox
      label="Technologies"
      options={availableTags}
      value={tags}
      onChange={setTags}
      multiple
      creatable
      onCreateOption={(inputValue) => {
        const newTag = { value: inputValue.toLowerCase(), label: inputValue };
        setAvailableTags([...availableTags, newTag]);
        setTags([...tags, newTag]);
      }}
      placeholder="Sélectionner ou créer des tags..."
    />
  );
}
```

### Avec groupes

```tsx
const groupedOptions = [
  {
    label: 'Fruits',
    options: [
      { value: 'apple', label: 'Pomme' },
      { value: 'banana', label: 'Banane' }
    ]
  },
  {
    label: 'Légumes',
    options: [
      { value: 'carrot', label: 'Carotte' },
      { value: 'lettuce', label: 'Laitue' }
    ]
  }
];

<Combobox
  label="Aliments"
  options={groupedOptions}
  grouped
  placeholder="Choisir un aliment..."
/>
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `label` | `string` | - | Label du champ |
| `options` | `ComboboxOption[]` | `[]` | Options disponibles |
| `value` | `ComboboxOption \| ComboboxOption[]` | - | Valeur(s) sélectionnée(s) |
| `onChange` | `(value) => void` | - | Callback de changement |
| `placeholder` | `string` | - | Texte d'aide |
| `searchable` | `boolean` | `true` | Permet la recherche |
| `multiple` | `boolean` | `false` | Sélection multiple |
| `creatable` | `boolean` | `false` | Permet la création d'options |
| `onCreateOption` | `(inputValue: string) => void` | - | Callback de création |
| `grouped` | `boolean` | `false` | Options groupées |

## 🎨 Exemples d'intégration

### Formulaire d'inscription complet

```tsx
function SignupForm() {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    birthDate: null,
    country: null,
    interests: [],
    newsletter: false,
    terms: false
  });

  const countries = [
    { value: 'fr', label: 'France' },
    { value: 'us', label: 'États-Unis' },
    { value: 'ca', label: 'Canada' }
  ];

  const interests = [
    { value: 'tech', label: 'Technologie' },
    { value: 'design', label: 'Design' },
    { value: 'business', label: 'Business' },
    { value: 'science', label: 'Science' }
  ];

  return (
    <Form className="max-w-2xl mx-auto space-y-8">
      <div className="text-center">
        <h2 className="text-3xl font-bold">Créer un compte</h2>
        <p className="text-base-content/70 mt-2">
          Rejoignez notre communauté dès aujourd'hui
        </p>
      </div>

      <FormFieldset legend="Informations personnelles">
        <FormGroupRow>
          <Input
            label="Prénom"
            value={formData.firstName}
            onChange={(e) => setFormData({...formData, firstName: e.target.value})}
            required
          />
          <Input
            label="Nom"
            value={formData.lastName}
            onChange={(e) => setFormData({...formData, lastName: e.target.value})}
            required
          />
        </FormGroupRow>

        <FormGroup>
          <Input
            label="Email"
            type="email"
            value={formData.email}
            onChange={(e) => setFormData({...formData, email: e.target.value})}
            required
          />
        </FormGroup>

        <FormGroupRow>
          <DatePicker
            label="Date de naissance"
            value={formData.birthDate}
            onChange={(date) => setFormData({...formData, birthDate: date})}
            maxDate={new Date()}
          />
          
          <Combobox
            label="Pays"
            options={countries}
            value={formData.country}
            onChange={(country) => setFormData({...formData, country})}
            placeholder="Sélectionner..."
          />
        </FormGroupRow>
      </FormFieldset>

      <FormDivider />

      <FormFieldset legend="Préférences">
        <FormGroup>
          <Combobox
            label="Centres d'intérêt"
            options={interests}
            value={formData.interests}
            onChange={(interests) => setFormData({...formData, interests})}
            multiple
            placeholder="Choisir vos centres d'intérêt..."
          />
        </FormGroup>

        <FormGroupColumn>
          <Checkbox
            checked={formData.newsletter}
            onChange={(checked) => setFormData({...formData, newsletter: checked})}
          >
            Recevoir la newsletter hebdomadaire
          </Checkbox>
          
          <Checkbox
            checked={formData.terms}
            onChange={(checked) => setFormData({...formData, terms: checked})}
            required
          >
            J'accepte les <a href="#" className="text-primary-500 underline">conditions d'utilisation</a>
          </Checkbox>
        </FormGroupColumn>
      </FormFieldset>

      <FormActions>
        <Button variant="outline" size="lg">
          Annuler
        </Button>
        <Button 
          variant="primary" 
          size="lg" 
          type="submit"
          disabled={!formData.terms}
        >
          Créer mon compte
        </Button>
      </FormActions>
    </Form>
  );
}
```

### Formulaire de paramètres

```tsx
function SettingsForm() {
  const [settings, setSettings] = useState({
    theme: 'auto',
    language: 'fr',
    notifications: {
      email: true,
      push: false,
      sms: false
    },
    privacy: 'friends'
  });

  return (
    <Form className="space-y-8">
      <FormFieldset legend="Apparence">
        <FormGroup>
          <ToggleGroup 
            value={settings.theme} 
            onValueChange={(theme) => setSettings({...settings, theme})}
          >
            <ToggleGroupItem value="light">
              <SunIcon />
              Clair
            </ToggleGroupItem>
            <ToggleGroupItem value="dark">
              <MoonIcon />
              Sombre
            </ToggleGroupItem>
            <ToggleGroupItem value="auto">
              <ComputerIcon />
              Auto
            </ToggleGroupItem>
          </ToggleGroup>
        </FormGroup>
      </FormFieldset>

      <FormFieldset legend="Notifications">
        <FormGroupColumn>
          <Toggle
            checked={settings.notifications.email}
            onChange={(checked) => setSettings({
              ...settings, 
              notifications: {...settings.notifications, email: checked}
            })}
            label="Notifications par email"
            description="Recevoir les mises à jour importantes"
          />
          
          <Toggle
            checked={settings.notifications.push}
            onChange={(checked) => setSettings({
              ...settings, 
              notifications: {...settings.notifications, push: checked}
            })}
            label="Notifications push"
            description="Notifications en temps réel sur votre appareil"
          />
        </FormGroupColumn>
      </FormFieldset>
    </Form>
  );
}
```

---

**Prochaine étape :** Explorez les [composants de navigation](./navigation.md) ! 