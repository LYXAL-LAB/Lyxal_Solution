// Lyxal Studio — JSON Renderer v3 (Level 3)
// Capabilities: expressions {{...}}, loops, conditions, slots, computed $fn, actions dispatcher, sandboxed evaluation
// Output: both Intermediate VDOM (VNode) and React element tree

// -----------------------------
// ✅ Added: Lyxal Operators (array.get, object.get)
// -----------------------------

// somewhere at module top

import { UILogicEngine } from '@lyxal/logic-ui';

const uiEngine = new UILogicEngine();

function runOperatorAuto(input: any, ctx: any) {

const keys = Object.keys(input);

if (keys.length === 1 && keys[0].startsWith('$')) {

const op = keys[0];

const params = interpolate((input as any)[op], ctx); // deep interpolate params first

return uiEngine.run(op, params, ctx);

}

return null;

}

// Lyxal Operators
export const LyxalOperators = {
    /**
     * $array.get: Retrieve items from array
     */
    "$array.get": ({ array, value, index, all }: any) => {
      if (!Array.isArray(array)) return null;
      if (all === true) return array;
      if (typeof value === "string" || typeof value === "number") {
        return array.find((item) => item === value || item?.id === value || item?.value === value);
      }
      if (typeof index === "number") return array[index];
      return null;
    },
    /**
     * $object.get: Retrieve value from object by key path
     */
    "$object.get": ({ object, key, all, default: def }: any) => {
      if (all === true) return object ? JSON.parse(JSON.stringify(object)) : null;
      if (!object) return def ?? null;
      if (!key) return def ?? null;
      const value = key.split(".").reduce((acc, k) => (acc == null ? undefined : acc[k]), object);
      return value ?? def ?? null;
    }
  };
  
  // -----------------------------
  // Operator Packs (Style A: $namespace.action)
  // -----------------------------
  function isTruthy(v: any) {
    return !!(Array.isArray(v) ? v.length : v);
  }
  
  export const OperatorPacks = {
    // Pack 1 — Core Logic
    "$eq": (args: any) => {
      const [a, b] = Array.isArray(args) ? args : [args, undefined];
      return a === b;
    },
    "$not": (arg: any) => !isTruthy(arg),
    "$and": (args: any[]) => (Array.isArray(args) ? args.every(isTruthy) : isTruthy(args)),
    "$or": (args: any[]) => (Array.isArray(args) ? args.some(isTruthy) : isTruthy(args)),
    "$if": (args: any[]) => {
      const [cond, thenVal, elseVal] = args || [];
      return isTruthy(cond) ? thenVal : elseVal;
    },
  
    // Pack 2 — Math
    "$math.add": (args: any[]) => (args || []).reduce((a, b) => Number(a) + Number(b), 0),
    "$math.sub": (args: any[]) => (args || []).slice(1).reduce((a, b) => Number(a) - Number(b), Number(args?.[0] ?? 0)),
    "$math.mul": (args: any[]) => (args || []).reduce((a, b) => Number(a) * Number(b), 1),
    "$math.div": (args: any[]) => (args || []).slice(1).reduce((a, b) => Number(a) / Number(b), Number(args?.[0] ?? 0)),
    "$math.round": (arg: any) => Math.round(Number(Array.isArray(arg) ? arg[0] : arg)),
    "$math.floor": (arg: any) => Math.floor(Number(Array.isArray(arg) ? arg[0] : arg)),
    "$math.ceil": (arg: any) => Math.ceil(Number(Array.isArray(arg) ? arg[0] : arg)),
    "$math.max": (args: any[]) => Math.max(...(args || []).map(Number)),
    "$math.min": (args: any[]) => Math.min(...(args || []).map(Number)),
    "$math.random": () => Math.random(),
  
    // Pack 3 — Date (minimal safe)
    "$date.now": () => new Date().toISOString(),
    "$date.format": (args: any[]) => {
      const [input, fmt] = args || [];
      const d = input ? new Date(input) : new Date();
      if (fmt === "ts" || fmt === "timestamp") return d.getTime();
      if (fmt === "iso" || !fmt) return d.toISOString();
      return d.toLocaleString();
    },
    "$date.addDays": (args: any[]) => {
      const [input, days] = args || [];
      const d = input ? new Date(input) : new Date();
      d.setDate(d.getDate() + Number(days ?? 0));
      return d.toISOString();
    },
  
    // Pack 4 — Array (extended)
    "$array.filter": ({ array, where }: any) => {
      if (!Array.isArray(array) || !where || typeof where !== "object") return [];
      return array.filter((item) => Object.entries(where).every(([k, v]) => item?.[k] === v));
    },
    "$array.map": ({ array, pick }: any) => {
      if (!Array.isArray(array)) return [];
      if (typeof pick === "string") return array.map((x) => x?.[pick]);
      if (typeof pick === "function") return array.map(pick);
      return array;
    },
    "$array.includes": ({ array, value }: any) => Array.isArray(array) ? array.includes(value) : false,
    "$array.length": ({ array }: any) => (Array.isArray(array) ? array.length : 0),
  
    // Pack 5 — Object (extended)
    "$object.keys": ({ object }: any) => (object ? Object.keys(object) : []),
    "$object.values": ({ object }: any) => (object ? Object.values(object) : []),
    "$object.merge": (args: any[]) => Object.assign({}, ...(args || []).filter(Boolean)),
  
    // Pack 6 — Utils
    "$string.upper": (arg: any) => String(Array.isArray(arg) ? arg[0] : arg ?? '').toUpperCase(),
    "$string.lower": (arg: any) => String(Array.isArray(arg) ? arg[0] : arg ?? '').toLowerCase(),
    "$string.trim": (arg: any) => String(Array.isArray(arg) ? arg[0] : arg ?? '').trim(),
    "$number.parse": (arg: any) => Number(Array.isArray(arg) ? arg[0] : arg),
    "$bool": (arg: any) => !!(Array.isArray(arg) ? arg[0] : arg),
    "$env": (key: any, ctx?: any) => {
      const k = Array.isArray(key) ? key[0] : key;
      return ctx?.data?.env ? ctx.data.env[k] : undefined;
    }
  };
  
  // Unified registry
  export const Operators = { ...LyxalOperators, ...OperatorPacks };
  
  // -----------------------------
  // Types
  // -----------------------------
  export type Dict<T = any> = Record<string, T>;
  
  export type VNode = {
    type: string | "component" | "slot" | "loop" | "if";
    props?: Dict;
    children?: VNode[] | string | null;
    // internal metadata after parsing
    __meta__?: {
      isDynamic?: boolean;
      slotName?: string;
      loop?: { each: any[]; as: string };
      condition?: boolean;
    };
  };
  
  export type SlotMap = Record<string, VNode | VNode[]>;
  
  export type FnRegistry = Record<string, (...args: any[]) => any>;
  
  export type Action = { do: string; [k: string]: any };
  
  export interface RenderContext {
    data: Dict;            // { user, props, state, local, computed, env }
    fns?: FnRegistry;      // { "ui.avatar.image": (id) => url }
    actions?: (action: Dict) => Action; // dispatcher
    slots?: SlotMap;       // provided slots
  }
  
  // -----------------------------
  // Safe expression evaluator (no eval)
  // Supports: {{ path.to.value }} and simple pipes like {{ props.count | number }} (extensible)
  // -----------------------------
  const MUSTACHE_RX = /{{\s*([^}]+?)\s*}}/g;
  
  function getPath(obj: any, path: string) {
    return path.split('.').reduce((acc, key) => (acc == null ? undefined : acc[key]), obj);
  }
  
  function resolveExpression(expr: string, ctx: RenderContext) {
    // support pipe syntax a.b.c | json etc. (minimal)
    const [raw, pipe] = expr.split('|').map((s) => s.trim());
    let val: any;
    if (raw.startsWith('$fn:')) {
      // $fn:namespace.name(arg1,arg2)
      const call = raw.slice(4); // remove $fn:
      const m = call.match(/^([\w.]+)\((.*)\)$/);
      const name = m ? m[1] : call;
      const args = m && m[2] ? m[2].split(',').map((s) => decodeArg(s.trim(), ctx)) : [];
      val = ctx.fns?.[name]?.(...args);
    } else {
      val = getPath(ctx.data, raw);
    }
    if (pipe) {
      if (pipe === 'number') val = Number(val);
      if (pipe === 'string') val = String(val);
      if (pipe === 'bool') val = Boolean(val);
    }
    return val;
  }
  
  function decodeArg(token: string, ctx: RenderContext) {
    if (token.startsWith('\"') && token.endsWith('\"')) return token.slice(1, -1);
    if (token === 'true') return true;
    if (token === 'false') return false;
    if (!Number.isNaN(Number(token))) return Number(token);
    // treat as path
    return getPath(ctx.data, token);
  }
  
  function interpolate(input: any, ctx: RenderContext): any {
    // primitives
    if (typeof input === 'string') {
      if (!input.includes('{{')) return input;
      return input.replace(MUSTACHE_RX, (_, expr) => {
        const val = resolveExpression(expr, ctx);
        return val == null ? '' : String(val);
      });
    }
    if (Array.isArray(input)) return input.map((x) => interpolate(x, ctx));
    if (input && typeof input === 'object') {
      // inside interpolate()
      const maybe = runOperatorAuto(input, ctx);
      if (maybe !== null) return maybe;
      // ...continue plain object interpolation

      // 1) Auto operator execution: { "$op": params }
      const keys = Object.keys(input);
      if (keys.length === 1 && keys[0].startsWith('$')) {
        const opName = keys[0];
        const op = (Operators as any)[opName];
        if (op) {
          const rawParams = (input as any)[opName];
          const params = interpolate(rawParams, ctx);
          try {
            // Pass ctx as second arg for operators needing environment
            return op(params, ctx);
          } catch (e) {
            console.error('Operator error', opName, e);
            return null;
          }
        }
      }
      // 2) $fn call object shape { $fn: "namespace.name", args: [..] }
      if ('$fn' in input) {
        const name = (input as any)['$fn'];
        const args = ((input as any)['args'] || []).map((a: any) => interpolate(a, ctx));
        return ctx.fns?.[name]?.(...args);
      }
      // 3) Deep interpolate of plain object
      const out: any = {};
      for (const [k, v] of Object.entries(input)) out[k] = interpolate(v, ctx);
      return out;
    }
    return input;
  }
    if (Array.isArray(input)) return input.map((x) => interpolate(x, ctx));
    if (input && typeof input === 'object') {
      // $fn call object shape { $fn: "namespace.name", args: [..] }
      if ('$fn' in input) {
        const name = input['$fn'];
        const args = (input['args'] || []).map((a: any) => interpolate(a, ctx));
        return ctx.fns?.[name]?.(...args);
      }
      const out: any = {};
      for (const [k, v] of Object.entries(input)) out[k] = interpolate(v, ctx);
      return out;
    }
    return input;
  }
  
  // -----------------------------
  // Parser: JSON -> Intermediate VNode tree (with loops, if, slots resolved)
  // -----------------------------
  export function parseNode(node: any, ctx: RenderContext): VNode | string | null {
    if (node == null) return null;
  
    // Primitive text (with expressions)
    if (typeof node === 'string') return interpolate(node, ctx);
  
    // Arrays map to an array of children VNodes
    if (Array.isArray(node)) {
      const children = node.map((n) => parseNode(n, ctx)).filter(Boolean) as VNode[];
      return { type: 'fragment', children };
    }
  
    // Special nodes: loop / if / slot
    if (node.type === 'loop') {
      const list = interpolate(node.each, ctx) || [];
      const as = node.as || 'item';
      const child = node.child;
      const items: VNode[] = [];
      for (let i = 0; i < list.length; i++) {
        const scope = {
          ...ctx.data,
          [as]: list[i],
          index: i,
        };
        const v = parseNode(child, { ...ctx, data: scope });
        if (v) items.push(v as VNode);
      }
      return { type: 'fragment', children: items };
    }
  
    if (node.type === 'if') {
      const condition = Boolean(interpolate(node.condition, ctx));
      const branch = condition ? node.then : node.else;
      return parseNode(branch, ctx);
    }
  
    if (node.type === 'slot') {
      const name = node.name as string;
      const provided = ctx.slots?.[name];
      if (provided) return parseNode(provided, ctx);
      return parseNode(node.fallback ?? null, ctx);
    }
  
    // Component or native tag
    const out: VNode = {
      type: node.type || (node.component ? 'component' : 'div'),
      props: {},
      children: null,
    };
  
    // props (interpolated)
    if (node.props) {
      const rawProps = interpolate(node.props, ctx);
      // action normalization: map {type: 'alert', ...} -> dispatcher(Action)
      for (const [k, v] of Object.entries(rawProps)) {
        if (k.startsWith('on') && v && typeof v === 'object' && ('type' in (v as any))) {
          const actionObj = v as Dict;
          out.props![k] = () => ctx.actions?.(actionObj);
        } else {
          out.props![k] = v;
        }
      }
    }
  
    // children
    if (node.children) {
      if (typeof node.children === 'string') {
        out.children = interpolate(node.children, ctx);
      } else if (Array.isArray(node.children)) {
        out.children = node.children
          .map((c: any) => parseNode(c, ctx))
          .filter(Boolean) as VNode[];
      } else {
        out.children = [parseNode(node.children, ctx) as VNode].filter(Boolean);
      }
    }
  
    // component mapping: if node.component provided
    if (node.component) {
      out.type = 'component';
      out.props = { ...(out.props || {}), __componentName: node.component };
    }
  
    return out;
  }
  
  // -----------------------------
  // React Renderer for VNode
  // -----------------------------
  import React from 'react';
  
  export type ComponentRegistry = Record<string, React.ComponentType<any>>;
  
  export function renderVNode(v: VNode | string | null, reg: ComponentRegistry): React.ReactNode {
    if (v == null) return null;
    if (typeof v === 'string') return v;
  
    const children = Array.isArray(v.children)
      ? (v.children as VNode[]).map((c) => renderVNode(c, reg))
      : typeof v.children === 'string'
        ? v.children
        : v.children
          ? renderVNode(v.children as VNode, reg)
          : null;
  
    if (v.type === 'fragment') return <>{children}</>;
  
    if (v.type === 'component') {
      const name = v.props?.__componentName as string;
      const Comp = reg[name];
      if (!Comp) return null;
      const { __componentName, ...rest } = v.props || {};
      return <Comp {...rest}>{children}</Comp>;
    }
  
    // native tag
    const Tag: any = v.type;
    return React.createElement(Tag, v.props || {}, children);
  }
  
  // -----------------------------
  // Example: use with circular_menu_pro JSON
  // -----------------------------
  // const json = { type: 'component', component: 'circular_menu_pro', props: { items: [...], radius: 80 } };
  // const ctx: RenderContext = {
  //   data: { user, props: {}, state, local: {}, computed: {} },
  //   fns: {
  //     'ui.circular.position_style': (pos: string) => ({ bottom: '20px', right: '20px' }),
  //   },
  //   actions: (a) => {
  //     switch (a.type) {
  //       case 'alert': return { do: 'alert', message: a.message };
  //       case 'navigation': return { do: 'navigate', url: a.url };
  //       default: return { do: 'custom', payload: a };
  //     }
  //   },
  //   slots: {}
  // };
  // const vtree = parseNode(json, ctx);
  // const reactTree = renderVNode(vtree as VNode, { circular_menu_pro: CircularMenuPro });
  //
  // render(reactTree);
  