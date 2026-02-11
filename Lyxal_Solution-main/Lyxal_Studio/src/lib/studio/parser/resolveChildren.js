import React from 'react';
import { resolveTemplate } from './resolveTemplate';
import { StructureRenderer } from '@/components/studio/StructureRenderer';
import { StudioComponentRenderer } from '@/components/studio/StudioComponentRenderer';
/**
 * Résout récursivement les children d'un composant
 *
 * Les children peuvent être :
 * - Des éléments texte (type: "text")
 * - Des composants DB (type: "component")
 * - Des éléments HTML natifs (div, span, etc.)
 *
 * @param children - Tableau de structures enfants
 * @param context - Contexte pour résoudre les templates
 * @returns Tableau de ReactNode
 */
export const resolveChildren = (children = [], context = {}) => {
    if (!Array.isArray(children) || children.length === 0) {
        return [];
    }
    return children
        .filter((child) => {
        // Filtrer selon conditions si présentes
        if (child.condition) {
            const conditionValue = resolveTemplate(child.condition, context);
            return conditionValue === true || conditionValue === 'true';
        }
        return true;
    })
        .map((child, index) => {
        // Élément texte
        if (child.type === 'text') {
            const content = child.content
                ? resolveTemplate(child.content, context)
                : '';
            return React.createElement(React.Fragment, { key: index }, content);
        }
        // Composant DB (résolu par StructureRenderer)
        if (child.type === 'component' && child.component) {
            // Si child.component est un code de composant, utiliser StudioComponentRenderer
            // Sinon, si c'est une structure, utiliser StructureRenderer
            if (typeof child.component === 'string') {
                // Code de composant - utiliser StudioComponentRenderer
                return React.createElement(StudioComponentRenderer, {
                    key: index,
                    code: child.component,
                    props: child.props || {},
                    context,
                });
            }
            else {
                // Structure directe - utiliser StructureRenderer
                return React.createElement(StructureRenderer, {
                    key: index,
                    structure: child.component,
                    componentProps: child.props || {},
                    context,
                });
            }
        }
        // Élément HTML natif
        const Element = child.type;
        const childProps = child.props || {};
        // Résoudre les props des enfants récursivement
        const resolvedProps = Object.fromEntries(Object.entries(childProps).map(([key, value]) => {
            // Convertir className array en string
            if (key === 'className' && Array.isArray(value)) {
                return [key, value.join(' ')];
            }
            // Résoudre les templates pour les strings
            if (typeof value === 'string') {
                return [key, resolveTemplate(value, context)];
            }
            // Garder les autres valeurs telles quelles
            return [key, value];
        }));
        // Résoudre les enfants récursifs
        const childChildren = child.children
            ? resolveChildren(child.children, context)
            : null;
        return React.createElement(Element, { key: index, ...resolvedProps }, childChildren);
    });
};
