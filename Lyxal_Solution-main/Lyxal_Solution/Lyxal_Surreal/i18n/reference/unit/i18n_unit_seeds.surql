-- =============================================================================================
-- |
-- | Fichier     : i18n_unit_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_unit` avec les unités de mesure de base.
-- |
-- =============================================================================================

-- Poids
CREATE i18n_unit:mg SET symbol = 'mg', key.name = i18n_key:'i18n.unit.mg.name', 
unit_type = i18n_unit_type:weight;
CREATE i18n_unit:g SET symbol = 'g', key.name = i18n_key:'i18n.unit.g.name',
unit_type = i18n_unit_type:weight;
CREATE i18n_unit:kg SET symbol = 'kg', key.name = i18n_key:'i18n.unit.kg.name', 
unit_type = i18n_unit_type:weight;
CREATE i18n_unit:t SET symbol = 't', key.name = i18n_key:'i18n.unit.t.name', 
unit_type = i18n_unit_type:weight;
CREATE i18n_unit:lb SET symbol = 'lb', key.name = i18n_key:'i18n.unit.lb.name', 
unit_type = i18n_unit_type:weight;
CREATE i18n_unit:oz SET symbol = 'oz', key.name = i18n_key:'i18n.unit.oz.name', 
unit_type = i18n_unit_type:weight;

-- Longueur
CREATE i18n_unit:mm SET symbol = 'mm', key.name = i18n_key:'i18n.unit.mm.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:cm SET symbol = 'cm', key.name = i18n_key:'i18n.unit.cm.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:m SET symbol = 'm', key.name = i18n_key:'i18n.unit.m.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:km SET symbol = 'km', key.name = i18n_key:'i18n.unit.km.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:in SET symbol = 'in', key.name = i18n_key:'i18n.unit.in.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:ft SET symbol = 'ft', key.name = i18n_key:'i18n.unit.ft.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:yd SET symbol = 'yd', key.name = i18n_key:'i18n.unit.yd.name', 
unit_type = i18n_unit_type:length;
CREATE i18n_unit:mi SET symbol = 'mi', key.name = i18n_key:'i18n.unit.mi.name', 
unit_type = i18n_unit_type:length;

-- Volume
CREATE i18n_unit:ml SET symbol = 'ml', key.name = i18n_key:'i18n.unit.ml.name', 
unit_type = i18n_unit_type:volume;
CREATE i18n_unit:cl SET symbol = 'cl', key.name = i18n_key:'i18n.unit.cl.name', 
unit_type = i18n_unit_type:volume;
CREATE i18n_unit:l SET symbol = 'L', key.name = i18n_key:'i18n.unit.l.name', 
unit_type = i18n_unit_type:volume;
CREATE i18n_unit:gal SET symbol = 'gal', key.name = i18n_key:'i18n.unit.gal.name', 
unit_type = i18n_unit_type:volume;
CREATE i18n_unit:pt SET symbol = 'pt', key.name = i18n_key:'i18n.unit.pt.name', 
unit_type = i18n_unit_type:volume;
CREATE i18n_unit:qt SET symbol = 'qt', key.name = i18n_key:'i18n.unit.qt.name', 
unit_type = i18n_unit_type:volume;

-- Temps
CREATE i18n_unit:ms SET symbol = 'ms', key.name = i18n_key:'i18n.unit.ms.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:s SET symbol = 's', key.name = i18n_key:'i18n.unit.s.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:min SET symbol = 'min', key.name = i18n_key:'i18n.unit.min.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:h SET symbol = 'h', key.name = i18n_key:'i18n.unit.h.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:day SET symbol = 'd', key.name = i18n_key:'i18n.unit.day.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:week SET symbol = 'sem', key.name = i18n_key:'i18n.unit.week.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:month SET symbol = 'mois', key.name = i18n_key:'i18n.unit.month.name', 
unit_type = i18n_unit_type:time;
CREATE i18n_unit:year SET symbol = 'an', key.name = i18n_key:'i18n.unit.year.name', 
unit_type = i18n_unit_type:time;

-- Quantité
CREATE i18n_unit:unit SET symbol = 'u', key.name = i18n_key:'i18n.unit.unit.name', 
unit_type = i18n_unit_type:quantity;

-- Surface
CREATE i18n_unit:m2 SET symbol = 'm²', key.name = i18n_key:'i18n.unit.m2.name', unit_type = i18n_unit_type:surface;
CREATE i18n_unit:km2 SET symbol = 'km²', key.name = i18n_key:'i18n.unit.km2.name', unit_type = i18n_unit_type:surface;
CREATE i18n_unit:ha SET symbol = 'ha', key.name = i18n_key:'i18n.unit.ha.name', unit_type = i18n_unit_type:surface;
CREATE i18n_unit:acre SET symbol = 'acre', key.name = i18n_key:'i18n.unit.acre.name', unit_type = i18n_unit_type:surface;

-- Vitesse
CREATE i18n_unit:mps SET symbol = 'm/s', key.name = i18n_key:'i18n.unit.mps.name', unit_type = i18n_unit_type:speed;
CREATE i18n_unit:kmh SET symbol = 'km/h', key.name = i18n_key:'i18n.unit.kmh.name', unit_type = i18n_unit_type:speed;
CREATE i18n_unit:mph SET symbol = 'mph', key.name = i18n_key:'i18n.unit.mph.name', unit_type = i18n_unit_type:speed;
CREATE i18n_unit:kn SET symbol = 'kn', key.name = i18n_key:'i18n.unit.kn.name', unit_type = i18n_unit_type:speed;

-- Température
CREATE i18n_unit:c SET symbol = '°C', key.name = i18n_key:'i18n.unit.c.name', unit_type = i18n_unit_type:temperature;
CREATE i18n_unit:f SET symbol = '°F', key.name = i18n_key:'i18n.unit.f.name', unit_type = i18n_unit_type:temperature;
CREATE i18n_unit:k SET symbol = 'K', key.name = i18n_key:'i18n.unit.k.name', unit_type = i18n_unit_type:temperature;

-- Données informatiques
CREATE i18n_unit:o SET symbol = 'o', key.name = i18n_key:'i18n.unit.o.name', unit_type = i18n_unit_type:data;
CREATE i18n_unit:ko SET symbol = 'Ko', key.name = i18n_key:'i18n.unit.ko.name', unit_type = i18n_unit_type:data;
CREATE i18n_unit:mo SET symbol = 'Mo', key.name = i18n_key:'i18n.unit.mo.name', unit_type = i18n_unit_type:data;
CREATE i18n_unit:go SET symbol = 'Go', key.name = i18n_key:'i18n.unit.go.name', unit_type = i18n_unit_type:data;
CREATE i18n_unit:to SET symbol = 'To', key.name = i18n_key:'i18n.unit.to.name', unit_type = i18n_unit_type:data;

-- Pression
CREATE i18n_unit:pa SET symbol = 'Pa', key.name = i18n_key:'i18n.unit.pa.name', unit_type = i18n_unit_type:pressure;
CREATE i18n_unit:bar SET symbol = 'bar', key.name = i18n_key:'i18n.unit.bar.name', unit_type = i18n_unit_type:pressure;
CREATE i18n_unit:psi SET symbol = 'psi', key.name = i18n_key:'i18n.unit.psi.name', unit_type = i18n_unit_type:pressure;

-- Angle
CREATE i18n_unit:deg SET symbol = '°', key.name = i18n_key:'i18n.unit.deg.name', unit_type = i18n_unit_type:angle;
CREATE i18n_unit:rad SET symbol = 'rad', key.name = i18n_key:'i18n.unit.rad.name', unit_type = i18n_unit_type:angle;

-- Énergie
CREATE i18n_unit:j SET symbol = 'J', key.name = i18n_key:'i18n.unit.j.name', unit_type = i18n_unit_type:energy;
CREATE i18n_unit:kwh SET symbol = 'kWh', key.name = i18n_key:'i18n.unit.kwh.name', unit_type = i18n_unit_type:energy;
CREATE i18n_unit:cal SET symbol = 'cal', key.name = i18n_key:'i18n.unit.cal.name', unit_type = i18n_unit_type:energy;

-- Puissance
CREATE i18n_unit:w SET symbol = 'W', key.name = i18n_key:'i18n.unit.w.name', unit_type = i18n_unit_type:power;
CREATE i18n_unit:kw SET symbol = 'kW', key.name = i18n_key:'i18n.unit.kw.name', unit_type = i18n_unit_type:power;
CREATE i18n_unit:hp SET symbol = 'ch', key.name = i18n_key:'i18n.unit.hp.name', unit_type = i18n_unit_type:power;

-- Fréquence
CREATE i18n_unit:hz SET symbol = 'Hz', key.name = i18n_key:'i18n.unit.hz.name', unit_type = i18n_unit_type:frequency;
CREATE i18n_unit:khz SET symbol = 'kHz', key.name = i18n_key:'i18n.unit.khz.name', unit_type = i18n_unit_type:frequency;
CREATE i18n_unit:mhz SET symbol = 'MHz', key.name = i18n_key:'i18n.unit.mhz.name', unit_type = i18n_unit_type:frequency;
