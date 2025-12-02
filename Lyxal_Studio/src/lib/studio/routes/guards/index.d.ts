import { GuardExecutionContext, GuardExecutionResult, RouteGuard, GuardType } from '../../types/route';
/**
 * Exécute un guard spécifique selon son type
 */
export declare function executeGuard(guard: RouteGuard, context: GuardExecutionContext): Promise<GuardExecutionResult>;
/**
 * Exécute une liste de guards en séquence
 * S'arrête au premier guard qui échoue
 */
export declare function executeGuards(guards: RouteGuard[], context: GuardExecutionContext): Promise<GuardExecutionResult>;
/**
 * Valide la configuration d'un guard
 */
export declare function validateGuardConfig(guard: RouteGuard): {
    valid: boolean;
    errors: string[];
};
/**
 * Récupère la liste des types de guards disponibles
 */
export declare function getAvailableGuardTypes(): string[];
/**
 * Récupère la description d'un type de guard
 */
export declare function getGuardTypeDescription(type: string): string;
/**
 * Crée un guard avec validation
 */
export declare function createGuard(type: GuardType, condition?: any): RouteGuard | null;
export { hasFeatureAccess } from './featureGuard';
export { isPlanAtLeast, getAvailablePlans, getPlanLevel } from './subscriptionGuard';
