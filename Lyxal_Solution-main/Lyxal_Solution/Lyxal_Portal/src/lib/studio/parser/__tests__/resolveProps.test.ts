import { describe, it, expect } from 'vitest';
import { resolveProps } from '../resolveProps';

describe('resolveProps', () => {
  it('should resolve template strings in structure props', () => {
    const structureProps = {
      disabled: '{{props.disabled}}',
      className: 'btn',
    };
    const componentProps = {};
    const context = {
      props: { disabled: true },
    };

    const result = resolveProps(structureProps, componentProps, context);

    expect(result.disabled).toBe(true);
    expect(result.className).toBe('btn');
  });

  it('should keep action objects untouched', () => {
    const action = {
      type: 'action',
      action: 'state_update',
      target: 'button_clicked',
    };
    const structureProps = {
      onClick: action,
    };
    const result = resolveProps(structureProps, {}, {});

    expect(result.onClick).toEqual(action);
  });

  it('should merge component props over structure props', () => {
    const structureProps = {
      className: 'btn',
      disabled: '{{props.disabled}}',
    };
    const componentProps = {
      className: 'btn-primary',
      variant: 'primary',
    };
    const context = {
      props: { disabled: false },
    };

    const result = resolveProps(structureProps, componentProps, context);

    // Component props should override structure props
    expect(result.className).toBe('btn-primary');
    expect(result.disabled).toBe(false);
    expect(result.variant).toBe('primary');
  });

  it('should handle empty props', () => {
    const result = resolveProps({}, {}, {});
    expect(result).toEqual({});
  });

  it('should resolve nested objects in props', () => {
    const structureProps = {
      style: {
        color: '{{props.color}}',
        fontSize: '16px',
      },
    };
    const context = {
      props: { color: 'blue' },
    };

    const result = resolveProps(structureProps, {}, context);

    expect(result.style).toEqual({
      color: 'blue',
      fontSize: '16px',
    });
  });

  it('should handle arrays in props', () => {
    const structureProps = {
      className: ['btn', 'btn-primary'],
    };

    const result = resolveProps(structureProps, {}, {});

    expect(result.className).toEqual(['btn', 'btn-primary']);
  });
});

