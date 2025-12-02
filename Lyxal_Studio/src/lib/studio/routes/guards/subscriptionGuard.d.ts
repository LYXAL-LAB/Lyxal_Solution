import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';
/**
 * Condition pour le guard d'abonnement
 */
export interface SubscriptionGuardCondition {
    plan?: string;
    feature?: string;
    minLevel?: number;
}
/**
 * Guard de vérification des abonnements
 * Vérifie si l'utilisateur a un abonnement actif et les fonctionnalités requises
 */
export declare function executeSubscriptionGuard(condition: SubscriptionGuardCondition, context: GuardExecutionContext): Promise<GuardExecutionResult>;
/**
 * Vérifie si un plan est supérieur ou égal à un autre
 */
export declare function isPlanAtLeast(userPlan: string, requiredPlan: string): boolean;
/**
 * Récupère tous les plans disponibles
 */
export declare function getAvailablePlans(): string[];
/**
 * Récupère le niveau d'un plan
 */
export declare function getPlanLevel(plan: string): number;
