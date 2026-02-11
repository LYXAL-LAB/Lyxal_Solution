# 💰 Modèle de Pricing LyxalSuite

## 🎯 Vue d'ensemble

LyxalSuite utilise un **modèle de pricing B2B2C** où les **tenants** (freelances/agences) paient selon leur plan et le nombre de SaaS créés, puis facturent leurs **clients finaux** librement.

## 📊 Plans Tenant

### Structure tarifaire
```
🏪 LyxalSuite Pricing (pour les tenants)
│
├── 🥉 Starter Plan
│   ├── €29/mois (base)
│   ├── €49/SaaS créé
│   ├── Max 3 SaaS
│   └── Support communauté
│
├── 🥈 Pro Plan  
│   ├── €99/mois (base)
│   ├── €29/SaaS créé
│   ├── Max 15 SaaS
│   ├── White label
│   └── Support email
│
└── 🥇 Enterprise Plan
    ├── €299/mois (base)
    ├── €19/SaaS créé
    ├── Max 100 SaaS
    ├── White label avancé
    ├── Domaines custom
    └── Support premium
```

### Calcul facturation tenant
```typescript
// Exemple calculs mensuels
interface TenantBilling {
  tenant_id: string;
  plan: 'starter' | 'pro' | 'enterprise';
  active_saas_count: number;
  monthly_cost: number;
}

// FreelanceA (Plan Pro)
const freelanceA: TenantBilling = {
  tenant_id: 'tenant_12345',
  plan: 'pro',
  active_saas_count: 3,
  monthly_cost: 99 + (3 * 29) // = €186/mois
};

// AgenceB (Plan Enterprise)  
const agenceB: TenantBilling = {
  tenant_id: 'tenant_67890', 
  plan: 'enterprise',
  active_saas_count: 12,
  monthly_cost: 299 + (12 * 19) // = €527/mois
};
```

## 💳 Facturation automatique

### Service de facturation
```typescript
@Injectable()
export class BillingService {
  
  // Calcul mensuel automatique
  @Cron('0 0 1 * *') // 1er de chaque mois
  async processMonthlyBilling() {
    const tenants = await this.getTenantsList();
    
    for (const tenant of tenants) {
      await this.processTenantBilling(tenant.id);
    }
  }
  
  async processTenantBilling(tenantId: string) {
    // 1. Comptage SaaS actifs
    const activeSaasCount = await this.countActiveSaaS(tenantId);
    
    // 2. Récupération plan tenant
    const tenantPlan = await this.getTenantPlan(tenantId);
    
    // 3. Calcul montant
    const amount = this.calculateBillingAmount(tenantPlan, activeSaasCount);
    
    // 4. Création facture
    const invoice = await this.createInvoice({
      tenant_id: tenantId,
      period: this.getCurrentPeriod(),
      saas_count: activeSaasCount,
      plan: tenantPlan.name,
      base_cost: tenantPlan.base_price,
      saas_cost: activeSaasCount * tenantPlan.price_per_saas,
      total_amount: amount,
      due_date: this.calculateDueDate()
    });
    
    // 5. Prélèvement automatique
    await this.processPayment(tenantId, invoice);
    
    // 6. Notification
    await this.sendInvoiceNotification(tenantId, invoice);
  }
  
  private calculateBillingAmount(
    plan: TenantPlan, 
    saasCount: number
  ): number {
    return plan.base_price + (saasCount * plan.price_per_saas);
  }
}
```

### Gestion des paiements
```typescript
@Injectable()
export class PaymentService {
  
  async processPayment(tenantId: string, invoice: Invoice) {
    const tenant = await this.getTenant(tenantId);
    const paymentMethod = tenant.payment_method;
    
    try {
      // Prélèvement Stripe
      const payment = await this.stripe.paymentIntents.create({
        amount: invoice.total_amount * 100, // centimes
        currency: 'eur',
        customer: tenant.stripe_customer_id,
        payment_method: paymentMethod.stripe_payment_method_id,
        confirm: true,
        description: `LyxalSuite - ${invoice.period} - ${invoice.saas_count} SaaS`
      });
      
      // Mise à jour statut facture
      await this.updateInvoiceStatus(invoice.id, 'paid', payment.id);
      
      // Notification succès
      await this.notifyPaymentSuccess(tenantId, invoice, payment);
      
    } catch (error) {
      // Gestion échec paiement
      await this.handlePaymentFailure(tenantId, invoice, error);
    }
  }
  
  async handlePaymentFailure(
    tenantId: string, 
    invoice: Invoice, 
    error: any
  ) {
    // 1. Marquer facture impayée
    await this.updateInvoiceStatus(invoice.id, 'failed', null);
    
    // 2. Notification tenant
    await this.notifyPaymentFailure(tenantId, invoice, error);
    
    // 3. Suspension progressive
    const failedPayments = await this.getFailedPaymentsCount(tenantId);
    
    if (failedPayments >= 3) {
      // Suspension des SaaS après 3 échecs
      await this.suspendTenantSaaS(tenantId);
    } else {
      // Relance automatique dans 3 jours
      await this.schedulePaymentRetry(tenantId, invoice.id, 3);
    }
  }
}
```

## 🎯 Pricing client final (B2C)

### Liberté tarifaire tenant
```typescript
// Les tenants définissent leurs propres prix
interface ClientPricingConfig {
  saas_id: string;
  tenant_id: string;
  
  // Plans définis par le tenant
  plans: {
    basic: {
      name: string;
      price: number;
      currency: string;
      billing_cycle: 'monthly' | 'yearly';
      features: string[];
      limits: Record<string, number>;
    };
    premium: {
      // ... même structure
    };
    enterprise: {
      // ... même structure
    };
  };
  
  // Configuration paiement
  payment_config: {
    stripe_account_id: string; // Compte Stripe du tenant
    accepted_methods: string[];
    trial_period_days: number;
    setup_fee?: number;
  };
}

// Exemple: Restaurant Bistro Paris
const bistroPricing: ClientPricingConfig = {
  saas_id: 'saas_67890',
  tenant_id: 'tenant_12345',
  plans: {
    basic: {
      name: 'Essentiel',
      price: 49,
      currency: 'EUR',
      billing_cycle: 'monthly',
      features: ['Menu en ligne', 'Commandes', 'Clients'],
      limits: { orders_per_month: 100, customers: 500 }
    },
    premium: {
      name: 'Professionnel', 
      price: 99,
      currency: 'EUR',
      billing_cycle: 'monthly',
      features: ['Tout Essentiel', 'Réservations', 'Analytics', 'Staff'],
      limits: { orders_per_month: 500, customers: 2000 }
    }
  },
  payment_config: {
    stripe_account_id: 'acct_freelancea_123',
    accepted_methods: ['card', 'sepa_debit'],
    trial_period_days: 14
  }
};
```

### Service facturation client final
```typescript
@Injectable()
export class ClientBillingService {
  
  async subscribeClient(
    accountId: string,
    planId: string,
    saasId: string
  ) {
    const pricingConfig = await this.getSaasPricing(saasId);
    const plan = pricingConfig.plans[planId];
    
    // Création subscription Stripe (compte tenant)
    const subscription = await this.stripe.subscriptions.create({
      customer: await this.getStripeCustomerId(accountId),
      items: [{
        price: await this.getStripePriceId(saasId, planId)
      }],
      trial_period_days: pricingConfig.payment_config.trial_period_days,
      metadata: {
        saas_id: saasId,
        account_id: accountId,
        plan_id: planId
      }
    }, {
      stripeAccount: pricingConfig.payment_config.stripe_account_id
    });
    
    // Mise à jour account
    await this.updateAccountSubscription(accountId, {
      plan: planId,
      stripe_subscription_id: subscription.id,
      status: 'active',
      current_period_end: new Date(subscription.current_period_end * 1000)
    });
    
    return subscription;
  }
  
  // Webhook Stripe pour mise à jour statuts
  @Post('webhooks/stripe/:saas_id')
  async handleStripeWebhook(
    @Param('saas_id') saasId: string,
    @Body() event: Stripe.Event
  ) {
    switch (event.type) {
      case 'invoice.payment_succeeded':
        await this.handlePaymentSuccess(event.data.object, saasId);
        break;
        
      case 'invoice.payment_failed':
        await this.handlePaymentFailure(event.data.object, saasId);
        break;
        
      case 'customer.subscription.deleted':
        await this.handleSubscriptionCancelled(event.data.object, saasId);
        break;
    }
  }
}
```

## 📈 Revenue Sharing

### Modèle de partage (optionnel)
```typescript
// Revenue sharing avec LyxalSuite (optionnel pour plans premium)
interface RevenueSharing {
  tenant_id: string;
  saas_id: string;
  
  // Configuration partage
  sharing_enabled: boolean;
  lyxalsuite_percentage: number; // Ex: 5%
  tenant_percentage: number; // Ex: 95%
  
  // Seuils
  minimum_revenue_threshold: number; // Ex: €1000/mois
  sharing_starts_after_months: number; // Ex: 6 mois
}

@Injectable()
export class RevenueSharingService {
  
  @Cron('0 0 1 * *') // Calcul mensuel
  async processRevenueSharing() {
    const eligibleSaaS = await this.getEligibleSaaSForSharing();
    
    for (const saas of eligibleSaaS) {
      await this.calculateAndProcessSharing(saas.id);
    }
  }
  
  async calculateAndProcessSharing(saasId: string) {
    // 1. Calcul revenus client final du mois
    const monthlyRevenue = await this.getMonthlyRevenue(saasId);
    
    // 2. Vérification seuils
    const sharingConfig = await this.getSharingConfig(saasId);
    
    if (monthlyRevenue < sharingConfig.minimum_revenue_threshold) {
      return; // Pas de partage si sous le seuil
    }
    
    // 3. Calcul parts
    const lyxalsuiteShare = monthlyRevenue * (sharingConfig.lyxalsuite_percentage / 100);
    const tenantShare = monthlyRevenue * (sharingConfig.tenant_percentage / 100);
    
    // 4. Prélèvement part LyxalSuite
    await this.processRevenueSharingPayment(saasId, lyxalsuiteShare);
    
    // 5. Reporting
    await this.createSharingReport(saasId, {
      period: this.getCurrentPeriod(),
      total_revenue: monthlyRevenue,
      lyxalsuite_share: lyxalsuiteShare,
      tenant_share: tenantShare
    });
  }
}
```

## 📊 Analytics financières

### Dashboard tenant
```typescript
@Injectable()
export class TenantFinancialAnalytics {
  
  async getTenantFinancialDashboard(tenantId: string) {
    return {
      // Coûts LyxalSuite
      monthly_lyxalsuite_cost: await this.getMonthlyLyxalSuiteCost(tenantId),
      yearly_lyxalsuite_cost: await this.getYearlyLyxalSuiteCost(tenantId),
      
      // Revenus clients finaux
      monthly_client_revenue: await this.getMonthlyClientRevenue(tenantId),
      yearly_client_revenue: await this.getYearlyClientRevenue(tenantId),
      
      // Profitabilité
      monthly_profit: await this.getMonthlyProfit(tenantId),
      profit_margin: await this.getProfitMargin(tenantId),
      roi: await this.getROI(tenantId),
      
      // Métriques SaaS
      saas_performance: await this.getSaaSPerformance(tenantId),
      churn_rate: await this.getChurnRate(tenantId),
      ltv_cac_ratio: await this.getLTVCACRatio(tenantId),
      
      // Prévisions
      revenue_forecast: await this.getRevenueForecast(tenantId),
      growth_rate: await this.getGrowthRate(tenantId)
    };
  }
  
  async getSaaSProfitability(saasId: string) {
    const costs = await this.getSaaSCosts(saasId);
    const revenue = await this.getSaaSRevenue(saasId);
    
    return {
      monthly_revenue: revenue.monthly,
      monthly_costs: costs.monthly,
      monthly_profit: revenue.monthly - costs.monthly,
      profit_margin: ((revenue.monthly - costs.monthly) / revenue.monthly) * 100,
      
      // Détail coûts
      lyxalsuite_cost: costs.lyxalsuite_fee,
      infrastructure_cost: costs.infrastructure,
      support_cost: costs.support,
      
      // Métriques clients
      mrr: revenue.mrr,
      arr: revenue.arr,
      active_subscriptions: revenue.active_subscriptions,
      average_revenue_per_user: revenue.arpu
    };
  }
}
```

### Rapports automatiques
```typescript
@Injectable()
export class FinancialReportingService {
  
  @Cron('0 9 1 * *') // 1er du mois à 9h
  async sendMonthlyFinancialReport() {
    const tenants = await this.getAllTenants();
    
    for (const tenant of tenants) {
      const report = await this.generateMonthlyReport(tenant.id);
      await this.sendReportEmail(tenant.email, report);
    }
  }
  
  async generateMonthlyReport(tenantId: string) {
    const analytics = await this.getTenantFinancialAnalytics(tenantId);
    
    return {
      tenant_id: tenantId,
      period: this.getCurrentPeriod(),
      
      // Résumé exécutif
      executive_summary: {
        total_revenue: analytics.monthly_client_revenue,
        total_costs: analytics.monthly_lyxalsuite_cost,
        net_profit: analytics.monthly_profit,
        profit_margin: analytics.profit_margin
      },
      
      // Performance SaaS
      saas_breakdown: analytics.saas_performance,
      
      // Tendances
      growth_metrics: {
        revenue_growth: analytics.growth_rate,
        new_saas_created: await this.getNewSaaSCount(tenantId),
        client_acquisition: await this.getClientAcquisition(tenantId)
      },
      
      // Recommandations IA
      recommendations: await this.generateRecommendations(tenantId, analytics)
    };
  }
}
```

## 🎯 Optimisation pricing

### A/B Testing prix
```typescript
@Injectable()
export class PricingOptimizationService {
  
  async runPricingExperiment(
    saasId: string,
    experimentConfig: PricingExperiment
  ) {
    // Création variantes prix
    const variants = await this.createPricingVariants(
      saasId,
      experimentConfig
    );
    
    // Attribution aléatoire visiteurs
    await this.setupTrafficSplit(saasId, variants);
    
    // Tracking conversions
    await this.trackConversions(saasId, variants);
    
    return {
      experiment_id: this.generateExperimentId(),
      variants: variants,
      duration_days: experimentConfig.duration_days,
      success_metric: experimentConfig.success_metric
    };
  }
  
  async analyzePricingResults(experimentId: string) {
    const results = await this.getExperimentResults(experimentId);
    
    return {
      winning_variant: results.best_performing_variant,
      conversion_rates: results.conversion_rates,
      revenue_impact: results.revenue_impact,
      statistical_significance: results.p_value < 0.05,
      recommendation: this.generatePricingRecommendation(results)
    };
  }
}
```

---

**💰 Pricing LyxalSuite : Modèle scalable pour tous les acteurs de l'écosystème** 