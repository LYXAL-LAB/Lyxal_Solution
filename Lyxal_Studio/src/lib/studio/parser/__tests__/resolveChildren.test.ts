import { describe, it, expect } from 'vitest';
import React from 'react';
import { render } from '@testing-library/react';
import { resolveChildren } from '../resolveChildren';
import type { StudioComponentChild } from '../../types/component';

describe('resolveChildren', () => {
  it('should resolve text children', () => {
    const children: StudioComponentChild[] = [
      {
        type: 'text',
        content: '{{props.label}}',
      },
    ];
    const context = {
      props: { label: 'Click me' },
    };

    const result = resolveChildren(children, context);

    expect(result).toHaveLength(1);
    expect(React.isValidElement(result[0])).toBe(true);
  });

  it('should resolve multiple text children', () => {
    const children: StudioComponentChild[] = [
      {
        type: 'text',
        content: '{{props.first}}',
      },
      {
        type: 'text',
        content: '{{props.second}}',
      },
    ];
    const context = {
      props: { first: 'Hello', second: 'World' },
    };

    const result = resolveChildren(children, context);

    expect(result).toHaveLength(2);
  });

  it('should resolve HTML element children', () => {
    const children: StudioComponentChild[] = [
      {
        type: 'span',
        props: {
          className: 'text-bold',
        },
        children: [
          {
            type: 'text',
            content: '{{props.label}}',
          },
        ],
      },
    ];
    const context = {
      props: { label: 'Bold text' },
    };

    const result = resolveChildren(children, context);

    expect(result).toHaveLength(1);
    expect(React.isValidElement(result[0])).toBe(true);
  });

  it('should filter children based on condition', () => {
    const children: StudioComponentChild[] = [
      {
        type: 'text',
        content: 'Always visible',
      },
      {
        type: 'text',
        content: 'Conditional',
        condition: '{{props.show}}',
      },
    ];
    const context = {
      props: { show: true },
    };

    const result = resolveChildren(children, context);

    expect(result).toHaveLength(2);
  });

  it('should filter out children when condition is false', () => {
    const children: StudioComponentChild[] = [
      {
        type: 'text',
        content: 'Always visible',
      },
      {
        type: 'text',
        content: 'Hidden',
        condition: '{{props.show}}',
      },
    ];
    const context = {
      props: { show: false },
    };

    const result = resolveChildren(children, context);

    expect(result).toHaveLength(1);
  });

  it('should handle empty children array', () => {
    const result = resolveChildren([], {});

    expect(result).toHaveLength(0);
  });

  it('should resolve nested children', () => {
    const children: StudioComponentChild[] = [
      {
        type: 'div',
        children: [
          {
            type: 'text',
            content: '{{props.label}}',
          },
        ],
      },
    ];
    const context = {
      props: { label: 'Nested' },
    };

    const result = resolveChildren(children, context);

    expect(result).toHaveLength(1);
  });
});

