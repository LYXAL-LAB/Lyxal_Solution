-- Fichier: dataseed/bridge_parameter_sources.surql

CREATE bridge_parameter_sources:static CONTENT 
{
     identity: 
     {
          name: 'static' 
     }, 
     affichage: 
     {
          display_name: 'Valeur Fixe (Interne)' 
     }, 
     status: 
     {
          status: bridge_status:active 
     } 
};

CREATE bridge_parameter_sources:user CONTENT 
{
     identity: 
     {
          name: 'user' 
     }, 
     affichage: 
     {
          display_name: 'Saisie Utilisateur' 
     }, 
     status: 
     {
          status: bridge_status:active 
     } 
};

CREATE bridge_parameter_sources:auth CONTENT 
{
     identity: 
     {
          name: 'auth' 
     }, 
     affichage: 
     {
          display_name: 'Secrets / Auth' 
     }, 
     status: 
     {
          status: bridge_status:active 
     } 
};

CREATE bridge_parameter_sources:expression CONTENT 
{
     identity: 
     {
          name: 'expression' 
     }, 
     affichage: 
     {
          display_name: 'Formule / Expression' 
     }, 
     status: 
     {
          status: bridge_status:active 
     } 
};