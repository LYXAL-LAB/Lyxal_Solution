import React from 'react';
import { useStudioComponent } from '@/lib/studio/hooks/useStudioComponent';
import { parseComponent } from '@/lib/studio/parser';
import { ContextManager } from '@/lib/studio/context/ContextManager';
import { useStudioState } from '@/lib/studio/store/useStudioState';
import { useActionHandler } from '@/lib/studio/hooks/useActionHandler';
import type { ContextSources } from '@/lib/studio/context/ContextManager';

/**
 * Props pour StudioComponentRenderer
 */
export interface StudioComponentRendererProps {
  code: string;  // Code du composant (ex: "test_button")
  props?: Record<string, any>;
  context?: ContextSources;
}

/**
 * Renderer principal pour les composants définis en DB
 * 
 * Charge un composant depuis SurrealDB et le rend avec le parser.
 * Gère automatiquement le chargement, les erreurs, et l'intégration
 * avec le state global et les actions.
 * 
 * @example
 * ```tsx
 * <StudioComponentRenderer
 *   code="test_button"
 *   props={{ label: "Click me", disabled: false }}
 * />
 * ```
 */
export const StudioComponentRenderer: React.FC<StudioComponentRendererProps> = ({
  code,
  props = {},
  context = {},
}) => {
  // Charger le composant depuis SurrealDB
  const { component, loading, error } = useStudioComponent(code);

  // Récupérer le state global
  const globalState = useStudioState((state: any) => state.state);

  // Handler pour les actions
  const { handleAction } = useActionHandler();

  // États de chargement et d'erreur
  if (loading) {
    return <div className="studio-component-loading">Loading...</div>;
  }

  if (error) {
    return (
      <div className="studio-component-error">
        Error loading component {code}: {error.message}
      </div>
    );
  }

  if (!component || !component.structure) {
    return (
      <div className="studio-component-not-found">
        Component {code} not found
      </div>
    );
  }

  // Fusionner tous les contextes
  const mergedContext = ContextManager.merge(
    {
      ...context,
      state: globalState,
      props,
    },
    props
  );

  // Parser le composant
  let element: React.ReactElement;
  
  try {
    element = parseComponent(component.structure, props, mergedContext);
  } catch (error) {
    console.error(`[StudioComponentRenderer] Error parsing component ${code}:`, error);
    return (
      <div className="studio-component-parse-error">
        Error parsing component {code}: {error instanceof Error ? error.message : String(error)}
      </div>
    );
  }

  // Vérifier que element est valide
  if (!element || !React.isValidElement(element)) {
    console.error(`[StudioComponentRenderer] Invalid element for component ${code}:`, element);
    return (
      <div className="studio-component-invalid-element">
        Invalid element for component {code}
      </div>
    );
  }

  // Injecter les handlers d'actions dans les props si nécessaire
  // (pour les actions onClick, onChange, etc.)
  if (element.props && typeof element.props === 'object') {
    const elementProps = element.props as Record<string, any>;
    const enhancedProps: Record<string, any> = { ...elementProps };

    // Si onClick est une action, la remplacer par un handler
    if (enhancedProps.onClick && typeof enhancedProps.onClick === 'object' && enhancedProps.onClick.type === 'action') {
      const actionDef = enhancedProps.onClick;
      enhancedProps.onClick = (e: any) => {
        try {
          handleAction(actionDef, e);
        } catch (error) {
          console.error('[StudioComponentRenderer] Error handling action:', error);
        }
      };
    }

    // Si onChange est une action, la remplacer par un handler
    if (enhancedProps.onChange && typeof enhancedProps.onChange === 'object' && enhancedProps.onChange.type === 'action') {
      enhancedProps.onChange = (e: any) => {
        handleAction(enhancedProps.onChange, e);
      };
    }

    // Re-créer l'élément avec les props améliorées seulement si nécessaire
    if (enhancedProps.onClick !== elementProps.onClick || enhancedProps.onChange !== elementProps.onChange) {
      element = React.createElement(
        element.type,
        enhancedProps,
        elementProps.children
      );
    }
  }

  return element;
};

