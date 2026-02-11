# 📞 LyxalCRM - Module Relation Client

## 🎯 Vue d'ensemble

**LyxalCRM** est le module de gestion de la relation client de LyxalSuite, adapté automatiquement selon l'industrie du SaaS (restaurant, finance, e-commerce, etc.).

## 🏗️ Architecture modulaire

### Structure adaptative
```
LyxalCRM Module
├── 🏭 Core CRM (base commune)
│   ├── Contacts/Customers
│   ├── Pipeline management
│   ├── Activities & Tasks
│   └── Communications
│
├── 🎨 Industry Adapters
│   ├── Restaurant CRM
│   ├── Finance CRM  
│   ├── E-commerce CRM
│   └── Healthcare CRM
│
└── 🔌 Integrations
    ├── Email providers
    ├── SMS services
    └── Calendar systems
```

## 🍽️ Restaurant CRM

### Entités spécifiques
```typescript
// Customer restaurant avec données spécifiques
interface RestaurantCustomer extends BaseCustomer {
  // Données restaurant
  dietary_restrictions: string[];
  favorite_dishes: string[];
  average_spend: number;
  visit_frequency: 'weekly' | 'monthly' | 'occasional';
  preferred_table: string;
  special_occasions: SpecialOccasion[];
  
  // Préférences
  preferred_time_slots: TimeSlot[];
  party_size_usual: number;
  communication_preferences: {
    reservation_reminders: boolean;
    promotional_offers: boolean;
    birthday_offers: boolean;
  };
  
  // Historique
  reservations: Reservation[];
  orders: Order[];
  reviews: Review[];
  loyalty_points: number;
}

// Réservations intégrées au CRM
interface Reservation {
  id: string;
  customer_id: string;
  date: Date;
  time: string;
  party_size: number;
  table_number?: string;
  status: 'confirmed' | 'seated' | 'completed' | 'cancelled' | 'no_show';
  special_requests: string;
  occasion?: 'birthday' | 'anniversary' | 'business' | 'date';
  created_at: Date;
}
```

### Pipeline restaurant
```typescript
// Pipeline adapté restaurant
const RESTAURANT_PIPELINE = [
  {
    stage: 'prospect',
    name: 'Prospect',
    description: 'Nouveau contact, jamais venu',
    actions: ['send_welcome_offer', 'schedule_callback']
  },
  {
    stage: 'first_visit',
    name: 'Première visite',
    description: 'Client venu une fois',
    actions: ['collect_feedback', 'send_thank_you']
  },
  {
    stage: 'regular',
    name: 'Client régulier',
    description: 'Vient régulièrement',
    actions: ['loyalty_program', 'personalized_offers']
  },
  {
    stage: 'vip',
    name: 'Client VIP',
    description: 'Client haute valeur',
    actions: ['priority_booking', 'exclusive_events']
  },
  {
    stage: 'inactive',
    name: 'Inactif',
    description: 'Pas venu depuis 3+ mois',
    actions: ['win_back_campaign', 'special_discount']
  }
];

// Service CRM Restaurant
@Injectable()
export class RestaurantCRMService extends BaseCRMService {
  
  async createCustomer(
    customerData: CreateRestaurantCustomerDto,
    workspaceId: string
  ): Promise<RestaurantCustomer> {
    
    // 1. Création customer de base
    const baseCustomer = await super.createCustomer(customerData, workspaceId);
    
    // 2. Ajout données restaurant
    const restaurantCustomer = await this.db.update(
      `ws_${workspaceId}.customers:${baseCustomer.id}`
    ).set({
      dietary_restrictions: customerData.dietary_restrictions || [],
      favorite_dishes: [],
      average_spend: 0,
      visit_frequency: 'occasional',
      loyalty_points: 0,
      pipeline_stage: 'prospect'
    });
    
    // 3. Déclenchement workflow bienvenue
    await this.workflowService.trigger('restaurant_welcome', {
      customer_id: baseCustomer.id,
      workspace_id: workspaceId
    });
    
    return restaurantCustomer;
  }
  
  async updateCustomerFromReservation(
    customerId: string,
    reservation: Reservation,
    workspaceId: string
  ) {
    const customer = await this.getCustomer(customerId, workspaceId);
    
    // Mise à jour automatique du pipeline
    const newStage = this.calculatePipelineStage(customer, reservation);
    
    await this.db.update(`ws_${workspaceId}.customers:${customerId}`).set({
      pipeline_stage: newStage,
      last_visit: reservation.date,
      total_visits: customer.total_visits + 1
    });
    
    // Déclenchement actions automatiques
    await this.triggerStageActions(customerId, newStage, workspaceId);
  }
  
  private calculatePipelineStage(
    customer: RestaurantCustomer,
    reservation: Reservation
  ): string {
    if (customer.total_visits === 0) return 'first_visit';
    if (customer.total_visits >= 10 && customer.average_spend > 50) return 'vip';
    if (customer.visit_frequency === 'weekly') return 'regular';
    
    const daysSinceLastVisit = this.daysSince(customer.last_visit);
    if (daysSinceLastVisit > 90) return 'inactive';
    
    return 'regular';
  }
}
```

## 💰 Finance CRM

### Entités spécifiques
```typescript
// Client finance avec données spécifiques
interface FinanceCustomer extends BaseCustomer {
  // Profil financier
  risk_profile: 'conservative' | 'moderate' | 'aggressive';
  investment_goals: string[];
  time_horizon: 'short' | 'medium' | 'long';
  liquidity_needs: 'low' | 'medium' | 'high';
  
  // Patrimoine
  net_worth: number;
  annual_income: number;
  investment_experience: 'beginner' | 'intermediate' | 'expert';
  
  // Portefeuille
  portfolios: Portfolio[];
  total_aum: number; // Assets Under Management
  
  // Relation
  advisor_id: string;
  onboarding_completed: boolean;
  kyc_status: 'pending' | 'approved' | 'rejected';
  last_review_date: Date;
  next_review_date: Date;
}

// Pipeline finance
const FINANCE_PIPELINE = [
  {
    stage: 'lead',
    name: 'Prospect',
    description: 'Contact initial, intérêt exprimé',
    actions: ['schedule_discovery_call', 'send_welcome_package']
  },
  {
    stage: 'qualified',
    name: 'Qualifié',
    description: 'Profil validé, besoins identifiés',
    actions: ['complete_risk_assessment', 'prepare_proposal']
  },
  {
    stage: 'proposal',
    name: 'Proposition',
    description: 'Proposition envoyée',
    actions: ['follow_up_proposal', 'schedule_review_meeting']
  },
  {
    stage: 'client',
    name: 'Client',
    description: 'Contrat signé, portefeuille actif',
    actions: ['quarterly_review', 'performance_report']
  },
  {
    stage: 'dormant',
    name: 'Dormant',
    description: 'Client inactif',
    actions: ['reactivation_campaign', 'check_satisfaction']
  }
];
```

### Service Finance CRM
```typescript
@Injectable()
export class FinanceCRMService extends BaseCRMService {
  
  async createFinanceClient(
    clientData: CreateFinanceClientDto,
    advisorId: string,
    workspaceId: string
  ): Promise<FinanceCustomer> {
    
    const client = await this.createCustomer({
      ...clientData,
      advisor_id: advisorId,
      pipeline_stage: 'lead',
      kyc_status: 'pending'
    }, workspaceId);
    
    // Déclenchement processus KYC
    await this.kycService.initiate(client.id, workspaceId);
    
    // Assignation à l'advisor
    await this.assignToAdvisor(client.id, advisorId, workspaceId);
    
    return client;
  }
  
  async completeRiskAssessment(
    clientId: string,
    riskData: RiskAssessmentData,
    workspaceId: string
  ) {
    await this.db.update(`ws_${workspaceId}.customers:${clientId}`).set({
      risk_profile: riskData.risk_profile,
      investment_goals: riskData.goals,
      time_horizon: riskData.time_horizon,
      pipeline_stage: 'qualified'
    });
    
    // Génération proposition automatique
    await this.proposalService.generate(clientId, riskData, workspaceId);
  }
  
  async scheduleReview(
    clientId: string,
    reviewType: 'quarterly' | 'annual' | 'ad_hoc',
    workspaceId: string
  ) {
    const client = await this.getCustomer(clientId, workspaceId);
    
    const review = await this.db.create(`ws_${workspaceId}.reviews`).set({
      client_id: clientId,
      advisor_id: client.advisor_id,
      type: reviewType,
      status: 'scheduled',
      scheduled_date: this.calculateNextReviewDate(reviewType),
      agenda: this.generateReviewAgenda(client, reviewType)
    });
    
    // Notification advisor
    await this.notificationService.notify(client.advisor_id, 'review_scheduled', {
      client_name: client.name,
      review_date: review.scheduled_date
    });
    
    return review;
  }
}
```

## 🛒 E-commerce CRM

### Entités spécifiques
```typescript
// Customer e-commerce
interface EcommerceCustomer extends BaseCustomer {
  // Comportement achat
  total_orders: number;
  total_spent: number;
  average_order_value: number;
  lifetime_value: number;
  
  // Préférences
  favorite_categories: string[];
  preferred_brands: string[];
  size_preferences: Record<string, string>;
  
  // Segmentation
  customer_segment: 'new' | 'regular' | 'vip' | 'at_risk' | 'churned';
  rfm_score: {
    recency: number;
    frequency: number;
    monetary: number;
  };
  
  // Marketing
  email_subscribed: boolean;
  sms_subscribed: boolean;
  push_subscribed: boolean;
  abandoned_carts: AbandonedCart[];
  wishlist: WishlistItem[];
}

// Pipeline e-commerce
const ECOMMERCE_PIPELINE = [
  {
    stage: 'visitor',
    name: 'Visiteur',
    description: 'Visite le site, pas encore client',
    actions: ['capture_email', 'show_welcome_popup']
  },
  {
    stage: 'cart',
    name: 'Panier',
    description: 'A ajouté des produits au panier',
    actions: ['send_cart_reminder', 'offer_discount']
  },
  {
    stage: 'first_order',
    name: 'Première commande',
    description: 'A passé sa première commande',
    actions: ['welcome_series', 'request_review']
  },
  {
    stage: 'repeat',
    name: 'Client récurrent',
    description: 'Plusieurs commandes',
    actions: ['loyalty_program', 'personalized_recommendations']
  },
  {
    stage: 'vip',
    name: 'Client VIP',
    description: 'Haute valeur, très fidèle',
    actions: ['exclusive_access', 'personal_shopper']
  }
];
```

## 🏥 Healthcare CRM

### Entités spécifiques
```typescript
// Patient healthcare
interface HealthcarePatient extends BaseCustomer {
  // Informations médicales
  date_of_birth: Date;
  gender: 'male' | 'female' | 'other';
  blood_type?: string;
  allergies: string[];
  chronic_conditions: string[];
  emergency_contact: EmergencyContact;
  
  // Assurance
  insurance_provider: string;
  insurance_number: string;
  insurance_expiry: Date;
  
  // Historique
  appointments: Appointment[];
  medical_records: MedicalRecord[];
  prescriptions: Prescription[];
  
  // Préférences
  preferred_doctor: string;
  preferred_appointment_times: TimeSlot[];
  communication_preferences: {
    appointment_reminders: boolean;
    health_tips: boolean;
    prescription_reminders: boolean;
  };
}
```

## 🔧 Configuration par industrie

### Service de configuration automatique
```typescript
@Injectable()
export class CRMConfigurationService {
  
  async configureCRMForIndustry(
    saasId: string,
    industry: string,
    workspaceId: string
  ): Promise<CRMConfig> {
    
    const config = INDUSTRY_CRM_CONFIGS[industry];
    
    // 1. Configuration pipeline
    await this.setupPipeline(workspaceId, config.pipeline);
    
    // 2. Configuration champs custom
    await this.setupCustomFields(workspaceId, config.custom_fields);
    
    // 3. Configuration workflows
    await this.setupWorkflows(workspaceId, config.workflows);
    
    // 4. Configuration rapports
    await this.setupReports(workspaceId, config.reports);
    
    return config;
  }
  
  private async setupPipeline(
    workspaceId: string,
    pipelineConfig: PipelineConfig
  ) {
    for (const stage of pipelineConfig.stages) {
      await this.db.create(`ws_${workspaceId}.pipeline_stages`).set({
        name: stage.name,
        description: stage.description,
        order: stage.order,
        actions: stage.actions,
        automation_rules: stage.automation_rules
      });
    }
  }
}

// Configurations par industrie
const INDUSTRY_CRM_CONFIGS = {
  restaurant: {
    pipeline: RESTAURANT_PIPELINE,
    custom_fields: [
      { name: 'dietary_restrictions', type: 'array' },
      { name: 'favorite_dishes', type: 'array' },
      { name: 'preferred_table', type: 'string' }
    ],
    workflows: [
      'restaurant_welcome',
      'birthday_reminder',
      'loyalty_points_update'
    ],
    reports: [
      'customer_lifetime_value',
      'visit_frequency_analysis',
      'dietary_preferences_report'
    ]
  },
  
  finance: {
    pipeline: FINANCE_PIPELINE,
    custom_fields: [
      { name: 'risk_profile', type: 'enum' },
      { name: 'net_worth', type: 'number' },
      { name: 'investment_goals', type: 'array' }
    ],
    workflows: [
      'kyc_process',
      'quarterly_review_reminder',
      'portfolio_rebalancing_alert'
    ],
    reports: [
      'aum_growth',
      'client_risk_distribution',
      'advisor_performance'
    ]
  }
};
```

## 📊 Analytics CRM

### Métriques par industrie
```typescript
@Injectable()
export class CRMAnalyticsService {
  
  async getRestaurantMetrics(workspaceId: string) {
    return {
      // Métriques restaurant
      total_customers: await this.getCustomerCount(workspaceId),
      repeat_customer_rate: await this.getRepeatCustomerRate(workspaceId),
      average_visit_frequency: await this.getAverageVisitFrequency(workspaceId),
      customer_lifetime_value: await this.getCustomerLTV(workspaceId),
      
      // Segmentation
      customer_segments: await this.getCustomerSegments(workspaceId),
      dietary_preferences: await this.getDietaryPreferences(workspaceId),
      
      // Tendances
      new_customers_trend: await this.getNewCustomersTrend(workspaceId),
      loyalty_points_distribution: await this.getLoyaltyPointsDistribution(workspaceId)
    };
  }
  
  async getFinanceMetrics(workspaceId: string) {
    return {
      // Métriques finance
      total_clients: await this.getClientCount(workspaceId),
      total_aum: await this.getTotalAUM(workspaceId),
      average_portfolio_size: await this.getAveragePortfolioSize(workspaceId),
      client_acquisition_cost: await this.getClientAcquisitionCost(workspaceId),
      
      // Performance
      portfolio_performance: await this.getPortfolioPerformance(workspaceId),
      advisor_productivity: await this.getAdvisorProductivity(workspaceId),
      
      // Risk
      risk_distribution: await this.getRiskDistribution(workspaceId),
      compliance_status: await this.getComplianceStatus(workspaceId)
    };
  }
}
```

## 🔄 Intégrations

### Email marketing
```typescript
@Injectable()
export class CRMEmailService {
  
  async sendIndustryEmail(
    customerId: string,
    templateType: string,
    workspaceId: string
  ) {
    const customer = await this.getCustomer(customerId, workspaceId);
    const saasConfig = await this.getSaasConfig(workspaceId);
    
    // Template adapté à l'industrie
    const template = await this.getIndustryTemplate(
      saasConfig.industry,
      templateType
    );
    
    // Personnalisation selon données client
    const personalizedContent = await this.personalizeContent(
      template,
      customer,
      saasConfig.industry
    );
    
    return await this.emailService.send({
      to: customer.email,
      subject: personalizedContent.subject,
      html: personalizedContent.html,
      branding: saasConfig.branding
    });
  }
}
```

---

**📞 LyxalCRM : Un CRM qui s'adapte automatiquement à votre industrie** 