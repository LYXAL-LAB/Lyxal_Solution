-- ================================================
-- MODULE AXELOR TALENT - ÉVALUATION & EMPLOYÉS
-- ================================================

-- Table appraisal (évaluations)
DEFINE TABLE appraisal SCHEMAFULL;
DEFINE FIELD id ON appraisal TYPE record<appraisal>;
DEFINE FIELD reference ON appraisal TYPE string;
DEFINE FIELD employee ON appraisal TYPE string;
DEFINE FIELD evaluator ON appraisal TYPE string;
DEFINE FIELD appraisal_type ON appraisal TYPE string;
DEFINE FIELD evaluation_date ON appraisal TYPE datetime;
DEFINE FIELD period_from ON appraisal TYPE datetime;
DEFINE FIELD period_to ON appraisal TYPE datetime;
DEFINE FIELD status_select ON appraisal TYPE int DEFAULT 1;
DEFINE FIELD overall_rating ON appraisal TYPE float;
DEFINE FIELD goals_achievement ON appraisal TYPE float;
DEFINE FIELD competencies_rating ON appraisal TYPE float;
DEFINE FIELD behavioral_rating ON appraisal TYPE float;
DEFINE FIELD technical_rating ON appraisal TYPE float;
DEFINE FIELD strengths ON appraisal TYPE string;
DEFINE FIELD areas_for_improvement ON appraisal TYPE string;
DEFINE FIELD development_plan ON appraisal TYPE string;
DEFINE FIELD employee_comments ON appraisal TYPE string;
DEFINE FIELD evaluator_comments ON appraisal TYPE string;
DEFINE FIELD hr_comments ON appraisal TYPE string;
DEFINE FIELD next_review_date ON appraisal TYPE datetime;
DEFINE FIELD is_final ON appraisal TYPE bool DEFAULT false;
DEFINE FIELD created_on ON appraisal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON appraisal TYPE datetime DEFAULT time::now();

-- Table appraisal_type (types d'évaluation)
DEFINE TABLE appraisal_type SCHEMAFULL;
DEFINE FIELD id ON appraisal_type TYPE record<appraisal_type>;
DEFINE FIELD name ON appraisal_type TYPE string;
DEFINE FIELD code ON appraisal_type TYPE string;
DEFINE FIELD description ON appraisal_type TYPE string;
DEFINE FIELD frequency_select ON appraisal_type TYPE int;
DEFINE FIELD duration_months ON appraisal_type TYPE int;
DEFINE FIELD is_mandatory ON appraisal_type TYPE bool DEFAULT false;
DEFINE FIELD template_content ON appraisal_type TYPE string;
DEFINE FIELD active ON appraisal_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON appraisal_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON appraisal_type TYPE datetime DEFAULT time::now();

-- Table employee (employés étendu)
DEFINE TABLE employee SCHEMAFULL;
DEFINE FIELD id ON employee TYPE record<employee>;
DEFINE FIELD name ON employee TYPE string;
DEFINE FIELD code ON employee TYPE string;
DEFINE FIELD first_name ON employee TYPE string;
DEFINE FIELD last_name ON employee TYPE string;
DEFINE FIELD email ON employee TYPE string;
DEFINE FIELD phone ON employee TYPE string;
DEFINE FIELD mobile ON employee TYPE string;
DEFINE FIELD hire_date ON employee TYPE datetime;
DEFINE FIELD department ON employee TYPE string;
DEFINE FIELD position ON employee TYPE string;
DEFINE FIELD manager ON employee TYPE string;
DEFINE FIELD status_select ON employee TYPE int DEFAULT 1;
DEFINE FIELD employment_type ON employee TYPE string;
DEFINE FIELD salary ON employee TYPE float;
DEFINE FIELD currency ON employee TYPE string;
DEFINE FIELD skills ON employee TYPE string;
DEFINE FIELD education_level ON employee TYPE string;
DEFINE FIELD experience_years ON employee TYPE int;
DEFINE FIELD performance_rating ON employee TYPE float;
DEFINE FIELD last_appraisal_date ON employee TYPE datetime;
DEFINE FIELD next_appraisal_date ON employee TYPE datetime;
DEFINE FIELD active ON employee TYPE bool DEFAULT true;
DEFINE FIELD created_on ON employee TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON employee TYPE datetime DEFAULT time::now();

-- Table company_talent (extension entreprises pour talent)
DEFINE TABLE company_talent SCHEMAFULL;
DEFINE FIELD id ON company_talent TYPE record<company_talent>;
DEFINE FIELD company_id ON company_talent TYPE record<company>;
-- Tous les champs communs sont maintenant dans la table company de base
DEFINE FIELD created_on ON company_talent TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_talent TYPE datetime DEFAULT time::now();

-- Table company_department (départements)
DEFINE TABLE company_department SCHEMAFULL;
DEFINE FIELD id ON company_department TYPE record<company_department>;
DEFINE FIELD name ON company_department TYPE string;
DEFINE FIELD code ON company_department TYPE string;
DEFINE FIELD company ON company_department TYPE string;
DEFINE FIELD parent_department ON company_department TYPE string;
DEFINE FIELD manager ON company_department TYPE string;
DEFINE FIELD description ON company_department TYPE string;
DEFINE FIELD location ON company_department TYPE string;
DEFINE FIELD budget ON company_department TYPE float;
DEFINE FIELD employee_count ON company_department TYPE int DEFAULT 0;
DEFINE FIELD active ON company_department TYPE bool DEFAULT true;
DEFINE FIELD created_on ON company_department TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_department TYPE datetime DEFAULT time::now(); 