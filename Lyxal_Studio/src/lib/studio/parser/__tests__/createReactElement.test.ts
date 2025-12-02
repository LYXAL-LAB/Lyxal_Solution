import { describe, it, expect } from 'vitest';
import React from 'react';
import { createReactElement } from '../createReactElement';
import type { StudioComponentStructure } from '../../types/component';

describe('createReactElement', () => {
  it('should create a button element', () => {
    const structure: StudioComponentStructure = {
      type: 'button',
      props: {
        className: ['btn'],
      },
    };

    const element = createReactElement(structure, {}, {});

    expect(element.type).toBe('button');
    expect(React.isValidElement(element)).toBe(true);
  });

    it('should resolve props with templates', () => {
      const structure: StudioComponentStructure = {
        type: 'button',
        props: {
          disabled: '{{props.disabled}}',
          className: ['btn'],
        },
      };

      const componentProps = { disabled: true };
      const context = { props: componentProps };

      const element = createReactElement(structure, componentProps, context);

      expect((element.props as any).disabled).toBe(true);
    });

    it('should include children', () => {
      const structure: StudioComponentStructure = {
        type: 'button',
        props: {
          className: ['btn'],
        },
        children: [
          {
            type: 'text',
            content: '{{props.label}}',
          },
        ],
      };

      const componentProps = { label: 'Click me' };
      const context = { props: componentProps };

      const element = createReactElement(structure, componentProps, context);

      expect((element.props as any).children).toBeDefined();
    });

    it('should apply variants', () => {
      const structure: StudioComponentStructure = {
        type: 'button',
        props: {
          className: ['btn'],
        },
        variants: {
          primary: {
            css_classes: ['btn-primary'],
          },
        },
      };

      const componentProps = { variant: 'primary' };

      const element = createReactElement(structure, componentProps, {});

      expect((element.props as any).className).toContain('btn-primary');
    });

  it('should handle empty structure', () => {
    const structure: StudioComponentStructure = {
      type: 'div',
    };

    const element = createReactElement(structure, {}, {});

    expect(element.type).toBe('div');
  });
});

