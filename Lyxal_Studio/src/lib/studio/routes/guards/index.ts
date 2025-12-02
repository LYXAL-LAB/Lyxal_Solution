import { GuardExecutionContext, GuardExecutionResult, RouteGuard, GuardType } from '../../types/route';
import { executeAuthGuard } from './authGuard';
import { executeRoleGuard } from './roleGuard';
import { executeSubscriptionGuard } from './subscriptionGuard';
import { executeFeatureGuard } from './featureGuard';

/**
 * Exécute un guard spécifique selon son type
 */
export async function executeGuard(
  guard: RouteGuard,
  context: GuardExecutionContext
): Promise<GuardExecutionResult> {
  const { type, condition } = guard;

  console.log(`[GuardExecutor] 🎯 Executing guard type: ${type}`);

  try {
    switch (type) {
      case 'auth':
        return await executeAuthGuard(condition, context);

      case 'role':
        return await executeRoleGuard((condition as any) || {}, context);

      case 'subscription':
        return await executeSubscriptionGuard((condition as any) || {}, context);

      case 'feature':
        return await executeFeatureGuard((condition as any) || {}, context);

      default:
        console.error(`[GuardExecutor] ❌ Unknown guard type: ${type}`);
        return {
          success: false,
          error: `Unknown guard type: ${type}`,
          redirectTo: '/error'
        };
    }
  } catch (error) {
    console.error(`[GuardExecutor] 💥 Guard execution failed for type ${type}:`, error);
    return {
      success: false,
      error: `Guard execution failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
      redirectTo: '/error'
    };
  }
}

/**
 * Exécute une liste de guards en séquence
 * S'arrête au premier guard qui échoue
 */
export async function executeGuards(
  guards: RouteGuard[],
  context: GuardExecutionContext
): Promise<GuardExecutionResult> {
  if (!guards || guards.length === 0) {
    console.log('[GuardExecutor] ℹ️ No guards to execute');
    return { success: true };
  }

  console.log(`[GuardExecutor] 🚦 Executing ${guards.length} guards in sequence`);

  for (let i = 0; i < guards.length; i++) {
    const guard = guards[i];
    console.log(`[GuardExecutor] ${i + 1}/${guards.length} - Executing guard: ${guard.type}`);

    const result = await executeGuard(guard, context);

    if (!result.success) {
      console.log(`[GuardExecutor] ❌ Guard ${i + 1} failed: ${guard.type}`);
      return result;
    }

    console.log(`[GuardExecutor] ✅ Guard ${i + 1} passed: ${guard.type}`);
  }

  console.log('[GuardExecutor] 🎉 All guards passed successfully');
  return { success: true };
}

/**
 * Valide la configuration d'un guard
 */
export function validateGuardConfig(guard: RouteGuard): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  // Vérifier le type
  if (!guard.type) {
    errors.push('Guard type is required');
  } else {
    const validTypes = ['auth', 'role', 'subscription', 'feature'];
    if (!validTypes.includes(guard.type)) {
      errors.push(`Invalid guard type: ${guard.type}. Must be one of: ${validTypes.join(', ')}`);
    }
  }

  // Validation spécifique selon le type
  if (guard.type === 'role' && guard.condition) {
    if (!guard.condition.role) {
      errors.push('Role guard requires a "role" in condition');
    }
  }

  if (guard.type === 'subscription' && guard.condition) {
    if (!guard.condition.plan && !guard.condition.feature) {
      errors.push('Subscription guard requires either "plan" or "feature" in condition');
    }
  }

  if (guard.type === 'feature' && guard.condition) {
    if (!guard.condition.feature) {
      errors.push('Feature guard requires a "feature" in condition');
    }
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

/**
 * Récupère la liste des types de guards disponibles
 */
export function getAvailableGuardTypes(): string[] {
  return ['auth', 'role', 'subscription', 'feature'];
}

/**
 * Récupère la description d'un type de guard
 */
export function getGuardTypeDescription(type: string): string {
  const descriptions: Record<string, string> = {
    'auth': 'Vérifie si l\'utilisateur est authentifié',
    'role': 'Vérifie si l\'utilisateur a un rôle spécifique',
    'subscription': 'Vérifie l\'abonnement et les fonctionnalités',
    'feature': 'Vérifie l\'accès à une fonctionnalité spécifique'
  };

  return descriptions[type] || 'Type de guard inconnu';
}

/**
 * Crée un guard avec validation
 */
export function createGuard(type: GuardType, condition: any = {}): RouteGuard | null {
  const guard: RouteGuard = { type, condition };

  const validation = validateGuardConfig(guard);
  if (!validation.valid) {
    console.error('[GuardFactory] Invalid guard configuration:', validation.errors);
    return null;
  }

  return guard;
}

// Export des fonctions utilitaires
export { hasFeatureAccess } from './featureGuard';
export { isPlanAtLeast, getAvailablePlans, getPlanLevel } from './subscriptionGuard';
