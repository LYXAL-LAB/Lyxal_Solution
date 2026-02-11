/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: observability.ts
 * Rôle: Observabilité hybride (console + buffer mémoire + SurrealDB via MetaContext.services.surreal)
 *
 * - Génère traceId/spanId
 * - Filtrage par niveau
 * - Buffer circulaire en RAM
 * - Insert SurrealDB non-bloquant (fail-soft)
 * - Schéma mixte: colonnes indexables + raw JSON (option C)
 */

import {
    Observability,
    SpanRecord,
    LogLevel,
    MetaContext,
  } from './types';
  
  /* -----------------------------
   * ID generators
   * ----------------------------- */
  function randBase36(n = 8) {
    return Math.random().toString(36).slice(2, 2 + n);
  }
  export function newTraceId(): string {
    return `tr_${Date.now().toString(36)}_${randBase36(10)}`;
  }
  export function newSpanId(): string {
    return `sp_${Date.now().toString(36)}_${randBase36(6)}`;
  }
  
  /* -----------------------------
   * Console helpers
   * ----------------------------- */
  const levelOrder: Record<LogLevel, number> = {
    debug: 10,
    info: 20,
    warn: 30,
    error: 40,
    fatal: 50,
  };
  
  function consolePrint(span: SpanRecord) {
    const prefix = `[${span.level.toUpperCase()}]`;
    const wf = span.workflowId ? `[wf:${span.workflowId}]` : '';
    const st = span.stepKey ? `[step:${span.stepKey}]` : '';
    const msg = `${prefix}${wf}${st} ${span.message}`;
    const data = span.data ? span.data : undefined;
  
    switch (span.level) {
      case 'debug':
      case 'info':
        data ? console.log(msg, data) : console.log(msg);
        break;
      case 'warn':
        data ? console.warn(msg, data) : console.warn(msg);
        break;
      case 'error':
      case 'fatal':
        data ? console.error(msg, data) : console.error(msg);
        break;
    }
  }
  
  /* -----------------------------
   * Surreal schema ensure (lazy)
   * ----------------------------- */
  async function ensureSurrealSchema(ctx: MetaContext) {
    const surreal = ctx.services?.surreal;
    if (!surreal?.query) return;
  
    // Schéma minimal "system_log" (id auto), + raw JSON
    // - level, message, t (epoch ms), traceId, spanId
    // - workflowId, versionId, stepId, stepKey
    // - data (ANY)  + raw (ANY) pour conserver la forme complète
    const ddl = `
      DEFINE TABLE IF NOT EXISTS system_log TYPE NORMAL SCHEMAFULL;
  
      DEFINE FIELD IF NOT EXISTS level      ON TABLE system_log TYPE string ASSERT $value IN ["debug","info","warn","error","fatal"];
      DEFINE FIELD IF NOT EXISTS message    ON TABLE system_log TYPE string;
      DEFINE FIELD IF NOT EXISTS t          ON TABLE system_log TYPE number;
      DEFINE FIELD IF NOT EXISTS traceId    ON TABLE system_log TYPE string;
      DEFINE FIELD IF NOT EXISTS spanId     ON TABLE system_log TYPE string;
  
      DEFINE FIELD IF NOT EXISTS workflowId ON TABLE system_log TYPE string;
      DEFINE FIELD IF NOT EXISTS versionId  ON TABLE system_log TYPE string;
      DEFINE FIELD IF NOT EXISTS stepId     ON TABLE system_log TYPE string;
      DEFINE FIELD IF NOT EXISTS stepKey    ON TABLE system_log TYPE string;
  
      DEFINE FIELD IF NOT EXISTS data       ON TABLE system_log TYPE any;
      DEFINE FIELD IF NOT EXISTS raw        ON TABLE system_log TYPE any;
  
      DEFINE INDEX IF NOT EXISTS idx_system_log_trace   ON TABLE system_log COLUMNS traceId;
      DEFINE INDEX IF NOT EXISTS idx_system_log_level   ON TABLE system_log COLUMNS level;
      DEFINE INDEX IF NOT EXISTS idx_system_log_time    ON TABLE system_log COLUMNS t;
      DEFINE INDEX IF NOT EXISTS idx_system_log_wfk     ON TABLE system_log COLUMNS workflowId, stepKey;
    `;
    try {
      await surreal.query(ddl);
    } catch {
      // Ne casse jamais le flux si DDL échoue (permissions, etc.)
    }
  }
  
  /* -----------------------------
   * DefaultObservabilityHybrid
   * ----------------------------- */
  export type ObservabilityConfig = {
    /** Niveau minimum envoyé (console + buffer + db). Default: 'debug' en dev, 'info' en prod */
    minLevel?: LogLevel;
    /** Taille du buffer circulaire en RAM. Default: 200 */
    bufferSize?: number;
    /** Activer console printing. Default: true */
    console?: boolean;
    /** Activer persistance SurrealDB. Default: true */
    surreal?: boolean;
  };
  
  export class DefaultObservabilityHybrid implements Observability {
    private _buffer: SpanRecord[] = [];
    private _busy = false;
    private _queue: SpanRecord[] = [];
    private _minLevel: LogLevel;
    private _bufSize: number;
    private _useConsole: boolean;
    private _useSurreal: boolean;
    private _schemaEnsured = false;
    private _ctxProvider: () => MetaContext | undefined;
  
    constructor(getContext: () => MetaContext | undefined, cfg?: ObservabilityConfig) {
      this._ctxProvider = getContext;
      const env = getContext()?.options?.env ?? 'dev';
  
      this._minLevel = cfg?.minLevel ?? (env === 'dev' ? 'debug' : 'info');
      this._bufSize = cfg?.bufferSize ?? 200;
      this._useConsole = cfg?.console ?? true;
      this._useSurreal = cfg?.surreal ?? true;
    }
  
    newSpanId() {
      return newSpanId();
    }
    newTraceId() {
      return newTraceId();
    }
  
    emit(span: SpanRecord): void {
      // Filtrage par niveau
      if (levelOrder[span.level] < levelOrder[this._minLevel]) return;
  
      // Normalisation time/ids
      if (!span.t) span.t = Date.now();
      if (!span.spanId) span.spanId = this.newSpanId();
      if (!span.traceId) span.traceId = this.newTraceId();
  
      // Console
      if (this._useConsole) {
        try { consolePrint(span); } catch { /* ignore */ }
      }
  
      // Buffer circulaire
      this._buffer.push(span);
      if (this._buffer.length > this._bufSize) this._buffer.shift();
  
      // Enqueue pour Surreal
      if (this._useSurreal) {
        this._queue.push(span);
        // Fire-and-forget
        this._drain().catch(() => { /* ignore */ });
      }
    }
  
    /** Récupère une copie du buffer courant (pour debug API / UI) */
    getBuffer(): SpanRecord[] {
      return [...this._buffer];
    }
  
    /** Drain asynchrone de la file vers Surreal */
    private async _drain() {
      if (this._busy) return;
      const ctx = this._ctxProvider?.();
      const surreal = ctx?.services?.surreal;
      if (!surreal?.query) return;
  
      this._busy = true;
      try {
        if (!this._schemaEnsured) {
          await ensureSurrealSchema(ctx!);
          this._schemaEnsured = true;
        }
  
        // On vide tout d’un coup (batch insert)
        const batch: SpanRecord[] = this._queue.splice(0, this._queue.length);
        if (batch.length === 0) return;
  
        // Insert multi-values (plus stable sur Surreal Cloud: INSERT INTO <table> CONTENT <json>)
        // On stocke à la fois champs structurés + raw complet
        const values = batch.map((s) => ({
          level: s.level,
          message: s.message,
          t: s.t,
          traceId: s.traceId,
          spanId: s.spanId,
          workflowId: s.workflowId ?? null,
          versionId: s.versionId ?? null,
          stepId: s.stepId ?? null,
          stepKey: s.stepKey ?? null,
          data: s.data ?? null,
          raw: s, // RAW ENTIER
        }));
  
        // On évite les variables bind pour la compatibilité: on compose un JSON propre
        const payload = JSON.stringify(values);
        const sql = `INSERT INTO system_log ${payload}`;
        await surreal.query(sql);
      } catch {
        // Fail-soft: on ne rejette pas, la console et le buffer sont déjà servis.
      } finally {
        this._busy = false;
      }
    }
  }
  
  /* -----------------------------
   * Noop implementation
   * ----------------------------- */
  export class NoopObservability implements Observability {
    newSpanId() { return newSpanId(); }
    newTraceId() { return newTraceId(); }
    emit(_: SpanRecord) { /* noop */ }
  }
  
  /* -----------------------------
   * Factory
   * ----------------------------- */
  export function createObservability(
    getContext: () => MetaContext | undefined,
    cfg?: ObservabilityConfig
  ): Observability {
    // Si pas de Surreal dans le contexte, on downgrade en console/buffer-only automatiquement.
    const ctx = getContext();
    const hasSurreal = !!ctx?.services?.surreal?.query;
  
    const useHybrid = cfg?.surreal ?? hasSurreal;
    if (!useHybrid && (cfg?.console ?? true)) {
      // Pas de Surreal => console + buffer seulement
      return new DefaultObservabilityHybrid(getContext, { ...cfg, surreal: false });
    }
    return new DefaultObservabilityHybrid(getContext, cfg);
  }
  