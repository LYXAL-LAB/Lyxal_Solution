/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: aiHooks.ts
 * Rôle: Interfaces & helpers d’intégration IA (Suggest + Patch)
 *
 * Principe:
 * - Le moteur appelle aiHooks.suggest() sur erreurs (ou événements)
 * - L’IA peut renvoyer une suggestion textuelle ET/OU un "patch" à appliquer
 * - Aucun backend IA imposé: implémentez AiHooks avec l’API de votre choix
 *
 * Important:
 * - Le moteur ne modifie pas le workflow automatiquement.
 * - Vous décidez quand/appliquer un patch (côté app/gateway).
 */

import { JsonValue, MetaContext, LogicVersion, LogicStep } from './types';

/* --------------------------------------------
 * Types d’événements IA supportés
 * -------------------------------------------- */
export type AiSignal =
  | 'fix'       // Une étape/flow a échoué → proposer correctifs
  | 'optimize'  // Flow réussi → proposer optimisations
  | 'explain'   // Demande d’explication (debug)
  | 'review';   // Audit qualité (linting/bonnes pratiques)

/* --------------------------------------------
 * Modèle de Patch (diff logique)
 * -------------------------------------------- */
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
    };

/* --------------------------------------------
 * Entrée & Sortie de suggestion IA
 * -------------------------------------------- */
export interface AiSuggestInput {
  signal: AiSignal;
  context: MetaContext;
  version: LogicVersion;
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
  summary?: string;          // explication/proposition humaine
  patches?: AiPatch[];       // un ou plusieurs patchs à appliquer (optionnel)
  warnings?: string[];       // ex: risques, prérequis
  telemetry?: Record<string, JsonValue>; // infos utiles (scores, temps, etc.)
}

/* --------------------------------------------
 * Interface principale à implémenter
 * -------------------------------------------- */
export interface AiHooks {
  suggest(input: AiSuggestInput): Promise<AiSuggestOutput>;
}

/* --------------------------------------------
 * Implémentation par défaut (no-op avec heuristiques)
 * - Fournit des messages utiles sans IA externe
 * -------------------------------------------- */
export class DefaultAiHooks implements AiHooks {
  async suggest(input: AiSuggestInput): Promise<AiSuggestOutput> {
    const lang = input.hints?.language ?? 'fr';

    // Messages simples orientés DX
    const explainFR = (msg: string) => msg;
    const explainEN = (msg: string) => msg;

    // Heuristique de base pour "fix" : si on détecte un timeout http → propose un retry/backoff
    if (input.signal === 'fix' && input.step?.config?.kind === 'action') {
      const err = input.snapshot?.error ?? '';
      const hasHttpTimeout = /timeout|ETIMEDOUT|ECONNRESET/i.test(err);
      if (hasHttpTimeout) {
        return {
          ok: true,
          summary:
            lang === 'fr'
              ? explainFR(
                  `J'ai détecté un probable timeout réseau. Suggestion: ajouter un retry avec backoff sur l'opérateur HTTP concerné.`
                )
              : explainEN(
                  `Detected a likely network timeout. Suggest: add retry with backoff on the HTTP operator.`
                ),
          patches: [
            {
              type: 'update-operator',
              target: { stepKey: input.step.key, opIndex: 0 }, // à adapter côté appli si multi-ops
              patch: {
                // Exemple: ajouter un param "retry" attendu par votre $http.get interne
                params: {
                  ...(input.step as any)?.config?.ops?.[0]?.params,
                  retry: { attempts: 3, backoffMs: 500 },
                },
              },
              rationale:
                lang === 'fr'
                  ? 'Réduire la sensibilité aux erreurs transitoires réseau.'
                  : 'Reduce sensitivity to transient network errors.',
            },
          ],
          warnings: [
            lang === 'fr'
              ? 'Vérifiez que votre opérateur HTTP supporte bien "retry.attempts" et "retry.backoffMs".'
              : 'Ensure your HTTP operator supports "retry.attempts" and "retry.backoffMs".',
          ],
        };
      }
    }

    // Heuristique simple "optimize" : si step d’action sans assign, proposer assign pour audit
    if (input.signal === 'optimize' && input.step?.config?.kind === 'action') {
      const hasAssign = Boolean((input.step as any)?.config?.assign);
      if (!hasAssign) {
        return {
          ok: true,
          summary:
            lang === 'fr'
              ? explainFR(
                  `Étape d'action sans "assign" : je recommande d'assigner la dernière valeur dans state.step pour faciliter debugging et test.`
                )
              : explainEN(
                  `Action step has no "assign": consider assigning last value into state.step for easier debugging/testing.`
                ),
          patches: [
            {
              type: 'update-step',
              target: { stepKey: input.step.key },
              patch: {
                config: {
                  ...(input.step.config as any),
                  assign: 'lastResult',
                },
              },
              rationale:
                lang === 'fr'
                  ? 'Aide au diagnostic et à la réutilisation du résultat.'
                  : 'Helps diagnostics and result reuse.',
            },
          ],
        };
      }
    }

    // Fallback générique: pas de patch, mais une explication utile
    const fallbackSummary =
      lang === 'fr'
        ? `Pas de correctif automatique proposé. Consultez les logs system_log et le trace pour davantage d’indices.`
        : `No automatic fix proposed. Check system_log records and trace for more clues.`;

    return { ok: true, summary: fallbackSummary, patches: [] };
  }
}

/* --------------------------------------------
 * Helper: attacher des hooks IA au contexte
 * - Le moteur lit ctx.aiHooks s’il existe (voir workflowEngine)
 * -------------------------------------------- */
export function attachAiHooks(ctx: MetaContext, hooks: AiHooks) {
  (ctx as any).aiHooks = hooks;
}

/* --------------------------------------------
 * Exemple d’adapteur (squelette) — IA externe
 * - À compléter côté gateway (OpenAI, Claude, etc.)
 * -------------------------------------------- */
export class ExternalAiHooks implements AiHooks {
  constructor(
    private callModel: (prompt: string, options?: Record<string, unknown>) => Promise<string>,
    private options?: { language?: 'fr' | 'en' }
  ) {}

  async suggest(input: AiSuggestInput): Promise<AiSuggestOutput> {
    const lang = this.options?.language ?? input.hints?.language ?? 'fr';

    // 1) Construire un prompt minimal (éviter de mettre des secrets !)
    const prompt =
      lang === 'fr'
        ? this.buildPromptFR(input)
        : this.buildPromptEN(input);

    // 2) Appeler le modèle (implémentation fournie par l’app appelante)
    const raw = await this.callModel(prompt, { signal: input.signal });

    // 3) Tenter d’extraire des patches depuis le raw (attendu: JSON ou directives)
    const { summary, patches } = this.extract(raw);

    return { ok: true, summary, patches };
  }

  private buildPromptFR(input: AiSuggestInput): string {
    return [
      `Tu es l'assistant IA du moteur Lyxal OS.`,
      `Signal: ${input.signal}`,
      `Erreur: ${input.snapshot?.error ?? 'n/a'}`,
      `Contexte: runtime=${input.context.runtime}, tenant=${input.context.tenantId}`,
      `Step: ${input.step?.key ?? 'n/a'} kind=${(input.step?.config as any)?.kind ?? 'n/a'}`,
      `Etat (résumé): ${safeJson(input.snapshot?.state)}`,
      `Objectif: proposer une courte explication (summary) et, si pertinent, des patches JSON (AiPatch).`,
      `Format de sortie demandé:`,
      `{"summary":"...", "patches":[ {"type":"update-step","target":{"stepKey":"..."},"patch":{...},"rationale":"..."} ]}`,
    ].join('\n');
  }

  private buildPromptEN(input: AiSuggestInput): string {
    return [
      `You are the AI assistant of Lyxal OS engine.`,
      `Signal: ${input.signal}`,
      `Error: ${input.snapshot?.error ?? 'n/a'}`,
      `Context: runtime=${input.context.runtime}, tenant=${input.context.tenantId}`,
      `Step: ${input.step?.key ?? 'n/a'} kind=${(input.step?.config as any)?.kind ?? 'n/a'}`,
      `State (summary): ${safeJson(input.snapshot?.state)}`,
      `Goal: provide a short explanation (summary) and, if useful, JSON patches (AiPatch).`,
      `Expected output format:`,
      `{"summary":"...", "patches":[ {"type":"update-step","target":{"stepKey":"..."},"patch":{...},"rationale":"..."} ]}`,
    ].join('\n');
  }

  private extract(raw: string): { summary?: string; patches?: AiPatch[] } {
    try {
      const parsed = JSON.parse(raw);
      const summary = typeof parsed.summary === 'string' ? parsed.summary : undefined;
      const patches = Array.isArray(parsed.patches) ? (parsed.patches as AiPatch[]) : undefined;
      return { summary, patches };
    } catch {
      // Fallback: pas de JSON valide → renvoyer le texte en summary
      return { summary: raw, patches: [] };
    }
  }
}

/* --------------------------------------------
 * Utils
 * -------------------------------------------- */
function safeJson(v: any): string {
  try {
    return JSON.stringify(v)?.slice(0, 2000);
  } catch {
    return '[unserializable]';
  }
}
