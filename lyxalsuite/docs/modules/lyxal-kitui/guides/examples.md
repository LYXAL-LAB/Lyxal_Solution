# 🎨 Exemples d'intégration

Cette section présente des exemples concrets d'utilisation de LyxalKitUI dans des applications réelles.

## 🚀 Application complète

### Dashboard d'administration

```tsx
import React, { useState, useEffect } from 'react';
import {
  Button,
  Input,
  Badge,
  DataTable,
  Chart,
  Modal,
  Toast,
  Sidebar,
  SidebarSection,
  SidebarNavItem,
  applyTheme,
  useToast
} from '@lyxal/ui-kit';

function AdminDashboard() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { showToast } = useToast();

  // Données simulées
  useEffect(() => {
    setTimeout(() => {
      setUsers([
        { id: 1, name: 'Alice Martin', email: 'alice@example.com', role: 'Admin', status: 'active', lastLogin: '2024-01-15' },
        { id: 2, name: 'Bob Dupont', email: 'bob@example.com', role: 'User', status: 'inactive', lastLogin: '2024-01-10' },
        { id: 3, name: 'Claire Bernard', email: 'claire@example.com', role: 'Moderator', status: 'active', lastLogin: '2024-01-14' }
      ]);
      setLoading(false);
    }, 1000);
  }, []);

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
        <Badge variant={value === 'Admin' ? 'primary' : value === 'Moderator' ? 'secondary' : 'outline'}>
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
          <Button 
            size="sm" 
            variant="outline"
            onClick={() => {
              setSelectedUser(row);
              setIsModalOpen(true);
            }}
          >
            Voir
          </Button>
          <Button 
            size="sm" 
            variant="destructive"
            onClick={() => handleDeleteUser(row.id)}
          >
            Supprimer
          </Button>
        </div>
      )
    }
  ];

  const handleDeleteUser = (userId) => {
    setUsers(users.filter(user => user.id !== userId));
    showToast('Utilisateur supprimé avec succès', 'success');
  };

  const chartData = {
    labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'],
    datasets: [{
      label: 'Nouveaux utilisateurs',
      data: [12, 19, 3, 5, 2, 3],
      borderColor: 'rgb(99, 102, 241)',
      backgroundColor: 'rgba(99, 102, 241, 0.1)'
    }]
  };

  return (
    <div className="flex h-screen bg-base-100">
      {/* Sidebar */}
      <Sidebar className="w-64">
        <div className="p-4">
          <h2 className="text-xl font-bold text-primary-500">Admin Panel</h2>
        </div>
        
        <SidebarSection title="Navigation">
          <SidebarNavItem icon="📊" active>
            Dashboard
          </SidebarNavItem>
          <SidebarNavItem icon="👥">
            Utilisateurs
          </SidebarNavItem>
          <SidebarNavItem icon="📈">
            Statistiques
          </SidebarNavItem>
          <SidebarNavItem icon="⚙️">
            Paramètres
          </SidebarNavItem>
        </SidebarSection>
      </Sidebar>

      {/* Contenu principal */}
      <div className="flex-1 overflow-auto">
        <div className="p-6 space-y-6">
          {/* En-tête */}
          <div className="flex items-center justify-between">
            <h1 className="text-3xl font-bold">Dashboard</h1>
            <div className="flex gap-2">
              <Button variant="outline" onClick={() => applyTheme('dracula')}>
                Thème sombre
              </Button>
              <Button variant="primary">
                Nouveau utilisateur
              </Button>
            </div>
          </div>

          {/* Statistiques */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="card bg-base-200 p-6">
              <h3 className="text-lg font-semibold">Total utilisateurs</h3>
              <p className="text-3xl font-bold text-primary-500">{users.length}</p>
              <Badge variant="success" size="sm">+12% ce mois</Badge>
            </div>
            
            <div className="card bg-base-200 p-6">
              <h3 className="text-lg font-semibold">Utilisateurs actifs</h3>
              <p className="text-3xl font-bold text-success">
                {users.filter(u => u.status === 'active').length}
              </p>
              <Badge variant="info" size="sm">85% du total</Badge>
            </div>
            
            <div className="card bg-base-200 p-6">
              <h3 className="text-lg font-semibold">Nouveaux ce mois</h3>
              <p className="text-3xl font-bold text-accent-500">8</p>
              <Badge variant="warning" size="sm">-5% vs mois dernier</Badge>
            </div>
          </div>

          {/* Graphique */}
          <div className="card bg-base-200 p-6">
            <h2 className="text-xl font-semibold mb-4">Évolution des inscriptions</h2>
            <Chart type="line" data={chartData} height={300} />
          </div>

          {/* Tableau des utilisateurs */}
          <div className="card bg-base-200 p-6">
            <h2 className="text-xl font-semibold mb-4">Gestion des utilisateurs</h2>
            <DataTable
              data={users}
              columns={columns}
              loading={loading}
              searchable
              pagination
              pageSize={10}
            />
          </div>
        </div>
      </div>

      {/* Modal de détails utilisateur */}
      <Modal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Détails de l'utilisateur"
        size="md"
      >
        {selectedUser && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium">Nom</label>
              <p className="text-lg">{selectedUser.name}</p>
            </div>
            
            <div>
              <label className="block text-sm font-medium">Email</label>
              <p className="text-lg">{selectedUser.email}</p>
            </div>
            
            <div>
              <label className="block text-sm font-medium">Rôle</label>
              <Badge variant="primary">{selectedUser.role}</Badge>
            </div>
            
            <div>
              <label className="block text-sm font-medium">Dernière connexion</label>
              <p>{selectedUser.lastLogin}</p>
            </div>
            
            <div className="flex justify-end gap-2 pt-4">
              <Button variant="outline" onClick={() => setIsModalOpen(false)}>
                Fermer
              </Button>
              <Button variant="primary">
                Modifier
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}

export default AdminDashboard;
```

## 📱 Application e-commerce

### Page produit avec panier

```tsx
import React, { useState } from 'react';
import {
  Button,
  Badge,
  Input,
  Modal,
  Toast,
  Tabs,
  Rating,
  ToggleGroup,
  ToggleGroupItem,
  useToast
} from '@lyxal/ui-kit';

function ProductPage() {
  const [selectedSize, setSelectedSize] = useState('M');
  const [selectedColor, setSelectedColor] = useState('blue');
  const [quantity, setQuantity] = useState(1);
  const [activeTab, setActiveTab] = useState('description');
  const [isCartModalOpen, setIsCartModalOpen] = useState(false);
  const { showToast } = useToast();

  const product = {
    id: 1,
    name: 'T-shirt Premium',
    price: 29.99,
    originalPrice: 39.99,
    rating: 4.5,
    reviews: 128,
    inStock: true,
    images: [
      '/product-1.jpg',
      '/product-2.jpg',
      '/product-3.jpg'
    ],
    description: 'T-shirt en coton bio de haute qualité, confortable et durable.',
    features: [
      '100% coton bio',
      'Coupe moderne',
      'Résistant au lavage',
      'Certifié OEKO-TEX'
    ]
  };

  const sizes = ['XS', 'S', 'M', 'L', 'XL'];
  const colors = [
    { value: 'blue', label: 'Bleu', color: '#3b82f6' },
    { value: 'red', label: 'Rouge', color: '#ef4444' },
    { value: 'green', label: 'Vert', color: '#10b981' },
    { value: 'black', label: 'Noir', color: '#1f2937' }
  ];

  const handleAddToCart = () => {
    // Logique d'ajout au panier
    showToast(`${quantity} article(s) ajouté(s) au panier`, 'success');
    setIsCartModalOpen(true);
  };

  const reviews = [
    {
      id: 1,
      author: 'Marie L.',
      rating: 5,
      comment: 'Excellent produit, très confortable !',
      date: '2024-01-10'
    },
    {
      id: 2,
      author: 'Pierre M.',
      rating: 4,
      comment: 'Bonne qualité, taille bien.',
      date: '2024-01-08'
    }
  ];

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Images produit */}
        <div className="space-y-4">
          <div className="aspect-square bg-base-200 rounded-lg flex items-center justify-center">
            <span className="text-4xl">📷</span>
          </div>
          <div className="grid grid-cols-3 gap-2">
            {product.images.map((_, index) => (
              <div key={index} className="aspect-square bg-base-300 rounded-lg flex items-center justify-center">
                <span className="text-xl">📷</span>
              </div>
            ))}
          </div>
        </div>

        {/* Informations produit */}
        <div className="space-y-6">
          <div>
            <h1 className="text-3xl font-bold">{product.name}</h1>
            <div className="flex items-center gap-2 mt-2">
              <Rating value={product.rating} readonly />
              <span className="text-sm text-base-content/70">
                ({product.reviews} avis)
              </span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <span className="text-3xl font-bold text-primary-500">
              {product.price}€
            </span>
            <span className="text-xl text-base-content/50 line-through">
              {product.originalPrice}€
            </span>
            <Badge variant="error">-25%</Badge>
          </div>

          {product.inStock ? (
            <Badge variant="success">En stock</Badge>
          ) : (
            <Badge variant="error">Rupture de stock</Badge>
          )}

          {/* Sélection de taille */}
          <div className="space-y-2">
            <label className="block text-sm font-medium">Taille</label>
            <ToggleGroup value={selectedSize} onValueChange={setSelectedSize}>
              {sizes.map(size => (
                <ToggleGroupItem key={size} value={size}>
                  {size}
                </ToggleGroupItem>
              ))}
            </ToggleGroup>
          </div>

          {/* Sélection de couleur */}
          <div className="space-y-2">
            <label className="block text-sm font-medium">Couleur</label>
            <div className="flex gap-2">
              {colors.map(color => (
                <button
                  key={color.value}
                  onClick={() => setSelectedColor(color.value)}
                  className={`w-8 h-8 rounded-full border-2 ${
                    selectedColor === color.value ? 'border-primary-500' : 'border-base-300'
                  }`}
                  style={{ backgroundColor: color.color }}
                  title={color.label}
                />
              ))}
            </div>
          </div>

          {/* Quantité */}
          <div className="space-y-2">
            <label className="block text-sm font-medium">Quantité</label>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
              >
                -
              </Button>
              <Input
                type="number"
                value={quantity}
                onChange={(e) => setQuantity(parseInt(e.target.value) || 1)}
                className="w-20 text-center"
                min="1"
              />
              <Button
                variant="outline"
                size="sm"
                onClick={() => setQuantity(quantity + 1)}
              >
                +
              </Button>
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-3">
            <Button
              variant="primary"
              size="lg"
              fullWidth
              onClick={handleAddToCart}
              disabled={!product.inStock}
            >
              Ajouter au panier - {(product.price * quantity).toFixed(2)}€
            </Button>
            
            <Button variant="outline" size="lg" fullWidth>
              ❤️ Ajouter aux favoris
            </Button>
          </div>
        </div>
      </div>

      {/* Onglets d'informations */}
      <div className="mt-12">
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <div className="border-b border-base-300">
            <div className="flex space-x-8">
              <button
                onClick={() => setActiveTab('description')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'description'
                    ? 'border-primary-500 text-primary-500'
                    : 'border-transparent text-base-content/70'
                }`}
              >
                Description
              </button>
              <button
                onClick={() => setActiveTab('features')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'features'
                    ? 'border-primary-500 text-primary-500'
                    : 'border-transparent text-base-content/70'
                }`}
              >
                Caractéristiques
              </button>
              <button
                onClick={() => setActiveTab('reviews')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'reviews'
                    ? 'border-primary-500 text-primary-500'
                    : 'border-transparent text-base-content/70'
                }`}
              >
                Avis ({product.reviews})
              </button>
            </div>
          </div>

          <div className="py-6">
            {activeTab === 'description' && (
              <div className="prose max-w-none">
                <p>{product.description}</p>
              </div>
            )}

            {activeTab === 'features' && (
              <ul className="space-y-2">
                {product.features.map((feature, index) => (
                  <li key={index} className="flex items-center gap-2">
                    <span className="text-success">✓</span>
                    {feature}
                  </li>
                ))}
              </ul>
            )}

            {activeTab === 'reviews' && (
              <div className="space-y-6">
                {reviews.map(review => (
                  <div key={review.id} className="border-b border-base-200 pb-4">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <span className="font-medium">{review.author}</span>
                        <Rating value={review.rating} readonly size="sm" />
                      </div>
                      <span className="text-sm text-base-content/70">{review.date}</span>
                    </div>
                    <p className="text-base-content/80">{review.comment}</p>
                  </div>
                ))}
              </div>
            )}
          </div>
        </Tabs>
      </div>

      {/* Modal panier */}
      <Modal
        open={isCartModalOpen}
        onClose={() => setIsCartModalOpen(false)}
        title="Produit ajouté au panier"
        size="md"
      >
        <div className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 bg-base-200 rounded-lg flex items-center justify-center">
              📷
            </div>
            <div>
              <h3 className="font-medium">{product.name}</h3>
              <p className="text-sm text-base-content/70">
                Taille: {selectedSize} | Couleur: {colors.find(c => c.value === selectedColor)?.label}
              </p>
              <p className="text-sm">Quantité: {quantity}</p>
            </div>
          </div>
          
          <div className="flex justify-between items-center pt-4 border-t">
            <span className="font-medium">Total: {(product.price * quantity).toFixed(2)}€</span>
          </div>
          
          <div className="flex gap-2">
            <Button variant="outline" onClick={() => setIsCartModalOpen(false)}>
              Continuer mes achats
            </Button>
            <Button variant="primary">
              Voir le panier
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

export default ProductPage;
```

## 📊 Application de gestion de projet

### Tableau Kanban

```tsx
import React, { useState } from 'react';
import {
  Button,
  Badge,
  Modal,
  Input,
  Textarea,
  Combobox,
  DatePicker,
  Avatar,
  DropdownMenu,
  useToast
} from '@lyxal/ui-kit';

function KanbanBoard() {
  const [columns, setColumns] = useState([
    {
      id: 'todo',
      title: 'À faire',
      color: 'secondary',
      tasks: [
        {
          id: 1,
          title: 'Créer la maquette',
          description: 'Concevoir l\'interface utilisateur',
          priority: 'high',
          assignee: { name: 'Alice', avatar: '👩' },
          dueDate: '2024-01-20',
          tags: ['Design', 'UI']
        }
      ]
    },
    {
      id: 'progress',
      title: 'En cours',
      color: 'warning',
      tasks: [
        {
          id: 2,
          title: 'Développer l\'API',
          description: 'Implémenter les endpoints REST',
          priority: 'medium',
          assignee: { name: 'Bob', avatar: '👨' },
          dueDate: '2024-01-25',
          tags: ['Backend', 'API']
        }
      ]
    },
    {
      id: 'review',
      title: 'En révision',
      color: 'info',
      tasks: []
    },
    {
      id: 'done',
      title: 'Terminé',
      color: 'success',
      tasks: [
        {
          id: 3,
          title: 'Configuration du projet',
          description: 'Mise en place de l\'environnement',
          priority: 'low',
          assignee: { name: 'Claire', avatar: '👩‍💻' },
          dueDate: '2024-01-15',
          tags: ['Setup']
        }
      ]
    }
  ]);

  const [isTaskModalOpen, setIsTaskModalOpen] = useState(false);
  const [selectedTask, setSelectedTask] = useState(null);
  const [newTask, setNewTask] = useState({
    title: '',
    description: '',
    priority: 'medium',
    assignee: null,
    dueDate: null,
    tags: []
  });

  const { showToast } = useToast();

  const priorityOptions = [
    { value: 'low', label: 'Faible', color: 'success' },
    { value: 'medium', label: 'Moyenne', color: 'warning' },
    { value: 'high', label: 'Élevée', color: 'error' }
  ];

  const teamMembers = [
    { value: 'alice', label: 'Alice Martin', avatar: '👩' },
    { value: 'bob', label: 'Bob Dupont', avatar: '👨' },
    { value: 'claire', label: 'Claire Bernard', avatar: '👩‍💻' }
  ];

  const availableTags = [
    { value: 'design', label: 'Design' },
    { value: 'frontend', label: 'Frontend' },
    { value: 'backend', label: 'Backend' },
    { value: 'api', label: 'API' },
    { value: 'ui', label: 'UI' },
    { value: 'setup', label: 'Setup' }
  ];

  const handleCreateTask = () => {
    const task = {
      id: Date.now(),
      ...newTask,
      tags: newTask.tags.map(tag => tag.label)
    };
    
    const updatedColumns = columns.map(col => 
      col.id === 'todo' 
        ? { ...col, tasks: [...col.tasks, task] }
        : col
    );
    
    setColumns(updatedColumns);
    setNewTask({
      title: '',
      description: '',
      priority: 'medium',
      assignee: null,
      dueDate: null,
      tags: []
    });
    setIsTaskModalOpen(false);
    showToast('Tâche créée avec succès', 'success');
  };

  const TaskCard = ({ task, columnId }) => {
    const priority = priorityOptions.find(p => p.value === task.priority);
    
    return (
      <div className="bg-base-100 rounded-lg p-4 shadow-sm border border-base-300 hover:shadow-md transition-shadow">
        <div className="flex items-start justify-between mb-2">
          <h3 className="font-medium text-sm">{task.title}</h3>
          <DropdownMenu
            trigger={
              <Button variant="ghost" size="sm">⋮</Button>
            }
            items={[
              { label: 'Modifier', onClick: () => {} },
              { label: 'Dupliquer', onClick: () => {} },
              { label: 'Supprimer', onClick: () => {}, variant: 'destructive' }
            ]}
          />
        </div>
        
        {task.description && (
          <p className="text-xs text-base-content/70 mb-3">{task.description}</p>
        )}
        
        <div className="flex flex-wrap gap-1 mb-3">
          {task.tags.map(tag => (
            <Badge key={tag} variant="outline" size="sm">
              {tag}
            </Badge>
          ))}
        </div>
        
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Avatar size="sm">{task.assignee.avatar}</Avatar>
            <Badge variant={priority.color} size="sm">
              {priority.label}
            </Badge>
          </div>
          
          {task.dueDate && (
            <span className="text-xs text-base-content/70">
              {new Date(task.dueDate).toLocaleDateString()}
            </span>
          )}
        </div>
      </div>
    );
  };

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Tableau de projet</h1>
        <Button 
          variant="primary" 
          onClick={() => setIsTaskModalOpen(true)}
        >
          + Nouvelle tâche
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {columns.map(column => (
          <div key={column.id} className="bg-base-200 rounded-lg p-4">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <h2 className="font-semibold">{column.title}</h2>
                <Badge variant={column.color} size="sm">
                  {column.tasks.length}
                </Badge>
              </div>
            </div>
            
            <div className="space-y-3">
              {column.tasks.map(task => (
                <TaskCard key={task.id} task={task} columnId={column.id} />
              ))}
            </div>
            
            {column.id === 'todo' && (
              <Button
                variant="ghost"
                size="sm"
                fullWidth
                className="mt-3 border-2 border-dashed border-base-300"
                onClick={() => setIsTaskModalOpen(true)}
              >
                + Ajouter une tâche
              </Button>
            )}
          </div>
        ))}
      </div>

      {/* Modal de création de tâche */}
      <Modal
        open={isTaskModalOpen}
        onClose={() => setIsTaskModalOpen(false)}
        title="Nouvelle tâche"
        size="lg"
      >
        <div className="space-y-4">
          <Input
            label="Titre de la tâche"
            value={newTask.title}
            onChange={(e) => setNewTask({...newTask, title: e.target.value})}
            placeholder="Ex: Créer la page d'accueil"
            required
          />
          
          <Textarea
            label="Description"
            value={newTask.description}
            onChange={(e) => setNewTask({...newTask, description: e.target.value})}
            placeholder="Décrivez la tâche en détail..."
            rows={3}
          />
          
          <div className="grid grid-cols-2 gap-4">
            <Combobox
              label="Priorité"
              options={priorityOptions}
              value={priorityOptions.find(p => p.value === newTask.priority)}
              onChange={(priority) => setNewTask({...newTask, priority: priority.value})}
            />
            
            <Combobox
              label="Assigné à"
              options={teamMembers}
              value={newTask.assignee}
              onChange={(assignee) => setNewTask({...newTask, assignee})}
              placeholder="Choisir une personne"
            />
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <DatePicker
              label="Date d'échéance"
              value={newTask.dueDate}
              onChange={(date) => setNewTask({...newTask, dueDate: date})}
              minDate={new Date()}
            />
            
            <Combobox
              label="Tags"
              options={availableTags}
              value={newTask.tags}
              onChange={(tags) => setNewTask({...newTask, tags})}
              multiple
              placeholder="Ajouter des tags"
            />
          </div>
          
          <div className="flex justify-end gap-2 pt-4">
            <Button 
              variant="outline" 
              onClick={() => setIsTaskModalOpen(false)}
            >
              Annuler
            </Button>
            <Button 
              variant="primary" 
              onClick={handleCreateTask}
              disabled={!newTask.title}
            >
              Créer la tâche
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

export default KanbanBoard;
```

## 🎨 Thèmes personnalisés

### Créer un thème d'entreprise

```tsx
import { registerTheme, applyTheme } from '@lyxal/ui-kit';

// Thème corporate personnalisé
const corporateTheme = {
  name: 'corporate-blue',
  type: 'light',
  colors: {
    primary: {
      50: '#eff6ff',
      100: '#dbeafe',
      200: '#bfdbfe',
      300: '#93c5fd',
      400: '#60a5fa',
      500: '#3b82f6', // Bleu principal de l'entreprise
      600: '#2563eb',
      700: '#1d4ed8',
      800: '#1e40af',
      900: '#1e3a8a'
    },
    secondary: {
      50: '#f8fafc',
      100: '#f1f5f9',
      200: '#e2e8f0',
      300: '#cbd5e1',
      400: '#94a3b8',
      500: '#64748b',
      600: '#475569',
      700: '#334155',
      800: '#1e293b',
      900: '#0f172a'
    },
    accent: {
      50: '#fdf4ff',
      100: '#fae8ff',
      200: '#f5d0fe',
      300: '#f0abfc',
      400: '#e879f9',
      500: '#d946ef',
      600: '#c026d3',
      700: '#a21caf',
      800: '#86198f',
      900: '#701a75'
    },
    base: {
      100: '#ffffff',
      200: '#f8fafc',
      300: '#f1f5f9',
      content: '#0f172a'
    },
    success: '#059669',
    warning: '#d97706',
    error: '#dc2626',
    info: '#0284c7'
  },
  radius: '0.375rem',
  fontFamily: '"Inter", "Segoe UI", sans-serif',
  fontSize: '14px',
  borderWidth: '1px',
  shadowDepth: '0.125rem',
  noise: '0'
};

// Enregistrer et appliquer le thème
registerTheme(corporateTheme);

function App() {
  useEffect(() => {
    applyTheme('corporate-blue');
  }, []);

  return <YourApp />;
}
```

### Système de thème dynamique

```tsx
function ThemeCustomizer() {
  const [customTheme, setCustomTheme] = useState({
    name: 'mon-theme-custom',
    type: 'light',
    colors: {
      primary: { 500: '#3b82f6' },
      base: { 100: '#ffffff', content: '#000000' }
    }
  });

  const handleColorChange = (colorPath, value) => {
    const newTheme = { ...customTheme };
    const keys = colorPath.split('.');
    let current = newTheme.colors;
    
    for (let i = 0; i < keys.length - 1; i++) {
      current = current[keys[i]];
    }
    current[keys[keys.length - 1]] = value;
    
    setCustomTheme(newTheme);
    registerTheme(newTheme);
    applyTheme(newTheme.name);
  };

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold">Personnaliser le thème</h2>
      
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium mb-2">
            Couleur principale
          </label>
          <input
            type="color"
            value={customTheme.colors.primary[500]}
            onChange={(e) => handleColorChange('primary.500', e.target.value)}
            className="w-full h-10 rounded border"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium mb-2">
            Arrière-plan
          </label>
          <input
            type="color"
            value={customTheme.colors.base[100]}
            onChange={(e) => handleColorChange('base.100', e.target.value)}
            className="w-full h-10 rounded border"
          />
        </div>
      </div>
      
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Prévisualisation</h3>
        <div className="p-4 border rounded-lg space-y-4">
          <Button variant="primary">Bouton principal</Button>
          <Input label="Champ de saisie" placeholder="Exemple" />
          <Badge variant="primary">Badge</Badge>
        </div>
      </div>
      
      <Button 
        variant="primary" 
        onClick={() => {
          // Sauvegarder le thème
          localStorage.setItem('custom-theme', JSON.stringify(customTheme));
          showToast('Thème sauvegardé !', 'success');
        }}
      >
        Sauvegarder le thème
      </Button>
    </div>
  );
}
```

---

**Ces exemples montrent la puissance et la flexibilité de LyxalKitUI pour créer des applications modernes et interactives !** 