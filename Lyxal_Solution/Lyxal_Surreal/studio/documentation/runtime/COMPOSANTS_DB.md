# 🎨 Composants Pilotés par Base de Données (Sans DaisyUI)

Guide complet pour créer et gérer des composants UI 100% pilotés par SurrealDB, **sans dépendre de DaisyUI**.

---

## 🎯 Vision : Composants Database-Driven

**Principe** : Définir la structure, les styles et le comportement de **tous les composants** dans SurrealDB, puis les rendre dynamiquement en React.

```
SurrealDB (studio_component)
  ↓ (Définition composant)
React (StudioRenderer)
  ↓ (Rendu dynamique)
DOM (HTML + CSS variables)
```

---

## 📊 Architecture Proposée

### 1. Table `studio_component`

**Définition** : Dictionnaire de tous les composants réutilisables du système.

```surql
DEFINE TABLE studio_component SCHEMAFULL
  COMMENT 'Composants UI réutilisables pilotés par DB';

DEFINE FIELD code ON studio_component
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Code unique du composant (ex: button, card, input)';

DEFINE FIELD name ON studio_component
  TYPE object
  COMMENT 'Nom du composant (multilingue)';

DEFINE FIELD type ON studio_component
  TYPE string
  ASSERT $value IN ['atom', 'molecule', 'organism']
  COMMENT 'Type de composant (atom = bouton, molecule = card+header, organism = formulaire complet)';

DEFINE FIELD html_structure ON studio_component
  TYPE string
  COMMENT 'Structure HTML avec placeholders : {{props.label}}, {{children}}';

DEFINE FIELD styles ON studio_component
  TYPE object
  COMMENT 'Styles CSS à appliquer (inline ou classes)';

DEFINE FIELD props ON studio_component
  TYPE array<object>
  COMMENT 'Props acceptées par le composant : [{name: "variant", type: "string", default: "primary"}]';

DEFINE FIELD variants ON studio_component
  TYPE object
  COMMENT 'Variantes de style : {primary: {bg: "#3B82F6"}, secondary: {bg: "#10B981"}}';

DEFINE FIELD slots ON studio_component
  TYPE array<string>
  DEFAULT []
  COMMENT 'Slots pour contenu dynamique : ["header", "body", "footer"]';

DEFINE FIELD dependencies ON studio_component
  TYPE array<string>
  DEFAULT []
  COMMENT 'Composants requis (ex: ["icon"] si le bouton peut avoir une icône)';

DEFINE FIELD active ON studio_component
  TYPE bool
  DEFAULT true;

DEFINE INDEX code_unique ON studio_component FIELDS code UNIQUE;
```

### 2. Table `studio_component_style`

**Définition** : Styles CSS réutilisables (classes ou CSS variables).

```surql
DEFINE TABLE studio_component_style SCHEMAFULL
  COMMENT 'Styles CSS réutilisables';

DEFINE FIELD code ON studio_component_style
  TYPE string
  ASSERT $value != NONE;

DEFINE FIELD css_classes ON studio_component_style
  TYPE option<string>
  COMMENT 'Classes Tailwind ou CSS custom : "px-4 py-2 rounded-lg"';

DEFINE FIELD css_variables ON studio_component_style
  TYPE option<object>
  COMMENT 'Variables CSS : {--bg: "#FFF", --text: "#000"}';

DEFINE FIELD inline_styles ON studio_component_style
  TYPE option<object>
  COMMENT 'Styles inline : {backgroundColor: "#3B82F6", padding: "1rem"}';

DEFINE FIELD responsive ON studio_component_style
  TYPE option<object>
  COMMENT 'Styles responsive : {mobile: {padding: "0.5rem"}, desktop: {padding: "1rem"}}';

DEFINE INDEX code_unique ON studio_component_style FIELDS code UNIQUE;
```

---

## 🧩 Exemples de Composants en Base de Données

### 1. Composant `button`

```surql
CREATE studio_component:button SET
  code = "button",
  name = {
    fr: "Bouton",
    en: "Button"
  },
  type = "atom",
  html_structure = '
    <button 
      class="{{props.className}} {{styles.base}} {{styles.variant}}"
      style="{{styles.inline}}"
      {{#if props.disabled}}disabled{{/if}}
      {{#if props.onClick}}onclick="{{props.onClick}}"{{/if}}
    >
      {{#if props.icon}}
        <Icon name="{{props.icon}}" size="{{props.iconSize}}" />
      {{/if}}
      {{#if props.label}}{{props.label}}{{/if}}
      {{children}}
    </button>
  ',
  styles = {
    base: "px-4 py-2 rounded-lg font-medium transition-colors cursor-pointer",
    variant: {
      primary: "bg-primary text-white hover:bg-primary-dark",
      secondary: "bg-secondary text-white hover:bg-secondary-dark",
      ghost: "bg-transparent border border-gray-300 hover:bg-gray-100"
    }
  },
  props = [
    {
      name: "variant",
      type: "string",
      default: "primary",
      options: ["primary", "secondary", "ghost", "danger"]
    },
    {
      name: "label",
      type: "string",
      required: false
    },
    {
      name: "icon",
      type: "string",
      required: false
    },
    {
      name: "disabled",
      type: "boolean",
      default: false
    },
    {
      name: "onClick",
      type: "function",
      required: false
    }
  ],
  variants = {
    primary: {
      css_classes: "bg-primary text-white hover:bg-primary-dark",
      css_variables: {
        "--button-bg": "#3B82F6",
        "--button-text": "#FFFFFF"
      }
    },
    secondary: {
      css_classes: "bg-secondary text-white hover:bg-secondary-dark",
      css_variables: {
        "--button-bg": "#10B981",
        "--button-text": "#FFFFFF"
      }
    }
  },
  dependencies = ["icon"],
  active = true;
```

### 2. Composant `card`

```surql
CREATE studio_component:card SET
  code = "card",
  name = {
    fr: "Carte",
    en: "Card"
  },
  type = "molecule",
  html_structure = '
    <div class="{{styles.base}} {{props.className}}">
      {{#if slots.header}}
        <div class="{{styles.header}}">
          {{slot:header}}
        </div>
      {{/if}}
      <div class="{{styles.body}}">
        {{#if props.title}}
          <h3 class="{{styles.title}}">{{props.title}}</h3>
        {{/if}}
        {{children}}
      </div>
      {{#if slots.footer}}
        <div class="{{styles.footer}}">
          {{slot:footer}}
        </div>
      {{/if}}
    </div>
  ',
  styles = {
    base: "bg-white rounded-lg shadow-md overflow-hidden",
    header: "px-6 py-4 border-b border-gray-200",
    body: "px-6 py-4",
    title: "text-xl font-semibold mb-2",
    footer: "px-6 py-4 border-t border-gray-200 bg-gray-50"
  },
  props = [
    {
      name: "title",
      type: "string",
      required: false
    },
    {
      name: "shadow",
      type: "string",
      default: "md",
      options: ["none", "sm", "md", "lg"]
    }
  ],
  slots = ["header", "footer"],
  active = true;
```

### 3. Composant `input`

```surql
CREATE studio_component:input SET
  code = "input",
  name = {
    fr: "Champ de saisie",
    en: "Input Field"
  },
  type = "atom",
  html_structure = '
    <div class="{{styles.wrapper}}">
      {{#if props.label}}
        <label class="{{styles.label}}">
          {{props.label}}
          {{#if props.required}}<span class="{{styles.required}}">*</span>{{/if}}
        </label>
      {{/if}}
      <input
        type="{{props.type}}"
        name="{{props.name}}"
        placeholder="{{props.placeholder}}"
        value="{{props.value}}"
        class="{{styles.input}} {{props.error ? styles.error : ''}}"
        {{#if props.required}}required{{/if}}
        {{#if props.disabled}}disabled{{/if}}
      />
      {{#if props.error}}
        <span class="{{styles.errorMessage}}">{{props.error}}</span>
      {{/if}}
      {{#if props.help}}
        <span class="{{styles.help}}">{{props.help}}</span>
      {{/if}}
    </div>
  ',
  styles = {
    wrapper: "flex flex-col gap-2",
    label: "text-sm font-medium text-gray-700",
    required: "text-red-500",
    input: "px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent",
    error: "border-red-500 focus:ring-red-500",
    errorMessage: "text-sm text-red-500",
    help: "text-sm text-gray-500"
  },
  props = [
    {
      name: "type",
      type: "string",
      default: "text",
      options: ["text", "email", "password", "number", "tel", "url"]
    },
    {
      name: "name",
      type: "string",
      required: true
    },
    {
      name: "label",
      type: "string",
      required: false
    },
    {
      name: "placeholder",
      type: "string",
      required: false
    },
    {
      name: "required",
      type: "boolean",
      default: false
    },
    {
      name: "disabled",
      type: "boolean",
      default: false
    },
    {
      name: "error",
      type: "string",
      required: false
    },
    {
      name: "help",
      type: "string",
      required: false
    }
  ],
  active = true;
```

### 4. Composant `table`

```surql
CREATE studio_component:table SET
  code = "table",
  name = {
    fr: "Tableau",
    en: "Table"
  },
  type = "organism",
  html_structure = '
    <div class="{{styles.wrapper}}">
      {{#if props.title}}
        <h2 class="{{styles.title}}">{{props.title}}</h2>
      {{/if}}
      <div class="{{styles.container}}">
        <table class="{{styles.table}}">
          <thead class="{{styles.thead}}">
            <tr>
              {{#each props.columns}}
                <th class="{{styles.th}}">{{this.label}}</th>
              {{/each}}
            </tr>
          </thead>
          <tbody class="{{styles.tbody}}">
            {{#each props.data}}
              <tr class="{{styles.tr}}">
                {{#each ../props.columns}}
                  <td class="{{styles.td}}">{{lookup ../this this.field}}</td>
                {{/each}}
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
      {{#if props.pagination}}
        <div class="{{styles.pagination}}">
          {{slot:pagination}}
        </div>
      {{/if}}
    </div>
  ',
  styles = {
    wrapper: "bg-white rounded-lg shadow-md overflow-hidden",
    title: "px-6 py-4 text-xl font-semibold border-b",
    container: "overflow-x-auto",
    table: "w-full",
    thead: "bg-gray-50",
    th: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider",
    tbody: "bg-white divide-y divide-gray-200",
    tr: "hover:bg-gray-50",
    td: "px-6 py-4 whitespace-nowrap text-sm text-gray-900",
    pagination: "px-6 py-4 border-t"
  },
  props = [
    {
      name: "title",
      type: "string",
      required: false
    },
    {
      name: "columns",
      type: "array",
      required: true,
      description: "[{field: 'name', label: 'Nom'}, ...]"
    },
    {
      name: "data",
      type: "array",
      required: true
    },
    {
      name: "pagination",
      type: "boolean",
      default: false
    }
  ],
  slots = ["pagination"],
  active = true;
```

---

## 🔧 Moteur de Rendu React

### `StudioComponentRenderer.tsx`

```typescript
import React, { useMemo } from 'react';
import { db } from '@/lib/surrealdb';
import * as Icons from 'lucide-react';

interface ComponentProps {
  code: string;
  props?: Record<string, any>;
  children?: React.ReactNode;
  slots?: Record<string, React.ReactNode>;
}

export const StudioComponentRenderer: React.FC<ComponentProps> = ({
  code,
  props = {},
  children,
  slots = {},
}) => {
  const [component, setComponent] = React.useState<any>(null);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    const loadComponent = async () => {
      try {
        const result = await db.query(`
          SELECT * FROM studio_component WHERE code = '${code}' AND active = true
        `);
        
        if (result?.[0]) {
          setComponent(result[0]);
        }
      } catch (error) {
        console.error(`Failed to load component ${code}:`, error);
      } finally {
        setLoading(false);
      }
    };

    loadComponent();
  }, [code]);

  const renderedHTML = useMemo(() => {
    if (!component) return null;

    let html = component.html_structure;

    // Remplacer les props
    Object.entries(props).forEach(([key, value]) => {
      const regex = new RegExp(`\\{\\{props\\.${key}\\}\\}`, 'g');
      html = html.replace(regex, String(value || ''));
    });

    // Remplacer les conditions
    if (props.disabled) {
      html = html.replace(/\{\{#if props\.disabled\}\}/g, '');
      html = html.replace(/\{\{\/if\}\}/g, '');
    } else {
      html = html.replace(/\{\{#if props\.disabled\}\}[\s\S]*?\{\{\/if\}\}/g, '');
    }

    // Remplacer les slots
    Object.entries(slots).forEach(([slotName, slotContent]) => {
      const regex = new RegExp(`\\{\\{slot:${slotName}\\}\\}`, 'g');
      html = html.replace(regex, typeof slotContent === 'string' ? slotContent : '[SLOT]');
    });

    // Remplacer children
    html = html.replace(/\{\{children\}\}/g, typeof children === 'string' ? children : '[CHILDREN]');

    // Appliquer les styles
    const variant = props.variant || 'primary';
    const variantStyles = component.variants?.[variant] || {};
    
    // Remplacer les classes CSS
    html = html.replace(/\{\{styles\.(\w+)\}\}/g, (match, styleKey) => {
      const style = component.styles?.[styleKey];
      if (typeof style === 'string') {
        return style;
      } else if (typeof style === 'object' && variant in style) {
        return style[variant];
      }
      return '';
    });

    return html;
  }, [component, props, children, slots]);

  if (loading) {
    return <div>Loading component...</div>;
  }

  if (!component) {
    return <div>Component {code} not found</div>;
  }

  // Parser le HTML et le rendre avec React
  return <ComponentFromHTML html={renderedHTML} props={props} children={children} slots={slots} />;
};

// Helper pour parser le HTML en composants React
const ComponentFromHTML: React.FC<{ html: string; props: any; children: any; slots: any }> = ({
  html,
  props,
  children,
  slots,
}) => {
  // Simple parser (pour production, utiliser une bibliothèque comme html-react-parser)
  // Pour l'exemple, on utilise dangerouslySetInnerHTML (⚠️ attention sécurité)
  
  // Appliquer les styles CSS variables depuis les variants
  const variant = props.variant || 'primary';
  const component = component; // Récupéré depuis le contexte
  
  const style = {
    ...component?.variants?.[variant]?.css_variables,
  };

  return (
    <div
      dangerouslySetInnerHTML={{ __html: html }}
      style={style}
      className={component?.variants?.[variant]?.css_classes}
    />
  );
};
```

### Version Plus Robuste avec Parser HTML

```typescript
import React from 'react';
import parse from 'html-react-parser';

const ComponentFromHTML: React.FC<{ 
  html: string; 
  props: any; 
  children: any; 
  slots: any;
  component: any;
}> = ({ html, props, children, slots, component }) => {
  const variant = props.variant || 'primary';
  const variantStyles = component?.variants?.[variant] || {};

  // Remplacer les icônes
  html = html.replace(/\{\{Icon name="(\w+)" size="(\w+)"\}\}/g, (match, iconName, size) => {
    const IconComponent = Icons[iconName as keyof typeof Icons];
    if (IconComponent) {
      return `<IconComponent size={${size || 16}} />`;
    }
    return '';
  });

  // Parser le HTML
  const parsed = parse(html, {
    replace: (domNode: any) => {
      // Remplacer les placeholders par les vrais composants React
      if (domNode.type === 'text' && domNode.data?.includes('[SLOT]')) {
        // Gérer les slots
      }
      if (domNode.type === 'text' && domNode.data?.includes('[CHILDREN]')) {
        return children;
      }
      return domNode;
    },
  });

  return (
    <div
      className={variantStyles.css_classes}
      style={variantStyles.css_variables}
    >
      {parsed}
    </div>
  );
};
```

---

## 🎨 Intégration avec Thèmes DB

### Lier les Composants aux Thèmes

```surql
-- Créer un style de composant lié au thème
CREATE studio_component_style:button_primary_lyxal SET
  code = "button_primary_lyxal",
  css_classes = "px-4 py-2 rounded-lg font-medium bg-primary text-white",
  css_variables = {
    "--bg": "var(--color-primary)",
    "--text": "var(--color-white)"
  };

-- Associer le style au composant et au tenant
UPDATE studio_component:button SET
  theme_styles = {
    lyxal: {
      primary: studio_component_style:button_primary_lyxal
    },
    batipro: {
      primary: studio_component_style:button_primary_batipro
    }
  };
```

---

## 📦 Utilisation dans les Pages Studio

### Exemple : Formulaire avec Composants DB

```surql
-- Définir un formulaire qui utilise les composants DB
CREATE studio_form:contact_create SET
  code = "contact_create",
  fields = [
    {
      name: "first_name",
      type: "input",
      component: "input",  -- Utilise studio_component:input
      props: {
        label: { fr: "Prénom", en: "First Name" },
        required: true,
        placeholder: { fr: "Jean", en: "John" }
      }
    },
    {
      name: "submit",
      type: "button",
      component: "button",  -- Utilise studio_component:button
      props: {
        variant: "primary",
        label: { fr: "Créer", en: "Create" },
        icon: "Plus"
      }
    }
  ];
```

### Rendu dans `StudioForm.tsx`

```typescript
export const StudioForm: React.FC<{ form: any }> = ({ form }) => {
  return (
    <form>
      {form.fields.map((field: any) => (
        <StudioComponentRenderer
          key={field.name}
          code={field.component}
          props={{
            ...field.props,
            name: field.name,
            type: field.type,
          }}
        />
      ))}
    </form>
  );
};
```

---

## 🎯 Avantages de cette Approche

### ✅ Sans DaisyUI

1. **100% Database-Driven** : Tous les composants définis en DB
2. **White-Label total** : Chaque tenant peut avoir ses propres composants
3. **Flexibilité maximale** : Créer n'importe quel composant sans limite
4. **A/B Testing facile** : Tester 2 versions d'un bouton en DB
5. **Pas de dépendance externe** : Pas besoin de DaisyUI ni Material-UI

### ✅ Possibilités

1. **Créer des composants custom** directement en DB
2. **Modifier les styles** instantanément (UPDATE DB)
3. **Partager des composants** entre tenants
4. **Versionner les composants** (historique dans DB)
5. **Composants conditionnels** (selon rôle, module, etc.)

---

## 🚀 Roadmap d'Implémentation

### Phase 1 : Fondations (1 semaine)

1. ✅ Créer table `studio_component`
2. ✅ Créer table `studio_component_style`
3. ✅ Implémenter `StudioComponentRenderer`
4. ✅ Créer 5 composants de base (button, input, card, table, modal)

### Phase 2 : Composants Avancés (1 semaine)

1. ✅ Créer composants complexes (form, dashboard, navigation)
2. ✅ Système de slots et children
3. ✅ Intégration avec thèmes DB
4. ✅ Variantes par tenant

### Phase 3 : Outils de Gestion (1 semaine)

1. ✅ Interface admin pour créer/modifier composants
2. ✅ Visual component builder
3. ✅ Prévisualisation en temps réel
4. ✅ Export/Import de composants

---

## 📝 Exemple Complet : Créer un Bouton Custom

```surql
-- 1. Créer le composant
CREATE studio_component:custom_button SET
  code = "custom_button",
  name = { fr: "Bouton Personnalisé", en: "Custom Button" },
  type = "atom",
  html_structure = '
    <button class="{{styles.base}} {{styles.variant}}" onclick="{{props.onClick}}">
      <span class="{{styles.icon}}">{{props.icon}}</span>
      <span class="{{styles.label}}">{{props.label}}</span>
    </button>
  ',
  styles = {
    base: "px-6 py-3 rounded-full font-bold transition-all transform hover:scale-105",
    variant: {
      primary: "bg-gradient-to-r from-blue-500 to-blue-600 text-white shadow-lg",
      secondary: "bg-gradient-to-r from-green-500 to-green-600 text-white shadow-lg"
    }
  },
  props = [
    { name: "label", type: "string", required: true },
    { name: "icon", type: "string", required: false },
    { name: "variant", type: "string", default: "primary" },
    { name: "onClick", type: "function", required: false }
  ],
  active = true;

-- 2. Utiliser dans une page
UPDATE studio_page:contact_list SET
  widgets = [
    {
      type: "action",
      component: "custom_button",
      props: {
        label: { fr: "Nouveau Contact", en: "New Contact" },
        icon: "Plus",
        variant: "primary",
        onClick: "navigate('/contacts/new')"
      }
    }
  ];
```

---

## 💡 Comparaison : DaisyUI vs DB-Driven

| Aspect | DaisyUI | DB-Driven |
|--------|---------|-----------|
| **Définition** | Classes CSS prédéfinies | Structure HTML + styles en DB |
| **White-Label** | Variables CSS | Composants entiers par tenant |
| **Flexibilité** | Limitée aux composants DaisyUI | Illimitée (créer n'importe quoi) |
| **Maintenance** | Mise à jour npm | UPDATE DB |
| **A/B Testing** | Difficile | Facile (2 versions en DB) |
| **Dépendance** | npm package | Aucune (tout en DB) |

---

## 🎓 Conclusion

**Oui, vous pouvez totalement vous passer de DaisyUI !**

En utilisant une approche **DB-Driven pour les composants** :
- ✅ Définir tous les composants en SurrealDB
- ✅ Rendre dynamiquement avec React
- ✅ White-Label total (chaque tenant a ses composants)
- ✅ Aucune dépendance externe de composants UI
- ✅ Flexibilité maximale

**Avantage principal** : Vous gardez la philosophie **"Tout piloté par la DB"** tout en ayant un contrôle total sur l'apparence et le comportement des composants.

---

**Note** : Pour l'implémentation, vous devrez créer un moteur de rendu React qui interprète les définitions DB. Vous pouvez utiliser des bibliothèques comme `html-react-parser` pour parser le HTML, ou créer votre propre système de rendu plus contrôlé.

