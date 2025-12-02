import { describe, it, expect } from 'vitest';
import { resolveTemplate, resolveTemplateObject } from '../resolveTemplate';
describe('resolveTemplate', () => {
    it('should resolve simple template with props', () => {
        const result = resolveTemplate('{{props.label}}', {
            props: { label: 'Click me' },
        });
        expect(result).toBe('Click me');
    });
    it('should resolve nested template', () => {
        const result = resolveTemplate('{{page.title.fr}}', {
            page: { title: { fr: 'Contact' } },
        });
        expect(result).toBe('Contact');
    });
    it('should resolve multiple templates in same string', () => {
        const result = resolveTemplate('Hello {{props.name}}, welcome to {{page.title}}', {
            props: { name: 'John' },
            page: { title: 'Dashboard' },
        });
        expect(result).toBe('Hello John, welcome to Dashboard');
    });
    it('should keep original template if value not found', () => {
        const result = resolveTemplate('{{props.unknown}}', {
            props: {},
        });
        expect(result).toBe('{{props.unknown}}');
    });
    it('should handle non-string values', () => {
        expect(resolveTemplate(123, {})).toBe(123);
        expect(resolveTemplate(null, {})).toBe(null);
        expect(resolveTemplate(undefined, {})).toBe(undefined);
        expect(resolveTemplate(true, {})).toBe(true);
    });
    it('should handle empty string', () => {
        const result = resolveTemplate('', {});
        expect(result).toBe('');
    });
    it('should handle template with no context', () => {
        const result = resolveTemplate('{{props.label}}', {});
        expect(result).toBe('{{props.label}}');
    });
    it('should resolve boolean values', () => {
        const result = resolveTemplate('{{props.disabled}}', {
            props: { disabled: true },
        });
        expect(result).toBe('true');
    });
    it('should resolve number values', () => {
        const result = resolveTemplate('{{props.count}}', {
            props: { count: 42 },
        });
        expect(result).toBe('42');
    });
});
describe('resolveTemplateObject', () => {
    it('should resolve templates in object', () => {
        const obj = {
            label: '{{props.label}}',
            disabled: '{{props.disabled}}',
        };
        const result = resolveTemplateObject(obj, {
            props: { label: 'Click', disabled: false },
        });
        expect(result).toEqual({
            label: 'Click',
            disabled: false,
        });
    });
    it('should resolve templates in array', () => {
        const arr = ['{{props.first}}', '{{props.second}}'];
        const result = resolveTemplateObject(arr, {
            props: { first: 'one', second: 'two' },
        });
        expect(result).toEqual(['one', 'two']);
    });
    it('should keep action objects untouched', () => {
        const obj = {
            onClick: {
                type: 'action',
                action: 'navigate',
                target: 'home',
            },
        };
        const result = resolveTemplateObject(obj, {});
        expect(result).toEqual(obj);
    });
    it('should resolve nested objects', () => {
        const obj = {
            user: {
                name: '{{props.name}}',
                email: '{{props.email}}',
            },
        };
        const result = resolveTemplateObject(obj, {
            props: { name: 'John', email: 'john@example.com' },
        });
        expect(result).toEqual({
            user: {
                name: 'John',
                email: 'john@example.com',
            },
        });
    });
    it('should handle empty object', () => {
        const result = resolveTemplateObject({}, {});
        expect(result).toEqual({});
    });
});
