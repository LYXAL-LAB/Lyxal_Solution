#### Table activity ####
  -- Activité finale avec hiérarchie  --
     DEFINE FIELD industrySector ON activity TYPE <record<industry_sector>>;

#### Table workspace ou company ####
  -- Liste des workspace que le client utilise dans son database  -- 

#### Table meta_file ####
  -- Liste des chemins de fichiers --
     DEFINE FIELD printingSettings ON meta_file TYPE string; 

#### Table partner_company ####
  -- Paramètres d'impression par nom commercial --
     DEFINE FIELD printingSettings ON trading_name_printing_settings TYPE option<record<printing_settings>>; 



