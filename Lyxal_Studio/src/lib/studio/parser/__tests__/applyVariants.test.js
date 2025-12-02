import { describe, it, expect } from 'vitest';
import { applyVariants } from '../applyVariants';
describe('applyVariants', () => {
    it('should apply CSS classes from variant', () => {
        const variants = {
            primary: {
                css_classes: ['btn-primary', 'font-bold'],
            },
        };
        const props = {
            className: ['btn'],
        };
        const result = applyVariants(variants, 'primary', props);
        expect(result.className).toContain('btn');
        expect(result.className).toContain('btn-primary');
        expect(result.className).toContain('font-bold');
    });
    it('should apply CSS variables from variant', () => {
        const variants = {
            primary: {
                css_variables: {
                    '--primary-color': '#007bff',
                    '--primary-hover': '#0056b3',
                },
            },
        };
        const props = {
            style: { fontSize: '16px' },
        };
        const result = applyVariants(variants, 'primary', props);
        expect(result.style).toEqual({
            fontSize: '16px',
            '--primary-color': '#007bff',
            '--primary-hover': '#0056b3',
        });
    });
    it('should merge with existing styles', () => {
        const variants = {
            primary: {
                css_variables: {
                    '--primary-color': '#007bff',
                },
            },
        };
        const props = {
            style: { fontSize: '16px', color: 'black' },
        };
        const result = applyVariants(variants, 'primary', props);
        expect(result.style).toHaveProperty('fontSize', '16px');
        expect(result.style).toHaveProperty('color', 'black');
        expect(result.style).toHaveProperty('--primary-color', '#007bff');
    });
    it('should handle non-array className', () => {
        const variants = {
            primary: {
                css_classes: ['btn-primary'],
            },
        };
        const props = {
            className: 'btn',
        };
        const result = applyVariants(variants, 'primary', props);
        expect(result.className).toContain('btn');
        expect(result.className).toContain('btn-primary');
    });
    it('should use default variant if specified variant not found', () => {
        const variants = {
            default: {
                css_classes: ['btn-default'],
            },
            primary: {
                css_classes: ['btn-primary'],
            },
        };
        const props = {
            className: ['btn'],
        };
        const result = applyVariants(variants, 'unknown', props);
        expect(result.className).toContain('btn-default');
    });
    it('should handle empty variants', () => {
        const props = {
            className: ['btn'],
        };
        const result = applyVariants({}, 'primary', props);
        expect(result.className).toEqual(['btn']);
    });
    it('should deduplicate CSS classes', () => {
        const variants = {
            primary: {
                css_classes: ['btn', 'btn-primary'],
            },
        };
        const props = {
            className: ['btn', 'font-bold'],
        };
        const result = applyVariants(variants, 'primary', props);
        // btn should appear only once
        const btnCount = result.className.filter((c) => c === 'btn').length;
        expect(btnCount).toBe(1);
        expect(result.className).toContain('btn-primary');
        expect(result.className).toContain('font-bold');
    });
});
