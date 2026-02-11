DEFINE TABLE IF NOT EXISTS partner TYPE NORMAL SCHEMAFULL 
COMMENT 'Partenaires avec toutes leurs propriétés étendues - Entité centrale du système' 
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 


DEFINE FIELD code ON partner TYPE option<string> 
COMMENT 'Code du partenaire';
DEFINE FIELD name ON partner TYPE string  
COMMENT 'Nom du partenaire';
DEFINE FIELD firstName ON partner TYPE option<string> 
COMMENT 'Prénom du partenaire (pour les contacts individuels)';
DEFINE FIELD fullName ON partner TYPE option<string>
COMMENT 'Nom complet';
DEFINE FIELD simpleFullName ON partner TYPE option<string>
COMMENT 'Nom simple';

-- Coordonnées
DEFINE FIELD emailAddress ON partner TYPE option<record<email_address>> 
COMMENT 'Adresse email principale du partenaire';
DEFINE FIELD fixedPhone ON partner TYPE option<string>
COMMENT 'Téléphone fixe';
DEFINE FIELD mobilePhone ON partner TYPE option<string>
COMMENT 'Téléphone mobile';
DEFINE FIELD webSite ON partner TYPE option<string>
COMMENT 'Site web';

-- Localisation
DEFINE FIELD localization ON partner TYPE option<record<locale>>
COMMENT 'Localisation (langue/format)';

-- Relations internes
DEFINE FIELD company ON partner TYPE option<record<partner>> 
COMMENT 'Société (partner) à laquelle le contact est rattaché';
DEFINE FIELD parentPartner ON partner TYPE option<record<partner>>
COMMENT 'Société mère';
DEFINE FIELD mainPartner ON partner TYPE option<record<partner>>
COMMENT 'Société principale';

-- Organisation / profils
DEFINE FIELD picture ON partner TYPE option<record<meta_file>>
COMMENT 'Photo/Avatar';
DEFINE FIELD team ON partner TYPE option<record<team>>
COMMENT 'Équipe';
DEFINE FIELD linkedUser ON partner TYPE option<record<user>>
COMMENT 'Utilisateur lié';
DEFINE FIELD tags ON partner TYPE array<record<system_tag>> DEFAULT [] 
COMMENT "Tags du partenaire";

-- ERP / prix / paiements
DEFINE FIELD currency ON partner TYPE option<record<currency>>
COMMENT 'Devise';
DEFINE FIELD salePartnerPriceList ON partner TYPE option<record<partner_price_list>>
COMMENT 'Liste de prix vente';
DEFINE FIELD purchasePartnerPriceList ON partner TYPE option<record<partner_price_list>>
COMMENT 'Liste de prix achat';
DEFINE FIELD paymentDelay ON partner TYPE option<number>
COMMENT 'Délai de paiement moyen (jours)';
DEFINE FIELD groupProductsOnPrintings ON partner TYPE bool DEFAULT false
COMMENT 'Regrouper les produits sur les impressions';
DEFINE FIELD fiscalPosition ON partner TYPE option<record<fiscal_position>>
COMMENT 'Position fiscale';

-- Description et commentaires
DEFINE FIELD description ON partner TYPE option<string>
COMMENT 'Description';
DEFINE FIELD invoiceComments ON partner TYPE option<string>
COMMENT 'Commentaire facture';
DEFINE FIELD saleOrderComments ON partner TYPE option<string>
COMMENT 'Commentaire commande vente';
DEFINE FIELD purchaseOrderComments ON partner TYPE option<string>
COMMENT 'Commentaire commande achat';
DEFINE FIELD deliveryComments ON partner TYPE option<string>
COMMENT 'Commentaire livraison';
DEFINE FIELD pickingOrderComments ON partner TYPE option<string>
COMMENT 'Commentaire préparation';
DEFINE FIELD proformaComments ON partner TYPE option<string>
COMMENT 'Commentaire proforma';

-- Liens et attributs
DEFINE FIELD partnerAttrs ON partner TYPE option<string>
COMMENT 'Champs (JSON)';
DEFINE FIELD contactAttrs ON partner TYPE option<string>
COMMENT 'Champs (JSON)';

-- Audit
DEFINE FIELD created_at ON partner TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON partner TYPE record<user>;
DEFINE FIELD updated_at ON partner TYPE datetime DEFAULT time::now();

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_partner_code_unique ON partner FIELDS code UNIQUE;
DEFINE INDEX idx_partner_name ON partner FIELDS name;
DEFINE INDEX idx_partner_company ON partner FIELDS company;
DEFINE INDEX idx_partner_email_unique ON partner FIELDS emailAddress;