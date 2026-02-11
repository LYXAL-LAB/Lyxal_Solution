/* 
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: metaContext.ts
 * Rôle: Construction du contexte d’exécution multi-scope et multi-tenant
 */

import {
    MetaContext,
    MetaStateScopes,
    MetaServices,
    MetaUser,
    RuntimeKind,
    TenantId,
    NamespaceId,
    LogicPolicy,
    TraceId,
  } from './types';
  
  export interface CreateMetaContextInput {
    runtime: RuntimeKind;                // 'ui' | 'backend'
    tenantId: TenantId;
    namespaceId: NamespaceId;
    user?: MetaUser;
    state?: MetaStateScopes;
    services?: MetaServices;
    policy?: LogicPolicy;
    registry?: MetaContext['registry'];
    traceId?: TraceId;
    options?: MetaContext['options'];
  }
  
  export function createMetaContext(input: CreateMetaContextInput): MetaContext {
    const {
      runtime,
      tenantId,
      namespaceId,
      user,
      state,
      services,
      policy,
      registry,
      traceId,
      options,
    } = input;
  
    const ctx: MetaContext = {
      runtime,
      tenantId,
      namespaceId,
      user: user ?? {},
      state: normalizeState(state),
      services: services ?? {},
      policy,
      registry: registry ?? {},
      traceId: traceId ?? generateTraceId(),
      options: {
        env: options?.env ?? 'dev',
        strict: options?.strict ?? false,
        logErrors: options?.logErrors ?? true,
        timeouts: {
          stepMs: options?.timeouts?.stepMs ?? 5000,
          flowMs: options?.timeouts?.flowMs ?? 20000,
        },
      },
    };
  
    return ctx;
  }
  
  /**
   * Normalise/Initialise les scopes pour éviter les undefined et permettre extension future (X2 adaptative)
   */
  function normalizeState(state?: MetaStateScopes): MetaStateScopes {
    return {
      global: state?.global ?? {},
      flow: state?.flow ?? {},
      step: state?.step ?? {},
      session: state?.session ?? {},
      ui: state?.ui ?? {},
    };
  }
  
  /** Génère un traceId simplifié (UUID-like, version légère) */
  function generateTraceId(): string {
    const rnd = Math.random().toString(36).substring(2, 10);
    const ts = Date.now().toString(36);
    return `trace_${ts}_${rnd}`;
  }
  