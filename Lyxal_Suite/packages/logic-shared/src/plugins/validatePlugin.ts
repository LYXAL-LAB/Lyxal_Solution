// packages/logic-shared/src/plugins/validatePlugin.ts
import type { CompiledPluginIndex, CompiledOperatorMeta, LoadedPlugin } from './pluginRegistry.js';

export interface ValidatePluginOptions {
  engineVersion: string; // version du moteur Lyxal (ex: "1.0.0")
  strict?: boolean;      // si true → bloque au moindre warning
}

export interface PluginValidationResult {
  ok: boolean;
  errors: string[];
  warnings: string[];
}

/**
 * Valide la structure générale d’un plugin chargé (FS, URL ou DB)
 * - Vérifie presence pluginId, version
 * - Vérifie operators[]
 * - Vérifie cohérence meta operator.name
 * - Option: compatibilité version moteur Lyxal
 */
export function validatePlugin(
  plugin: LoadedPlugin,
  options: ValidatePluginOptions
): PluginValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];
  const { engineVersion, strict = false } = options;

  const index: CompiledPluginIndex = plugin.index;

  // 1. Obligatoire
  if (!index.pluginId) errors.push('Missing pluginId in index.');
  if (!index.version) errors.push('Missing plugin version.');

  // 2. Operators list must exist
  if (!Array.isArray(index.operators) || index.operators.length === 0) {
    errors.push('Plugin has no operators defined.');
  }

  // 3. Validate each operator
  for (const op of index.operators) {
    if (!op.name) errors.push(`Operator missing name in index: ${JSON.stringify(op)}`);
    if (!op.file) errors.push(`Operator "${op.name}" missing file reference.`);
    const meta: CompiledOperatorMeta | undefined = plugin.operators[op.file];
    if (!meta) {
      errors.push(`Operator "${op.name}" meta file "${op.file}" is missing or unreadable.`);
      continue;
    }

    // Name mismatch (index vs meta)
    if (meta.name && meta.name !== op.name) {
      warnings.push(`Operator name mismatch: index="${op.name}" vs meta="${meta.name}"`);
    }

    if (!meta.category) warnings.push(`Operator "${op.name}" has no category.`);
    if (!meta.version) warnings.push(`Operator "${op.name}" has no version.`);
  }

  // 4. Versioning minimal check (simple for now)
  if (index.version !== engineVersion) {
    warnings.push(
      `Plugin version ${index.version} differs from engine version ${engineVersion}.`
    );
  }

  // — Future: Add semver compatibility, signature checks, tenant permissions, etc.

  return {
    ok: errors.length === 0 && (!strict || warnings.length === 0),
    errors,
    warnings,
  };
}
