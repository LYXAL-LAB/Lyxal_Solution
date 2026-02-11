/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: types.ts
 * Rôle: Types & interfaces de base pour le moteur logique méta
 *       (workflows, steps, exécution, observabilité, IA).
 */

/* -------------------------------------------------
 * JSON
 * ------------------------------------------------- */
export type JsonPrimitive = string | number | boolean | null;
export type JsonValue = JsonPrimitive | JsonObject | JsonArray;
export interface JsonObject { [k: string]: JsonValue }
export interface JsonArray extends Array<JsonValue> {}

/* -------------------------------------------------
 * Identités & Runtime
 * ------------------------------------------------- */
export type RuntimeKind = 'ui' | 'backend';
export type TenantId = string;          // record<tenant> id
export type NamespaceId = string;       // record<logic_namespace> id
export type WorkflowId = string;        // record<logic_workflow> id
export type VersionId = string;         // record<logic_version> id
export type StepId = string;            // record<logic_step> id
export type PluginId = string;          // record<logic_plugin> id
export type PolicyId = string;          // record<logic_policy> id

/** ID de corrélation d'une exécution (request, job, interaction) */
export type TraceId = string;
/** ID de sous-étape / segment */
export type SpanId = string;

/* -------------------------------------------------
 * Logs & Observabilité
 * ------------------------------------------------- */
export type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'fatal';

export interface SpanRecord {
  spanId: SpanId;
  traceId: TraceId;
  level: LogLevel;
  message: string;
  data?: any;
  workflowId?: WorkflowId;
  versionId?: VersionId;
  stepId?: StepId;
  stepKey?: string;
  t: number; // epoch ms
}

/** API Observability minimale */
export interface Observability {
  /** Crée un span/log */
  emit: (span: SpanRecord) => void | Promise<void>;
  /** Génère un nouveau spanId */
  newSpanId: () => SpanId;
  /** Génère un nouveau traceId (si absent) */
  newTraceId: () => TraceId;
}

/* -------------------------------------------------
 * Opérateurs
 * ------------------------------------------------- */

/** Représentation d'un opérateur déclaratif ex: { op:"$http.request.get", params:{ url: "..." } } */
export interface OperatorCall {
  /** Nom pleinement qualifié de l'opérateur: $namespace.category.method */
  op: string;
  /** Paramètres (objet, tableau ou scalaire) */
  params?: any;
  /** Indique si l'opérateur doit être évalué dans le runtime UI ou Backend. Sinon résolution automatique. */
  runtime?: RuntimeKind;
  /** Politique de gestion d'erreur spécifique à cet appel (override) */
  onError?: 'throw' | 'warn' | 'silent' | 'fallback';
  /** Valeur de repli si onError=fallback */
  fallbackValue?: any;
}

/** Signature d'un exécuteur d'opérateur (UI/Backend) */
export type OperatorExecutorFn = (
  opName: string,
  params: any,
  ctx: MetaContext
) => any | Promise<any>;

/* -------------------------------------------------
 * Steps & Workflows
 * ------------------------------------------------- */
export type StepKind =
  | 'action'     // exécuter une ou plusieurs opérations
  | 'condition'  // if/else unique
  | 'switch'     // match multi-cas
  | 'loop'       // boucle sur une collection
  | 'parallel'   // exécuter plusieurs branches en parallèle
  | 'wait'       // pause (ms) / attente signal
  | 'call'       // appeler un opérateur comme fonction (retour)
  | 'subflow';   // appeler un workflow/version enfant

/** Expression conditionnelle (bindings) — libre, évaluée par Parser */
export type Expr = any;

/** Configuration générique d'une étape */
export interface StepBaseConfig {
  /** Données d'entrée projetées pour l'étape (binding-enabled) */
  payload?: JsonValue;
  /** Condition d'exécution (truthy => exécuter) */
  when?: Expr;
  /** Politique d'erreur par défaut pour l'étape */
  onError?: 'throw' | 'warn' | 'silent' | 'fallback';
  /** Valeur de fallback si onError=fallback */
  fallbackValue?: any;
}

/** Étapes spécialisées */
export interface ActionStepConfig extends StepBaseConfig {
  /** Liste d'opérateurs à exécuter (séquentiel) */
  ops: OperatorCall[];
  /** Routage en fin d'étape */
  next?: { success?: string; failure?: string };
  /** Optionnel: affecter le dernier résultat à state.step[assign] */
  assign?: string;
}

export interface ConditionStepConfig extends StepBaseConfig {
  /** Test (truthy / falsy) */
  test: Expr;
  /** Clés de step cible */
  next: { then?: string; else?: string };
}

export interface SwitchCase {
  when: Expr;      // condition pour ce cas
  goto: string;    // clé de step cible
}
export interface SwitchStepConfig extends StepBaseConfig {
  cases: SwitchCase[];
  /** Optionnel: défaut si aucun cas ne matche */
  default?: string;
}

export interface LoopStepConfig extends StepBaseConfig {
  /** Collection à itérer (binding) */
  each: Expr;
  /** Clé de la variable courante dans le scope (ex: "item") */
  as?: string;
  /** Étape à appeler pour chaque item (clé) */
  body: string;
  /** Goto après la boucle */
  next?: string;
}

export interface ParallelBranch {
  /** Nom de la branche (clé logique) */
  key: string;
  /** Première étape de la branche */
  start: string;
}
export interface ParallelStepConfig extends StepBaseConfig {
  /** Branches à exécuter en parallèle */
  branches: ParallelBranch[];
  /** Politique d'agrégation des résultats */
  join?: 'all' | 'any' | 'race' | 'allSettled';
  /** Routage post-join */
  next?: { success?: string; failure?: string };
}

export interface WaitStepConfig extends StepBaseConfig {
  /** Durée en ms, ou condition d'attente (Expr) */
  for: number | Expr;
  next?: string;
}

export interface CallStepConfig extends StepBaseConfig {
  /** Opérateur à appeler comme fonction (retourne output) */
  op: OperatorCall;
  /** Clé dans le state/local pour stocker le résultat */
  assign?: string;
  next?: string;
}

export interface SubflowRef {
  /** Référence du workflow appelé (ID ou code+namespace) */
  workflowId?: WorkflowId;
  /** Optionnel: version spécifique, sinon active */
  versionId?: VersionId;
  /** Optionnel: surcharger le namespace (multi-tenant/plugin) */
  namespaceId?: NamespaceId;
}
export interface SubflowStepConfig extends StepBaseConfig {
  subflow: SubflowRef;
  /** Mapping d'entrée pour le sous-flow */
  input?: JsonValue;
  /** Où stocker le résultat */
  assign?: string;
  next?: string;
}

/** Union de configuration par type */
export type StepConfig =
  | ({ kind: 'action' } & ActionStepConfig)
  | ({ kind: 'condition' } & ConditionStepConfig)
  | ({ kind: 'switch' } & SwitchStepConfig)
  | ({ kind: 'loop' } & LoopStepConfig)
  | ({ kind: 'parallel' } & ParallelStepConfig)
  | ({ kind: 'wait' } & WaitStepConfig)
  | ({ kind: 'call' } & CallStepConfig)
  | ({ kind: 'subflow' } & SubflowStepConfig);

/** Définition d'une étape versionnée (métadonnée méta) */
export interface LogicStep {
  id?: StepId;
  versionId: VersionId;
  key: string;        // identifiant unique humain par version
  order?: number;
  config: StepConfig; // configuration déclarative
}

/** Statut d'une version */
export type VersionStatus = 'draft' | 'released' | 'deprecated' | 'revoked';

/** Version d'un workflow */
export interface LogicVersion {
  id?: VersionId;
  workflowId: WorkflowId;
  number: number;
  status: VersionStatus;
  changelog?: string;
  createdBy?: string;
  createdAt?: string;
}

/** Statut d'un workflow */
export type WorkflowStatus = 'draft' | 'active' | 'archived';

/** Workflow logique méta */
export interface LogicWorkflow {
  id?: WorkflowId;
  tenantId: TenantId;
  namespaceId: NamespaceId;
  code: string;
  label?: string;
  tags?: string[];
  activeVersionId?: VersionId | null;
  status: WorkflowStatus;
  createdAt?: string;
}

/* -------------------------------------------------
 * Policies & Plugins
 * ------------------------------------------------- */
export interface LogicPolicy {
  id?: PolicyId;
  tenantId: TenantId;
  namespaceId: NamespaceId;
  name: string;
  runtime: RuntimeKind | 'both';
  allow_ops?: string[];     // glob patterns ex: "$http.*"
  deny_ops?: string[];
  allow_plugins?: string[];
  deny_plugins?: string[];
}

export interface LogicPluginMeta {
  id: PluginId | string;
  name: string;
  version: string;
  namespaceId: NamespaceId;
  enabled?: boolean;
  meta?: JsonObject; // author, signatures, checksum...
}

/* -------------------------------------------------
 * State & Services
 * ------------------------------------------------- */
export interface MetaStateScopes {
  /** Scope global tenant / namespace */
  global?: JsonObject;
  /** Scope workflow (durée d'une exécution de flow) */
  flow?: JsonObject;
  /** Scope step (courant) — remplace à chaque étape */
  step?: JsonObject;
  /** Scope session utilisateur (UI) */
  session?: JsonObject;
  /** Scope component/page (UI) */
  ui?: JsonObject;
}

export interface MetaUser {
  id?: string;
  email?: string;
  roles?: string[];
  claims?: JsonObject;
}

export interface MetaServices {
  /** SurrealDB adapter minimal */
  surreal?: {
    query: (sql: string, vars?: Record<string, any>) => Promise<any>;
    select?: (thing: string) => Promise<any>;
    create?: (thing: string, data?: any) => Promise<any>;
    update?: (thing: string, data?: any) => Promise<any>;
    delete?: (thing: string) => Promise<any>;
  };
  /** HTTP fetch adapter (node-fetch ou global fetch) */
  http?: {
    fetch: typeof fetch;
  };
  /** Mailer, storage, crypto, queue, etc. (extensibles) */
  mailer?: any;
  storage?: any;
  crypto?: any;
  queue?: any;
  logger?: {
    log: (level: LogLevel, message: string, data?: any) => void | Promise<void>;
  };
}

/* -------------------------------------------------
 * Contexte d'exécution
 * ------------------------------------------------- */
export interface MetaContext {
  runtime: RuntimeKind;
  tenantId: TenantId;
  namespaceId: NamespaceId;
  user?: MetaUser;
  state?: MetaStateScopes;
  services?: MetaServices;

  /** ID de corrélation d'exécution */
  traceId?: TraceId;

  /** Plugin/registry (pour résolution dynamique d'opérateurs) */
  registry?: {
    resolveOperator?: (opName: string) => ((opName: string, params: any, ctx: any) => any) | undefined;
  };

  /** Politique active (sécurité/gouvernance) */
  policy?: LogicPolicy;

  /** Options d'exécution (dev/prod, strict…) */
  options?: {
    env?: 'dev' | 'prod';
    strict?: boolean;
    logErrors?: boolean;
    timeouts?: {
      stepMs?: number;
      flowMs?: number;
    };
  };

  /** Hooks IA optionnels (branchés par l’engine ou l’app) */
  aiHooks?: AiHooks;
}

/* -------------------------------------------------
 * Parser
 * ------------------------------------------------- */
export interface MetaParserOptions {
  /** Préfixe des opérateurs (ex: "_" ou "$") */
  operatorPrefix?: string; // défaut: "$" côté Lyxal
  /** Résolution automatique du runtime si non fourni dans OperatorCall */
  autoRuntime?: boolean;   // défaut: true
}

export interface ParseResult<T = any> {
  output: T;
  errors: (Error | string)[];
}

/* -------------------------------------------------
 * Exécution
 * ------------------------------------------------- */
export interface StepResult {
  ok: boolean;
  error?: Error | string;
  /** Valeur utile retournée par l'étape (ex: résultat d'un opérateur) */
  value?: any;
  /** Clé de la prochaine étape choisie (si applicable) */
  nextKey?: string;
  /** Spans générés dans l'étape */
  spans?: SpanRecord[];
}

export interface WorkflowResult {
  ok: boolean;
  error?: Error | string;
  /** Sortie finale du flow (si body/call/subflow affectent une sortie) */
  output?: any;
  /** Journal d'exécution (spans agrégés) */
  trace?: SpanRecord[];
  /** Version exécutée */
  versionId?: VersionId;
}

export interface ExecutionPlan {
  version: LogicVersion;
  steps: LogicStep[];
  entryKey?: string; // première étape
}

export interface WorkflowEngine {
  /** Exécuter une version de workflow (à partir d'une clé d'entrée optionnelle) */
  run: (input: {
    context: MetaContext;
    version: LogicVersion;
    steps: LogicStep[];
    entryKey?: string;
    inputPayload?: JsonValue;
    observability?: Observability;
  }) => Promise<WorkflowResult>;
}

/* -------------------------------------------------
 * IA — Mode 1C (Workflows, Steps, Opérateurs/Plugins/Policies) + Patch JSON (2A)
 * ------------------------------------------------- */

/** Événements IA supportés */
export type AiSignal =
  | 'fix'        // Une étape/flow a échoué → proposer correctifs
  | 'optimize'   // Flow réussi → proposer optimisations
  | 'explain'    // Demande d’explication (debug)
  | 'review'     // Audit qualité (linting/bonnes pratiques)
  | 'governance' // Gouvernance (policies, sécurité, conformité)

/** Modèle de Patch (diff logique JSON standard, 2A) */
export type AiPatch =
  | {
      type: 'update-step';
      target: { stepKey: string };
      patch: Partial<LogicStep>; // ex: { config: { ... } }
      rationale?: string;
    }
  | {
      type: 'update-operator'; // ciblage fin d’un op dans une step
      target: { stepKey: string; opIndex: number };
      patch: { op?: string; params?: any; remove?: boolean };
      rationale?: string;
    }
  | {
      type: 'update-version'; // patch global sur version: metadata/output policy, etc.
      target: { versionId: string };
      patch: Partial<LogicVersion>;
      rationale?: string;
    }
  | {
      type: 'update-policy'; // gouvernance (allow/deny ops/plugins, runtime, etc.)
      target: { policyId?: string } & Partial<LogicPolicy>;
      patch: Partial<LogicPolicy>;
      rationale?: string;
    }
  | {
      type: 'update-plugin'; // enable/disable plugin, meta, version
      target: { pluginId: string };
      patch: Partial<LogicPluginMeta>;
      rationale?: string;
    };

/** Entrée & Sortie de suggestion IA */
export interface AiSuggestInput {
  signal: AiSignal;
  context: MetaContext;
  version: LogicVersion;
  workflow?: LogicWorkflow;
  step?: LogicStep;
  snapshot?: {
    state?: MetaContext['state'];
    error?: string;
    extra?: Record<string, JsonValue>;
  };
  // Hints facultatifs pour guider le modèle
  hints?: {
    style?: 'short' | 'detailed' | 'bulleted';
    language?: 'fr' | 'en';
    maxTokens?: number;
  };
}

export interface AiSuggestOutput {
  ok: boolean;
  summary?: string;                // explication/proposition humaine
  patches?: AiPatch[];             // un ou plusieurs patchs à appliquer (optionnel)
  warnings?: string[];             // ex: risques, prérequis
  telemetry?: Record<string, JsonValue>; // infos utiles (scores, temps, etc.)
}

/** Interface principale des hooks IA (version moderne alignée @lyxal/logic-meta/aiHooks) */
export interface AiHooks {
  suggest(input: AiSuggestInput): Promise<AiSuggestOutput>;
}
