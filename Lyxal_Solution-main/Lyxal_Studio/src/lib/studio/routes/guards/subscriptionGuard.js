/**
 * Niveaux d'abonnement (du plus bas au plus élevé)
 */
const SUBSCRIPTION_LEVELS = {
    'free': 0,
    'basic': 1,
    'pro': 2,
    'premium': 3,
    'enterprise': 4
};
/**
 * Guard de vérification des abonnements
 * Vérifie si l'utilisateur a un abonnement actif et les fonctionnalités requises
 */
export async function executeSubscriptionGuard(condition, context) {
    console.log('[SubscriptionGuard] 💳 Checking subscription...', condition);
    try {
        // Vérifier si un utilisateur est présent
        if (!context.user) {
            console.log('[SubscriptionGuard] ❌ No user found');
            return {
                success: false,
                error: 'User not authenticated',
                redirectTo: '/signin'
            };
        }
        // Vérifier si l'utilisateur a des informations d'abonnement
        if (!context.user.subscription) {
            console.log('[SubscriptionGuard] ❌ No subscription information');
            return {
                success: false,
                error: 'No subscription found',
                redirectTo: '/subscription/required'
            };
        }
        const subscription = context.user.subscription;
        console.log(`[SubscriptionGuard] User subscription:`, subscription);
        // Vérifier si l'abonnement est actif
        if (!subscription.active) {
            console.log('[SubscriptionGuard] ❌ Subscription not active');
            return {
                success: false,
                error: 'Subscription not active',
                redirectTo: '/subscription/renew'
            };
        }
        // Vérifier le plan requis
        if (condition.plan) {
            const requiredLevel = SUBSCRIPTION_LEVELS[condition.plan];
            const userLevel = SUBSCRIPTION_LEVELS[subscription.plan];
            if (userLevel === undefined) {
                console.log(`[SubscriptionGuard] ❌ Unknown user plan: ${subscription.plan}`);
                return {
                    success: false,
                    error: 'Invalid subscription plan',
                    redirectTo: '/subscription/upgrade'
                };
            }
            if (userLevel < requiredLevel) {
                console.log(`[SubscriptionGuard] ❌ Insufficient plan level. Required: ${condition.plan} (${requiredLevel}), User: ${subscription.plan} (${userLevel})`);
                return {
                    success: false,
                    error: `Plan ${condition.plan} required`,
                    redirectTo: '/subscription/upgrade'
                };
            }
            console.log(`[SubscriptionGuard] ✅ Plan requirement met: ${condition.plan}`);
        }
        // Vérifier la fonctionnalité spécifique
        if (condition.feature) {
            if (!subscription.features || !subscription.features.includes(condition.feature)) {
                console.log(`[SubscriptionGuard] ❌ Required feature not found: ${condition.feature}`);
                console.log(`[SubscriptionGuard] Available features:`, subscription.features);
                return {
                    success: false,
                    error: `Feature ${condition.feature} not available`,
                    redirectTo: '/subscription/upgrade'
                };
            }
            console.log(`[SubscriptionGuard] ✅ Feature requirement met: ${condition.feature}`);
        }
        // Vérifier le niveau minimum
        if (condition.minLevel !== undefined) {
            const userLevel = SUBSCRIPTION_LEVELS[subscription.plan] || 0;
            if (userLevel < condition.minLevel) {
                console.log(`[SubscriptionGuard] ❌ Insufficient level. Required: ${condition.minLevel}, User: ${userLevel}`);
                return {
                    success: false,
                    error: `Minimum subscription level ${condition.minLevel} required`,
                    redirectTo: '/subscription/upgrade'
                };
            }
            console.log(`[SubscriptionGuard] ✅ Level requirement met: ${condition.minLevel}`);
        }
        console.log(`[SubscriptionGuard] ✅ All subscription requirements met`);
        return {
            success: true
        };
    }
    catch (error) {
        console.error('[SubscriptionGuard] Error during subscription check:', error);
        return {
            success: false,
            error: 'Subscription verification failed',
            redirectTo: '/error'
        };
    }
}
/**
 * Vérifie si un plan est supérieur ou égal à un autre
 */
export function isPlanAtLeast(userPlan, requiredPlan) {
    const userLevel = SUBSCRIPTION_LEVELS[userPlan] || 0;
    const requiredLevel = SUBSCRIPTION_LEVELS[requiredPlan] || 0;
    return userLevel >= requiredLevel;
}
/**
 * Récupère tous les plans disponibles
 */
export function getAvailablePlans() {
    return Object.keys(SUBSCRIPTION_LEVELS);
}
/**
 * Récupère le niveau d'un plan
 */
export function getPlanLevel(plan) {
    return SUBSCRIPTION_LEVELS[plan] || 0;
}
