# 🚀 Guide de démarrage rapide

Ce guide vous permet de commencer rapidement avec LyxalKitUI et ses composants essentiels.

## ⚡ Premier exemple

Voici un exemple complet pour créer votre première interface avec LyxalKitUI :

```tsx
import React, { useState } from 'react';
import { 
  Button, 
  Input, 
  Badge, 
  Modal, 
  Toast, 
  applyTheme 
} from '@lyxal/ui-kit';

function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [email, setEmail] = useState('');

  // Appliquer un thème au démarrage
  React.useEffect(() => {
    applyTheme('dracula');
  }, []);

  return (
    <div className="min-h-screen bg-base-100 p-8">
      <div className="max-w-4xl mx-auto space-y-8">
        
        {/* En-tête */}
        <div className="text-center space-y-4">
          <h1 className="text-4xl font-bold text-base-content">
            Bienvenue dans LyxalKitUI
          </h1>
          <Badge variant="primary" size="lg">
            Version 1.0.0
          </Badge>
        </div>

        {/* Formulaire de base */}
        <div className="card bg-base-200 shadow-xl p-6">
          <h2 className="text-2xl font-semibold mb-4">Formulaire de contact</h2>
          
          <div className="space-y-4">
            <Input
              label="Adresse email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="votre@email.com"
              helperText="Nous ne partagerons jamais votre email"
            />
            
            <div className="flex gap-2">
              <Button 
                variant="primary" 
                onClick={() => setIsModalOpen(true)}
                disabled={!email}
              >
                Envoyer
              </Button>
              
              <Button variant="outline">
                Annuler
              </Button>
            </div>
          </div>
        </div>

        {/* Modal de confirmation */}
        <Modal
          open={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          title="Confirmation"
          size="md"
        >
          <div className="space-y-4">
            <p>Voulez-vous vraiment envoyer ce message à {email} ?</p>
            
            <div className="flex justify-end gap-2">
              <Button 
                variant="outline" 
                onClick={() => setIsModalOpen(false)}
              >
                Annuler
              </Button>
              <Button 
                variant="primary"
                onClick={() => {
                  setIsModalOpen(false);
                  // Logique d'envoi ici
                }}
              >
                Confirmer
              </Button>
            </div>
          </div>
        </Modal>
      </div>
    </div>
  );
}

export default App;
```

## 🎨 Changement de thème

LyxalKitUI inclut plusieurs thèmes prédéfinis :

```tsx
import { applyTheme, getAvailableThemes } from '@lyxal/ui-kit';

function ThemeSelector() {
  const themes = getAvailableThemes();
  
  return (
    <div className="space-y-2">
      <h3>Choisir un thème :</h3>
      {themes.map(theme => (
        <Button
          key={theme}
          variant="outline"
          size="sm"
          onClick={() => applyTheme(theme)}
        >
          {theme}
        </Button>
      ))}
    </div>
  );
}
```

## 📋 Formulaire complet

Exemple d'un formulaire d'inscription avec validation :

```tsx
import React, { useState } from 'react';
import { 
  Form, 
  FormGroup, 
  Input, 
  Textarea, 
  Checkbox, 
  Button,
  Badge,
  useToast 
} from '@lyxal/ui-kit';

function SignupForm() {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    bio: '',
    acceptTerms: false
  });
  
  const [errors, setErrors] = useState({});
  const { showToast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation simple
    const newErrors = {};
    if (!formData.firstName) newErrors.firstName = 'Prénom requis';
    if (!formData.email) newErrors.email = 'Email requis';
    if (!formData.acceptTerms) newErrors.acceptTerms = 'Vous devez accepter les CGU';
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    // Simulation d'envoi
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      showToast('Inscription réussie !', 'success');
      setFormData({ firstName: '', lastName: '', email: '', bio: '', acceptTerms: false });
    } catch (error) {
      showToast('Erreur lors de l\'inscription', 'error');
    }
  };

  return (
    <div className="max-w-md mx-auto">
      <Form onSubmit={handleSubmit} className="space-y-6">
        <div className="text-center">
          <h2 className="text-2xl font-bold">Inscription</h2>
          <Badge variant="info">Créez votre compte</Badge>
        </div>

        <FormGroup>
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Prénom"
              value={formData.firstName}
              onChange={(e) => setFormData({...formData, firstName: e.target.value})}
              error={errors.firstName}
              required
            />
            
            <Input
              label="Nom"
              value={formData.lastName}
              onChange={(e) => setFormData({...formData, lastName: e.target.value})}
            />
          </div>
        </FormGroup>

        <FormGroup>
          <Input
            label="Email"
            type="email"
            value={formData.email}
            onChange={(e) => setFormData({...formData, email: e.target.value})}
            error={errors.email}
            required
          />
        </FormGroup>

        <FormGroup>
          <Textarea
            label="Bio (optionnel)"
            value={formData.bio}
            onChange={(e) => setFormData({...formData, bio: e.target.value})}
            placeholder="Parlez-nous de vous..."
            rows={3}
          />
        </FormGroup>

        <FormGroup>
          <Checkbox
            checked={formData.acceptTerms}
            onChange={(checked) => setFormData({...formData, acceptTerms: checked})}
            error={errors.acceptTerms}
          >
            J'accepte les conditions d'utilisation
          </Checkbox>
        </FormGroup>

        <Button 
          type="submit" 
          variant="primary" 
          size="lg" 
          fullWidth
          disabled={!formData.acceptTerms}
        >
          S'inscrire
        </Button>
      </Form>
    </div>
  );
}
```

## 📊 Tableau de données

Exemple d'affichage de données tabulaires :

```tsx
import { DataTable, Badge, Button } from '@lyxal/ui-kit';

function UserTable() {
  const users = [
    { id: 1, name: 'Alice Martin', email: 'alice@example.com', role: 'Admin', status: 'active' },
    { id: 2, name: 'Bob Dupont', email: 'bob@example.com', role: 'User', status: 'inactive' },
    { id: 3, name: 'Claire Bernard', email: 'claire@example.com', role: 'Moderator', status: 'active' },
  ];

  const columns = [
    {
      key: 'name',
      title: 'Nom',
      sortable: true
    },
    {
      key: 'email',
      title: 'Email'
    },
    {
      key: 'role',
      title: 'Rôle',
      render: (value) => (
        <Badge variant={value === 'Admin' ? 'primary' : 'secondary'}>
          {value}
        </Badge>
      )
    },
    {
      key: 'status',
      title: 'Statut',
      render: (value) => (
        <Badge variant={value === 'active' ? 'success' : 'warning'}>
          {value === 'active' ? 'Actif' : 'Inactif'}
        </Badge>
      )
    },
    {
      key: 'actions',
      title: 'Actions',
      render: (_, row) => (
        <div className="flex gap-2">
          <Button size="sm" variant="outline">
            Éditer
          </Button>
          <Button size="sm" variant="destructive">
            Supprimer
          </Button>
        </div>
      )
    }
  ];

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-semibold">Gestion des utilisateurs</h2>
      
      <DataTable
        data={users}
        columns={columns}
        searchable
        pagination
        pageSize={5}
      />
    </div>
  );
}
```

## 🎯 Interface de tableau de bord

Exemple d'un mini-dashboard :

```tsx
import { 
  Badge, 
  Button, 
  Chart, 
  Skeleton, 
  Toast,
  Modal 
} from '@lyxal/ui-kit';

function Dashboard() {
  const [loading, setLoading] = useState(true);

  // Simulation de chargement
  useEffect(() => {
    setTimeout(() => setLoading(false), 2000);
  }, []);

  const stats = [
    { title: 'Utilisateurs', value: '1,234', change: '+12%', positive: true },
    { title: 'Ventes', value: '€45,678', change: '+8%', positive: true },
    { title: 'Commandes', value: '234', change: '-3%', positive: false },
    { title: 'Revenus', value: '€12,345', change: '+15%', positive: true }
  ];

  const chartData = {
    labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'],
    datasets: [{
      label: 'Ventes',
      data: [12, 19, 3, 5, 2, 3],
      borderColor: 'rgb(99, 102, 241)',
      backgroundColor: 'rgba(99, 102, 241, 0.1)'
    }]
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <Skeleton height="h-8" className="w-64" />
        <div className="grid grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <Skeleton key={i} height="h-24" />
          ))}
        </div>
        <Skeleton height="h-64" />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold">Tableau de bord</h1>
        <Button variant="primary">
          Actualiser
        </Button>
      </div>

      {/* Statistiques */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, index) => (
          <div key={index} className="card bg-base-200 p-4">
            <h3 className="text-sm font-medium text-base-content/70">
              {stat.title}
            </h3>
            <div className="flex items-center justify-between mt-2">
              <p className="text-2xl font-bold">{stat.value}</p>
              <Badge 
                variant={stat.positive ? 'success' : 'warning'}
                size="sm"
              >
                {stat.change}
              </Badge>
            </div>
          </div>
        ))}
      </div>

      {/* Graphique */}
      <div className="card bg-base-200 p-6">
        <h2 className="text-xl font-semibold mb-4">Évolution des ventes</h2>
        <Chart type="line" data={chartData} height={300} />
      </div>
    </div>
  );
}
```

## 🔍 Composants de recherche

Interface de recherche avancée :

```tsx
import { 
  Input, 
  Button, 
  Badge, 
  Combobox, 
  ContextMenu 
} from '@lyxal/ui-kit';

function SearchInterface() {
  const [query, setQuery] = useState('');
  const [filters, setFilters] = useState([]);
  
  const categories = [
    { value: 'docs', label: 'Documentation' },
    { value: 'code', label: 'Code' },
    { value: 'issues', label: 'Issues' }
  ];

  return (
    <div className="space-y-4">
      <div className="flex gap-2">
        <Input
          placeholder="Rechercher..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="flex-1"
        />
        
        <Combobox
          options={categories}
          placeholder="Catégorie"
          onChange={(value) => setFilters([...filters, value])}
        />
        
        <Button variant="primary">
          Rechercher
        </Button>
      </div>

      {/* Filtres appliqués */}
      {filters.length > 0 && (
        <div className="flex gap-2 flex-wrap">
          <span className="text-sm text-base-content/70">Filtres :</span>
          {filters.map((filter, index) => (
            <Badge
              key={index}
              variant="outline"
              className="cursor-pointer"
              onClick={() => setFilters(filters.filter((_, i) => i !== index))}
            >
              {filter} ✕
            </Badge>
          ))}
        </div>
      )}
    </div>
  );
}
```

## 🎨 Prochaines étapes

Maintenant que vous maîtrisez les bases, explorez :

1. [**Système de thèmes**](./themes.md) - Personnaliser l'apparence
2. [**Composants avancés**](./components/) - Explorer tous les composants
3. [**Exemples complets**](./examples.md) - Intégrations réelles
4. [**Personnalisation**](./customization.md) - Adapter à vos besoins

## 💡 Conseils pratiques

### Performance
- Utilisez `React.memo()` pour les composants qui se re-rendent souvent
- Préférez les imports spécifiques aux imports globaux
- Utilisez le lazy loading pour les gros composants

### Accessibilité
- Ajoutez toujours des labels aux inputs
- Utilisez les props `aria-*` quand nécessaire
- Testez la navigation au clavier

### Styling
- Utilisez les variables CSS de thème pour la cohérence
- Préférez les classes Tailwind aux styles inline
- Respectez la hiérarchie des couleurs du thème

---

**Prêt à aller plus loin ?** Consultez la [référence complète des composants](./components/basic.md) ! 