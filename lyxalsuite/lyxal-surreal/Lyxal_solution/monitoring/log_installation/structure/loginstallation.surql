-- Table : loginstallation
-- Module : lyxal-saas
-- SubModule : entities/geographic
-- Entity : loginstallation
-- Description : Suivi des installations techniques de modules en temps réel (via LIVE SELECT uniquement)
-- Version : 1.0.0

DEFINE TABLE loginstallation SCHEMAFULL
  PERMISSIONS
    FOR select WHERE true,
    FOR create WHERE true,
    FOR update WHERE false,
    FOR delete WHERE false;
    
-- Champs de niveau logique
DEFINE FIELD module     ON loginstallation TYPE string;        -- Ex: "base"
DEFINE FIELD submodule  ON loginstallation TYPE string;        -- Ex: "geographic"
DEFINE FIELD entity     ON loginstallation TYPE string;        -- Ex: "continent"

-- Phase métier et état d'avancement
DEFINE FIELD phase      ON loginstallation TYPE string;        -- Ex: "create_table", "validation", "rollback"
DEFINE FIELD status     ON loginstallation TYPE string;        -- Ex: "in_progress", "success", "failure"

-- Métadonnées et informations de trace
DEFINE FIELD message    ON loginstallation TYPE string;        -- Message simple à afficher dans une UI
DEFINE FIELD timestamp  ON loginstallation TYPE datetime;      -- Date exacte de l'événement
DEFINE FIELD details    ON loginstallation FLEXIBLE;           -- Payload additionnel (object libre)

-- Index classiques pour LIVE SELECT ou audit
DEFINE INDEX idx_loginstallation_module    ON loginstallation FIELDS module;
DEFINE INDEX idx_loginstallation_submodule ON loginstallation FIELDS submodule;
DEFINE INDEX idx_loginstallation_entity    ON loginstallation FIELDS entity;
DEFINE INDEX idx_loginstallation_phase     ON loginstallation FIELDS phase;
DEFINE INDEX idx_loginstallation_status    ON loginstallation FIELDS status;
