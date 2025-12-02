# 🎨 NOUVEAUX COMPOSANTS - Système de Thèmes v2.0

**34 nouveaux composants et utilitaires disponibles**

---

## 📋 LISTE COMPLÈTE

### 🔘 Boutons (11 nouveaux)

#### Tailles (4)
```html
<!-- Extra Small -->
<button class="btn btn-primary btn-xs">XS</button>

<!-- Small -->
<button class="btn btn-primary btn-sm">Small</button>

<!-- Large -->
<button class="btn btn-primary btn-lg">Large</button>

<!-- Extra Large -->
<button class="btn btn-primary btn-xl">Extra Large</button>
```

#### Variants Avancés (4)
```html
<!-- Gradient (Primary → Accent) -->
<button class="btn btn-gradient">Gradient</button>

<!-- Neon Glow -->
<button class="btn btn-neon">Neon Effect</button>

<!-- Glassmorphism -->
<button class="btn btn-glass">Glass Effect</button>

<!-- 3D Effect -->
<button class="btn btn-3d">3D Button</button>
```

#### États Spéciaux (3)
```html
<!-- Loading avec spinner -->
<button class="btn btn-primary btn-loading">
  Chargement...
</button>

<!-- Success -->
<button class="btn btn-success">Validé</button>

<!-- Error -->
<button class="btn btn-error">Erreur</button>
```

---

### 🎚️ Toggle/Switch (3 nouveaux)

```html
<!-- Toggle normal -->
<input type="checkbox" class="toggle" />

<!-- Toggle petit -->
<input type="checkbox" class="toggle toggle-sm" />

<!-- Toggle grand -->
<input type="checkbox" class="toggle toggle-lg" />
```

**JSX/React :**
```tsx
<input 
  type="checkbox" 
  className="toggle" 
  checked={isActive}
  onChange={(e) => setIsActive(e.target.checked)}
/>
```

---

### 📊 Progress Bars (3 nouveaux)

```html
<!-- Progress basique -->
<div class="progress">
  <div style="width: 60%"></div>
</div>

<!-- Progress avec couleur primaire -->
<div class="progress progress-primary">
  <div style="width: 75%"></div>
</div>

<!-- Progress succès (vert) -->
<div class="progress progress-success">
  <div style="width: 100%"></div>
</div>
```

**Avec React :**
```tsx
const [progress, setProgress] = useState(0);

<div className="progress progress-primary">
  <div 
    className="h-full bg-primary transition-all duration-300"
    style={{ width: `${progress}%` }}
  />
</div>
```

---

### 🏷️ Badge Variants (2 nouveaux)

```html
<!-- Badge avec outline -->
<span class="badge badge-outline">Outline</span>

<!-- Badge large -->
<span class="badge badge-primary badge-lg">Large Badge</span>
```

---

### 🎨 Utilitaires Couleur (5 nouveaux)

```html
<!-- Background primary-focus (hover state) -->
<div class="bg-primary-focus">Darker primary</div>

<!-- Text primary-content (texte sur fond primary) -->
<div class="bg-primary text-primary-content">
  Contraste optimal
</div>

<!-- Border variants -->
<div class="border-2 border-secondary">Bordure secondary</div>
<div class="border-2 border-accent">Bordure accent</div>
```

---

### ✨ Animations (6 nouvelles)

```html
<!-- Fade in (apparition douce) -->
<div class="animate-fade-in">
  Contenu qui apparaît
</div>

<!-- Slide in (depuis gauche) -->
<div class="animate-slide-in">
  Glisse depuis la gauche
</div>

<!-- Slide in right (depuis droite) -->
<div class="animate-slide-in-right">
  Glisse depuis la droite
</div>

<!-- Shimmer (effet brillance) -->
<div class="relative overflow-hidden">
  <div class="animate-shimmer absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-50"></div>
  Loading...
</div>

<!-- Spin (rotation) -->
<div class="animate-spin">⚙️</div>

<!-- Pulse glow (pulsation lumineuse) -->
<div class="animate-pulse-glow">
  Effet lumineux pulsant
</div>
```

---

### 💫 Box Shadows (4 nouvelles)

```html
<!-- Shadow neon (petite) -->
<button class="btn bg-primary text-primary-content shadow-neon">
  Neon Small
</button>

<!-- Shadow neon large -->
<button class="btn bg-accent text-accent-content shadow-neon-lg">
  Neon Large
</button>

<!-- Shadow neon extra large -->
<button class="btn bg-secondary text-secondary-content shadow-neon-xl">
  Neon XL
</button>

<!-- Inner shadow large -->
<div class="shadow-inner-lg p-4">
  Ombre intérieure
</div>
```

---

## 🎯 EXEMPLES D'UTILISATION

### Exemple 1 : CTA avec Gradient

```tsx
<button className="btn btn-gradient btn-lg animate-fade-in">
  Démarrer gratuitement
</button>

// Résultat :
// - Taille large
// - Gradient Primary → Accent
// - Animation fade-in au montage
// - S'adapte au thème actuel ✅
```

### Exemple 2 : Bouton de Chargement

```tsx
const [loading, setLoading] = useState(false);

<button 
  className={`btn btn-primary ${loading ? 'btn-loading' : ''}`}
  onClick={() => setLoading(true)}
>
  {loading ? 'Envoi en cours...' : 'Envoyer'}
</button>

// Résultat :
// - Spinner automatique quand loading
// - Bouton désactivé pendant loading
// - Transition smooth
```

### Exemple 3 : Toggle avec État

```tsx
const [enabled, setEnabled] = useState(false);

<div className="flex items-center gap-3">
  <input 
    type="checkbox"
    className="toggle"
    checked={enabled}
    onChange={(e) => setEnabled(e.target.checked)}
  />
  <span>{enabled ? 'Activé' : 'Désactivé'}</span>
</div>

// Résultat :
// - Switch animé avec couleur du thème
// - Transition smooth
// - Couleur primary quand activé
```

### Exemple 4 : Card avec Progress

```tsx
<div className="card card-bordered">
  <div className="card-body">
    <h3 className="card-title">Progression</h3>
    <div className="progress progress-success">
      <div style={{ width: '75%' }}></div>
    </div>
    <p>75% complété</p>
  </div>
</div>
```

### Exemple 5 : Modal avec Neon Button

```tsx
<div className="modal modal-open">
  <div className="modal-box animate-fade-in">
    <h3 className="text-lg font-bold mb-4">Confirmation</h3>
    <p className="mb-4">Êtes-vous sûr ?</p>
    <div className="flex gap-2 justify-end">
      <button className="btn btn-ghost">Annuler</button>
      <button className="btn btn-neon shadow-neon-lg">
        Confirmer
      </button>
    </div>
  </div>
</div>
```

---

## 🎨 COMBINAISONS PUISSANTES

### Stack d'Effets

```tsx
{/* Bouton ultra-stylé */}
<button className="
  btn 
  btn-gradient 
  btn-xl 
  shadow-neon-lg 
  animate-fade-in
  hover:scale-105
  transition-all
">
  Action Premium
</button>

// Combine :
// ✅ Gradient thème
// ✅ Taille XL
// ✅ Ombre néon
// ✅ Fade in
// ✅ Scale au hover
```

### Card Interactive

```tsx
<div className="
  card 
  card-bordered 
  hover:shadow-neon
  animate-slide-in
  transition-all
">
  <div className="card-body">
    <h3 className="card-title">
      Titre avec badge
      <span className="badge badge-primary badge-lg">NEW</span>
    </h3>
    <button className="btn btn-primary btn-sm">
      Action
    </button>
  </div>
</div>
```

---

## 📚 GUIDE DE CHOIX

### Quand utiliser chaque variant ?

#### Boutons
```
.btn-primary     → Action principale (1 par page)
.btn-secondary   → Actions secondaires
.btn-outline     → Actions tertiaires
.btn-ghost       → Navigation, actions discrètes
.btn-gradient    → CTA marketing, landing pages
.btn-neon        → Gaming, tech, effets spéciaux
.btn-glass       → Overlays, transparence, modernité
.btn-3d          → E-commerce, profondeur visuelle
```

#### Tailles
```
.btn-xs  → Toolbar, actions mineures
.btn-sm  → Formulaires compacts
(défaut) → Usage standard (80% des cas)
.btn-lg  → CTA, actions importantes
.btn-xl  → Hero sections, landing pages
```

#### États
```
.btn-loading  → Pendant requête async
.btn-success  → Après action réussie
.btn-error    → Après erreur
```

#### Toggle
```
.toggle       → Paramètres standard
.toggle-sm    → Listes denses, tableaux
.toggle-lg    → Paramètres importants, visuels
```

---

## 🎯 ACCESSIBILITÉ

### Tous les Composants Respectent WCAG

```tsx
// Les couleurs sont calculées pour contraste optimal
<button className="btn btn-primary">
  {/* Texte blanc sur fond bleu = contraste ✅ */}
</button>

// Vérifiez avant création de thème
const contrast = ThemeGenerator.checkContrast(
  ThemeGenerator.hexToRgb('#your-color'),
  [255, 255, 255]
);

if (!contrast.AA) {
  console.error('⚠️ Ajustez la couleur pour WCAG AA');
}
```

---

## 💡 TIPS & TRICKS

### 1. Combiner Classes Tailwind

```tsx
{/* Classes du système + classes Tailwind = ✅ */}
<button className="btn btn-primary btn-lg px-12 shadow-xl">
  Custom combo
</button>
```

### 2. Animations au Montage

```tsx
{/* Utile pour modals, tooltips, etc. */}
{isOpen && (
  <div className="modal modal-open">
    <div className="modal-box animate-fade-in">
      Contenu
    </div>
  </div>
)}
```

### 3. Progress Dynamique

```tsx
{/* Barre qui se remplit */}
const [progress, setProgress] = useState(0);

useEffect(() => {
  const timer = setInterval(() => {
    setProgress(p => Math.min(100, p + 10));
  }, 500);
  return () => clearInterval(timer);
}, []);

<div className="progress progress-success">
  <div className="transition-all duration-300" style={{ width: `${progress}%` }} />
</div>
```

---

## 🔗 LIENS UTILES

### Documentation
- `README.md` - Guide complet
- `SYNTHESE_RAPIDE.md` - Vue d'ensemble
- `SCHEMA_ARCHITECTURE.md` - Diagrammes

### Code
- `theme-generator.ts` - Générateur
- `ThemeManager.ts` - Gestionnaire
- `tailwind-theme-system.ts` - Plugin
- `tailwind.config.ts` - Configuration

---

## ✅ CHECKLIST D'UTILISATION

Avant d'utiliser les nouveaux composants :

- [ ] Lire README.md (10 min)
- [ ] Tester un bouton avec variant (.btn-gradient)
- [ ] Tester une animation (.animate-fade-in)
- [ ] Tester un toggle (.toggle)
- [ ] Tester changement de thème (tout s'adapte ?)
- [ ] Valider accessibilité (checkContrast)
- [ ] Intégrer dans votre UI

---

**Créé le :** 17 Novembre 2025  
**Version :** 2.0.0  
**Statut :** ✅ Production Ready

