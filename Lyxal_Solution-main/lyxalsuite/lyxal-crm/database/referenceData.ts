export const CRM_REFERENCE_DATA = `
CREATE lead_status:nouveau SET code = "NOUVEAU", name = "Nouveau";
CREATE lead_status:contacte SET code = "CONTACTE", name = "Contacté";
CREATE lead_status:qualifie SET code = "QUALIFIE", name = "Qualifié";
CREATE lead_status:perdu SET code = "PERDU", name = "Perdu";

CREATE opportunity_status:ouverte SET code = "OUVERTE", name = "Ouverte";
CREATE opportunity_status:gagnee SET code = "GAGNEE", name = "Gagnée";
CREATE opportunity_status:perdue SET code = "PERDUE", name = "Perdue";

CREATE partner_status:client SET code = "CLIENT", name = "Client";
CREATE partner_status:prospect SET code = "PROSPECT", name = "Prospect";
CREATE partner_status:fournisseur SET code = "FOURNISSEUR", name = "Fournisseur";

CREATE event_category:rdv SET code = "RDV", name = "Rendez-vous";
CREATE event_category:appel SET code = "APPEL", name = "Appel téléphonique";

CREATE catalog_type:pdf SET code = "PDF", name = "Catalogue PDF";
CREATE catalog_type:plaquette SET code = "PLAQUETTE", name = "Plaquette commerciale";
CREATE catalog_type:brochure SET code = "BROCHURE", name = "Brochure";

CREATE crm_configuration:default SET 
  code = "DEFAULT", 
  name = "Configuration par défaut",
  notifyOnLeadAssign = true,
  autoAssign = false;

CREATE fidelity:standard SET programName = "Programme fidélité", level = "Standard", points = 0;
CREATE fidelity:gold SET programName = "Programme fidélité", level = "Gold", points = 1000;

CREATE lost_reason:prix SET code = "PRIX", name = "Prix trop élevé";
CREATE lost_reason:delai SET code = "DELAI", name = "Délais trop longs";
CREATE lost_reason:concurrent SET code = "CONCURRENT", name = "Concurrent choisi";
`;
