import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';
/**
 * Condition pour le guard de fonctionnalité
 */
export interface FeatureGuardCondition {
    feature: string;
    version?: string;
    fallback?: string;
}
/**
 * Guard de vérification des fonctionnalités
 * Vérifie si l'utilisateur a accès à une fonctionnalité spécifique
 */
export declare function executeFeatureGuard(condition: FeatureGuardCondition, context: GuardExecutionContext): Promise<GuardExecutionResult>;
/**
 * Vérifie si une fonctionnalité est disponible pour un utilisateur
 * (version simplifiée pour usage général)
 */
export declare function hasFeatureAccess(user: any, feature: string, version?: string): boolean;
