DEFINE FUNCTION IF NOT EXISTS fn::icon_get(
    $pack: string,
    $name: string
) {

   -- on contrôle les paramètres
   IF $pack = NONE OR string::len($pack) = 0 {
    THROW 'Le pack est requis.';
   };
   IF $name = NONE OR string::len($name) = 0 {
    THROW 'Le nom est requis.';
   };

   -- on récupère l'icône
   LET $icon = SELECT * FROM icon WHERE pack = $pack AND name = $name LIMIT 1;

   -- si l'icône n'existe pas, on retourne une erreur
   IF array::len($icon) = 0 {
    THROW 'L\'icône n\'existe pas.';
   };

   -- on retourne l'icône
   RETURN $icon[0];
};

COMMENT 'Récupère une icône par son pack et son nom'
PERMISSIONS FULL;

