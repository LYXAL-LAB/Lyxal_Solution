-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : ANALYTICS & REPORTING JURIDIQUES
-- ==============================================================================
-- Fichier : 07_legal_analytics.surql
-- Description : Tableaux de bord, métriques, rapports et analyses juridiques
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : MÉTRIQUES JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_metric SCHEMAFULL;
DEFINE FIELD metric_id ON legal_metric TYPE string;
DEFINE FIELD name ON legal_metric TYPE string;
DEFINE FIELD description ON legal_metric TYPE string;
DEFINE FIELD category ON legal_metric TYPE string;
DEFINE FIELD metric_type ON legal_metric TYPE string;
DEFINE FIELD calculation_method ON legal_metric TYPE string;
DEFINE FIELD target_value ON legal_metric TYPE option<decimal>;
DEFINE FIELD warning_threshold ON legal_metric TYPE option<decimal>;
DEFINE FIELD critical_threshold ON legal_metric TYPE option<decimal>;
DEFINE FIELD unit_of_measure ON legal_metric TYPE option<string>;
DEFINE FIELD is_kpi ON legal_metric TYPE bool DEFAULT false;
DEFINE FIELD is_active ON legal_metric TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_metric TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_metric_id ON legal_metric COLUMNS metric_id UNIQUE;
DEFINE INDEX idx_legal_metric_kpi ON legal_metric COLUMNS is_kpi;

-- ==============================================================================
-- TABLE : VALEURS DE MÉTRIQUES
-- ==============================================================================

DEFINE TABLE legal_metric_value SCHEMAFULL;
DEFINE FIELD value_id ON legal_metric_value TYPE string;
DEFINE FIELD metric ON legal_metric_value TYPE record<legal_metric>;
DEFINE FIELD company ON legal_metric_value TYPE record<company>;
DEFINE FIELD period_start ON legal_metric_value TYPE datetime;
DEFINE FIELD period_end ON legal_metric_value TYPE datetime;
DEFINE FIELD value ON legal_metric_value TYPE decimal;
DEFINE FIELD status ON legal_metric_value TYPE string;
DEFINE FIELD trend ON legal_metric_value TYPE string;
DEFINE FIELD is_active ON legal_metric_value TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_metric_value TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_metric_value_metric ON legal_metric_value COLUMNS metric;
DEFINE INDEX idx_legal_metric_value_company ON legal_metric_value COLUMNS company;
DEFINE INDEX idx_legal_metric_value_period ON legal_metric_value COLUMNS period_start, period_end;

-- ==============================================================================
-- TABLE : TABLEAUX DE BORD JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_dashboard SCHEMAFULL;
DEFINE FIELD dashboard_id ON legal_dashboard TYPE string;
DEFINE FIELD name ON legal_dashboard TYPE string;
DEFINE FIELD description ON legal_dashboard TYPE string;
DEFINE FIELD dashboard_type ON legal_dashboard TYPE string;
DEFINE FIELD company ON legal_dashboard TYPE record<company>;
DEFINE FIELD owner ON legal_dashboard TYPE record<user>;
DEFINE FIELD widgets ON legal_dashboard TYPE array<object>;
DEFINE FIELD layout_config ON legal_dashboard TYPE object;
DEFINE FIELD refresh_interval ON legal_dashboard TYPE int DEFAULT 300;
DEFINE FIELD is_default ON legal_dashboard TYPE bool DEFAULT false;
DEFINE FIELD is_active ON legal_dashboard TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_dashboard TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_dashboard_id ON legal_dashboard COLUMNS dashboard_id UNIQUE;
DEFINE INDEX idx_legal_dashboard_company ON legal_dashboard COLUMNS company;

-- ==============================================================================
-- TABLE : RAPPORTS JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_report SCHEMAFULL;
DEFINE FIELD report_id ON legal_report TYPE string;
DEFINE FIELD name ON legal_report TYPE string;
DEFINE FIELD description ON legal_report TYPE string;
DEFINE FIELD report_type ON legal_report TYPE string;
DEFINE FIELD company ON legal_report TYPE record<company>;
DEFINE FIELD template ON legal_report TYPE option<string>;
DEFINE FIELD parameters ON legal_report TYPE object;
DEFINE FIELD schedule ON legal_report TYPE option<object>;
DEFINE FIELD recipients ON legal_report TYPE array<record<user>>;
DEFINE FIELD output_format ON legal_report TYPE array<string>;
DEFINE FIELD is_automated ON legal_report TYPE bool DEFAULT false;
DEFINE FIELD last_generated ON legal_report TYPE option<datetime>;
DEFINE FIELD next_generation ON legal_report TYPE option<datetime>;
DEFINE FIELD is_active ON legal_report TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_report TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_report_id ON legal_report COLUMNS report_id UNIQUE;
DEFINE INDEX idx_legal_report_company ON legal_report COLUMNS company;
DEFINE INDEX idx_legal_report_automated ON legal_report COLUMNS is_automated;

-- ==============================================================================
-- TABLE : ANALYSES DE RISQUES
-- ==============================================================================

DEFINE TABLE legal_risk_analysis SCHEMAFULL;
DEFINE FIELD analysis_id ON legal_risk_analysis TYPE string;
DEFINE FIELD name ON legal_risk_analysis TYPE string;
DEFINE FIELD description ON legal_risk_analysis TYPE string;
DEFINE FIELD analysis_type ON legal_risk_analysis TYPE string;
DEFINE FIELD company ON legal_risk_analysis TYPE record<company>;
DEFINE FIELD risk_factors ON legal_risk_analysis TYPE array<object>;
DEFINE FIELD overall_risk_score ON legal_risk_analysis TYPE decimal;
DEFINE FIELD risk_level ON legal_risk_analysis TYPE string;
DEFINE FIELD mitigation_recommendations ON legal_risk_analysis TYPE array<object>;
DEFINE FIELD next_review_date ON legal_risk_analysis TYPE datetime;
DEFINE FIELD analyst ON legal_risk_analysis TYPE record<user>;
DEFINE FIELD is_active ON legal_risk_analysis TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_risk_analysis TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_risk_analysis_id ON legal_risk_analysis COLUMNS analysis_id UNIQUE;
DEFINE INDEX idx_legal_risk_analysis_company ON legal_risk_analysis COLUMNS company;
DEFINE INDEX idx_legal_risk_analysis_level ON legal_risk_analysis COLUMNS risk_level;

-- ==============================================================================
-- TABLE : ALERTES JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_alert SCHEMAFULL;
DEFINE FIELD alert_id ON legal_alert TYPE string;
DEFINE FIELD title ON legal_alert TYPE string;
DEFINE FIELD description ON legal_alert TYPE string;
DEFINE FIELD alert_type ON legal_alert TYPE string;
DEFINE FIELD severity ON legal_alert TYPE string;
DEFINE FIELD company ON legal_alert TYPE record<company>;
DEFINE FIELD triggered_on ON legal_alert TYPE datetime;
DEFINE FIELD acknowledged_on ON legal_alert TYPE option<datetime>;
DEFINE FIELD resolved_on ON legal_alert TYPE option<datetime>;
DEFINE FIELD status ON legal_alert TYPE string;
DEFINE FIELD recipients ON legal_alert TYPE array<record<user>>;
DEFINE FIELD is_active ON legal_alert TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_alert TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_alert_id ON legal_alert COLUMNS alert_id UNIQUE;
DEFINE INDEX idx_legal_alert_company ON legal_alert COLUMNS company;
DEFINE INDEX idx_legal_alert_severity ON legal_alert COLUMNS severity;
DEFINE INDEX idx_legal_alert_status ON legal_alert COLUMNS status;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour calculer une métrique
DEFINE FUNCTION calculate_legal_metric($metric_id: record<legal_metric>, $company_id: record<company>, $period_start: datetime, $period_end: datetime) {
    LET $metric = SELECT * FROM legal_metric WHERE id = $metric_id;
    LET $value = 0.0;
    
    IF $metric.metric_id = "PROCESS_COMPLETION_RATE" THEN
        LET $total = SELECT COUNT() FROM legal_process WHERE company = $company_id AND start_date BETWEEN $period_start AND $period_end;
        LET $completed = SELECT COUNT() FROM legal_process WHERE company = $company_id AND start_date BETWEEN $period_start AND $period_end AND status = "completed";
        $value = IF $total > 0 THEN ($completed / $total) * 100 ELSE 0 END;
    END;
    
    RETURN { metric_id: $metric_id, value: $value, calculation_date: time::now() };
};

-- Fonction pour générer un rapport de performance
DEFINE FUNCTION generate_performance_report($company_id: record<company>, $period_start: datetime, $period_end: datetime) {
    LET $processes = SELECT COUNT() FROM legal_process WHERE company = $company_id AND start_date BETWEEN $period_start AND $period_end;
    LET $deadlines = SELECT COUNT() FROM legal_deadline WHERE company = $company_id AND due_date BETWEEN $period_start AND $period_end;
    LET $incidents = SELECT COUNT() FROM compliance_incident WHERE company = $company_id AND detection_date BETWEEN $period_start AND $period_end;
    
    RETURN {
        company: $company_id,
        period: { start: $period_start, end: $period_end },
        summary: { total_processes: $processes, total_deadlines: $deadlines, total_incidents: $incidents },
        generated_on: time::now()
    };
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des KPIs principaux
DEFINE TABLE legal_kpi_overview AS SELECT 
    legal_metric.*,
    legal_metric_value.value AS current_value,
    legal_metric_value.status,
    legal_metric_value.trend,
    company.name AS company_name
FROM legal_metric 
INNER JOIN legal_metric_value ON legal_metric.id = legal_metric_value.metric
INNER JOIN company ON legal_metric_value.company = company.id
WHERE legal_metric.is_kpi = true 
AND legal_metric.is_active = true;

-- Vue des alertes actives
DEFINE TABLE active_legal_alerts AS SELECT 
    legal_alert.*,
    company.name AS company_name
FROM legal_alert 
INNER JOIN company ON legal_alert.company = company.id
WHERE legal_alert.status IN ['active', 'acknowledged']
AND legal_alert.is_active = true
ORDER BY legal_alert.severity DESC;

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : MÉTRIQUES JURIDIQUES
-- ==============================================================================

-- Taux de finalisation des processus
CREATE legal_metric:process_completion_rate CONTENT {
    metric_id: "PROCESS_COMPLETION_RATE",
    name: "Taux de finalisation des processus",
    description: "Pourcentage de processus juridiques finalisés",
    category: "operational",
    metric_type: "percentage",
    is_kpi: true,
    is_active: true,
    created_on: time::now()
};

-- Score de conformité
CREATE legal_metric:compliance_score CONTENT {
    metric_id: "COMPLIANCE_SCORE",
    name: "Score de conformité",
    description: "Score global de conformité réglementaire",
    category: "compliance",
    metric_type: "score",
    is_kpi: true,
    is_active: true,
    created_on: time::now()
};

-- Coûts juridiques
CREATE legal_metric:legal_costs CONTENT {
    metric_id: "LEGAL_COSTS",
    name: "Coûts juridiques",
    description: "Coûts totaux des processus juridiques",
    category: "financial",
    metric_type: "amount",
    calculation_method: "Somme des coûts réels des processus juridiques",
    unit_of_measure: "EUR",
    is_kpi: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TABLEAUX DE BORD
-- ==============================================================================

-- Tableau de bord direction
CREATE legal_dashboard:executive_dashboard CONTENT {
    dashboard_id: "EXEC_LEGAL_DASHBOARD",
    name: "Tableau de bord Direction - Juridique",
    description: "Vue d'ensemble des KPIs juridiques pour la direction",
    dashboard_type: "executive",
    company: company:sample_company,
    owner: user:legal_director,
    widgets: [
        {
            id: "kpi_overview",
            type: "kpi_grid",
            title: "KPIs Juridiques",
            metrics: ["PROCESS_COMPLETION_RATE", "COMPLIANCE_SCORE", "LEGAL_COSTS"],
            size: "large"
        },
        {
            id: "alerts_summary",
            type: "alert_list",
            title: "Alertes Critiques",
            filter: "severity:critical",
            size: "medium"
        }
    ],
    layout_config: { columns: 2, responsive: true },
    refresh_interval: 900,
    is_default: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES ANALYTICS JURIDIQUES :

1. MÉTRIQUES (legal_metric)
   - Définition des KPIs juridiques
   - Calculs automatisés
   - Seuils d'alerte

2. VALEURS DE MÉTRIQUES (legal_metric_value)
   - Historique des valeurs
   - Tendances et comparaisons
   - Qualité des données

3. TABLEAUX DE BORD (legal_dashboard)
   - Vues personnalisées
   - Widgets configurables
   - Permissions d'accès

4. RAPPORTS (legal_report)
   - Rapports automatisés
   - Formats multiples
   - Planification

5. ANALYSES DE RISQUES (legal_risk_analysis)
   - Évaluations quantitatives
   - Matrices de risques
   - Recommandations

6. ALERTES (legal_alert)
   - Déclenchement automatique
   - Escalade intelligente
   - Résolution trackée

7. BENCHMARKS (legal_benchmark)
   - Comparaisons sectorielles
   - Données de marché
   - Positionnement concurrentiel

UTILISATION :
- Pilotage par les KPIs
- Tableaux de bord temps réel
- Rapports réglementaires automatisés
- Détection d'anomalies
- Analyse prédictive des risques
- Benchmarking concurrentiel
*/ 