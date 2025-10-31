-- referenceCashManagementData.surql

-- Types de lignes de recap (ForecastRecapLineType)
CREATE forecast_recap_line_type:1 SET name = "Facture client", elementSelect = 1, typeSelect = 1;
CREATE forecast_recap_line_type:2 SET name = "Commande fournisseur", elementSelect = 3, typeSelect = 2;
CREATE forecast_recap_line_type:3 SET name = "Salaire", elementSelect = 7, typeSelect = 2;
CREATE forecast_recap_line_type:4 SET name = "Dépense diverse", elementSelect = 4, typeSelect = 2;
CREATE forecast_recap_line_type:5 SET name = "Prévision manuelle", elementSelect = 5, typeSelect = 1;

-- Types de périodicité pour ForecastGenerator (1=Mensuel, 7=Hebdo, etc.)
-- à utiliser par convention d'application

-- Types de mouvement (1=Entrée, 2=Sortie)
-- Déjà présents dans iaccount.payment.mode.in.out.select