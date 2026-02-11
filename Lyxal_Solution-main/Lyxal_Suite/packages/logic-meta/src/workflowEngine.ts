/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: workflowEngine.ts (FULL — Part 2/2)
 * Rôle: Exécution complète des workflows déclaratifs:
 *       - kind: action, condition, switch, loop, parallel, wait, call, subflow
 *       - Hybrid Smart State (snapshot pre-step + rollback pour fallback)
 *       - Observabilité (spans, trace locale)
 *       - Hooks IA (suggest sur erreurs)
 */

import {
    JsonValue,
    MetaContext,
    Observability,
    OperatorCall,
    StepResult,
    WorkflowEngine as IWorkflowEngine,
    WorkflowResult,
    LogicStep,
    LogicVersion,
    SpanRecord,
    LogLevel,
    AiHooks,
    StepConfig,
  } from './types';
  import { MetaParser } from './metaParser';
  
  /* -----------------------------
   * Utils: spans & snapshots
   * ----------------------------- */
  
  function now(): number {
    return Date.now();
  }
  
  function clone<T>(v: T): T {
    return JSON.parse(JSON.stringify(v));
  }
  
  function emitSpan(
    obs: Observability | undefined,
    span: Omit<SpanRecord, 'spanId' | 'traceId' | 't'> & Partial<Pick<SpanRecord, 'spanId' | 'traceId' | 't'>>
  ) {
    if (!obs) return;
    const record: SpanRecord = {
      spanId: span.spanId ?? obs.newSpanId(),
      traceId: span.traceId ?? obs.newTraceId(),
      t: span.t ?? now(),
      level: span.level as LogLevel,
      message: span.message,
      data: span.data,
      workflowId: span.workflowId,
      versionId: span.versionId,
      stepId: span.stepId,
      stepKey: span.stepKey,
    };
    obs.emit(record);
  }
  
  function safeLogData(data: any) {
    try {
      return typeof data === 'object' ? JSON.parse(JSON.stringify(data)) : data;
    } catch {
      return '[unserializable]';
    }
  }
  
  /* -----------------------------
   * Operator execution wrapper
   * ----------------------------- */
  
  async function runOperator(
    parser: MetaParser,
    op: OperatorCall,
    ctx: MetaContext,
    location: string
  ): Promise<any> {
    // Le MetaParser exécute l’opérateur en résolvant bindings + sécurité.
    const { output, errors } = parser.parse({ [parser['opts'].operatorPrefix + op.op]: op.params }, location);
    if (errors.length) {
      const messages = errors.map((e) => (e instanceof Error ? e.message : String(e))).join('; ');
      throw new Error(`Operator parse error: ${messages}`);
    }
    const keys = Object.keys(output || {});
    if (keys.length === 1 && keys[0].startsWith(parser['opts'].operatorPrefix)) {
      return output[keys[0]];
    }
    return output;
  }
  
  /* -----------------------------
   * Expressions helpers
   * ----------------------------- */
  
  function truthy(v: any): boolean {
    return !!v;
  }
  
  /** Évalue une expression/valeur via le parser (permet bindings dans 'when', 'test', etc.) */
  function evalExpr<T = any>(parser: MetaParser, expr: any, ctx: MetaContext, location: string): T {
    const { output, errors } = parser.parse(expr, location);
    if (errors.length) {
      const messages = errors.map((e) => (e instanceof Error ? e.message : String(e))).join('; ');
      throw new Error(`Expression parse error at ${location}: ${messages}`);
    }
    return output as T;
  }
  
  /* -----------------------------
   * Step runners
   * ----------------------------- */
  
  async function runActionStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs } = args;
    const cfg = step.config as any; // ActionStepConfig
    const ops = (cfg?.ops ?? []) as OperatorCall[];
  
    // Snapshots pré-étape
    const preSnapshot = {
      flow: clone(ctx.state?.flow ?? {}),
      step: clone(ctx.state?.step ?? {}),
    };
  
    try {
      // Filtre when
      if (cfg?.when !== undefined) {
        const cond = evalExpr<boolean>(parser, cfg.when, ctx, `step(${step.key}).when`);
        if (!truthy(cond)) {
          emitSpan(obs, {
            level: 'debug',
            message: `Step "${step.key}" skipped by when=false`,
            versionId: step.versionId,
            stepId: step.id,
            stepKey: step.key,
          });
          return { ok: true, value: undefined, nextKey: nextSuccess(cfg) };
        }
      }
  
      let lastValue: any = undefined;
      for (let i = 0; i < ops.length; i++) {
        const op = ops[i];
  
        emitSpan(obs, {
          level: 'debug',
          message: `Run operator ${op.op}`,
          data: { index: i, params: safeLogData(op.params) },
          versionId: step.versionId,
          stepId: step.id,
          stepKey: step.key,
        });
  
        lastValue = await runOperator(parser, op, ctx, `step(${step.key}).ops[${i}]`);
  
        if (cfg?.assign) {
          ctx.state = ctx.state || {};
          ctx.state.step = ctx.state.step || {};
          (ctx.state.step as any)[cfg.assign] = lastValue;
        }
      }
  
      emitSpan(obs, {
        level: 'info',
        message: `Step "${step.key}" succeeded`,
        data: { lastValue, next: nextSuccess(cfg) },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
  
      return { ok: true, value: lastValue, nextKey: nextSuccess(cfg) };
    } catch (err: any) {
      if (cfg?.onError === 'fallback') {
        ctx.state = ctx.state || {};
        ctx.state.flow = preSnapshot.flow;
        ctx.state.step = preSnapshot.step;
  
        emitSpan(obs, {
          level: 'warn',
          message: `Step "${step.key}" failed, fallback applied`,
          data: { error: String(err), fallbackValue: cfg.fallbackValue },
          versionId: step.versionId,
          stepId: step.id,
          stepKey: step.key,
        });
  
        return { ok: true, value: cfg.fallbackValue, nextKey: nextSuccess(cfg) };
      }
  
      emitSpan(obs, {
        level: 'error',
        message: `Step "${step.key}" failed`,
        data: { error: err?.message ?? String(err) },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
  
      if (cfg?.onError === 'silent' || cfg?.onError === 'warn') {
        return { ok: false, error: err, nextKey: nextFailure(cfg) };
      }
      throw err;
    }
  }
  
  async function runConditionStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs } = args;
    const cfg = step.config as any; // ConditionStepConfig
    try {
      const test = evalExpr<boolean>(parser, cfg.test, ctx, `step(${step.key}).test`);
      const nextKey = truthy(test) ? cfg.next?.then : cfg.next?.else;
  
      emitSpan(obs, {
        level: 'info',
        message: `Condition "${step.key}" => ${truthy(test) ? 'then' : 'else'}`,
        data: { test: !!test, nextKey },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
  
      return { ok: true, nextKey };
    } catch (err: any) {
      return handleStepError('condition', step, err, cfg, ctx, obs);
    }
  }
  
  async function runSwitchStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs } = args;
    const cfg = step.config as any; // SwitchStepConfig
    try {
      for (const c of cfg.cases ?? []) {
        const ok = evalExpr<boolean>(parser, c.when, ctx, `step(${step.key}).case.when`);
        if (truthy(ok)) {
          emitSpan(obs, {
            level: 'info',
            message: `Switch "${step.key}" matched`,
            data: { goto: c.goto },
            versionId: step.versionId,
            stepId: step.id,
            stepKey: step.key,
          });
          return { ok: true, nextKey: c.goto };
        }
      }
      const nextKey = cfg.default;
      emitSpan(obs, {
        level: 'info',
        message: `Switch "${step.key}" default`,
        data: { goto: nextKey },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
      return { ok: true, nextKey };
    } catch (err: any) {
      return handleStepError('switch', step, err, cfg, ctx, obs);
    }
  }
  
  async function runLoopStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
    map: Map<string, LogicStep>;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs, map } = args;
    const cfg = step.config as any; // LoopStepConfig
  
    // Snapshot
    const preSnapshot = {
      flow: clone(ctx.state?.flow ?? {}),
      step: clone(ctx.state?.step ?? {}),
    };
  
    try {
      const list = evalExpr<any[]>(parser, cfg.each, ctx, `step(${step.key}).each`) || [];
      const asKey = cfg.as || 'item';
      const bodyKey = cfg.body;
  
      emitSpan(obs, {
        level: 'debug',
        message: `Loop "${step.key}" over ${list.length} items`,
        data: { as: asKey, body: bodyKey },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
  
      for (let i = 0; i < list.length; i++) {
        ctx.state = ctx.state || {};
        ctx.state.step = ctx.state.step || {};
        (ctx.state.step as any)[asKey] = list[i];
        (ctx.state.step as any)[`${asKey}Index`] = i;
  
        // Exécuter la sous-étape body (si elle existe)
        if (bodyKey) {
          await runSingleStepByKey(map, bodyKey, ctx, parser, obs);
        }
      }
  
      return { ok: true, nextKey: cfg.next };
    } catch (err: any) {
      // Fallback
      if (cfg?.onError === 'fallback') {
        ctx.state = ctx.state || {};
        ctx.state.flow = preSnapshot.flow;
        ctx.state.step = preSnapshot.step;
        emitSpan(obs, {
          level: 'warn',
          message: `Loop "${step.key}" failed, fallback`,
          data: { error: String(err) },
          versionId: step.versionId,
          stepId: step.id,
          stepKey: step.key,
        });
        return { ok: true, value: cfg.fallbackValue, nextKey: cfg.next };
      }
      emitSpan(obs, {
        level: 'error',
        message: `Loop "${step.key}" failed`,
        data: { error: String(err) },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
      if (cfg?.onError === 'silent' || cfg?.onError === 'warn') return { ok: false, error: err, nextKey: cfg.next };
      throw err;
    }
  }
  
  async function runParallelStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
    map: Map<string, LogicStep>;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs, map } = args;
    const cfg = step.config as any; // ParallelStepConfig
  
    emitSpan(obs, {
      level: 'debug',
      message: `Parallel "${step.key}" start`,
      data: { branches: (cfg.branches ?? []).map((b: any) => b.key) },
      versionId: step.versionId,
      stepId: step.id,
      stepKey: step.key,
    });
  
    const promises = (cfg.branches ?? []).map(async (b: any) => {
      try {
        await runSingleStepByKey(map, b.start, ctx, parser, obs);
        return { key: b.key, ok: true };
      } catch (e: any) {
        return { key: b.key, ok: false, error: e };
      }
    });
  
    const results = cfg.join === 'race' ? await Promise.race([Promise.all(promises)]) : await Promise.all(promises);
  
    const allOk = results.every((r: any) => r.ok);
    const anyOk = results.some((r: any) => r.ok);
  
    const success =
      cfg.join === 'all' ? allOk :
      cfg.join === 'any' ? anyOk :
      cfg.join === 'race' ? anyOk :
      /* allSettled */ true;
  
    emitSpan(obs, {
      level: success ? 'info' : 'warn',
      message: `Parallel "${step.key}" done`,
      data: { results: safeLogData(results), success },
      versionId: step.versionId,
      stepId: step.id,
      stepKey: step.key,
    });
  
    return { ok: success, nextKey: success ? cfg.next?.success : cfg.next?.failure };
  }
  
  async function runWaitStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs } = args;
    const cfg = step.config as any; // WaitStepConfig
    try {
      const ms = typeof cfg.for === 'number'
        ? cfg.for
        : Number(evalExpr<any>(parser, cfg.for, ctx, `step(${step.key}).for`));
      await new Promise((r) => setTimeout(r, isFinite(ms) ? ms : 0));
  
      emitSpan(obs, {
        level: 'debug',
        message: `Wait "${step.key}" ${ms}ms`,
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
  
      return { ok: true, nextKey: cfg.next };
    } catch (err: any) {
      return handleStepError('wait', step, err, cfg, ctx, obs);
    }
  }
  
  async function runCallStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs } = args;
    const cfg = step.config as any; // CallStepConfig
    try {
      const value = await runOperator(parser, cfg.op, ctx, `step(${step.key}).op`);
      if (cfg.assign) {
        ctx.state = ctx.state || {};
        ctx.state.step = ctx.state.step || {};
        (ctx.state.step as any)[cfg.assign] = value;
      }
      emitSpan(obs, {
        level: 'info',
        message: `Call "${step.key}" ok`,
        data: { assign: cfg.assign },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
      return { ok: true, value, nextKey: cfg.next };
    } catch (err: any) {
      return handleStepError('call', step, err, cfg, ctx, obs);
    }
  }
  
  async function runSubflowStep(args: {
    step: LogicStep;
    ctx: MetaContext;
    parser: MetaParser;
    obs?: Observability;
    runWorkflow: (input: {
      context: MetaContext;
      version: LogicVersion;
      steps: LogicStep[];
      entryKey?: string;
      inputPayload?: JsonValue;
      observability?: Observability;
    }) => Promise<WorkflowResult>;
    resolveVersionByRef: (ref: any) => Promise<{ version: LogicVersion; steps: LogicStep[] }>;
  }): Promise<StepResult> {
    const { step, ctx, parser, obs, runWorkflow, resolveVersionByRef } = args;
    const cfg = step.config as any; // SubflowStepConfig
  
    try {
      const { version, steps } = await resolveVersionByRef(cfg.subflow);
      const inputPayload = cfg.input ? evalExpr<JsonValue>(parser, cfg.input, ctx, `step(${step.key}).input`) : undefined;
  
      emitSpan(obs, {
        level: 'debug',
        message: `Subflow "${step.key}" -> v${version.number}`,
        data: { workflowId: version.workflowId, versionId: version.id },
        versionId: step.versionId,
        stepId: step.id,
        stepKey: step.key,
      });
  
      const res = await runWorkflow({
        context: ctx,
        version,
        steps,
        inputPayload,
        observability: obs,
      });
  
      if (!res.ok) throw new Error(res.error ?? 'Subflow error');
  
      if (cfg.assign) {
        ctx.state = ctx.state || {};
        ctx.state.step = ctx.state.step || {};
        (ctx.state.step as any)[cfg.assign] = res.output;
      }
  
      return { ok: true, value: res.output, nextKey: cfg.next };
    } catch (err: any) {
      return handleStepError('subflow', step, err, cfg, ctx, obs);
    }
  }
  
  /* -----------------------------
   * Erreurs & IA hooks
   * ----------------------------- */
  
  function nextSuccess(cfg: any): string | undefined {
    return cfg?.next?.success;
  }
  function nextFailure(cfg: any): string | undefined {
    return cfg?.next?.failure;
  }
  
  async function handleStepError(
    kind: string,
    step: LogicStep,
    err: any,
    cfg: any,
    ctx: MetaContext,
    obs?: Observability
  ): Promise<StepResult> {
    emitSpan(obs, {
      level: 'error',
      message: `Step "${step.key}" (${kind}) failed`,
      data: { error: String(err) },
      versionId: step.versionId,
      stepId: step.id,
      stepKey: step.key,
    });
  
    // IA hook (non bloquant)
    const ai: AiHooks | undefined = (ctx as any).aiHooks;
    if (ai?.suggest) {
      try {
        await ai.suggest({
          context: ctx,
          version: { id: step.versionId, workflowId: '' } as any, // si besoin, enrichir resolve
          step,
          signal: 'fix',
          snapshot: { state: ctx.state, error: String(err) },
        });
      } catch {
        // ignore suggestion errors
      }
    }
  
    if (cfg?.onError === 'fallback') {
      // snapshot/rollback géré au cas par cas (action/loop l'ont fait),
      // ici on renvoie juste fallback si présent
      return { ok: true, value: cfg.fallbackValue, nextKey: nextSuccess(cfg) };
    }
  
    if (cfg?.onError === 'silent' || cfg?.onError === 'warn') {
      return { ok: false, error: err, nextKey: nextFailure(cfg) };
    }
  
    throw err;
  }
  
  /* -----------------------------
   * Engine
   * ----------------------------- */
  
  export class WorkflowEngine implements IWorkflowEngine {
    constructor(
      private opts?: {
        observability?: Observability;
        aiHooks?: AiHooks;
        resolveVersionByRef?: (ref: any) => Promise<{ version: LogicVersion; steps: LogicStep[] }>;
      }
    ) {}
  
    async run(input: {
      context: MetaContext;
      version: LogicVersion;
      steps: LogicStep[];
      entryKey?: string;
      inputPayload?: JsonValue;
      observability?: Observability; // override optionnel
    }): Promise<WorkflowResult> {
      const { context, version, steps, entryKey, inputPayload } = input;
  
      // Brancher IA hooks dans le contexte si fournis
      if (this.opts?.aiHooks) (context as any).aiHooks = this.opts.aiHooks;
  
      // Observability
      const obs = input.observability ?? this.opts?.observability;
      const traceId = context.traceId;
      const trace: Array<SpanRecord> = [];
      const localObs: Observability | undefined = obs && {
        ...obs,
        emit: (span) => {
          trace.push({
            ...span,
            traceId: span.traceId ?? traceId ?? obs.newTraceId(),
            t: span.t ?? now(),
          });
          return obs.emit(span);
        },
      };
  
      // Parser par exécution
      const parser = new MetaParser(context);
  
      // Index steps
      const map = new Map<string, LogicStep>();
      for (const s of steps) map.set(s.key, s);
  
      // Entry step
      let currentKey =
        entryKey ??
        steps
          .slice()
          .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
          .at(0)?.key;
  
      if (!currentKey) {
        return { ok: false, error: 'No entry step.', versionId: version.id };
      }
  
      // Init state.flow
      context.state = context.state || {};
      context.state.flow = context.state.flow || {};
      if (inputPayload !== undefined) {
        (context.state.flow as any).input = inputPayload;
      }
  
      try {
        while (currentKey) {
          const step = map.get(currentKey);
          if (!step) throw new Error(`Unknown step key "${currentKey}"`);
  
          const cfg = step.config as StepConfig | undefined;
  
          // Pre-step observability
          emitSpan(localObs, {
            level: 'debug',
            message: `Enter step "${step.key}"`,
            data: { kind: cfg?.kind },
            versionId: version.id,
            stepId: step.id,
            stepKey: step.key,
          });
  
          // Route par type
          let res: StepResult;
  
          switch (cfg?.kind) {
            case 'action':
              res = await runActionStep({ step, ctx: context, parser, obs: localObs });
              break;
            case 'condition':
              res = await runConditionStep({ step, ctx: context, parser, obs: localObs });
              break;
            case 'switch':
              res = await runSwitchStep({ step, ctx: context, parser, obs: localObs });
              break;
            case 'loop':
              res = await runLoopStep({ step, ctx: context, parser, obs: localObs, map });
              break;
            case 'parallel':
              res = await runParallelStep({ step, ctx: context, parser, obs: localObs, map });
              break;
            case 'wait':
              res = await runWaitStep({ step, ctx: context, parser, obs: localObs });
              break;
            case 'call':
              res = await runCallStep({ step, ctx: context, parser, obs: localObs });
              break;
            case 'subflow':
              res = await runSubflowStep({
                step,
                ctx: context,
                parser,
                obs: localObs,
                runWorkflow: (args) => this.run(args),
                resolveVersionByRef:
                  this.opts?.resolveVersionByRef ??
                  (async () => {
                    throw new Error('resolveVersionByRef not implemented');
                  }),
              });
              break;
            default:
              // Step sans kind => on saute à la suivante par ordre
              emitSpan(localObs, {
                level: 'warn',
                message: `Unsupported or missing kind, skipping`,
                data: { stepKey: step.key, kind: cfg?.kind },
                versionId: version.id,
                stepId: step.id,
                stepKey: step.key,
              });
              res = { ok: true, nextKey: nextByOrder(map, step)?.key };
          }
  
          // Next key
          if (res.nextKey !== undefined) {
            currentKey = res.nextKey;
          } else {
            const next = nextByOrder(map, step);
            currentKey = next?.key ?? null as any;
          }
        }
  
        emitSpan(localObs, {
          level: 'info',
          message: 'Workflow finished',
          data: { ok: true },
          versionId: version.id,
        });
  
        return {
          ok: true,
          output: (context.state?.flow as any)?.output ?? undefined,
          trace,
          versionId: version.id,
        };
      } catch (err: any) {
        emitSpan(localObs, {
          level: 'error',
          message: 'Workflow failed',
          data: { error: err?.message ?? String(err) },
          versionId: version.id,
        });
  
        // IA suggest globale sur échec de flow (non bloquant)
        const ai: AiHooks | undefined = (context as any).aiHooks;
        if (ai?.suggest) {
          try {
            await ai.suggest({
              context,
              version,
              signal: 'fix',
              snapshot: { state: context.state, error: String(err) },
            });
          } catch { /* ignore */ }
        }
  
        return {
          ok: false,
          error: err?.message ?? String(err),
          trace,
          versionId: version.id,
        };
      }
    }
  }
  
  /* -----------------------------
   * Helpers
   * ----------------------------- */
  
  function nextByOrder(map: Map<string, LogicStep>, current: LogicStep): LogicStep | undefined {
    const steps = [...map.values()].sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
    const idx = steps.findIndex((s) => s.key === current.key);
    return idx >= 0 ? steps[idx + 1] : undefined;
  }
  