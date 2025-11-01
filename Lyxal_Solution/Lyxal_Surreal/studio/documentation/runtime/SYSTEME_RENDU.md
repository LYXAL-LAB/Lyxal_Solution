# 🔧 Système de Rendu Contrôlé pour Composants DB

Guide complet pour comprendre et implémenter un système de rendu personnalisé qui transforme les définitions DB en composants React réels.

---

## 🤔 Pourquoi un Système de Rendu Contrôlé ?

### Problème avec le Parsing HTML Direct

Si vous stockez du **HTML brut** dans la DB et utilisez `dangerouslySetInnerHTML` ou `html-react-parser`, vous avez plusieurs problèmes :

#### ❌ Problèmes du HTML Brut

1. **Sécurité** : Risque XSS (Cross-Site Scripting)
2. **Pas de contrôle** : Difficile de gérer les événements (onClick, onChange)
3. **Pas de props React** : Impossible de passer des fonctions ou des objets
4. **Difficile à déboguer** : Erreurs obscures dans le HTML généré
5. **Pas de validation** : Rien ne vérifie que le HTML est valide
6. **Performance** : Parsing HTML est plus lent que React natif

#### ✅ Avantages d'un Système Contrôlé

1. **Sécurité** : Validation stricte, pas de code malveillant
2. **Composants React natifs** : Vraie intégration React
3. **Props typées** : Validation TypeScript possible
4. **Événements** : Gestion propre des onClick, onChange, etc.
5. **Débogage facile** : Erreurs claires, stack traces React
6. **Performance** : Rendu React optimisé
7. **Réutilisabilité** : Composants réutilisables entre composants DB

---

## 🎯 Deux Approches Comparées

### Approche 1 : HTML Brut (Simple mais Limité)

```surql
-- Stockage HTML brut dans la DB
CREATE studio_component:button SET
  html_structure = '<button class="btn btn-primary" onclick="handleClick()">{{props.label}}</button>';
```

**Problème** : 
- `onclick="handleClick()"` ne fonctionne pas en React
- Pas de gestion d'état
- Pas de validation

### Approche 2 : Structure de Données (Contrôlé)

```surql
-- Stockage structure JSON dans la DB
CREATE studio_component:button SET
  structure = {
    type: "button",
    props: {
      className: ["btn", "btn-primary"],
      onClick: { type: "function", handler: "handleClick" }
    },
    children: [
      { type: "text", content: "{{props.label}}" }
    ]
  };
```

**Avantage** :
- Transformation en composant React natif
- Validation stricte
- Sécurité garantie

---

## 📐 Architecture du Système Contrôlé

### Étape 1 : Structure de Données dans la DB

Au lieu de stocker du HTML, stockez une **structure JSON** qui décrit le composant :

```surql
DEFINE TABLE studio_component SCHEMAFULL;

DEFINE FIELD structure ON studio_component
  TYPE object
  COMMENT 'Structure JSON du composant (au lieu de HTML brut)';
```

### Étape 2 : Parser la Structure

Transformer la structure DB en **arbre de composants React**.

### Étape 3 : Rendu React

Rendre les composants React natifs avec validation et sécurité.

---

## 💻 Implémentation Complète

### 1. Structure de Données dans SurrealDB

```surql
-- Composant Button avec structure contrôlée
CREATE studio_component:button SET
  code = "button",
  name = { fr: "Bouton", en: "Button" },
  
  -- Structure JSON au lieu de HTML brut
  structure = {
    -- Type de l'élément racine
    type: "button",
    
    -- Props (attributs du composant)
    props: {
      className: {
        type: "array",
        value: ["btn", "btn-base", "{{props.variant}}"],
        default: ["btn", "btn-base", "btn-primary"]
      },
      onClick: {
        type: "function",
        handler: "{{props.onClick}}",
        required: false
      },
      disabled: {
        type: "boolean",
        value: "{{props.disabled}}",
        default: false
      }
    },
    
    -- Styles inline (optionnel)
    styles: {
      padding: "0.5rem 1rem",
      borderRadius: "0.375rem",
      transition: "all 0.2s"
    },
    
    -- Children (contenu du composant)
    children: [
      {
        type: "icon",
        props: {
          name: "{{props.icon}}",
          size: 16,
          className: ["mr-2"]
        },
        condition: "{{props.icon}}"
      },
      {
        type: "text",
        content: "{{props.label}}",
        className: ["font-medium"]
      }
    ],
    
    -- Variants (styles différents selon props)
    variants: {
      primary: {
        className: ["bg-blue-500", "text-white", "hover:bg-blue-600"],
        styles: { backgroundColor: "var(--color-primary)" }
      },
      secondary: {
        className: ["bg-gray-500", "text-white", "hover:bg-gray-600"],
        styles: { backgroundColor: "var(--color-secondary)" }
      }
    }
  },
  
  -- Props acceptées par ce composant
  props_schema = [
    {
      name: "label",
      type: "string",
      required: true,
      description: "Texte du bouton"
    },
    {
      name: "variant",
      type: "string",
      default: "primary",
      options: ["primary", "secondary", "danger", "ghost"]
    },
    {
      name: "icon",
      type: "string",
      required: false,
      description: "Nom de l'icône Lucide"
    },
    {
      name: "onClick",
      type: "function",
      required: false
    },
    {
      name: "disabled",
      type: "boolean",
      default: false
    }
  ],
  
  active = true;
```

### 2. Parser : Transformer Structure DB → Composant React

```typescript
// lib/studio/ComponentParser.ts

interface ComponentStructure {
  type: string;
  props?: Record<string, any>;
  styles?: Record<string, string>;
  children?: Array<any>;
  variants?: Record<string, any>;
}

interface ParsedComponent {
  component: React.ComponentType<any>;
  props: Record<string, any>;
  children?: React.ReactNode;
}

export class ComponentParser {
  /**
   * Parse une structure DB en composant React
   */
  static parse(
    structure: ComponentStructure,
    componentProps: Record<string, any>,
    variant?: string
  ): ParsedComponent {
    const elementType = this.getElementType(structure.type);
    
    // Appliquer le variant si spécifié
    const variantStyles = variant && structure.variants?.[variant] 
      ? structure.variants[variant] 
      : {};
    
    // Fusionner les props
    const mergedProps = this.mergeProps(
      structure.props || {},
      componentProps,
      variantStyles
    );
    
    // Parser les children
    const children = structure.children
      ? this.parseChildren(structure.children, componentProps)
      : undefined;
    
    return {
      component: elementType,
      props: mergedProps,
      children,
    };
  }
  
  /**
   * Convertir le type DB en composant React
   */
  private static getElementType(type: string): React.ComponentType<any> {
    // Types HTML natifs
    const htmlElements: Record<string, any> = {
      button: 'button',
      div: 'div',
      span: 'span',
      input: 'input',
      textarea: 'textarea',
      select: 'select',
      label: 'label',
      form: 'form',
      table: 'table',
      thead: 'thead',
      tbody: 'tbody',
      tr: 'tr',
      td: 'td',
      th: 'th',
    };
    
    // Types spéciaux (composants React)
    const specialElements: Record<string, any> = {
      icon: IconComponent,  // Composant React pour icônes
      text: TextComponent,   // Composant React pour texte
      slot: SlotComponent,   // Composant pour slots
    };
    
    // Retourner le composant approprié
    if (htmlElements[type]) {
      return htmlElements[type] as any;
    }
    
    if (specialElements[type]) {
      return specialElements[type];
    }
    
    // Par défaut, div
    return 'div' as any;
  }
  
  /**
   * Fusionner les props de la structure avec les props du composant
   */
  private static mergeProps(
    structureProps: Record<string, any>,
    componentProps: Record<string, any>,
    variantStyles?: any
  ): Record<string, any> {
    const merged: Record<string, any> = {};
    
    // Traiter chaque prop de la structure
    Object.entries(structureProps).forEach(([key, propDef]) => {
      if (typeof propDef === 'object' && propDef.type) {
        // Prop avec définition (ex: {type: "array", value: [...]})
        merged[key] = this.resolvePropValue(propDef, componentProps);
      } else if (typeof propDef === 'string' && propDef.startsWith('{{')) {
        // Template string (ex: "{{props.label}}")
        merged[key] = this.resolveTemplate(propDef, componentProps);
      } else {
        // Valeur directe
        merged[key] = propDef;
      }
    });
    
    // Appliquer les styles du variant
    if (variantStyles?.styles) {
      merged.style = { ...merged.style, ...variantStyles.styles };
    }
    
    if (variantStyles?.className) {
      merged.className = this.mergeClassNames(
        merged.className,
        variantStyles.className
      );
    }
    
    return merged;
  }
  
  /**
   * Résoudre une valeur de prop (template string, function, etc.)
   */
  private static resolvePropValue(
    propDef: any,
    componentProps: Record<string, any>
  ): any {
    switch (propDef.type) {
      case 'array':
        // Array avec templates
        return (propDef.value || []).map((item: any) => {
          if (typeof item === 'string' && item.startsWith('{{')) {
            return this.resolveTemplate(item, componentProps);
          }
          return item;
        });
        
      case 'function':
        // Fonction - récupérer depuis componentProps
        const handlerName = this.resolveTemplate(
          propDef.handler || '',
          componentProps
        );
        return componentProps[handlerName] || propDef.default || undefined;
        
      case 'boolean':
        return this.resolveTemplate(propDef.value, componentProps) ?? propDef.default ?? false;
        
      default:
        return this.resolveTemplate(propDef.value, componentProps) ?? propDef.default;
    }
  }
  
  /**
   * Résoudre un template string (ex: "{{props.label}}" → valeur réelle)
   */
  private static resolveTemplate(
    template: string,
    componentProps: Record<string, any>
  ): any {
    if (!template || typeof template !== 'string') {
      return template;
    }
    
    // Remplacer {{props.xxx}} par la valeur réelle
    return template.replace(/\{\{props\.(\w+)\}\}/g, (match, propName) => {
      return componentProps[propName] ?? match;
    });
  }
  
  /**
   * Parser les children (éléments enfants)
   */
  private static parseChildren(
    children: Array<any>,
    componentProps: Record<string, any>
  ): React.ReactNode {
    return children
      .filter((child) => {
        // Filtrer selon les conditions
        if (child.condition) {
          const conditionValue = this.resolveTemplate(
            child.condition,
            componentProps
          );
          return conditionValue === true || conditionValue === 'true';
        }
        return true;
      })
      .map((child, index) => {
        switch (child.type) {
          case 'text':
            // Texte simple
            const content = this.resolveTemplate(
              child.content || '',
              componentProps
            );
            return (
              <span key={index} className={child.className?.join(' ')}>
                {content}
              </span>
            );
            
          case 'icon':
            // Icône Lucide
            const iconName = this.resolveTemplate(
              child.props?.name || '',
              componentProps
            );
            const IconComponent = Icons[iconName as keyof typeof Icons];
            
            if (!IconComponent) {
              console.warn(`Icon ${iconName} not found`);
              return null;
            }
            
            return (
              <IconComponent
                key={index}
                size={child.props?.size || 16}
                className={child.props?.className?.join(' ')}
              />
            );
            
          case 'slot':
            // Slot (contenu externe)
            return componentProps[`slot_${child.name}`] || null;
            
          default:
            // Récurrence pour éléments imbriqués
            const parsed = this.parse(
              child,
              componentProps,
              componentProps.variant
            );
            return React.createElement(
              parsed.component,
              { ...parsed.props, key: index },
              parsed.children
            );
        }
      });
  }
  
  /**
   * Fusionner les classNames
   */
  private static mergeClassNames(...classNames: (string | string[] | undefined)[]): string {
    const all: string[] = [];
    
    classNames.forEach((cn) => {
      if (Array.isArray(cn)) {
        all.push(...cn);
      } else if (typeof cn === 'string') {
        all.push(cn);
      }
    });
    
    // Résoudre les templates dans les classNames
    return all
      .map((c) => {
        // Résoudre {{props.variant}} → btn-primary
        return c.replace(/\{\{props\.(\w+)\}\}/g, (match, propName) => {
          // Ne pas résoudre ici, on le fera dans le composant final
          return match;
        });
      })
      .filter(Boolean)
      .join(' ');
  }
}
```

### 3. Composant Renderer React

```typescript
// components/studio/StudioComponentRenderer.tsx

import React, { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';
import { ComponentParser } from '@/lib/studio/ComponentParser';
import * as Icons from 'lucide-react';

interface StudioComponentRendererProps {
  code: string;
  props?: Record<string, any>;
  children?: React.ReactNode;
  slots?: Record<string, React.ReactNode>;
}

export const StudioComponentRenderer: React.FC<StudioComponentRendererProps> = ({
  code,
  props = {},
  children,
  slots = {},
}) => {
  const [component, setComponent] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadComponent = async () => {
      try {
        setLoading(true);
        
        const result = await db.query(`
          SELECT * FROM studio_component 
          WHERE code = '${code}' AND active = true
        `);
        
        if (result?.[0]) {
          setComponent(result[0]);
        } else {
          setError(`Component ${code} not found`);
        }
      } catch (err: any) {
        setError(err.message || 'Failed to load component');
      } finally {
        setLoading(false);
      }
    };

    loadComponent();
  }, [code]);

  if (loading) {
    return <div className="animate-pulse">Loading...</div>;
  }

  if (error || !component) {
    return <div className="text-red-500">Error: {error || 'Component not found'}</div>;
  }

  // Parser la structure en composant React
  const parsed = ComponentParser.parse(
    component.structure,
    {
      ...props,
      ...slots, // Inclure les slots comme props
    },
    props.variant // Variant à appliquer
  );

  // Rendre le composant
  return React.createElement(
    parsed.component,
    {
      ...parsed.props,
      // Gérer les événements
      onClick: parsed.props.onClick || props.onClick,
      onChange: parsed.props.onChange || props.onChange,
    },
    children || parsed.children
  );
};

// Composants spéciaux
const IconComponent: React.FC<{ name: string; size?: number; className?: string }> = ({
  name,
  size = 16,
  className,
}) => {
  const Icon = Icons[name as keyof typeof Icons];
  if (!Icon) return null;
  return <Icon size={size} className={className} />;
};

const TextComponent: React.FC<{ content: string; className?: string }> = ({
  content,
  className,
}) => {
  return <span className={className}>{content}</span>;
};

const SlotComponent: React.FC<{ name: string; children?: React.ReactNode }> = ({
  name,
  children,
}) => {
  return <>{children}</>;
};
```

---

## 🎨 Exemple d'Utilisation : 100% DB-Driven

### ❌ Problème : Code en Dur (Pas DB-Driven)

```typescript
// ❌ MAUVAIS : Code React en dur
export const ContactPage: React.FC = () => {
  return (
    <div>
      <StudioComponentRenderer code="button" props={{...}} />
      <StudioComponentRenderer code="input" props={{...}} />
    </div>
  );
};
```

**Problème** : Vous devez écrire du code React pour chaque page. Ce n'est **pas 100% DB-driven** !

---

### ✅ Solution : Définir la Page Entière dans la DB

#### 1. Étendre `studio_page` avec `content_structure`

```surql
-- Ajouter un champ pour définir la structure complète de la page
DEFINE FIELD content_structure ON studio_page
  TYPE object
  COMMENT 'Structure complète de la page avec composants et leurs props';

-- Exemple : Page Contact avec tous ses composants définis en DB
CREATE studio_page:contact_list SET
  code = "contact_list",
  title = { fr: "Liste des Contacts", en: "Contact List" },
  url = "/contacts",
  layout = "flex",
  
  -- ✅ Structure complète de la page en DB (100% DB-driven)
  content_structure = {
    type: "div",
    props: {
      className: ["container", "mx-auto", "p-6"]
    },
    children: [
      {
        -- Header de la page
        type: "div",
        props: { className: ["mb-6", "flex", "justify-between", "items-center"] },
        children: [
          {
            type: "h1",
            props: { className: ["text-3xl", "font-bold"] },
            children: [{ type: "text", content: "{{page.title.fr}}" }]
          },
          {
            -- Bouton "Créer" défini en DB
            type: "component",
            component: "button",
            props: {
              label: { fr: "Créer un Contact", en: "Create Contact" },
              icon: "Plus",
              variant: "primary",
              onClick: {
                type: "action",
                action: "navigate",
                params: { url: "/contacts/new" }
              }
            }
          }
        ]
      },
      {
        -- Formulaire de recherche
        type: "component",
        component: "card",
        props: {
          title: { fr: "Recherche", en: "Search" }
        },
        slots: {
          body: {
            type: "form",
            props: {
              onSubmit: {
                type: "action",
                action: "search",
                params: { table: "contact" }
              }
            },
            children: [
              {
                type: "component",
                component: "input",
                props: {
                  name: "search",
                  label: { fr: "Rechercher", en: "Search" },
                  placeholder: { fr: "Nom, email...", en: "Name, email..." },
                  icon: "Search"
                }
              },
              {
                type: "component",
                component: "button",
                props: {
                  label: { fr: "Rechercher", en: "Search" },
                  variant: "primary",
                  type: "submit"
                }
              }
            ]
          }
        }
      },
      {
        -- Tableau des contacts
        type: "component",
        component: "table",
        props: {
          title: { fr: "Contacts", en: "Contacts" },
          query: "SELECT * FROM contact ORDER BY created_at DESC LIMIT 50",
          columns: [
            { field: "first_name", label: { fr: "Prénom", en: "First Name" } },
            { field: "last_name", label: { fr: "Nom", en: "Last Name" } },
            { field: "email", label: { fr: "Email", en: "Email" } },
            { field: "company.name", label: { fr: "Entreprise", en: "Company" } },
            {
              field: "actions",
              label: { fr: "Actions", en: "Actions" },
              type: "component",
              component: "button_group",
              props: {
                buttons: [
                  {
                    component: "button",
                    props: {
                      label: { fr: "Voir", en: "View" },
                      icon: "Eye",
                      variant: "ghost",
                      size: "sm",
                      onClick: {
                        type: "action",
                        action: "navigate",
                        params: { url: "/contacts/{{row.id}}" }
                      }
                    }
                  },
                  {
                    component: "button",
                    props: {
                      label: { fr: "Modifier", en: "Edit" },
                      icon: "Edit",
                      variant: "ghost",
                      size: "sm",
                      onClick: {
                        type: "action",
                        action: "navigate",
                        params: { url: "/contacts/{{row.id}}/edit" }
                      }
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    ]
  },
  active = true;
```

#### 2. Renderer de Page 100% DB-Driven

```typescript
// components/studio/StudioPage.tsx
import React, { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';
import { StudioComponentRenderer } from './StudioComponentRenderer';
import { StructureRenderer } from './StructureRenderer';

interface StudioPageProps {
  pageCode: string;
  tenant: string;
}

export const StudioPage: React.FC<StudioPageProps> = ({ pageCode, tenant }) => {
  const [page, setPage] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadPage = async () => {
      try {
        const result = await db.query(`
          SELECT * FROM studio_page 
          WHERE code = '${pageCode}' AND active = true
        `);
        
        if (result?.[0]) {
          setPage(result[0]);
        }
      } catch (error) {
        console.error('Failed to load page:', error);
      } finally {
        setLoading(false);
      }
    };

    loadPage();
  }, [pageCode]);

  if (loading) return <div>Loading...</div>;
  if (!page) return <div>Page not found</div>;

  // ✅ Si la page a une structure complète, on la rend
  if (page.content_structure) {
    return <StructureRenderer structure={page.content_structure} page={page} />;
  }

  // Fallback : layout classique avec widgets
  return (
    <div className={`p-6 layout-${page.layout}`}>
      <h1>{page.title.fr}</h1>
      {page.widgets?.map((w: any) => (
        <StudioWidget key={w.code} widget={w} />
      ))}
    </div>
  );
};
```

#### 3. StructureRenderer : Rendre la Structure DB

```typescript
// components/studio/StructureRenderer.tsx
import React from 'react';
import { StudioComponentRenderer } from './StudioComponentRenderer';
import { ActionHandler } from './ActionHandler';

interface StructureRendererProps {
  structure: any;
  page?: any;
  context?: Record<string, any>;
}

export const StructureRenderer: React.FC<StructureRendererProps> = ({
  structure,
  page,
  context = {},
}) => {
  // Si c'est un composant DB
  if (structure.type === 'component') {
    // Résoudre les props avec le contexte
    const resolvedProps = resolveProps(structure.props, { page, ...context });
    
    // Résoudre les actions (onClick, onSubmit, etc.)
    const resolvedPropsWithActions = resolveActions(resolvedProps);
    
    return (
      <StudioComponentRenderer
        code={structure.component}
        props={resolvedPropsWithActions}
        slots={structure.slots ? renderSlots(structure.slots, { page, ...context }) : undefined}
      />
    );
  }

  // Si c'est un élément HTML natif
  if (['div', 'span', 'h1', 'h2', 'h3', 'p', 'form', 'table'].includes(structure.type)) {
    const Element = structure.type as any;
    const props = resolveProps(structure.props || {}, { page, ...context });
    
    return (
      <Element {...props}>
        {structure.children?.map((child: any, index: number) => (
          <StructureRenderer
            key={index}
            structure={child}
            page={page}
            context={context}
          />
        ))}
      </Element>
    );
  }

  // Si c'est du texte
  if (structure.type === 'text') {
    return <>{resolveTemplate(structure.content, { page, ...context })}</>;
  }

  return null;
};

// Helper : Résoudre les templates ({{page.title.fr}}, {{row.id}}, etc.)
function resolveTemplate(template: string, context: Record<string, any>): string {
  if (!template || typeof template !== 'string') return template;
  
  return template.replace(/\{\{([^}]+)\}\}/g, (match, path) => {
    const keys = path.split('.');
    let value: any = context;
    
    for (const key of keys) {
      value = value?.[key];
      if (value === undefined) break;
    }
    
    return value ?? match;
  });
}

// Helper : Résoudre les props avec templates
function resolveProps(props: any, context: Record<string, any>): any {
  if (!props) return {};
  
  const resolved: any = {};
  
  Object.entries(props).forEach(([key, value]) => {
    if (typeof value === 'string') {
      resolved[key] = resolveTemplate(value, context);
    } else if (typeof value === 'object' && value !== null) {
      if (Array.isArray(value)) {
        resolved[key] = value.map(v => resolveTemplate(v, context));
      } else if (value.type === 'action') {
        // Action spéciale (onClick, onSubmit, etc.)
        resolved[key] = value;
      } else if (value.fr || value.en) {
        // Multilingue
        resolved[key] = value;
      } else {
        resolved[key] = resolveProps(value, context);
      }
    } else {
      resolved[key] = value;
    }
  });
  
  return resolved;
}

// Helper : Résoudre les actions en fonctions React
function resolveActions(props: any): any {
  const resolved = { ...props };
  
  Object.entries(props).forEach(([key, value]: [string, any]) => {
    if (value && typeof value === 'object' && value.type === 'action') {
      // Transformer l'action DB en fonction React
      resolved[key] = ActionHandler.createHandler(value);
    }
  });
  
  return resolved;
}

// Helper : Rendre les slots
function renderSlots(slots: any, context: Record<string, any>): Record<string, React.ReactNode> {
  const rendered: Record<string, React.ReactNode> = {};
  
  Object.entries(slots).forEach(([slotName, slotStructure]: [string, any]) => {
    rendered[slotName] = (
      <StructureRenderer
        structure={slotStructure}
        context={context}
      />
    );
  });
  
  return rendered;
}
```

#### 4. ActionHandler : Gérer les Actions Depuis la DB

```typescript
// components/studio/ActionHandler.ts
import { useNavigate } from 'react-router-dom';
import { db } from '@/lib/surrealdb';

export class ActionHandler {
  static createHandler(action: any): (...args: any[]) => void {
    return (...args: any[]) => {
      switch (action.action) {
        case 'navigate':
          // Navigation
          const navigate = useNavigate(); // ⚠️ Utiliser un hook dans un composant
          const url = resolveTemplate(action.params.url, args[0] || {});
          navigate(url);
          break;
          
        case 'search':
          // Recherche
          // Exécuter une query SurrealDB
          break;
          
        case 'submit':
          // Soumission de formulaire
          // Insérer/Mettre à jour dans DB
          break;
          
        case 'delete':
          // Suppression
          // DELETE dans DB
          break;
          
        default:
          console.warn(`Unknown action: ${action.action}`);
      }
    };
  }
}

// Version avec hooks React (meilleure)
export const useActionHandler = () => {
  const navigate = useNavigate();
  
  const handleAction = async (action: any, params?: any) => {
    switch (action.action) {
      case 'navigate':
        const url = resolveTemplate(action.params.url, params || {});
        navigate(url);
        break;
        
      case 'search':
        // Implémenter recherche
        break;
        
      case 'submit':
        // Implémenter soumission
        await db.query(`INSERT INTO ${action.params.table} ${action.params.data}`);
        break;
        
      default:
        console.warn(`Unknown action: ${action.action}`);
    }
  };
  
  return { handleAction };
};
```

---

## ✅ Résultat : 100% DB-Driven

### Dans votre App React

```typescript
// App.tsx - Zéro code en dur pour les pages !
import { Routes, Route } from 'react-router-dom';
import { StudioPage } from '@/components/studio/StudioPage';

export const App: React.FC = () => {
  return (
    <Routes>
      {/* ✅ Route dynamique : La page est entièrement définie dans la DB */}
      <Route path="/contacts" element={<StudioPage pageCode="contact_list" tenant="lyxal" />} />
      <Route path="/crm/dashboard" element={<StudioPage pageCode="crm_dashboard" tenant="lyxal" />} />
      {/* ... toutes les pages viennent de la DB */}
    </Routes>
  );
};
```

**Résultat** :
- ✅ **Zéro code React** pour le contenu des pages
- ✅ **Tout est dans la DB** : structure, composants, props, actions
- ✅ **Modification instantanée** : UPDATE DB → Page mise à jour
- ✅ **White-Label total** : Chaque tenant peut avoir ses propres pages

---

## 📊 Comparaison : Avant vs Après

### ❌ Avant (Code en Dur)

```typescript
// ContactPage.tsx - Code React en dur
export const ContactPage = () => {
  return (
    <div>
      <Button label="Créer" onClick={handleCreate} />
      <Input name="search" />
      <Table columns={...} />
    </div>
  );
};
```

**Problèmes** :
- Modifier la page = modifier le code React
- Redéploiement nécessaire
- Pas de White-Label facile

### ✅ Après (100% DB-Driven)

```surql
-- contact_list.surql - Tout dans la DB
CREATE studio_page:contact_list SET
  content_structure = {
    type: "div",
    children: [
      { type: "component", component: "button", props: {...} },
      { type: "component", component: "input", props: {...} },
      { type: "component", component: "table", props: {...} }
  ];
```

```typescript
// App.tsx - Route générique
<Route path="/contacts" element={<StudioPage pageCode="contact_list" />} />
```

**Avantages** :
- Modifier la page = UPDATE DB
- Pas de redéploiement
- White-Label instantané

---

## 💡 Principe Fondamental : Tout est un Template JSON en DB

### 🎯 Règle d'Or : 100% DB-Driven = Aucun Code en Dur

Pour avoir un système **vraiment 100% DB-driven** sans aucun code en dur, **TOUT** doit être défini dans la base de données comme des **templates JSON**.

### 📋 Ce qui Doit Être en DB

#### 1. **Pages** → `studio_page.content_structure`
- Structure complète de la page (divs, sections, composants)
- Layout, ordre d'affichage, imbrication
- Tout est défini en JSON dans la DB

#### 2. **Sections** → Parties de la structure
- Header, Body, Footer, Sidebar
- Définies dans `content_structure.children[]`
- Chaque section = un objet JSON dans la DB

#### 3. **Composants** → `studio_component`
- Structure HTML/React de chaque composant (button, input, card, etc.)
- Props acceptées, variants, styles
- Définis dans `studio_component.structure`

#### 4. **Props des Composants** → Dans `content_structure`
- Toutes les valeurs passées aux composants
- Labels, placeholders, variants
- Définis dans `content_structure.children[].props`

#### 5. **Actions** → Définies en DB
- Navigation : `{type: "action", action: "navigate", params: {url: "/..."}}`
- Submit : `{type: "action", action: "submit", params: {table: "contact"}}`
- Delete, Search, etc.
- Toutes les actions = objets JSON en DB

### 🔄 Exemple Complet : Template JSON en DB

```surql
-- ✅ TOUT est dans la DB comme un template JSON
CREATE studio_page:contact_list SET
  content_structure = {
    -- Page = template JSON complet
    type: "div",
    props: {
      className: ["container", "mx-auto", "p-6"]
    },
    children: [
      -- Section Header (définie en DB)
      {
        type: "div",
        props: { className: ["header", "mb-6"] },
        children: [
          { type: "h1", props: { className: ["text-3xl"] }, children: [...] },
          { type: "component", component: "button", props: {...} }
        ]
      },
      
      -- Section Body (définie en DB)
      {
        type: "div",
        props: { className: ["body"] },
        children: [
          -- Composant button (référence à studio_component:button)
          {
            type: "component",
            component: "button",
            props: {
              label: { fr: "Créer", en: "Create" },
              variant: "primary",
              onClick: {
                type: "action",
                action: "navigate",
                params: { url: "/contacts/new" }
              }
            }
          },
          -- Autres composants...
        ]
      },
      
      -- Section Footer (définie en DB)
      {
        type: "div",
        props: { className: ["footer", "mt-6"] },
        children: [...]
      }
    ]
  };
```

### 🎨 Rôle de React : Interpréteur de Templates

React ne fait **que** :
1. ✅ Charger la structure depuis la DB
2. ✅ Parser le JSON template
3. ✅ Rendre récursivement les éléments

**React = Moteur de rendu, pas créateur de contenu**

### ❌ Ce qu'on NE Fait PAS (Code en Dur)

```typescript
// ❌ MAUVAIS : Code JSX en dur
export const ContactPage = () => {
  return (
    <div>
      <Button label="Créer" onClick={handleCreate} />
      <Input name="search" />
    </div>
  );
};

// ❌ MAUVAIS : Structure HTML en dur
<div className="header">...</div>

// ❌ MAUVAIS : Logique de layout en dur
const layout = page.layout === 'grid' ? 'grid-cols-3' : 'flex-col';
```

### ✅ Ce qu'on FAIT (100% DB)

```surql
-- ✅ BON : Tout dans la DB
CREATE studio_page:contact_list SET
  content_structure = {
    type: "div",
    children: [
      { type: "component", component: "button", props: {...} },
      { type: "component", component: "input", props: {...} }
    ]
  };
```

```typescript
// ✅ BON : React charge et rend seulement
<StudioPage pageCode="contact_list" />
```

### 📊 Résumé

| Élément | Où il est défini | Exemple |
|---------|------------------|---------|
| **Structure page** | `studio_page.content_structure` | JSON template |
| **Sections** | `content_structure.children[]` | Array d'objets JSON |
| **Composants** | `studio_component.structure` | Structure JSON |
| **Props composants** | `content_structure.children[].props` | Objets JSON |
| **Actions** | `props.onClick.type: "action"` | Objets JSON |
| **Styles** | `studio_component.variants` | Objets JSON |

**Résultat** : C'est comme un système de **templates JSON stockés dans la DB**, que React interprète dynamiquement.

**Aucun code en dur** = Tout est template JSON dans SurrealDB.

---

## ✅ Avantages du Système Contrôlé

### 1. Sécurité

```typescript
// ❌ HTML brut : Risque XSS
html_structure = '<button onclick="alert(\'hack\')">Click</button>';

// ✅ Structure contrôlée : Validation stricte
structure = {
  type: "button",
  props: {
    onClick: { type: "function", handler: "safeHandler" } // Seulement fonctions autorisées
  }
};
```

### 2. Props Typées

```typescript
// Validation TypeScript possible
interface ButtonProps {
  label: string;
  variant?: 'primary' | 'secondary';
  onClick?: () => void;
}
```

### 3. Performance

```typescript
// React optimise automatiquement
// Pas de parsing HTML à chaque render
const Button = React.memo(StudioComponentRenderer);
```

### 4. Débogage

```typescript
// Erreurs claires dans React DevTools
// Stack traces React normales
// Pas d'erreurs HTML obscures
```

---

## 🔄 Comparaison Visuelle

### HTML Brut (❌)

```
DB: "<button class='btn'>{{props.label}}</button>"
     ↓ (html-react-parser)
React: <div dangerouslySetInnerHTML={{...}} />
     ↓
DOM: <button class="btn">Label</button>
```

**Problèmes** :
- Pas de gestion onClick React
- Pas de validation
- Risque XSS

### Système Contrôlé (✅)

```
DB: {
  type: "button",
  props: { className: ["btn"], onClick: {...} },
  children: [{ type: "text", content: "{{props.label}}" }]
}
     ↓ (ComponentParser)
React: React.createElement('button', {...}, ...)
     ↓
DOM: <button class="btn" onClick={...}>Label</button>
```

**Avantages** :
- Vraie intégration React
- Validation stricte
- Sécurité garantie
- Performance optimale

---

## 🚀 Prochaines Étapes

1. **Créer les schémas DB** : Tables `studio_component` avec structure JSON
2. **Implémenter ComponentParser** : Transformer structure → React
3. **Créer les composants de base** : Button, Input, Card, etc.
4. **Tester et itérer** : Valider avec des cas réels

---

## 💡 Résumé

**Système contrôlé = Structure JSON + Parser personnalisé + Composants React natifs**

Au lieu de parser du HTML brut (dangereux, limité), vous :
1. Stockez une **structure JSON** dans la DB
2. **Parsez** cette structure avec votre code
3. **Rendez** des composants React **natifs** et **sécurisés**

**Résultat** : Flexibilité totale + Sécurité + Performance !

