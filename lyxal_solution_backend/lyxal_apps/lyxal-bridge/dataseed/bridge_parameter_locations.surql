-- Fichier: dataseed/bridge_parameter_locations.surql
CREATE bridge_parameter_locations:query CONTENT 
{ 
    identity: 
    {
         name: 'query' 
    }, 
    affichage: 
    {
         display_name: 'URL Query' 
    }, 
    status: 
    {
         status: bridge_status:active 
    } 
};

CREATE bridge_parameter_locations:header CONTENT 
{ 
    identity: 
    {
         name: 'header' 
    }, 
    affichage: 
    {
         display_name: 'HTTP Header' 
    }, 
    status: 
    {
         status: bridge_status:active 
    } 
};

CREATE bridge_parameter_locations:path CONTENT 
{ 
    identity: 
    {
         name: 'path' 
    }, 
    affichage: 
    {
         display_name: 'URL Path' 
    }, 
    status: 
    {
         status: bridge_status:active 
    } 
};

CREATE bridge_parameter_locations:body CONTENT 
{ 
    identity: 
    {
         name: 'body' 
    }, 
    affichage: 
    {
         display_name: 'Request Body' 
    }, 
    status: 
    {
         status: bridge_status:active 
    } 
};

CREATE bridge_parameter_locations:cookie CONTENT 
{ 
    identity: 
    {
         name: 'cookie' 
    }, 
    affichage: 
    {
         display_name: 'Cookie' 
    }, 
    status: 
    {
         status: bridge_status:active 
    } 
};