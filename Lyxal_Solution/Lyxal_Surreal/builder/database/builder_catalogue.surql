DEFINE TABLE IF NOT EXISTS builder_catalogue TYPE NORMAL SCHEMAFULL
  COMMENT 'CATALOGUE UNIVERSEL du système Builder Lyxal
  
  Contient TOUTES les ressources de l\'application Lyxal :
  • Ressources Builder (templates, actions, configs, analyseurs, séquences, événements)
  • Tables métier (product, customer, order, invoice, etc.)
  • Tables infrastructure (bunny_dns_zone, bunny_pull_zone, bunny_storage, etc.)
  • Fonctions (fn::bunny_*, fn::create_*, fn::builder_*, fn::validate_*, etc.)
  • Modules (infrastructure, business, CRM, marketing, authentification, etc.)
  • Plugins et extensions
  
  Utilisé par :
  - Le Builder : pour générer et déployer l\'application dynamiquement
  - L\'IA via MCP : pour découvrir et orchestrer automatiquement toutes les ressources
  - Le système : pour gérer les dépendances et relations inter-ressources
  - Les développeurs : comme documentation technique centrale et source unique de vérité
  
  Le catalogue est dans le module Builder car le Builder est le système de méta-programmation
  responsable de l\'orchestration et du déploiement de toutes ces ressources, comme un chef
  d\'orchestre possède la partition complète de tous les instruments.
  
  Documentation complète : /builder/documentation/ARCHITECTURE_MODULE_BUILDER.md'
  PERMISSIONS 
      FOR UPDATE,DELETE NONE
      FOR SELECT,CREATE FULL;

  -- Définition des champs génériques
  DEFINE FIELD IF NOT EXISTS name ON builder_catalogue 
    TYPE string
    VALUE string::lowercase(string::trim($value)) 
    ASSERT string::len($value) > 2 AND string::len($value) < 101
    COMMENT 'Nom de l élément du catalogue (base, crm, builder...)';

  DEFINE FIELD IF NOT EXISTS code ON builder_catalogue
    TYPE string
    READONLY
    COMMENT 'Code unique de l élément.';

  DEFINE FIELD IF NOT EXISTS description ON builder_catalogue 
    TYPE string
    ASSERT string::len($value) > 4 AND string::len($value) < 201
    COMMENT 'Description de l élément';

  DEFINE FIELD IF NOT EXISTS version ON builder_catalogue 
    TYPE string 
    DEFAULT '1.0.0'
    COMMENT 'Version de l élément.';

  DEFINE FIELD IF NOT EXISTS metadata ON builder_catalogue 
    FLEXIBLE 
    TYPE object DEFAULT {}
    COMMENT 'Données libres pour champs spécifiques au type.';

  DEFINE FIELD IF NOT EXISTS personnal_tag ON builder_catalogue 
    TYPE record<system_tag>
    REFERENCE ON DELETE REJECT  
    COMMENT 'Tag système personnalisé pour cet élément du catalogue.';

  -- Champs spécifiques (rendus optionnels)
  DEFINE FIELD IF NOT EXISTS deploy_function ON builder_catalogue 
    TYPE option<record<builder_catalogue>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Fonction de déploiement (principalement pour les modules).';

  DEFINE FIELD IF NOT EXISTS fichier_surql ON builder_catalogue 
    TYPE record<storage_file>
    REFERENCE ON DELETE REJECT
    READONLY
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier surql de l\'élément.';

  -- Relation hiérarchique
  DEFINE FIELD IF NOT EXISTS parent ON builder_catalogue 
    TYPE option<record<builder_catalogue>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence optionnelle vers un élément parent pour créer une hiérarchie.'; 

  -- Timestamps
  DEFINE FIELD IF NOT EXISTS created_at ON builder_catalogue 
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création de l\'élément.';

  DEFINE FIELD IF NOT EXISTS updated_at ON builder_catalogue 
    TYPE datetime
    READONLY
    VALUE time::now()
    COMMENT 'Date de mise à jour de l\'élément.';

  -- Définition des index
  DEFINE INDEX IF NOT EXISTS idx_builder_catalogue_code ON builder_catalogue 
    FIELDS code UNIQUE
    COMMENT 'Index sur le code de l\'élément.';

  DEFINE INDEX IF NOT EXISTS idx_builder_catalogue_name ON builder_catalogue 
    FIELDS name UNIQUE
    COMMENT 'Index sur le nom de l\'élément.';

  DEFINE INDEX IF NOT EXISTS idx_builder_catalogue_parent ON builder_catalogue 
    FIELDS parent
    COMMENT 'Index sur le parent de l\'élément.';

  DEFINE INDEX IF NOT EXISTS idx_builder_catalogue_updated_at ON builder_catalogue 
    FIELDS updated_at
    COMMENT 'Index sur la date de mise à jour de l\'élément.';