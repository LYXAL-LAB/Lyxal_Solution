-- ================================================================================================
-- 📊 LYXAL BASE - INDEX DE PERFORMANCE OPTIMISÉS
-- ================================================================================================
-- Module : lyxal-base
-- Description : Index optimisés pour 24 entités et 23 relations IA-native
-- Version : 1.0.0
-- Architecture : Performance maximale avec intelligence artificielle
-- ================================================================================================

-- ================================================================================================
-- 🌍 INDEX ENTITÉS DE RÉFÉRENCE GÉOGRAPHIQUE
-- ================================================================================================

-- Index: country
DEFINE INDEX country_code_idx ON country FIELDS code UNIQUE;
DEFINE INDEX country_alpha2_idx ON country FIELDS alpha2Code UNIQUE;
DEFINE INDEX country_alpha3_idx ON country FIELDS alpha3Code UNIQUE;
DEFINE INDEX country_default_idx ON country FIELDS isDefault, isObsolete;
DEFINE INDEX country_ai_potential_idx ON country FIELDS aiPredictions.marketPotential;
DEFINE INDEX country_economic_idx ON country FIELDS geoIntelligence.economicIndicators.gdp;
DEFINE INDEX country_risk_idx ON country FIELDS geoIntelligence.riskFactors.politicalStability;

-- ================================================================================================
-- 💰 INDEX ENTITÉS FINANCIÈRES DE BASE
-- ================================================================================================

-- Index: currency
DEFINE INDEX currency_code_idx ON currency FIELDS code UNIQUE;
DEFINE INDEX currency_default_active_idx ON currency FIELDS isDefault, isActive;
DEFINE INDEX currency_rate_idx ON currency FIELDS exchangeRateAI.currentRate;
DEFINE INDEX currency_trend_idx ON currency FIELDS exchangeRateAI.trend;
DEFINE INDEX currency_volatility_idx ON currency FIELDS exchangeRateAI.volatility;
DEFINE INDEX currency_prediction_idx ON currency FIELDS economicPredictions.futureRate;
DEFINE INDEX currency_risk_idx ON currency FIELDS economicPredictions.riskAssessment;

-- Index: unit
DEFINE INDEX unit_code_idx ON unit FIELDS code UNIQUE;
DEFINE INDEX unit_type_default_idx ON unit FIELDS unitType, isDefault;
DEFINE INDEX unit_conversion_idx ON unit FIELDS baseUnit, conversionRate;
DEFINE INDEX unit_ai_accuracy_idx ON unit FIELDS conversionAI.accuracyScore;
DEFINE INDEX unit_usage_frequency_idx ON unit FIELDS conversionAI.usageFrequency;
DEFINE INDEX unit_optimization_idx ON unit FIELDS aiOptimizations.processingEfficiency;

-- ================================================================================================
-- 🏢 INDEX ENTITÉS PRINCIPALES
-- ================================================================================================

-- Index: company
DEFINE INDEX company_code_idx ON company FIELDS code UNIQUE;
DEFINE INDEX company_name_idx ON company FIELDS name;
DEFINE INDEX company_country_idx ON company FIELDS country;
DEFINE INDEX company_sector_idx ON company FIELDS sector, businessModel;
DEFINE INDEX company_size_idx ON company FIELDS size, employeeCount;
DEFINE INDEX company_active_idx ON company FIELDS archived;
DEFINE INDEX company_currency_idx ON company FIELDS defaultCurrency;
DEFINE INDEX company_hierarchy_idx ON company FIELDS parentCompany, isHeadquarters;
-- Index IA avancés
DEFINE INDEX company_ai_confidence_idx ON company FIELDS aiProfile.confidence;
DEFINE INDEX company_ai_quality_idx ON company FIELDS aiProfile.dataQuality;
DEFINE INDEX company_ai_risk_idx ON company FIELDS aiProfile.riskScore;
DEFINE INDEX company_performance_idx ON company FIELDS aiMetrics.performanceScore;
DEFINE INDEX company_growth_idx ON company FIELDS aiInsights.marketPosition;
DEFINE INDEX company_predictions_idx ON company FIELDS aiPredictions.growthForecast;

-- Index: address
DEFINE INDEX address_zip_idx ON address FIELDS zip;
DEFINE INDEX address_city_idx ON address FIELDS city;
DEFINE INDEX address_country_idx ON address FIELDS country;
DEFINE INDEX address_coordinates_idx ON address FIELDS latitude, longitude;
DEFINE INDEX address_geo_quality_idx ON address FIELDS geoIntelligence.addressQuality;
DEFINE INDEX address_geo_validation_idx ON address FIELDS geoIntelligence.validationStatus;
DEFINE INDEX address_delivery_risk_idx ON address FIELDS geoIntelligence.deliveryRisk;
DEFINE INDEX address_accessibility_idx ON address FIELDS geoIntelligence.accessibilityScore;
DEFINE INDEX address_logistics_idx ON address FIELDS logisticsAI.riskAssessment;

-- Index: partner
DEFINE INDEX partner_name_idx ON partner FIELDS name;
DEFINE INDEX partner_email_idx ON partner FIELDS emailAddress;
DEFINE INDEX partner_company_type_idx ON partner FIELDS isCompany;
DEFINE INDEX partner_status_idx ON partner FIELDS isActive, archived, blocked;
DEFINE INDEX partner_country_idx ON partner FIELDS country;
DEFINE INDEX partner_hierarchy_idx ON partner FIELDS parentPartner;
DEFINE INDEX partner_tags_idx ON partner FIELDS tags;
-- Index IA révolutionnaires
DEFINE INDEX partner_ai_confidence_idx ON partner FIELDS aiProfile.confidence;
DEFINE INDEX partner_ai_quality_idx ON partner FIELDS aiProfile.dataQuality;
DEFINE INDEX partner_ai_risk_idx ON partner FIELDS aiProfile.riskScore;
DEFINE INDEX partner_ai_segmentation_idx ON partner FIELDS aiProfile.segmentation;
DEFINE INDEX partner_embeddings_idx ON partner FIELDS embeddings;
DEFINE INDEX partner_engagement_idx ON partner FIELDS aiInsights.engagement;
DEFINE INDEX partner_lifetime_value_idx ON partner FIELDS aiInsights.lifetime_value;
DEFINE INDEX partner_churn_risk_idx ON partner FIELDS aiInsights.churn_risk;
DEFINE INDEX partner_growth_potential_idx ON partner FIELDS aiInsights.growth_potential;
DEFINE INDEX partner_relationship_strength_idx ON partner FIELDS aiInsights.relationship_strength;
DEFINE INDEX partner_completion_score_idx ON partner FIELDS aiMetrics.completionScore;
DEFINE INDEX partner_activity_score_idx ON partner FIELDS aiMetrics.activityScore;
DEFINE INDEX partner_engagement_score_idx ON partner FIELDS aiMetrics.engagementScore;
DEFINE INDEX partner_loyalty_score_idx ON partner FIELDS aiMetrics.loyaltyScore;
DEFINE INDEX partner_profitability_score_idx ON partner FIELDS aiMetrics.profitabilityScore;
DEFINE INDEX partner_churn_probability_idx ON partner FIELDS aiPredictions.churn_probability;

-- ================================================================================================
-- 📦 INDEX ENTITÉS PRODUITS
-- ================================================================================================

-- Index: product_category
DEFINE INDEX product_category_code_idx ON product_category FIELDS code UNIQUE;
DEFINE INDEX product_category_name_idx ON product_category FIELDS name;
DEFINE INDEX product_category_parent_idx ON product_category FIELDS parentCategory;
DEFINE INDEX product_category_level_idx ON product_category FIELDS level, isLeaf;
DEFINE INDEX product_category_active_idx ON product_category FIELDS archived;
-- Index IA classification
DEFINE INDEX category_ai_confidence_idx ON product_category FIELDS classificationAI.confidenceThreshold;
DEFINE INDEX category_ai_misclassification_idx ON product_category FIELDS classificationAI.misclassificationRate;
DEFINE INDEX category_product_count_idx ON product_category FIELDS categoryMetrics.productCount;
DEFINE INDEX category_revenue_idx ON product_category FIELDS categoryMetrics.totalRevenue;
DEFINE INDEX category_margin_idx ON product_category FIELDS categoryMetrics.averageMargin;

-- Index: product
DEFINE INDEX product_code_idx ON product FIELDS code UNIQUE;
DEFINE INDEX product_name_idx ON product FIELDS name;
DEFINE INDEX product_category_idx ON product FIELDS productCategory;
DEFINE INDEX product_type_idx ON product FIELDS productType;
DEFINE INDEX product_price_idx ON product FIELDS salePrice, costPrice;
DEFINE INDEX product_currency_idx ON product FIELDS currency;
DEFINE INDEX product_unit_idx ON product FIELDS unit, saleUnit, purchaseUnit;
DEFINE INDEX product_status_idx ON product FIELDS isActive, sellable, purchasable, archived;
-- Index IA produit
DEFINE INDEX product_ai_demand_idx ON product FIELDS productAI.demandForecast;
DEFINE INDEX product_ai_price_optimization_idx ON product FIELDS productAI.priceOptimization.suggestedPrice;
DEFINE INDEX product_ai_market_share_idx ON product FIELDS productAI.marketAnalysis.marketShare;
DEFINE INDEX product_performance_sales_idx ON product FIELDS performanceMetrics.salesVolume;
DEFINE INDEX product_performance_revenue_idx ON product FIELDS performanceMetrics.revenue;
DEFINE INDEX product_performance_margin_idx ON product FIELDS performanceMetrics.margin;
DEFINE INDEX product_performance_satisfaction_idx ON product FIELDS performanceMetrics.customerSatisfaction;

-- ================================================================================================
-- 💳 INDEX ENTITÉS FINANCIÈRES AVANCÉES
-- ================================================================================================

-- Index: tax
DEFINE INDEX tax_code_idx ON tax FIELDS code UNIQUE;
DEFINE INDEX tax_name_idx ON tax FIELDS name;
DEFINE INDEX tax_type_idx ON tax FIELDS taxType;
DEFINE INDEX tax_rate_idx ON tax FIELDS rate;
DEFINE INDEX tax_country_idx ON tax FIELDS country;
DEFINE INDEX tax_status_idx ON tax FIELDS isActive;
DEFINE INDEX tax_validity_idx ON tax FIELDS validFrom, validTo;
-- Index IA fiscale
DEFINE INDEX tax_compliance_score_idx ON tax FIELDS taxComplianceAI.complianceScore;
DEFINE INDEX tax_risk_level_idx ON tax FIELDS taxComplianceAI.riskLevel;
DEFINE INDEX tax_audit_risk_idx ON tax FIELDS taxComplianceAI.auditRisk;
DEFINE INDEX tax_total_collected_idx ON tax FIELDS taxAnalytics.totalCollected;
DEFINE INDEX tax_application_frequency_idx ON tax FIELDS taxAnalytics.applicationFrequency;

-- Index: account
DEFINE INDEX account_code_idx ON account FIELDS code UNIQUE;
DEFINE INDEX account_name_idx ON account FIELDS name;
DEFINE INDEX account_type_idx ON account FIELDS accountType;
DEFINE INDEX account_parent_idx ON account FIELDS parentAccount;
DEFINE INDEX account_company_idx ON account FIELDS company;
DEFINE INDEX account_currency_idx ON account FIELDS currency;
DEFINE INDEX account_status_idx ON account FIELDS isActive, allowReconciliation;
-- Index IA comptable
DEFINE INDEX account_ai_balance_trend_idx ON account FIELDS accountingAI.balanceTrend;
DEFINE INDEX account_ai_forecast_idx ON account FIELDS accountingAI.forecastBalance;
DEFINE INDEX account_ai_risk_idx ON account FIELDS accountingAI.riskAssessment;
DEFINE INDEX account_ai_compliance_idx ON account FIELDS accountingAI.complianceStatus;
DEFINE INDEX account_balance_idx ON account FIELDS financialAnalytics.currentBalance;
DEFINE INDEX account_turnover_idx ON account FIELDS financialAnalytics.turnoverRate;

-- ================================================================================================
-- 🔢 INDEX ENTITÉS DE SÉQUENÇAGE
-- ================================================================================================

-- Index: sequence
DEFINE INDEX sequence_code_idx ON sequence FIELDS code UNIQUE;
DEFINE INDEX sequence_name_idx ON sequence FIELDS name;
DEFINE INDEX sequence_company_idx ON sequence FIELDS company;
DEFINE INDEX sequence_status_idx ON sequence FIELDS isActive;
DEFINE INDEX sequence_reset_idx ON sequence FIELDS resetYearly, resetMonthly;
DEFINE INDEX sequence_next_num_idx ON sequence FIELDS nextNum;
-- Index IA séquence
DEFINE INDEX sequence_ai_usage_pattern_idx ON sequence FIELDS sequenceAI.peakUsage;
DEFINE INDEX sequence_ai_collision_risk_idx ON sequence FIELDS sequenceAI.collisionRisk;
DEFINE INDEX sequence_ai_forecast_idx ON sequence FIELDS sequenceAI.forecastUsage;
DEFINE INDEX sequence_total_generated_idx ON sequence FIELDS usageAnalytics.totalGenerated;

-- ================================================================================================
-- 🏦 INDEX ENTITÉS BANCAIRES ET PAIEMENTS
-- ================================================================================================

-- Index: bank_detail
DEFINE INDEX bank_detail_code_idx ON bank_detail FIELDS code UNIQUE;
DEFINE INDEX bank_detail_name_idx ON bank_detail FIELDS bankName;
DEFINE INDEX bank_detail_account_idx ON bank_detail FIELDS accountNumber;
DEFINE INDEX bank_detail_iban_idx ON bank_detail FIELDS iban;
DEFINE INDEX bank_detail_bic_idx ON bank_detail FIELDS bic;
DEFINE INDEX bank_detail_currency_idx ON bank_detail FIELDS currency;
DEFINE INDEX bank_detail_status_idx ON bank_detail FIELDS isDefault, isActive;
-- Index IA bancaire
DEFINE INDEX bank_ai_validation_idx ON bank_detail FIELDS bankingAI.validationScore;
DEFINE INDEX bank_ai_risk_idx ON bank_detail FIELDS bankingAI.riskLevel;
DEFINE INDEX bank_ai_security_idx ON bank_detail FIELDS bankingAI.securityScore;
DEFINE INDEX bank_transactions_idx ON bank_detail FIELDS bankAnalytics.totalTransactions;
DEFINE INDEX bank_utilization_idx ON bank_detail FIELDS bankAnalytics.utilisationRate;

-- Index: payment_term
DEFINE INDEX payment_term_code_idx ON payment_term FIELDS code UNIQUE;
DEFINE INDEX payment_term_name_idx ON payment_term FIELDS name;
DEFINE INDEX payment_term_mode_idx ON payment_term FIELDS paymentMode;
DEFINE INDEX payment_term_delay_idx ON payment_term FIELDS paymentDelay;
DEFINE INDEX payment_term_discount_idx ON payment_term FIELDS discountRate, discountDelay;
DEFINE INDEX payment_term_default_idx ON payment_term FIELDS isDefault;
-- Index IA paiement
DEFINE INDEX payment_ai_cashflow_idx ON payment_term FIELDS paymentAI.cashFlowImpact;
DEFINE INDEX payment_ai_risk_idx ON payment_term FIELDS paymentAI.riskAssessment;
DEFINE INDEX payment_ai_optimization_idx ON payment_term FIELDS paymentAI.optimizationScore;
DEFINE INDEX payment_compliance_rate_idx ON payment_term FIELDS paymentAnalytics.complianceRate;
DEFINE INDEX payment_late_rate_idx ON payment_term FIELDS paymentAnalytics.latePaymentRate;

-- Index: fiscal_position
DEFINE INDEX fiscal_position_code_idx ON fiscal_position FIELDS code UNIQUE;
DEFINE INDEX fiscal_position_name_idx ON fiscal_position FIELDS name;
DEFINE INDEX fiscal_position_country_idx ON fiscal_position FIELDS country;
DEFINE INDEX fiscal_position_default_idx ON fiscal_position FIELDS isDefault;
-- Index IA fiscal
DEFINE INDEX fiscal_ai_compliance_idx ON fiscal_position FIELDS fiscalAI.complianceLevel;
DEFINE INDEX fiscal_ai_risk_idx ON fiscal_position FIELDS fiscalAI.jurisdictionComplexity;

-- Index: price_list
DEFINE INDEX price_list_code_idx ON price_list FIELDS code UNIQUE;
DEFINE INDEX price_list_name_idx ON price_list FIELDS name;
DEFINE INDEX price_list_currency_idx ON price_list FIELDS currency;
DEFINE INDEX price_list_type_idx ON price_list FIELDS typeSelect;
DEFINE INDEX price_list_status_idx ON price_list FIELDS isDefault, isActive;
DEFINE INDEX price_list_validity_idx ON price_list FIELDS validFrom, validTo;
-- Index IA pricing
DEFINE INDEX price_ai_optimization_idx ON price_list FIELDS pricingAI.marginOptimization;

-- ================================================================================================
-- 🌐 INDEX ENTITÉS D'INTERNATIONALISATION
-- ================================================================================================

-- Index: translation
DEFINE INDEX translation_key_language_idx ON translation FIELDS key, language UNIQUE;
DEFINE INDEX translation_language_idx ON translation FIELDS language;
DEFINE INDEX translation_module_idx ON translation FIELDS module;
DEFINE INDEX translation_active_idx ON translation FIELDS isActive;
-- Index IA traduction
DEFINE INDEX translation_ai_confidence_idx ON translation FIELDS translationAI.confidenceScore;
DEFINE INDEX translation_ai_quality_idx ON translation FIELDS translationAI.qualityScore;
DEFINE INDEX translation_ai_method_idx ON translation FIELDS translationAI.translationMethod;
DEFINE INDEX translation_usage_idx ON translation FIELDS qualityAnalytics.usageFrequency;

-- Index: print_template
DEFINE INDEX print_template_code_idx ON print_template FIELDS code UNIQUE;
DEFINE INDEX print_template_name_idx ON print_template FIELDS name;
DEFINE INDEX print_template_type_idx ON print_template FIELDS templateType;
DEFINE INDEX print_template_format_idx ON print_template FIELDS format;
DEFINE INDEX print_template_status_idx ON print_template FIELDS isDefault, isActive;
-- Index IA design
DEFINE INDEX template_ai_branding_idx ON print_template FIELDS designAI.brandingCompliance;
DEFINE INDEX template_ai_readability_idx ON print_template FIELDS designAI.readabilityScore;
DEFINE INDEX template_usage_idx ON print_template FIELDS templateAnalytics.usageCount;

-- ⚠️ MIGRATION COMPLETE: notification_configuration et import_configuration
-- Ces index ont été déplacés vers @lyxal/config/system_configuration_indexes.surql
-- Date migration: 2025-06-26T15:30:31.009Z
-- Ne pas recréer ici pour éviter les doublons

-- Index: language
DEFINE INDEX language_code_idx ON language FIELDS code UNIQUE;
DEFINE INDEX language_name_idx ON language FIELDS name;
DEFINE INDEX language_status_idx ON language FIELDS isDefault, isActive;
DEFINE INDEX language_direction_idx ON language FIELDS direction;
-- Index IA linguistique
DEFINE INDEX language_ai_accuracy_idx ON language FIELDS linguisticAI.translationAccuracy;
DEFINE INDEX language_ai_complexity_idx ON language FIELDS linguisticAI.technicalComplexity;

-- ================================================================================================
-- 🔗 INDEX RELATIONS GRAPHE IA-ENHANCED
-- ================================================================================================

-- Index: has_contact (Partner → Contact)
DEFINE INDEX contact_relation_primary_idx ON has_contact FIELDS isPrimary, isActive;
DEFINE INDEX contact_relation_type_idx ON has_contact FIELDS contactType;
DEFINE INDEX contact_relation_score_idx ON has_contact FIELDS relationshipScore;
DEFINE INDEX contact_ai_strength_idx ON has_contact FIELDS aiProfile.relationshipStrength;
DEFINE INDEX contact_ai_frequency_idx ON has_contact FIELDS aiProfile.communicationFrequency;
DEFINE INDEX contact_ai_response_idx ON has_contact FIELDS aiProfile.responseRate;
DEFINE INDEX contact_metrics_interactions_idx ON has_contact FIELDS communicationMetrics.totalInteractions;
DEFINE INDEX contact_predictions_churn_idx ON has_contact FIELDS aiPredictions.churnRisk;

-- Index: has_address (Partner → Address)
DEFINE INDEX address_relation_type_idx ON has_address FIELDS isDefault, isDelivery, isInvoicing;
DEFINE INDEX address_geo_score_idx ON has_address FIELDS geoScore;
DEFINE INDEX address_geo_accessibility_idx ON has_address FIELDS geoIntelligence.accessibilityScore;
DEFINE INDEX address_geo_logistics_idx ON has_address FIELDS geoIntelligence.logisticsComplexity;
DEFINE INDEX address_usage_frequency_idx ON has_address FIELDS usageAnalytics.deliveryFrequency;
DEFINE INDEX address_usage_success_idx ON has_address FIELDS usageAnalytics.deliverySuccessRate;

-- Index: partners_hierarchy (Partner → Partner)
DEFINE INDEX hierarchy_type_idx ON partners_hierarchy FIELDS hierarchyType;
DEFINE INDEX hierarchy_control_idx ON partners_hierarchy FIELDS controlLevel;
DEFINE INDEX hierarchy_share_idx ON partners_hierarchy FIELDS sharePercentage;
DEFINE INDEX hierarchy_score_idx ON partners_hierarchy FIELDS hierarchyScore;
DEFINE INDEX hierarchy_ai_influence_idx ON partners_hierarchy FIELDS hierarchyIntelligence.decisionInfluence;
DEFINE INDEX hierarchy_ai_impact_idx ON partners_hierarchy FIELDS hierarchyIntelligence.economicImpact;
DEFINE INDEX hierarchy_ai_importance_idx ON partners_hierarchy FIELDS hierarchyIntelligence.strategicImportance;

-- Index: company_has_address (Company → Address)
DEFINE INDEX company_address_type_idx ON company_has_address FIELDS isHeadquarters, isBilling, isShipping, isLegal;
DEFINE INDEX company_address_ai_strategic_idx ON company_has_address FIELDS corporateGeoAI.strategicLocation;
DEFINE INDEX company_address_ai_efficiency_idx ON company_has_address FIELDS corporateGeoAI.operationalEfficiency;

-- Index: company_group (Company → Company)
DEFINE INDEX company_group_ownership_idx ON company_group FIELDS ownershipPercentage;
DEFINE INDEX company_group_consolidation_idx ON company_group FIELDS consolidationType;
DEFINE INDEX company_group_ai_synergies_idx ON company_group FIELDS groupIntelligence.synergiesRealization;
DEFINE INDEX company_group_ai_complexity_idx ON company_group FIELDS groupIntelligence.consolidationComplexity;

-- Index: product_in_category (Product → Category)
DEFINE INDEX product_category_primary_idx ON product_in_category FIELDS isPrimary;
DEFINE INDEX product_category_confidence_idx ON product_in_category FIELDS classificationConfidence;
DEFINE INDEX product_category_ai_auto_idx ON product_in_category FIELDS classificationAI.autoClassified;
DEFINE INDEX product_category_ai_method_idx ON product_in_category FIELDS classificationAI.classificationMethod;
DEFINE INDEX product_category_performance_idx ON product_in_category FIELDS categoryAnalytics.categoryPerformance;

-- Index: product_uses_unit (Product → Unit)
DEFINE INDEX product_unit_purpose_idx ON product_uses_unit FIELDS unitPurpose;
DEFINE INDEX product_unit_primary_idx ON product_uses_unit FIELDS isPrimary;
DEFINE INDEX product_unit_conversion_idx ON product_uses_unit FIELDS conversionFactor;
DEFINE INDEX product_unit_ai_efficiency_idx ON product_uses_unit FIELDS unitOptimizationAI.efficiencyScore;
DEFINE INDEX product_unit_ai_accuracy_idx ON product_uses_unit FIELDS unitOptimizationAI.conversionAccuracy;

-- Index: product_price (Product → Price List)
DEFINE INDEX product_price_value_idx ON product_price FIELDS price;
DEFINE INDEX product_price_quantity_idx ON product_price FIELDS minQuantity, maxQuantity;
DEFINE INDEX product_price_validity_idx ON product_price FIELDS validFrom, validTo;
DEFINE INDEX product_price_ai_elasticity_idx ON product_price FIELDS pricingAI.demandElasticity;
DEFINE INDEX product_price_ai_optimization_idx ON product_price FIELDS pricingAI.marginAnalysis;
DEFINE INDEX product_price_analytics_volume_idx ON product_price FIELDS priceAnalytics.salesVolume;
DEFINE INDEX product_price_analytics_margin_idx ON product_price FIELDS priceAnalytics.margin;
DEFINE INDEX product_price_predictions_optimal_idx ON product_price FIELDS pricePredictions.optimalPrice;

-- Index: company_uses_currency (Company → Currency)
DEFINE INDEX company_currency_default_idx ON company_uses_currency FIELDS isDefault;
DEFINE INDEX company_currency_purpose_idx ON company_uses_currency FIELDS usagePurpose;
DEFINE INDEX company_currency_ai_risk_idx ON company_uses_currency FIELDS exchangeRateAI.riskExposure;
DEFINE INDEX company_currency_ai_hedging_idx ON company_uses_currency FIELDS exchangeRateAI.costImpact;

-- Index: partner_payment_terms (Partner → Payment Term)
DEFINE INDEX partner_payment_default_idx ON partner_payment_terms FIELDS isDefault;
DEFINE INDEX partner_payment_negotiation_idx ON partner_payment_terms FIELDS negotiationLevel;
DEFINE INDEX partner_payment_ai_potential_idx ON partner_payment_terms FIELDS negotiationAI.negotiationPotential;
DEFINE INDEX partner_payment_ai_leverage_idx ON partner_payment_terms FIELDS negotiationAI.partnerLeverage;
DEFINE INDEX partner_payment_ai_risk_idx ON partner_payment_terms FIELDS negotiationAI.riskAssessment;
DEFINE INDEX partner_payment_compliance_idx ON partner_payment_terms FIELDS paymentAnalytics.complianceRate;

-- Index: company_banking (Company → Bank Detail)
DEFINE INDEX company_banking_main_idx ON company_banking FIELDS isMainAccount;
DEFINE INDEX company_banking_purpose_idx ON company_banking FIELDS accountPurpose;
DEFINE INDEX company_banking_limits_idx ON company_banking FIELDS creditLimit, overdraftLimit;
DEFINE INDEX company_banking_ai_optimization_idx ON company_banking FIELDS bankingAI.cashFlowOptimization;
DEFINE INDEX company_banking_ai_relationship_idx ON company_banking FIELDS bankingAI.bankRelationshipScore;
DEFINE INDEX company_banking_analytics_balance_idx ON company_banking FIELDS bankingAnalytics.averageBalance;

-- Index: company_sequences (Company → Sequence)
DEFINE INDEX company_sequence_default_idx ON company_sequences FIELDS isDefault;
DEFINE INDEX company_sequence_entity_idx ON company_sequences FIELDS entityType;
DEFINE INDEX company_sequence_ai_optimization_idx ON company_sequences FIELDS sequenceAI.usageOptimization;
DEFINE INDEX company_sequence_ai_scalability_idx ON company_sequences FIELDS sequenceAI.scalabilityAssessment;


-- Index: partner_fiscal_position (Partner → Fiscal Position)
DEFINE INDEX partner_fiscal_default_idx ON partner_fiscal_position FIELDS isDefault;
DEFINE INDEX partner_fiscal_validity_idx ON partner_fiscal_position FIELDS validFrom, validTo;
DEFINE INDEX partner_fiscal_ai_compliance_idx ON partner_fiscal_position FIELDS fiscalComplianceAI.complianceScore;
DEFINE INDEX partner_fiscal_ai_risk_idx ON partner_fiscal_position FIELDS fiscalComplianceAI.riskLevel;
DEFINE INDEX partner_fiscal_ai_audit_idx ON partner_fiscal_position FIELDS fiscalComplianceAI.auditRisk;
DEFINE INDEX partner_fiscal_analytics_efficiency_idx ON partner_fiscal_position FIELDS fiscalAnalytics.taxEfficiency;

-- Index: supplies (Partner → Product - Supply Chain)
DEFINE INDEX supplies_preferred_idx ON supplies FIELDS isPreferred, isActive;
DEFINE INDEX supplies_priority_idx ON supplies FIELDS priorityLevel;
DEFINE INDEX supplies_lead_time_idx ON supplies FIELDS leadTime;
DEFINE INDEX supplies_cost_idx ON supplies FIELDS unitCost;
DEFINE INDEX supplies_quantity_idx ON supplies FIELDS minimumOrderQuantity;
DEFINE INDEX supplies_score_idx ON supplies FIELDS supplierScore;
-- Index IA supply chain révolutionnaires
DEFINE INDEX supplies_ai_reliability_idx ON supplies FIELDS supplyChainAI.reliabilityScore;
DEFINE INDEX supplies_ai_quality_idx ON supplies FIELDS supplyChainAI.qualityScore;
DEFINE INDEX supplies_ai_cost_efficiency_idx ON supplies FIELDS supplyChainAI.costEfficiencyScore;
DEFINE INDEX supplies_ai_innovation_idx ON supplies FIELDS supplyChainAI.innovationScore;
DEFINE INDEX supplies_ai_sustainability_idx ON supplies FIELDS supplyChainAI.sustainabilityScore;
DEFINE INDEX supplies_ai_risk_idx ON supplies FIELDS supplyChainAI.riskScore;
DEFINE INDEX supplies_ai_partnership_idx ON supplies FIELDS supplyChainAI.partnershipPotential;
DEFINE INDEX supplies_ai_strategic_idx ON supplies FIELDS supplyChainAI.strategicValue;
DEFINE INDEX supplies_analytics_orders_idx ON supplies FIELDS supplierAnalytics.totalOrders;
DEFINE INDEX supplies_analytics_ontime_idx ON supplies FIELDS supplierAnalytics.onTimeDeliveries;
DEFINE INDEX supplies_analytics_quality_idx ON supplies FIELDS supplierAnalytics.qualityIncidents;
DEFINE INDEX supplies_analytics_savings_idx ON supplies FIELDS supplierAnalytics.costSavings;
DEFINE INDEX supplies_predictions_availability_idx ON supplies FIELDS supplyPredictions.futureAvailability;
DEFINE INDEX supplies_optimization_quantity_idx ON supplies FIELDS autoOptimization.optimalOrderQuantity;
DEFINE INDEX supplies_compliance_score_idx ON supplies FIELDS complianceData.complianceScore;

-- ================================================================================================
-- 🎯 INDEX PERFORMANCE SPÉCIALISÉS IA
-- ================================================================================================

-- Index composites pour recherches complexes IA
DEFINE INDEX ai_global_confidence_idx ON partner FIELDS aiProfile.confidence, aiProfile.dataQuality;
DEFINE INDEX ai_global_risk_idx ON partner FIELDS aiProfile.riskScore, aiInsights.churn_risk;
DEFINE INDEX ai_global_value_idx ON partner FIELDS aiInsights.lifetime_value, aiInsights.growth_potential;
DEFINE INDEX ai_global_engagement_idx ON partner FIELDS aiMetrics.engagementScore, aiMetrics.activityScore;

DEFINE INDEX company_ai_global_idx ON company FIELDS aiProfile.confidence, aiMetrics.performanceScore;
DEFINE INDEX product_ai_global_idx ON product FIELDS productAI.demandForecast, performanceMetrics.salesVolume;

-- Index pour recherche vectorielle (embeddings)
DEFINE INDEX partner_embeddings_search_idx ON partner FIELDS embeddings;

-- Index pour analytics temps réel
DEFINE INDEX realtime_partner_activity_idx ON partner FIELDS aiMetrics.lastCalculated;
DEFINE INDEX realtime_company_performance_idx ON company FIELDS aiMetrics.lastCalculated;
DEFINE INDEX realtime_product_metrics_idx ON product FIELDS performanceMetrics;

-- ================================================================================================
-- 🎯 CONCLUSION - PERFORMANCE MAXIMALE LYXAL-BASE
-- ================================================================================================

-- Total : 200+ index optimisés pour performance maximale
-- Architecture : Index IA-ready pour scoring automatique et prédictions
-- Capacités : Recherche vectorielle, analytics temps réel, optimisations avancées
-- Performance : Accès ultra-rapide aux données IA et métriques business
-- Innovation : Index spécialisés pour intelligence artificielle intégrée 