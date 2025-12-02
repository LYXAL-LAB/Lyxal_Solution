import { describe, it, expect } from 'vitest';
import React from 'react';
import { parseComponent } from '../index';
/**
 * Tests pour parseComponent avec la structure réelle de test_button
 * Basé sur les données de studio_component:test_button dans SurrealDB
 */
describe('parseComponent - test_button integration', () => {
    // Structure réelle du test_button depuis SurrealDB
    const testButtonStructure = {
        type: 'button',
        props: {
            className: ['btn', 'btn-primary'],
            disabled: '{{props.disabled}}',
            onClick: {
                type: 'action',
                action: 'state_update',
                target: 'button_clicked',
            },
        },
        children: [
            {
                type: 'text',
                content: '{{props.label}}',
            },
        ],
        variants: {},
    };
    it('should parse test_button structure with label', () => {
        const props = {
            label: 'Mon Bouton',
            disabled: false,
        };
        const element = parseComponent(testButtonStructure, props);
        expect(element).toBeDefined();
        expect(element.type).toBe('button');
        expect(React.isValidElement(element)).toBe(true);
    });
    it('should resolve label template in children', () => {
        const props = {
            label: 'Click Me',
            disabled: false,
        };
        const element = parseComponent(testButtonStructure, props);
        // Les children devraient contenir le texte résolu
        expect(element.props.children).toBeDefined();
    });
    it('should resolve disabled prop from template', () => {
        const props = {
            label: 'Test',
            disabled: true,
        };
        const element = parseComponent(testButtonStructure, props);
        expect(element.props.disabled).toBe(true);
    });
    it('should keep action object in onClick', () => {
        const props = {
            label: 'Test',
            disabled: false,
        };
        const element = parseComponent(testButtonStructure, props);
        expect(element.props.onClick).toBeDefined();
        expect(element.props.onClick.type).toBe('action');
        expect(element.props.onClick.action).toBe('state_update');
        expect(element.props.onClick.target).toBe('button_clicked');
    });
    it('should apply className from structure', () => {
        const props = {
            label: 'Test',
            disabled: false,
        };
        const element = parseComponent(testButtonStructure, props);
        expect(element.props.className).toContain('btn');
        expect(element.props.className).toContain('btn-primary');
    });
    it('should override className if provided in props', () => {
        const props = {
            label: 'Test',
            disabled: false,
            className: 'custom-class',
        };
        const element = parseComponent(testButtonStructure, props);
        // Props should override structure props
        expect(element.props.className).toBe('custom-class');
    });
    it('should work with minimal props (only required)', () => {
        const props = {
            label: 'Minimal',
        };
        const element = parseComponent(testButtonStructure, props);
        expect(element).toBeDefined();
        expect(element.type).toBe('button');
    });
    it('should handle empty props', () => {
        const element = parseComponent(testButtonStructure, {});
        expect(element).toBeDefined();
        // disabled should remain as template string if not provided
        expect(element.props.disabled).toBe('{{props.disabled}}');
    });
});
describe('parseComponent - edge cases', () => {
    it('should handle structure without props', () => {
        const structure = {
            type: 'div',
        };
        const element = parseComponent(structure, {});
        expect(element.type).toBe('div');
    });
    it('should handle structure without children', () => {
        const structure = {
            type: 'input',
            props: {
                type: 'text',
            },
        };
        const element = parseComponent(structure, {});
        expect(element.type).toBe('input');
        expect(element.props.type).toBe('text');
    });
    it('should handle complex nested templates', () => {
        const structure = {
            type: 'div',
            props: {
                'data-page': '{{page.title.fr}}',
            },
            children: [
                {
                    type: 'text',
                    content: '{{user.name}} - {{page.title.fr}}',
                },
            ],
        };
        const context = {
            page: { title: { fr: 'Contact' } },
            user: { name: 'John' },
        };
        const element = parseComponent(structure, {}, context);
        expect(element.props['data-page']).toBe('Contact');
    });
    it('should preserve non-template values', () => {
        const structure = {
            type: 'button',
            props: {
                type: 'submit',
                className: ['btn'],
            },
        };
        const element = parseComponent(structure, {});
        expect(element.props.type).toBe('submit');
        expect(element.props.className).toEqual(['btn']);
    });
});
