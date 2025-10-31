# 🎨 Personnalisation

Ce guide vous explique comment personnaliser et étendre LyxalKitUI pour répondre aux besoins spécifiques de votre projet.

## 🎯 Personnalisation des composants

### Surcharge des styles par défaut

Vous pouvez personnaliser l'apparence des composants en utilisant les classes CSS ou les props de style :

```tsx
import { Button } from '@lyxal/ui-kit';

// Avec des classes CSS personnalisées
<Button 
  className="bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600"
  variant="primary"
>
  Bouton dégradé
</Button>

// Avec des styles inline
<Button 
  style={{
    background: 'linear-gradient(45deg, #FE6B8B 30%, #FF8E53 90%)',
    borderRadius: '12px',
    boxShadow: '0 3px 5px 2px rgba(255, 105, 135, .3)'
  }}
>
  Bouton personnalisé
</Button>
```

### Création de variantes personnalisées

Étendez les composants existants avec de nouvelles variantes :

```tsx
import { Button, ButtonProps } from '@lyxal/ui-kit';
import { clsx } from 'clsx';

interface CustomButtonProps extends ButtonProps {
  variant?: 'primary' | 'secondary' | 'gradient' | 'neon';
}

function CustomButton({ variant = 'primary', className, ...props }: CustomButtonProps) {
  const customVariants = {
    gradient: 'bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white',
    neon: 'bg-black border-2 border-cyan-400 text-cyan-400 hover:bg-cyan-400 hover:text-black shadow-lg shadow-cyan-400/50'
  };

  const variantClass = customVariants[variant] || '';

  return (
    <Button
      {...props}
      variant={variant === 'gradient' || variant === 'neon' ? undefined : variant}
      className={clsx(variantClass, className)}
    />
  );
}

// Utilisation
<CustomButton variant="gradient">Bouton dégradé</CustomButton>
<CustomButton variant="neon">Bouton néon</CustomButton>
```

## 🎨 Variables CSS personnalisées

### Surcharge des variables de thème

Créez vos propres variables CSS pour personnaliser l'apparence globale :

```css
/* styles/custom-theme.css */
:root {
  /* Couleurs personnalisées */
  --primary-500: #6366f1;
  --primary-600: #4f46e5;
  --primary-700: #4338ca;
  
  /* Rayons personnalisés */
  --radius: 0.75rem;
  --radius-sm: 0.375rem;
  --radius-lg: 1rem;
  
  /* Ombres personnalisées */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  
  /* Animations personnalisées */
  --transition-fast: 150ms ease-in-out;
  --transition-normal: 250ms ease-in-out;
  --transition-slow: 350ms ease-in-out;
}

/* Mode sombre */
[data-theme="dark"] {
  --primary-500: #818cf8;
  --primary-600: #6366f1;
  --primary-700: #4f46e5;
}
```

### Utilisation dans vos composants

```tsx
function CustomCard({ children, className, ...props }) {
  return (
    <div 
      className={clsx(
        'p-6 rounded-[var(--radius-lg)] shadow-[var(--shadow-md)]',
        'bg-white dark:bg-gray-800',
        'border border-gray-200 dark:border-gray-700',
        'transition-[var(--transition-normal)]',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
```

## 🧩 Composants composés

### Créer des composants complexes

Combinez plusieurs composants LyxalKitUI pour créer des interfaces plus complexes :

```tsx
import { 
  Button, 
  Input, 
  Badge, 
  Modal, 
  Avatar,
  DropdownMenu 
} from '@lyxal/ui-kit';

interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
    avatar?: string;
    status: 'online' | 'offline' | 'away';
  };
  onEdit?: (user: any) => void;
  onDelete?: (userId: string) => void;
}

function UserCard({ user, onEdit, onDelete }: UserCardProps) {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const statusColors = {
    online: 'success',
    offline: 'secondary',
    away: 'warning'
  };

  return (
    <>
      <div className="bg-base-100 rounded-lg p-6 shadow-sm border border-base-300 hover:shadow-md transition-shadow">
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Avatar size="lg" src={user.avatar}>
                {user.name.charAt(0)}
              </Avatar>
              <div className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white bg-${statusColors[user.status]}`} />
            </div>
            
            <div>
              <h3 className="text-lg font-semibold">{user.name}</h3>
              <p className="text-sm text-base-content/70">{user.email}</p>
              <Badge variant="outline" size="sm" className="mt-1">
                {user.role}
              </Badge>
            </div>
          </div>

          <DropdownMenu
            trigger={
              <Button variant="ghost" size="sm">⋮</Button>
            }
            items={[
              { 
                label: 'Voir le profil', 
                onClick: () => setIsModalOpen(true) 
              },
              { 
                label: 'Modifier', 
                onClick: () => onEdit?.(user) 
              },
              { type: 'separator' },
              { 
                label: 'Supprimer', 
                onClick: () => onDelete?.(user.id),
                variant: 'destructive'
              }
            ]}
          />
        </div>

        <div className="mt-4 flex items-center justify-between">
          <Badge variant={statusColors[user.status]} size="sm">
            {user.status === 'online' ? 'En ligne' : 
             user.status === 'away' ? 'Absent' : 'Hors ligne'}
          </Badge>
          
          <Button 
            variant="outline" 
            size="sm"
            onClick={() => setIsModalOpen(true)}
          >
            Voir le profil
          </Button>
        </div>
      </div>

      {/* Modal de profil */}
      <Modal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={`Profil de ${user.name}`}
        size="md"
      >
        <div className="space-y-6">
          <div className="text-center">
            <Avatar size="xl" src={user.avatar} className="mx-auto mb-4">
              {user.name.charAt(0)}
            </Avatar>
            <h2 className="text-xl font-bold">{user.name}</h2>
            <p className="text-base-content/70">{user.email}</p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Rôle</label>
              <Badge variant="primary">{user.role}</Badge>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Statut</label>
              <Badge variant={statusColors[user.status]}>
                {user.status === 'online' ? 'En ligne' : 
                 user.status === 'away' ? 'Absent' : 'Hors ligne'}
              </Badge>
            </div>
          </div>

          <div className="flex gap-2">
            <Button variant="outline" onClick={() => setIsModalOpen(false)}>
              Fermer
            </Button>
            <Button variant="primary" onClick={() => onEdit?.(user)}>
              Modifier
            </Button>
          </div>
        </div>
      </Modal>
    </>
  );
}
```

## 🎭 Hooks personnalisés

### Hook de gestion d'état local

```tsx
import { useState, useCallback } from 'react';
import { useToast } from '@lyxal/ui-kit';

function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error('Error saving to localStorage:', error);
    }
  }, [key, storedValue]);

  return [storedValue, setValue] as const;
}

// Hook de gestion de formulaire
function useForm<T extends Record<string, any>>(
  initialValues: T,
  validationRules?: Partial<Record<keyof T, (value: any) => string | null>>
) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});
  const { showToast } = useToast();

  const setValue = useCallback((field: keyof T, value: any) => {
    setValues(prev => ({ ...prev, [field]: value }));
    
    // Validation en temps réel
    if (validationRules?.[field] && touched[field]) {
      const error = validationRules[field](value);
      setErrors(prev => ({ ...prev, [field]: error }));
    }
  }, [validationRules, touched]);

  const setTouched = useCallback((field: keyof T) => {
    setTouched(prev => ({ ...prev, [field]: true }));
  }, []);

  const validate = useCallback(() => {
    if (!validationRules) return true;

    const newErrors: Partial<Record<keyof T, string>> = {};
    let isValid = true;

    Object.keys(validationRules).forEach(field => {
      const error = validationRules[field as keyof T]?.(values[field as keyof T]);
      if (error) {
        newErrors[field as keyof T] = error;
        isValid = false;
      }
    });

    setErrors(newErrors);
    return isValid;
  }, [values, validationRules]);

  const reset = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
  }, [initialValues]);

  return {
    values,
    errors,
    touched,
    setValue,
    setTouched,
    validate,
    reset,
    isValid: Object.keys(errors).length === 0
  };
}

// Utilisation
function ContactForm() {
  const { values, errors, setValue, validate, reset } = useForm(
    { name: '', email: '', message: '' },
    {
      name: (value) => !value ? 'Le nom est requis' : null,
      email: (value) => {
        if (!value) return 'L\'email est requis';
        if (!/\S+@\S+\.\S+/.test(value)) return 'Email invalide';
        return null;
      },
      message: (value) => !value ? 'Le message est requis' : null
    }
  );

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      // Envoyer le formulaire
      console.log('Form submitted:', values);
      reset();
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Input
        label="Nom"
        value={values.name}
        onChange={(e) => setValue('name', e.target.value)}
        error={errors.name}
        required
      />
      
      <Input
        label="Email"
        type="email"
        value={values.email}
        onChange={(e) => setValue('email', e.target.value)}
        error={errors.email}
        required
      />
      
      <Textarea
        label="Message"
        value={values.message}
        onChange={(e) => setValue('message', e.target.value)}
        error={errors.message}
        required
      />
      
      <Button type="submit" variant="primary">
        Envoyer
      </Button>
    </form>
  );
}
```

## 🎨 Système de design personnalisé

### Tokens de design

Créez un système de tokens cohérent :

```tsx
// design-tokens.ts
export const designTokens = {
  colors: {
    brand: {
      primary: '#6366f1',
      secondary: '#8b5cf6',
      accent: '#06b6d4'
    },
    semantic: {
      success: '#10b981',
      warning: '#f59e0b',
      error: '#ef4444',
      info: '#3b82f6'
    },
    neutral: {
      50: '#f9fafb',
      100: '#f3f4f6',
      200: '#e5e7eb',
      300: '#d1d5db',
      400: '#9ca3af',
      500: '#6b7280',
      600: '#4b5563',
      700: '#374151',
      800: '#1f2937',
      900: '#111827'
    }
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
    '2xl': '3rem',
    '3xl': '4rem'
  },
  typography: {
    fontFamily: {
      sans: ['Inter', 'system-ui', 'sans-serif'],
      mono: ['JetBrains Mono', 'monospace']
    },
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem'
    },
    fontWeight: {
      normal: '400',
      medium: '500',
      semibold: '600',
      bold: '700'
    }
  },
  borderRadius: {
    none: '0',
    sm: '0.125rem',
    base: '0.25rem',
    md: '0.375rem',
    lg: '0.5rem',
    xl: '0.75rem',
    full: '9999px'
  },
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
  }
};

// Générateur de classes utilitaires
export function createUtilityClasses(tokens: typeof designTokens) {
  const classes = {};
  
  // Générer les classes de couleur
  Object.entries(tokens.colors.brand).forEach(([name, value]) => {
    classes[`text-${name}`] = { color: value };
    classes[`bg-${name}`] = { backgroundColor: value };
    classes[`border-${name}`] = { borderColor: value };
  });
  
  // Générer les classes d'espacement
  Object.entries(tokens.spacing).forEach(([name, value]) => {
    classes[`p-${name}`] = { padding: value };
    classes[`m-${name}`] = { margin: value };
    classes[`gap-${name}`] = { gap: value };
  });
  
  return classes;
}
```

### Composant de thème provider

```tsx
import React, { createContext, useContext, useState } from 'react';
import { designTokens } from './design-tokens';

interface ThemeContextType {
  tokens: typeof designTokens;
  currentTheme: string;
  setTheme: (theme: string) => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [currentTheme, setCurrentTheme] = useState('default');

  const value = {
    tokens: designTokens,
    currentTheme,
    setTheme: setCurrentTheme
  };

  return (
    <ThemeContext.Provider value={value}>
      <div data-theme={currentTheme} className="min-h-screen">
        {children}
      </div>
    </ThemeContext.Provider>
  );
}

export function useDesignTokens() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useDesignTokens must be used within a ThemeProvider');
  }
  return context;
}

// Utilisation
function App() {
  return (
    <ThemeProvider>
      <YourApp />
    </ThemeProvider>
  );
}
```

## 🔧 Configuration avancée

### Configuration Tailwind personnalisée

```js
// tailwind.config.js
const { designTokens } = require('./src/design-tokens');

module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
    './node_modules/@lyxal/ui-kit/dist/**/*.{js,ts,jsx,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        ...designTokens.colors.brand,
        ...designTokens.colors.semantic,
        neutral: designTokens.colors.neutral
      },
      spacing: designTokens.spacing,
      fontFamily: designTokens.typography.fontFamily,
      fontSize: designTokens.typography.fontSize,
      fontWeight: designTokens.typography.fontWeight,
      borderRadius: designTokens.borderRadius,
      boxShadow: designTokens.shadows,
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-in': 'bounceIn 0.6s ease-out'
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' }
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' }
        },
        bounceIn: {
          '0%': { transform: 'scale(0.3)', opacity: '0' },
          '50%': { transform: 'scale(1.05)' },
          '70%': { transform: 'scale(0.9)' },
          '100%': { transform: 'scale(1)', opacity: '1' }
        }
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    // Plugin personnalisé pour les utilitaires
    function({ addUtilities }) {
      addUtilities({
        '.glass': {
          background: 'rgba(255, 255, 255, 0.1)',
          backdropFilter: 'blur(10px)',
          border: '1px solid rgba(255, 255, 255, 0.2)'
        },
        '.gradient-text': {
          background: 'linear-gradient(45deg, #6366f1, #8b5cf6)',
          backgroundClip: 'text',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent'
        }
      });
    }
  ]
};
```

---

**Avec ces techniques de personnalisation, vous pouvez adapter LyxalKitUI à n'importe quel design system ou besoin spécifique !** 