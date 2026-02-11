// packages/logic-shared/src/engine/interpolate.ts
import { EngineContext } from './EngineContext.js';
import { resolveOperator } from './resolveOperator.js';

export type ExecuteOperatorFn = (opName: string, params: any, ctx: EngineContext) => any;

const OP_PREFIX = '$';
const MUSTACHE_RE = /\{\{\s*([^}]+?)\s*\}\}/g;               // {{ ... }}
const LITERAL_MUSTACHE_RE = /^\s*\{\{\s*([^}]+?)\s*\}\}\s*$/; // entire string is {{ ... }}

// ---------- Utils
function isPlainObject(v: any) {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

// Unique-key object starting with $
function isOperatorObject(obj: any): { opName: string; params: any } | null {
  if (!isPlainObject(obj)) return null;
  const keys = Object.keys(obj);
  if (keys.length !== 1) return null;
  const k = keys[0];
  if (!k || typeof k !== 'string' || !k.startsWith(OP_PREFIX)) return null;
  return { opName: k, params: obj[k] };
}

// ---------- Inline expression parser: "$ns.name(arg1, arg2, ...)"
// Supports numbers, booleans, null, quoted strings, arrays/objects JSON-like.
function tryParseJsonLoose(token: string): any {
  const t = token.trim();

  // number
  if (/^[+-]?\d+(\.\d+)?$/.test(t)) return Number(t);
  // boolean
  if (t === 'true') return true;
  if (t === 'false') return false;
  // null
  if (t === 'null') return null;

  // quoted string (single or double)
  if ((t.startsWith('"') && t.endsWith('"')) || (t.startsWith("'") && t.endsWith("'"))) {
    return t.slice(1, -1);
  }

  // object/array JSON
  if ((t.startsWith('{') && t.endsWith('}')) || (t.startsWith('[') && t.endsWith(']'))) {
    try {
      return JSON.parse(t);
    } catch {
      // fallthrough
    }
  }

  // fallback = raw string
  return t;
}

function splitArgsPreservingNesting(argsSrc: string): string[] {
  const out: string[] = [];
  let buf = '';
  let depthParen = 0;
  let depthBracket = 0;
  let depthBrace = 0;
  let inSingle = false;
  let inDouble = false;
  for (let i = 0; i < argsSrc.length; i++) {
    const c = argsSrc[i];
    const prev = i > 0 ? argsSrc[i - 1] : '';

    // quotes
    if (!inDouble && c === "'" && prev !== '\\') inSingle = !inSingle;
    else if (!inSingle && c === '"' && prev !== '\\') inDouble = !inDouble;

    if (!inSingle && !inDouble) {
      if (c === '(') depthParen++;
      else if (c === ')') depthParen = Math.max(0, depthParen - 1);
      else if (c === '[') depthBracket++;
      else if (c === ']') depthBracket = Math.max(0, depthBracket - 1);
      else if (c === '{') depthBrace++;
      else if (c === '}') depthBrace = Math.max(0, depthBrace - 1);

      if (c === ',' && depthParen === 0 && depthBracket === 0 && depthBrace === 0) {
        out.push(buf);
        buf = '';
        continue;
      }
    }
    buf += c;
  }
  if (buf.trim().length > 0) out.push(buf);
  return out;
}

function parseInlineCall(expr: string): { opName: string; args: any[] } | null {
  // expr like: $math.add(1, 2)  OR  $date.instance.addDays('2025-01-01', 3)
  const trimmed = expr.trim();
  if (!trimmed.startsWith(OP_PREFIX)) return null;

  const openIdx = trimmed.indexOf('(');
  const closeIdx = trimmed.lastIndexOf(')');
  if (openIdx === -1 || closeIdx === -1 || closeIdx < openIdx) return null;

  const opName = trimmed.slice(0, openIdx).trim();
  if (!opName.startsWith(OP_PREFIX)) return null;

  const argsSrc = trimmed.slice(openIdx + 1, closeIdx);
  const parts = splitArgsPreservingNesting(argsSrc);
  const args = parts.map((p) => tryParseJsonLoose(p));
  return { opName, args };
}

// ---------- Core interpolation
export function interpolate(input: any, ctx: EngineContext, execOp: ExecuteOperatorFn): any {
  if (input == null) return input;

  // arrays
  if (Array.isArray(input)) {
    return input.map((v) => interpolate(v, ctx, execOp));
  }

  // operator object (Style A)
  const opObj = isOperatorObject(input);
  if (opObj) {
    const { opName, params } = opObj;
    const resolved = resolveOperator(opName, ctx);
    if (!resolved) {
      if (ctx.config.strictOperators) {
        throw new Error(`Unknown operator: ${opName}`);
      }
      return input; // passthrough if not strict
    }
    return execOp(opName, interpolate(params, ctx, execOp), ctx);
  }

  // plain objects
  if (isPlainObject(input)) {
    const out: Record<string, any> = {};
    for (const [k, v] of Object.entries(input)) {
      out[k] = interpolate(v, ctx, execOp);
    }
    return out;
  }

  // strings → inline operators (Style B)
  if (typeof input === 'string') {
    // LITERAL form: whole string is {{ ... }}
    const literalMatch = input.match(LITERAL_MUSTACHE_RE);
    if (literalMatch) {
      const expr = literalMatch[1]?.trim() ?? '';
      const parsed = parseInlineCall(expr);
      if (!parsed) return input; // not an op call → leave as-is
      const resolved = resolveOperator(parsed.opName, ctx);
      if (!resolved) {
        if (ctx.config.strictOperators) {
          throw new Error(`Unknown operator: ${parsed.opName}`);
        }
        return input;
      }
      return execOp(parsed.opName, parsed.args, ctx);
    }

    // TEMPLATE form: "Hello {{ $op(...) }} world"
    let changed = false;
    const pieces: string[] = [];
    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = MUSTACHE_RE.exec(input)) !== null) {
      const raw = match[0];
      const inner = match[1]?.trim() ?? '';
      const parsed = parseInlineCall(inner);
      if (!parsed) continue;

      // push text chunk before match
      if (match.index > lastIndex) {
        pieces.push(input.slice(lastIndex, match.index));
      }

      const resolved = resolveOperator(parsed.opName, ctx);
      if (!resolved) {
        if (ctx.config.strictOperators) {
          throw new Error(`Unknown operator: ${parsed.opName}`);
        }
        // if unknown and non-strict → keep raw mustache
        pieces.push(raw);
      } else {
        const value = execOp(parsed.opName, parsed.args, ctx);
        pieces.push(String(value));
        changed = true;
      }
      lastIndex = match.index + raw.length;
    }

    if (changed) {
      if (lastIndex < input.length) pieces.push(input.slice(lastIndex));
      return pieces.join('');
    }
    return input;
  }

  // other scalars
  return input;
}
