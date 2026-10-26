//! Moteur de regroupement technique et d'évaluation multi-niveaux.
//!
//! Implémente rigoureusement les règles de sécurité métier CTO :
//! - Jamais de fusion des références commerciales.
//! - Jamais d'équivalence automatique sur la seule similarité de libellé.
//! - Prise en charge des 4 familles clés : Plaques de plâtre, Rails/Montants, Appareillage électrique, Isolants.
//! - Attribution de `TO_CONFIRM` en cas d'incertitude ou d'absence de preuve.
//! - Niveau 4 (Substitution autorisée) strictement contextualisé et révocable.

use std::collections::{HashMap, HashSet};

use super::types::{
    ContextualSubstitutionRule, FamilyRule, TechnicalGroupLevel, TechnicalGroupingDecision,
    TechnicalSpecification,
};
use crate::normalization::{CanonicalDimensions, NormalizedItemDto};
use crate::types::ItemQualification;

/// Moteur de rapprochement technique multi-niveaux Lyxal OS.
#[derive(Debug, Clone)]
pub struct TechnicalGroupingEngine {
    rules_version: String,
    known_families: HashMap<String, FamilyRule>,
    known_specifications: Vec<TechnicalSpecification>,
    /// Paires certifiées simples (rétro-compatibilité Phase 2) : (fabricant_source, ref_source, fabricant_cible, ref_cible)
    certified_substitutions: HashSet<(String, String, String, String)>,
    /// Règles de substitution contextualisées et révocables (Directive CTO Phase 3)
    contextual_rules: HashMap<String, ContextualSubstitutionRule>,
}

impl TechnicalGroupingEngine {
    /// Initialise le moteur avec les spécifications standards du BTP
    pub fn new() -> Self {
        let mut engine = Self {
            rules_version: "2026.1-TECHNICAL".to_string(),
            known_families: HashMap::new(),
            known_specifications: Vec::new(),
            certified_substitutions: HashSet::new(),
            contextual_rules: HashMap::new(),
        };
        engine.init_default_specifications();
        engine
    }

    /// Enregistre une règle de famille de produits
    pub fn register_family(&mut self, family: FamilyRule) {
        self.known_families.insert(family.code.clone(), family);
    }

    /// Récupère une famille enregistrée
    pub fn get_family(&self, code: &str) -> Option<&FamilyRule> {
        self.known_families.get(code)
    }

    /// Efface et recharge dynamiquement l'ensemble des règles depuis SurrealDB
    pub fn clear_and_load(
        &mut self,
        families: Vec<FamilyRule>,
        specs: Vec<TechnicalSpecification>,
        substitutions: Vec<ContextualSubstitutionRule>,
    ) {
        self.known_families.clear();
        for f in families {
            self.known_families.insert(f.code.clone(), f);
        }
        self.known_specifications = specs;
        self.contextual_rules.clear();
        for s in substitutions {
            self.contextual_rules.insert(s.rule_id.clone(), s);
        }
    }

    /// Enregistre une spécification technique générique patronne
    pub fn register_specification(&mut self, spec: TechnicalSpecification) {
        self.known_specifications.push(spec);
    }

    /// Enregistre une règle explicite et certifiée de substitution autorisée (Niveau 4 basique)
    pub fn register_certified_substitution(
        &mut self,
        source_mfg: &str,
        source_ref: &str,
        target_mfg: &str,
        target_ref: &str,
    ) {
        self.certified_substitutions.insert((
            source_mfg.to_uppercase(),
            source_ref.to_uppercase(),
            target_mfg.to_uppercase(),
            target_ref.to_uppercase(),
        ));
    }

    /// Enregistre une règle de substitution certifiée contextualisée (Directive CTO Phase 3)
    pub fn register_contextual_substitution(&mut self, rule: ContextualSubstitutionRule) {
        self.contextual_rules.insert(rule.rule_id.clone(), rule);
    }

    /// Révoque formellement une règle de substitution existante avec motif traçable
    pub fn revoke_substitution(&mut self, rule_id: &str, reason: &str) -> bool {
        if let Some(rule) = self.contextual_rules.get_mut(rule_id) {
            rule.is_revoked = true;
            rule.revocation_reason = Some(reason.to_string());
            true
        } else {
            false
        }
    }

    /// Initialise les spécifications génériques de référence couvrant les 4 familles exigées
    fn init_default_specifications(&mut self) {
        // Enregistrement des 4 familles initiales BTP
        self.register_family(FamilyRule {
            code: "CLOISON_PLAQUE_PLATRE".to_string(),
            label: "Plaques de plâtre et doublages".to_string(),
            keywords: vec![
                "plaque".to_string(),
                "placo".to_string(),
                "ba13".to_string(),
                "plâtre".to_string(),
                "platre".to_string(),
            ],
            standard_unit: Some("M2".to_string()),
        });
        self.register_family(FamilyRule {
            code: "OSSATURE_METALLIQUE".to_string(),
            label: "Ossatures et profilés métalliques".to_string(),
            keywords: vec![
                "rail".to_string(),
                "montant".to_string(),
                "r48".to_string(),
                "m48".to_string(),
                "r70".to_string(),
                "m70".to_string(),
            ],
            standard_unit: Some("ML".to_string()),
        });
        self.register_family(FamilyRule {
            code: "APPAREILLAGE_ELECTRIQUE".to_string(),
            label: "Appareillages électriques terminaux".to_string(),
            keywords: vec![
                "prise".to_string(),
                "interrupteur".to_string(),
                "2p+t".to_string(),
                "va-et-vient".to_string(),
            ],
            standard_unit: Some("PCE".to_string()),
        });
        self.register_family(FamilyRule {
            code: "ISOLATION_THERMIQUE_ACOUSTIQUE".to_string(),
            label: "Isolants thermiques et acoustiques".to_string(),
            keywords: vec![
                "isol".to_string(),
                "laine".to_string(),
                "gr32".to_string(),
                "ibr".to_string(),
                "verre".to_string(),
                "roche".to_string(),
                "rockwool".to_string(),
            ],
            standard_unit: Some("M2".to_string()),
        });
        // 1. Spécification générique Plaque de plâtre BA13 2500x1200
        let mut ba13_features = HashMap::new();
        ba13_features.insert("edge_type".to_string(), "BA".to_string());
        self.register_specification(TechnicalSpecification {
            family_code: "CLOISON_PLAQUE_PLATRE".to_string(),
            technical_identity_key: "SPEC_GEN_PLAQUE_BA13_2500x1200".to_string(),
            generic_title: "Plaque de plâtre standard type A 2500x1200x12.5mm bords amincis".to_string(),
            nominal_dimensions: Some(CanonicalDimensions {
                length_mm: Some(2500.0),
                width_mm: Some(1200.0),
                height_mm: Some(12.5),
            }),
            tolerances: None,
            nominal_weight: None,
            standard_norm: Some("NF EN 520".to_string()),
            fire_rating: Some("A2-S1,D0".to_string()),
            required_features: ba13_features,
        });

        // 2. Spécification générique Rail métallique R48 3m
        let mut rail_features = HashMap::new();
        rail_features.insert("profile_type".to_string(), "R48".to_string());
        rail_features.insert("steel_thickness_mm".to_string(), "0.6".to_string());
        self.register_specification(TechnicalSpecification {
            family_code: "OSSATURE_METALLIQUE".to_string(),
            technical_identity_key: "SPEC_GEN_RAIL_R48_3000".to_string(),
            generic_title: "Rail métallique pour cloison R48 longueur 3000mm épaisseur 0.6mm".to_string(),
            nominal_dimensions: Some(CanonicalDimensions {
                length_mm: Some(3000.0),
                width_mm: Some(48.0),
                height_mm: Some(40.0),
            }),
            tolerances: None,
            nominal_weight: None,
            standard_norm: Some("NF EN 14195".to_string()),
            fire_rating: Some("A1".to_string()),
            required_features: rail_features,
        });

        // 3. Spécification générique Prise de courant 2P+T 16A encastrée
        let mut prise_features = HashMap::new();
        prise_features.insert("poles".to_string(), "2P+T".to_string());
        prise_features.insert("current_a".to_string(), "16".to_string());
        prise_features.insert("mounting".to_string(), "ENCASTRE".to_string());
        self.register_specification(TechnicalSpecification {
            family_code: "APPAREILLAGE_ELECTRIQUE".to_string(),
            technical_identity_key: "SPEC_GEN_PRISE_2PT_16A_ENCASTRE".to_string(),
            generic_title: "Socle de prise de courant 2P+T 16A 230V encastré".to_string(),
            nominal_dimensions: None,
            tolerances: None,
            nominal_weight: None,
            standard_norm: Some("NF C 15-100".to_string()),
            fire_rating: None,
            required_features: prise_features,
        });

        // 4. Spécification générique Isolant Laine de verre GR32 100mm (Directive CTO Phase 3)
        let mut gr32_features = HashMap::new();
        gr32_features.insert("insulation_material".to_string(), "LAINE_DE_VERRE".to_string());
        gr32_features.insert("thermal_lambda".to_string(), "0.032".to_string());
        self.register_specification(TechnicalSpecification {
            family_code: "ISOLATION_THERMIQUE_ACOUSTIQUE".to_string(),
            technical_identity_key: "SPEC_GEN_ISOLANT_LAINE_VERRE_GR32_100".to_string(),
            generic_title: "Panneau roulé de laine de verre semi-rigide lambda 0.032 épaisseur 100mm R=3.15".to_string(),
            nominal_dimensions: Some(CanonicalDimensions {
                length_mm: Some(2700.0),
                width_mm: Some(1200.0),
                height_mm: Some(100.0),
            }),
            tolerances: None,
            nominal_weight: None,
            standard_norm: Some("NF EN 13162".to_string()),
            fire_rating: Some("A1".to_string()),
            required_features: gr32_features,
        });

        // 5. Spécification générique Isolant Laine de roche 100mm
        let mut rock_features = HashMap::new();
        rock_features.insert("insulation_material".to_string(), "LAINE_DE_ROCHE".to_string());
        rock_features.insert("thermal_lambda".to_string(), "0.035".to_string());
        self.register_specification(TechnicalSpecification {
            family_code: "ISOLATION_THERMIQUE_ACOUSTIQUE".to_string(),
            technical_identity_key: "SPEC_GEN_ISOLANT_LAINE_ROCHE_100".to_string(),
            generic_title: "Panneau rigide de laine de roche lambda 0.035 épaisseur 100mm R=2.85".to_string(),
            nominal_dimensions: Some(CanonicalDimensions {
                length_mm: Some(1200.0),
                width_mm: Some(600.0),
                height_mm: Some(100.0),
            }),
            tolerances: None,
            nominal_weight: None,
            standard_norm: Some("NF EN 13162".to_string()),
            fire_rating: Some("A1".to_string()),
            required_features: rock_features,
        });
    }

    /// Analyse et rapproche un article normalisé avec les spécifications techniques de référence.
    pub fn evaluate_item(&self, item: &NormalizedItemDto) -> TechnicalGroupingDecision {
        let mut best_decision = TechnicalGroupingDecision {
            manufacturer_ref: item.manufacturer_ref.clone(),
            manufacturer: item.manufacturer.clone(),
            technical_identity_key: "UNRESOLVED_GENERIC_IDENTITY".to_string(),
            reached_level: TechnicalGroupLevel::Family,
            qualification: ItemQualification::ToConfirm,
            confidence_score: 0.1,
            matched_criteria: Vec::new(),
            missing_evidence: vec!["Aucune famille technique reconnue".to_string()],
            decision_reason: "L'article n'a pas pu être rattaché à une spécification technique standard".to_string(),
            rules_engine_version: self.rules_version.clone(),
        };

        for spec in &self.known_specifications {
            let decision = self.compare_item_with_spec(item, spec);
            if decision.confidence_score > best_decision.confidence_score {
                best_decision = decision;
            }
        }

        best_decision
    }

    /// Compare un article normalisé avec une spécification technique candidate selon les 4 niveaux
    pub fn compare_item_with_spec(
        &self,
        item: &NormalizedItemDto,
        spec: &TechnicalSpecification,
    ) -> TechnicalGroupingDecision {
        let mut matched_criteria = Vec::new();
        let mut missing_evidence = Vec::new();

        // ---------------------------------------------------------------------
        // NIVEAU 1 : Appartenance à la même famille (taxonomie / métier)
        // ---------------------------------------------------------------------
        let des_lower = item.commercial_label.to_lowercase();
        let family_match = if let Some(family_rule) = self.known_families.get(&spec.family_code) {
            family_rule.keywords.iter().any(|kw| des_lower.contains(&kw.to_lowercase()))
                || des_lower.contains(&family_rule.label.to_lowercase())
        } else {
            match spec.family_code.as_str() {
                "CLOISON_PLAQUE_PLATRE" => {
                    des_lower.contains("plaque")
                        || des_lower.contains("placo")
                        || des_lower.contains("ba13")
                        || des_lower.contains("plâtre")
                        || des_lower.contains("platre")
                }
                "OSSATURE_METALLIQUE" => {
                    des_lower.contains("rail")
                        || des_lower.contains("montant")
                        || des_lower.contains("r48")
                        || des_lower.contains("m48")
                }
                "APPAREILLAGE_ELECTRIQUE" => {
                    des_lower.contains("prise")
                        || des_lower.contains("interrupteur")
                        || des_lower.contains("2p+t")
                }
                "ISOLATION_THERMIQUE_ACOUSTIQUE" => {
                    des_lower.contains("isol")
                        || des_lower.contains("laine")
                        || des_lower.contains("gr32")
                        || des_lower.contains("ibr")
                }
                other => des_lower.contains(&other.to_lowercase().replace('_', " ")),
            }
        };

        if !family_match {
            return TechnicalGroupingDecision {
                manufacturer_ref: item.manufacturer_ref.clone(),
                manufacturer: item.manufacturer.clone(),
                technical_identity_key: spec.technical_identity_key.clone(),
                reached_level: TechnicalGroupLevel::Family,
                qualification: ItemQualification::Rejected,
                confidence_score: 0.0,
                matched_criteria: vec![],
                missing_evidence: vec![format!("Famille '{}' non concordante", spec.family_code)],
                decision_reason: "Famille technique incompatible".to_string(),
                rules_engine_version: self.rules_version.clone(),
            };
        }

        matched_criteria.push(format!("Famille validée : {}", spec.family_code));
        let mut current_level = TechnicalGroupLevel::Family;
        let mut confidence = 0.40;

        // ---------------------------------------------------------------------
        // NIVEAU 2 : Correspondance à la même spécification technique
        // ---------------------------------------------------------------------
        let (len_tol, wid_tol, hgt_tol) = if let Some(ref tols) = spec.tolerances {
            (tols.length_tol_mm, tols.width_tol_mm, tols.height_tol_mm)
        } else {
            (5.0, 5.0, 1.0)
        };

        let mut dims_match = true;
        if let (Some(ref item_dims), Some(ref spec_dims)) = (&item.dimensions, &spec.nominal_dimensions) {
            if let (Some(il), Some(sl)) = (item_dims.length_mm, spec_dims.length_mm) {
                if (il - sl).abs() <= len_tol {
                    matched_criteria.push(format!("Longueur conforme : {il}mm =~ {sl}mm"));
                } else {
                    dims_match = false;
                    missing_evidence.push(format!("Longueur divergente : {il}mm vs {sl}mm"));
                }
            }
            if let (Some(iw), Some(sw)) = (item_dims.width_mm, spec_dims.width_mm) {
                if (iw - sw).abs() <= wid_tol {
                    matched_criteria.push(format!("Largeur conforme : {iw}mm =~ {sw}mm"));
                } else {
                    dims_match = false;
                    missing_evidence.push(format!("Largeur divergente : {iw}mm vs {sw}mm"));
                }
            }
            if let (Some(ih), Some(sh)) = (item_dims.height_mm, spec_dims.height_mm) {
                if (ih - sh).abs() <= hgt_tol {
                    matched_criteria.push(format!("Épaisseur conforme : {ih}mm =~ {sh}mm"));
                } else {
                    dims_match = false;
                    missing_evidence.push(format!("Épaisseur divergente : {ih}mm vs {sh}mm"));
                }
            }
        } else if spec.nominal_dimensions.is_some() {
            dims_match = false;
            missing_evidence.push("Dimensions physiques requises non renseignées".to_string());
        }

        // Norme de référence
        let norm_match = if let Some(ref required_norm) = spec.standard_norm {
            if let Some(item_norm) = item.technical_features.get("standard_norm") {
                if item_norm.to_uppercase() == required_norm.to_uppercase() {
                    matched_criteria.push(format!("Norme conforme : {required_norm}"));
                    true
                } else {
                    missing_evidence.push(format!("Norme divergente : {item_norm} vs {required_norm}"));
                    false
                }
            } else {
                missing_evidence.push(format!("Norme requise non documentée : {required_norm}"));
                false
            }
        } else {
            true
        };

        if dims_match && norm_match {
            current_level = TechnicalGroupLevel::Specification;
            confidence = 0.70;
        }

        // ---------------------------------------------------------------------
        // NIVEAU 3 : Équivalence fonctionnelle
        // ---------------------------------------------------------------------
        if current_level == TechnicalGroupLevel::Specification {
            let mut performance_match = true;

            // Vérification feu
            if let Some(ref required_fire) = spec.fire_rating {
                if let Some(item_fire) = item.technical_features.get("fire_rating") {
                    if item_fire.to_uppercase() == required_fire.to_uppercase() {
                        matched_criteria.push(format!("Classement feu conforme : {required_fire}"));
                    } else {
                        performance_match = false;
                        missing_evidence.push(format!("Classement feu non équivalent : {item_fire} vs {required_fire}"));
                    }
                } else {
                    performance_match = false;
                    missing_evidence.push("Absence de preuve du classement au feu requis pour l'équivalence fonctionnelle".to_string());
                }
            }

            // Vérification des attributs spécifiques
            for (req_k, req_v) in &spec.required_features {
                if let Some(item_v) = item.technical_features.get(req_k) {
                    if item_v.to_uppercase() == req_v.to_uppercase() {
                        matched_criteria.push(format!("Attribut technique '{}' conforme : {}", req_k, req_v));
                    } else {
                        performance_match = false;
                        missing_evidence.push(format!("Attribut '{}' divergent : {} vs {}", req_k, item_v, req_v));
                    }
                } else {
                    performance_match = false;
                    missing_evidence.push(format!("Caractéristique '{}' non renseignée dans la source", req_k));
                }
            }

            if performance_match {
                current_level = TechnicalGroupLevel::FunctionalEquivalence;
                confidence = 0.90;
            }
        }

        // ---------------------------------------------------------------------
        // NIVEAU 4 : Substitution réellement autorisée
        // ---------------------------------------------------------------------
        let mut is_substitution_certified = false;
        if current_level == TechnicalGroupLevel::FunctionalEquivalence {
            // Vérifie si une règle de substitution existe entre cet article et la spécification de référence
            for (src_mfg, src_ref, _, target_ref) in &self.certified_substitutions {
                if src_mfg == &item.manufacturer.to_uppercase()
                    && src_ref == &item.manufacturer_ref.to_uppercase()
                    && target_ref == &spec.technical_identity_key.to_uppercase()
                {
                    is_substitution_certified = true;
                    break;
                }
            }

            if is_substitution_certified {
                current_level = TechnicalGroupLevel::AuthorizedSubstitution;
                confidence = 1.0;
                matched_criteria.push("Substitution formellement certifiée par règle métier / Avis Technique".to_string());
            } else {
                missing_evidence.push(
                    "Substitution contractuelle (Niveau 4) non certifiée : nécessite une règle métier explicite ou arbitrage steward_admin".to_string()
                );
            }
        }

        let (qualification, decision_reason) = match current_level {
            TechnicalGroupLevel::AuthorizedSubstitution => {
                // Règle inviolable CTO : Une équivalence ou substitution technique ne confère jamais à elle seule le statut commercial VERIFIED
                let qual = if item.qualification == ItemQualification::Verified {
                    ItemQualification::Verified
                } else {
                    ItemQualification::ToConfirm
                };
                (
                    qual,
                    "Substitution autorisée et certifiée conforme aux exigences contractuelles".to_string(),
                )
            }
            TechnicalGroupLevel::FunctionalEquivalence => {
                // Règle inviolable CTO : L'équivalence technique ne peut pas écraser une qualification commerciale ToConfirm ou Rejected
                let qual = if item.qualification == ItemQualification::Verified {
                    ItemQualification::Verified
                } else {
                    ItemQualification::ToConfirm
                };
                (
                    qual,
                    "Équivalence fonctionnelle techniquement démontrée (même usage et performances)".to_string(),
                )
            }
            TechnicalGroupLevel::Specification => (
                ItemQualification::ToConfirm,
                "Spécification géométrique concordante mais preuves de performance incomplètes : TO_CONFIRM".to_string(),
            ),
            TechnicalGroupLevel::Family => (
                ItemQualification::ToConfirm,
                "Appartenance à la même famille sans équivalence technique démontrée : TO_CONFIRM".to_string(),
            ),
        };

        TechnicalGroupingDecision {
            manufacturer_ref: item.manufacturer_ref.clone(),
            manufacturer: item.manufacturer.clone(),
            technical_identity_key: spec.technical_identity_key.clone(),
            reached_level: current_level,
            qualification,
            confidence_score: confidence,
            matched_criteria,
            missing_evidence,
            decision_reason,
            rules_engine_version: self.rules_version.clone(),
        }
    }

    /// Compare deux articles concurrents avec prise en compte du contexte système constructif (Directive CTO Phase 3)
    pub fn compare_items_in_context(
        &self,
        item_a: &NormalizedItemDto,
        item_b: &NormalizedItemDto,
        context_system: Option<&str>,
    ) -> TechnicalGroupingDecision {
        let mut matched = Vec::new();
        let mut missing = Vec::new();

        // 1. Famille
        let des_a = item_a.commercial_label.to_lowercase();
        let des_b = item_b.commercial_label.to_lowercase();

        let is_plaque = |des: &str, ref_str: &str| {
            let d = des.to_lowercase();
            let r = ref_str.to_lowercase();
            d.contains("plaque")
                || d.contains("ba13")
                || d.contains("ba15")
                || d.contains("ks13")
                || d.contains("ks 13")
                || d.contains("platr")
                || r.contains("ba13")
                || r.contains("ks13")
        };
        let is_both_plaque = is_plaque(&des_a, &item_a.manufacturer_ref) && is_plaque(&des_b, &item_b.manufacturer_ref);

        let is_rail = |des: &str, ref_str: &str| {
            let d = des.to_lowercase();
            let r = ref_str.to_lowercase();
            d.contains("rail") || d.contains("montant") || d.contains("r48") || d.contains("m48") || r.contains("r48") || r.contains("m48")
        };
        let is_both_rail = is_rail(&des_a, &item_a.manufacturer_ref) && is_rail(&des_b, &item_b.manufacturer_ref);

        let is_prise = |des: &str, feat: &std::collections::HashMap<String, String>| {
            let d = des.to_lowercase();
            d.contains("prise") || d.contains("interrupteur") || d.contains("2p+t") || feat.contains_key("current_rating_a")
        };
        let is_both_prise = is_prise(&des_a, &item_a.technical_features) && is_prise(&des_b, &item_b.technical_features);

        let is_isolant = |des: &str, feat: &std::collections::HashMap<String, String>| {
            let d = des.to_lowercase();
            d.contains("isol") || d.contains("laine") || d.contains("gr32") || feat.contains_key("insulation_material") || feat.contains_key("thermal_lambda")
        };
        let is_both_isolant = is_isolant(&des_a, &item_a.technical_features) && is_isolant(&des_b, &item_b.technical_features);

        if !is_both_plaque && !is_both_rail && !is_both_prise && !is_both_isolant {
            return TechnicalGroupingDecision {
                manufacturer_ref: item_a.manufacturer_ref.clone(),
                manufacturer: item_a.manufacturer.clone(),
                technical_identity_key: "DIFF_FAMILIES".to_string(),
                reached_level: TechnicalGroupLevel::Family,
                qualification: ItemQualification::Rejected,
                confidence_score: 0.0,
                matched_criteria: vec![],
                missing_evidence: vec!["Articles de familles totalement différentes".to_string()],
                decision_reason: "Différence de famille".to_string(),
                rules_engine_version: self.rules_version.clone(),
            };
        }

        matched.push("Articles appartenant à la même famille métier".to_string());
        let mut level = TechnicalGroupLevel::Family;
        let mut confidence = 0.40;

        // 2. Spécification
        let dims_match = match (&item_a.dimensions, &item_b.dimensions) {
            (Some(da), Some(db)) => {
                let dl = (da.length_mm.unwrap_or(0.0) - db.length_mm.unwrap_or(0.0)).abs() <= 5.0;
                let dw = (da.width_mm.unwrap_or(0.0) - db.width_mm.unwrap_or(0.0)).abs() <= 5.0;
                let dh = (da.height_mm.unwrap_or(0.0) - db.height_mm.unwrap_or(0.0)).abs() <= 1.0;
                dl && dw && dh
            }
            _ => false,
        };

        if dims_match {
            level = TechnicalGroupLevel::Specification;
            confidence = 0.70;
            matched.push("Dimensions et géométrie strictement concordantes".to_string());
        } else {
            missing.push("Dimensions non concordantes ou partiellement documentées".to_string());
        }

        // Contrôle transversal pour isolants : incompatibilité stricte si matériaux différents (ex: verre vs roche)
        if is_both_isolant {
            let mat_a = item_a.technical_features.get("insulation_material");
            let mat_b = item_b.technical_features.get("insulation_material");
            if mat_a.is_some() && mat_b.is_some() && mat_a != mat_b {
                missing.push(format!("Matériaux isolants incompatibles : {:?} vs {:?}", mat_a, mat_b));
            }
        }

        // 3. Équivalence fonctionnelle (Cas général + cas spécifique Isolants)
        if level == TechnicalGroupLevel::Specification {
            if is_both_isolant {
                // Spécificités Isolants : Matériau & Lambda thermique
                let mat_a = item_a.technical_features.get("insulation_material");
                let mat_b = item_b.technical_features.get("insulation_material");
                let lam_a = item_a.technical_features.get("thermal_lambda");
                let lam_b = item_b.technical_features.get("thermal_lambda");

                if mat_a.is_some() && mat_a != mat_b {
                    // Déjà consigné ci-dessus
                } else if lam_a.is_some() && lam_a != lam_b {
                    missing.push(format!("Conductivité thermique (lambda) divergente : {:?} vs {:?}", lam_a, lam_b));
                } else if mat_a.is_some() && lam_a.is_some() {
                    level = TechnicalGroupLevel::FunctionalEquivalence;
                    confidence = 0.90;
                    matched.push("Isolants de même matériau, même lambda et cotes équivalentes".to_string());
                } else {
                    missing.push("Informations lambda ou matériau insuffisantes pour équivalence isolant".to_string());
                }
            } else {
                // Plâtrerie, rails, électricité
                let fire_a = item_a.technical_features.get("fire_rating");
                let fire_b = item_b.technical_features.get("fire_rating");
                let edge_a = item_a.technical_features.get("edge_type");
                let edge_b = item_b.technical_features.get("edge_type");

                if fire_a.is_some() && fire_a == fire_b && edge_a == edge_b {
                    level = TechnicalGroupLevel::FunctionalEquivalence;
                    confidence = 0.90;
                    matched.push("Performances feu et type de bords strictement équivalents".to_string());
                } else {
                    missing.push("Preuve de classement au feu ou caractéristiques de bord divergentes/absentes".to_string());
                }
            }
        }

        // 4. Substitution autorisée contextualisée et révocable (Directive CTO Phase 3)
        if level == TechnicalGroupLevel::FunctionalEquivalence {
            let mfg_a = item_a.manufacturer.to_uppercase();
            let ref_a = item_a.manufacturer_ref.to_uppercase();
            let mfg_b = item_b.manufacturer.to_uppercase();
            let ref_b = item_b.manufacturer_ref.to_uppercase();

            let mut substitution_found = false;
            let mut substitution_revoked = false;
            let mut revocation_msg = String::new();
            let mut scope_mismatch = false;

            for rule in self.contextual_rules.values() {
                let pair_matches = (rule.source_manufacturer == mfg_a && rule.source_ref == ref_a && rule.target_manufacturer == mfg_b && rule.target_ref == ref_b)
                    || (rule.source_manufacturer == mfg_b && rule.source_ref == ref_b && rule.target_manufacturer == mfg_a && rule.target_ref == ref_a);

                if pair_matches {
                    if rule.is_revoked {
                        substitution_revoked = true;
                        revocation_msg = rule.revocation_reason.clone().unwrap_or_else(|| "Révocation administrative".to_string());
                    } else if let Some(req_scope) = context_system {
                        if rule.system_scope.eq_ignore_ascii_case(req_scope) {
                            substitution_found = true;
                            matched.push(format!(
                                "Substitution certifiée valide : {} ({}, scope: {})",
                                rule.certification_reference, rule.certification_body, rule.system_scope
                            ));
                            break;
                        } else {
                            scope_mismatch = true;
                        }
                    } else {
                        // Pas de contexte fourni
                        scope_mismatch = true;
                    }
                }
            }

            // Fallback rétro-compatible certified_substitutions (Phase 2 sans contexte)
            let is_legacy_certified = self.certified_substitutions.contains(&(mfg_a.clone(), ref_a.clone(), mfg_b.clone(), ref_b.clone()))
                || self.certified_substitutions.contains(&(mfg_b, ref_b, mfg_a, ref_a));

            if substitution_revoked {
                missing.push(format!("Substitution formellement révoquée : {revocation_msg}"));
            } else if substitution_found || (is_legacy_certified && context_system.is_none()) {
                level = TechnicalGroupLevel::AuthorizedSubstitution;
                confidence = 1.0;
                matched.push("Paire de substitution certifiée conforme (Avis Technique / Règle métier)".to_string());
            } else if scope_mismatch {
                missing.push(format!(
                    "Substitution non autorisée pour le système demandé (justificatif hors périmètre : {:?})",
                    context_system
                ));
            } else {
                missing.push("Substitution contractuelle non autorisée sans accord ou ATec validé".to_string());
            }
        }

        // Règle inviolable CTO : Une équivalence technique ne doit jamais, à elle seule, conférer le statut commercial VERIFIED.
        // Les deux articles doivent déjà être commercialement VERIFIED pour que le résultat soit VERIFIED.
        let qual = if level >= TechnicalGroupLevel::FunctionalEquivalence
            && item_a.qualification == ItemQualification::Verified
            && item_b.qualification == ItemQualification::Verified
        {
            ItemQualification::Verified
        } else {
            ItemQualification::ToConfirm
        };

        TechnicalGroupingDecision {
            manufacturer_ref: item_a.manufacturer_ref.clone(),
            manufacturer: item_a.manufacturer.clone(),
            technical_identity_key: format!("{}_VS_{}", item_a.manufacturer_ref, item_b.manufacturer_ref),
            reached_level: level,
            qualification: qual,
            confidence_score: confidence,
            matched_criteria: matched,
            missing_evidence: missing,
            decision_reason: format!("Comparaison multi-niveaux aboutie au {}", level),
            rules_engine_version: self.rules_version.clone(),
        }
    }

    /// Compare deux articles concurrents entre eux (délègue à compare_items_in_context sans filtre système)
    pub fn compare_items(
        &self,
        item_a: &NormalizedItemDto,
        item_b: &NormalizedItemDto,
    ) -> TechnicalGroupingDecision {
        self.compare_items_in_context(item_a, item_b, None)
    }
}

impl Default for TechnicalGroupingEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::normalization::dimensions::CanonicalDimensions;
    use crate::types::SourceFormat;

    fn build_test_item(
        mfg: &str,
        reference: &str,
        label: &str,
        dims: CanonicalDimensions,
        fire: Option<&str>,
        edge: Option<&str>,
        norm: Option<&str>,
    ) -> NormalizedItemDto {
        let mut tech = HashMap::new();
        if let Some(f) = fire { tech.insert("fire_rating".to_string(), f.to_string()); }
        if let Some(e) = edge { tech.insert("edge_type".to_string(), e.to_string()); }
        if let Some(n) = norm { tech.insert("standard_norm".to_string(), n.to_string()); }

        NormalizedItemDto {
            line_number: 1,
            source_format: SourceFormat::FabDis,
            manufacturer_ref: reference.to_string(),
            manufacturer: mfg.to_string(),
            brand: Some(mfg.to_string()),
            commercial_label: label.to_string(),
            gtin: Some("3017620422003".to_string()),
            is_gtin_valid: true,
            unit_code: Some("M2".to_string()),
            price: Some(8.50),
            currency: "EUR".to_string(),
            dimensions: Some(dims),
            weight: None,
            technical_features: tech,
            commercial_proof: None,
            qualification: ItemQualification::Verified,
            qualification_reason: "Validé".to_string(),
            canonical_fingerprint: "hash".to_string(),
            raw_payload: serde_json::json!({}),
            raw_hash: "raw_hash".to_string(),
            rules_engine_version: "2026.1".to_string(),
        }
    }

    #[test]
    fn test_contextual_substitution_and_revocation() {
        let mut engine = TechnicalGroupingEngine::new();

        let placo = build_test_item(
            "PLACO",
            "BA13_2500",
            "Placoplatre BA13 2500x1200",
            CanonicalDimensions { length_mm: Some(2500.0), width_mm: Some(1200.0), height_mm: Some(12.5) },
            Some("A2-S1,D0"),
            Some("BA"),
            Some("NF EN 520"),
        );

        let knauf = build_test_item(
            "KNAUF",
            "KS13_2500",
            "Plaque Knauf Standard KS 13 2500x1200",
            CanonicalDimensions { length_mm: Some(2500.0), width_mm: Some(1200.0), height_mm: Some(12.5) },
            Some("A2-S1,D0"),
            Some("BA"),
            Some("NF EN 520"),
        );

        // 1. Sans règle, la substitution n'est pas autorisée
        let dec_no_rule = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_CLOISON_72_48"));
        assert_eq!(dec_no_rule.reached_level, TechnicalGroupLevel::FunctionalEquivalence);

        // 2. Enregistrement d'une règle contextualisée pour "SYSTEME_CLOISON_72_48"
        engine.register_contextual_substitution(ContextualSubstitutionRule {
            rule_id: "RULE-001".to_string(),
            source_manufacturer: "PLACO".to_string(),
            source_ref: "BA13_2500".to_string(),
            target_manufacturer: "KNAUF".to_string(),
            target_ref: "KS13_2500".to_string(),
            system_scope: "SYSTEME_CLOISON_72_48".to_string(),
            certification_body: "CSTB".to_string(),
            certification_reference: "Avis Technique n° 9/21-1050_V1".to_string(),
            valid_until: "2028-12-31".to_string(),
            is_revoked: false,
            revocation_reason: None,
        });

        // 3. Test avec le bon scope système -> Substitution autorisée (Niveau 4)
        let dec_valid = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_CLOISON_72_48"));
        assert_eq!(dec_valid.reached_level, TechnicalGroupLevel::AuthorizedSubstitution);
        assert_eq!(dec_valid.confidence_score, 1.0);

        // 4. Test avec un scope système différent -> Rejet du Niveau 4
        let dec_wrong_scope = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_PLAFOND_SUSPENDU"));
        assert_eq!(dec_wrong_scope.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
        assert!(dec_wrong_scope.missing_evidence.iter().any(|m| m.contains("hors périmètre")));

        // 5. Révocation de la règle -> Rejet du Niveau 4 même avec le bon scope
        let revoked = engine.revoke_substitution("RULE-001", "Avis Technique suspendu suite à sinistre");
        assert!(revoked);

        let dec_revoked = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_CLOISON_72_48"));
        assert_eq!(dec_revoked.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
        assert!(dec_revoked.missing_evidence.iter().any(|m| m.contains("révoquée")));
    }

    #[test]
    fn test_insulation_family_matching_and_differentiation() {
        let engine = TechnicalGroupingEngine::new();

        let mut features_glass = HashMap::new();
        features_glass.insert("insulation_material".to_string(), "LAINE_DE_VERRE".to_string());
        features_glass.insert("thermal_lambda".to_string(), "0.032".to_string());
        features_glass.insert("thermal_resistance_r".to_string(), "3.15".to_string());

        let glass_wool = NormalizedItemDto {
            line_number: 1,
            source_format: SourceFormat::FabDis,
            manufacturer_ref: "GR32_100".to_string(),
            manufacturer: "ISOVER".to_string(),
            brand: Some("ISOVER".to_string()),
            commercial_label: "Panneau roulé laine de verre GR32 100mm R=3.15".to_string(),
            gtin: Some("3017620422003".to_string()),
            is_gtin_valid: true,
            unit_code: Some("M2".to_string()),
            price: Some(14.50),
            currency: "EUR".to_string(),
            dimensions: Some(CanonicalDimensions { length_mm: Some(2700.0), width_mm: Some(1200.0), height_mm: Some(100.0) }),
            weight: None,
            technical_features: features_glass,
            commercial_proof: None,
            qualification: ItemQualification::Verified,
            qualification_reason: "Validé".to_string(),
            canonical_fingerprint: "hash1".to_string(),
            raw_payload: serde_json::json!({}),
            raw_hash: "hash_raw".to_string(),
            rules_engine_version: "2026.1".to_string(),
        };

        let mut features_rock = HashMap::new();
        features_rock.insert("insulation_material".to_string(), "LAINE_DE_ROCHE".to_string());
        features_rock.insert("thermal_lambda".to_string(), "0.035".to_string());
        features_rock.insert("thermal_resistance_r".to_string(), "2.85".to_string());

        let rock_wool = NormalizedItemDto {
            line_number: 2,
            source_format: SourceFormat::FabDis,
            manufacturer_ref: "ROCKPLUS_100".to_string(),
            manufacturer: "ROCKWOOL".to_string(),
            brand: Some("ROCKWOOL".to_string()),
            commercial_label: "Panneau rigide laine de roche 100mm R=2.85".to_string(),
            gtin: Some("3017620422003".to_string()),
            is_gtin_valid: true,
            unit_code: Some("M2".to_string()),
            price: Some(16.20),
            currency: "EUR".to_string(),
            dimensions: Some(CanonicalDimensions { length_mm: Some(1200.0), width_mm: Some(600.0), height_mm: Some(100.0) }),
            weight: None,
            technical_features: features_rock,
            commercial_proof: None,
            qualification: ItemQualification::Verified,
            qualification_reason: "Validé".to_string(),
            canonical_fingerprint: "hash2".to_string(),
            raw_payload: serde_json::json!({}),
            raw_hash: "hash_raw2".to_string(),
            rules_engine_version: "2026.1".to_string(),
        };

        // Laine de verre vs Laine de roche : même famille (Niveau 1), mais matériaux différents -> Jamais équivalent !
        let dec = engine.compare_items(&glass_wool, &rock_wool);
        assert_eq!(dec.reached_level, TechnicalGroupLevel::Family);
        assert!(dec.missing_evidence.iter().any(|m| m.contains("incompatibles")));
    }
}
