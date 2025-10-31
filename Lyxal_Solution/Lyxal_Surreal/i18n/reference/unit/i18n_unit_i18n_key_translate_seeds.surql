-- =============================================================================================
-- |
-- | Fichier     : i18n_unit_i18n_key_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les noms des unités.
-- |
-- =============================================================================================

-- === POIDS ===

-- Traductions pour 'i18n.unit.mg.name'
RELATE i18n_key:'i18n.unit.mg.name'->i18n_translation->i18n_language:fr SET text = 'Milligramme';
RELATE i18n_key:'i18n.unit.mg.name'->i18n_translation->i18n_language:en SET text = 'Milligram';
RELATE i18n_key:'i18n.unit.mg.name'->i18n_translation->i18n_language:es SET text = 'Miligramo';
RELATE i18n_key:'i18n.unit.mg.name'->i18n_translation->i18n_language:de SET text = 'Milligramm';
RELATE i18n_key:'i18n.unit.mg.name'->i18n_translation->i18n_language:it SET text = 'Milligrammo';

-- Traductions pour 'i18n.unit.g.name'
RELATE i18n_key:'i18n.unit.g.name'->i18n_translation->i18n_language:fr SET text = 'Gramme';
RELATE i18n_key:'i18n.unit.g.name'->i18n_translation->i18n_language:en SET text = 'Gram';
RELATE i18n_key:'i18n.unit.g.name'->i18n_translation->i18n_language:es SET text = 'Gramo';
RELATE i18n_key:'i18n.unit.g.name'->i18n_translation->i18n_language:de SET text = 'Gramm';
RELATE i18n_key:'i18n.unit.g.name'->i18n_translation->i18n_language:it SET text = 'Grammo';

-- Traductions pour 'i18n.unit.kg.name'
RELATE i18n_key:'i18n.unit.kg.name'->i18n_translation->i18n_language:fr SET text = 'Kilogramme';
RELATE i18n_key:'i18n.unit.kg.name'->i18n_translation->i18n_language:en SET text = 'Kilogram';
RELATE i18n_key:'i18n.unit.kg.name'->i18n_translation->i18n_language:es SET text = 'Kilogramo';
RELATE i18n_key:'i18n.unit.kg.name'->i18n_translation->i18n_language:de SET text = 'Kilogramm';
RELATE i18n_key:'i18n.unit.kg.name'->i18n_translation->i18n_language:it SET text = 'Chilogrammo';

-- Traductions pour 'i18n.unit.t.name'
RELATE i18n_key:'i18n.unit.t.name'->i18n_translation->i18n_language:fr SET text = 'Tonne';
RELATE i18n_key:'i18n.unit.t.name'->i18n_translation->i18n_language:en SET text = 'Tonne';
RELATE i18n_key:'i18n.unit.t.name'->i18n_translation->i18n_language:es SET text = 'Tonelada';
RELATE i18n_key:'i18n.unit.t.name'->i18n_translation->i18n_language:de SET text = 'Tonne';
RELATE i18n_key:'i18n.unit.t.name'->i18n_translation->i18n_language:it SET text = 'Tonnellata';

-- Traductions pour 'i18n.unit.lb.name'
RELATE i18n_key:'i18n.unit.lb.name'->i18n_translation->i18n_language:fr SET text = 'Livre';
RELATE i18n_key:'i18n.unit.lb.name'->i18n_translation->i18n_language:en SET text = 'Pound';
RELATE i18n_key:'i18n.unit.lb.name'->i18n_translation->i18n_language:es SET text = 'Libra';
RELATE i18n_key:'i18n.unit.lb.name'->i18n_translation->i18n_language:de SET text = 'Pfund';
RELATE i18n_key:'i18n.unit.lb.name'->i18n_translation->i18n_language:it SET text = 'Libbra';

-- Traductions pour 'i18n.unit.oz.name'
RELATE i18n_key:'i18n.unit.oz.name'->i18n_translation->i18n_language:fr SET text = 'Once';
RELATE i18n_key:'i18n.unit.oz.name'->i18n_translation->i18n_language:en SET text = 'Ounce';
RELATE i18n_key:'i18n.unit.oz.name'->i18n_translation->i18n_language:es SET text = 'Onza';
RELATE i18n_key:'i18n.unit.oz.name'->i18n_translation->i18n_language:de SET text = 'Unze';
RELATE i18n_key:'i18n.unit.oz.name'->i18n_translation->i18n_language:it SET text = 'Oncia';

-- === LONGUEUR ===

-- Traductions pour 'i18n.unit.mm.name'
RELATE i18n_key:'i18n.unit.mm.name'->i18n_translation->i18n_language:fr SET text = 'Millimètre';
RELATE i18n_key:'i18n.unit.mm.name'->i18n_translation->i18n_language:en SET text = 'Millimeter';
RELATE i18n_key:'i18n.unit.mm.name'->i18n_translation->i18n_language:es SET text = 'Milímetro';
RELATE i18n_key:'i18n.unit.mm.name'->i18n_translation->i18n_language:de SET text = 'Millimeter';
RELATE i18n_key:'i18n.unit.mm.name'->i18n_translation->i18n_language:it SET text = 'Millimetro';

-- ... (et ainsi de suite pour toutes les unités)

-- Traductions pour 'i18n.unit.year.name'
RELATE i18n_key:'i18n.unit.year.name'->i18n_translation->i18n_language:fr SET text = 'Année';
RELATE i18n_key:'i18n.unit.year.name'->i18n_translation->i18n_language:en SET text = 'Year';
RELATE i18n_key:'i18n.unit.year.name'->i18n_translation->i18n_language:es SET text = 'Año';
RELATE i18n_key:'i18n.unit.year.name'->i18n_translation->i18n_language:de SET text = 'Jahr';
RELATE i18n_key:'i18n.unit.year.name'->i18n_translation->i18n_language:it SET text = 'Anno';

-- === QUANTITÉ ===

-- Traductions pour 'i18n.unit.unit.name'
RELATE i18n_key:'i18n.unit.unit.name'->i18n_translation->i18n_language:fr SET text = 'Unité';
RELATE i18n_key:'i18n.unit.unit.name'->i18n_translation->i18n_language:en SET text = 'Unit';
RELATE i18n_key:'i18n.unit.unit.name'->i18n_translation->i18n_language:es SET text = 'Unidad';
RELATE i18n_key:'i18n.unit.unit.name'->i18n_translation->i18n_language:de SET text = 'Einheit';
RELATE i18n_key:'i18n.unit.unit.name'->i18n_translation->i18n_language:it SET text = 'Unità';

-- === SURFACE ===

-- Traductions pour 'i18n.unit.m2.name'
RELATE i18n_key:'i18n.unit.m2.name'->i18n_translation->i18n_language:fr SET text = 'Mètre carré';
RELATE i18n_key:'i18n.unit.m2.name'->i18n_translation->i18n_language:en SET text = 'Square Meter';
RELATE i18n_key:'i18n.unit.m2.name'->i18n_translation->i18n_language:es SET text = 'Metro cuadrado';
RELATE i18n_key:'i18n.unit.m2.name'->i18n_translation->i18n_language:de SET text = 'Quadratmeter';
RELATE i18n_key:'i18n.unit.m2.name'->i18n_translation->i18n_language:it SET text = 'Metro quadrato';

-- Traductions pour 'i18n.unit.km2.name'
RELATE i18n_key:'i18n.unit.km2.name'->i18n_translation->i18n_language:fr SET text = 'Kilomètre carré';
RELATE i18n_key:'i18n.unit.km2.name'->i18n_translation->i18n_language:en SET text = 'Square Kilometer';
RELATE i18n_key:'i18n.unit.km2.name'->i18n_translation->i18n_language:es SET text = 'Kilómetro cuadrado';
RELATE i18n_key:'i18n.unit.km2.name'->i18n_translation->i18n_language:de SET text = 'Quadratkilometer';
RELATE i18n_key:'i18n.unit.km2.name'->i18n_translation->i18n_language:it SET text = 'Chilometro quadrato';

-- Traductions pour 'i18n.unit.ha.name'
RELATE i18n_key:'i18n.unit.ha.name'->i18n_translation->i18n_language:fr SET text = 'Hectare';
RELATE i18n_key:'i18n.unit.ha.name'->i18n_translation->i18n_language:en SET text = 'Hectare';
RELATE i18n_key:'i18n.unit.ha.name'->i18n_translation->i18n_language:es SET text = 'Hectárea';
RELATE i18n_key:'i18n.unit.ha.name'->i18n_translation->i18n_language:de SET text = 'Hektar';
RELATE i18n_key:'i18n.unit.ha.name'->i18n_translation->i18n_language:it SET text = 'Ettaro';

-- Traductions pour 'i18n.unit.acre.name'
RELATE i18n_key:'i18n.unit.acre.name'->i18n_translation->i18n_language:fr SET text = 'Acre';
RELATE i18n_key:'i18n.unit.acre.name'->i18n_translation->i18n_language:en SET text = 'Acre';
RELATE i18n_key:'i18n.unit.acre.name'->i18n_translation->i18n_language:es SET text = 'Acre';
RELATE i18n_key:'i18n.unit.acre.name'->i18n_translation->i18n_language:de SET text = 'Acre';
RELATE i18n_key:'i18n.unit.acre.name'->i18n_translation->i18n_language:it SET text = 'Acro';

-- === VITESSE ===

-- Traductions pour 'i18n.unit.mps.name'
RELATE i18n_key:'i18n.unit.mps.name'->i18n_translation->i18n_language:fr SET text = 'Mètre par seconde';
RELATE i18n_key:'i18n.unit.mps.name'->i18n_translation->i18n_language:en SET text = 'Meter per second';
RELATE i18n_key:'i18n.unit.mps.name'->i18n_translation->i18n_language:es SET text = 'Metro por segundo';
RELATE i18n_key:'i18n.unit.mps.name'->i18n_translation->i18n_language:de SET text = 'Meter pro Sekunde';
RELATE i18n_key:'i18n.unit.mps.name'->i18n_translation->i18n_language:it SET text = 'Metro al secondo';

-- Traductions pour 'i18n.unit.kmh.name'
RELATE i18n_key:'i18n.unit.kmh.name'->i18n_translation->i18n_language:fr SET text = 'Kilomètre par heure';
RELATE i18n_key:'i18n.unit.kmh.name'->i18n_translation->i18n_language:en SET text = 'Kilometer per hour';
RELATE i18n_key:'i18n.unit.kmh.name'->i18n_translation->i18n_language:es SET text = 'Kilómetro por hora';
RELATE i18n_key:'i18n.unit.kmh.name'->i18n_translation->i18n_language:de SET text = 'Kilometer pro Stunde';
RELATE i18n_key:'i18n.unit.kmh.name'->i18n_translation->i18n_language:it SET text = 'Chilometro orario';

-- Traductions pour 'i18n.unit.mph.name'
RELATE i18n_key:'i18n.unit.mph.name'->i18n_translation->i18n_language:fr SET text = 'Mile par heure';
RELATE i18n_key:'i18n.unit.mph.name'->i18n_translation->i18n_language:en SET text = 'Mile per hour';
RELATE i18n_key:'i18n.unit.mph.name'->i18n_translation->i18n_language:es SET text = 'Milla por hora';
RELATE i18n_key:'i18n.unit.mph.name'->i18n_translation->i18n_language:de SET text = 'Meilen pro Stunde';
RELATE i18n_key:'i18n.unit.mph.name'->i18n_translation->i18n_language:it SET text = 'Miglia orarie';

-- Traductions pour 'i18n.unit.kn.name'
RELATE i18n_key:'i18n.unit.kn.name'->i18n_translation->i18n_language:fr SET text = 'Nœud';
RELATE i18n_key:'i18n.unit.kn.name'->i18n_translation->i18n_language:en SET text = 'Knot';
RELATE i18n_key:'i18n.unit.kn.name'->i18n_translation->i18n_language:es SET text = 'Nudo';
RELATE i18n_key:'i18n.unit.kn.name'->i18n_translation->i18n_language:de SET text = 'Knoten';
RELATE i18n_key:'i18n.unit.kn.name'->i18n_translation->i18n_language:it SET text = 'Nodo';

-- === TEMPÉRATURE ===

-- Traductions pour 'i18n.unit.c.name'
RELATE i18n_key:'i18n.unit.c.name'->i18n_translation->i18n_language:fr SET text = 'Celsius';
RELATE i18n_key:'i18n.unit.c.name'->i18n_translation->i18n_language:en SET text = 'Celsius';
RELATE i18n_key:'i18n.unit.c.name'->i18n_translation->i18n_language:es SET text = 'Celsius';
RELATE i18n_key:'i18n.unit.c.name'->i18n_translation->i18n_language:de SET text = 'Celsius';
RELATE i18n_key:'i18n.unit.c.name'->i18n_translation->i18n_language:it SET text = 'Celsius';

-- Traductions pour 'i18n.unit.f.name'
RELATE i18n_key:'i18n.unit.f.name'->i18n_translation->i18n_language:fr SET text = 'Fahrenheit';
RELATE i18n_key:'i18n.unit.f.name'->i18n_translation->i18n_language:en SET text = 'Fahrenheit';
RELATE i18n_key:'i18n.unit.f.name'->i18n_translation->i18n_language:es SET text = 'Fahrenheit';
RELATE i18n_key:'i18n.unit.f.name'->i18n_translation->i18n_language:de SET text = 'Fahrenheit';
RELATE i18n_key:'i18n.unit.f.name'->i18n_translation->i18n_language:it SET text = 'Fahrenheit';

-- Traductions pour 'i18n.unit.k.name'
RELATE i18n_key:'i18n.unit.k.name'->i18n_translation->i18n_language:fr SET text = 'Kelvin';
RELATE i18n_key:'i18n.unit.k.name'->i18n_translation->i18n_language:en SET text = 'Kelvin';
RELATE i18n_key:'i18n.unit.k.name'->i18n_translation->i18n_language:es SET text = 'Kelvin';
RELATE i18n_key:'i18n.unit.k.name'->i18n_translation->i18n_language:de SET text = 'Kelvin';
RELATE i18n_key:'i18n.unit.k.name'->i18n_translation->i18n_language:it SET text = 'Kelvin';

-- === DONNÉES INFORMATIQUES ===

-- Traductions pour 'i18n.unit.o.name'
RELATE i18n_key:'i18n.unit.o.name'->i18n_translation->i18n_language:fr SET text = 'Octet';
RELATE i18n_key:'i18n.unit.o.name'->i18n_translation->i18n_language:en SET text = 'Byte';
RELATE i18n_key:'i18n.unit.o.name'->i18n_translation->i18n_language:es SET text = 'Byte';
RELATE i18n_key:'i18n.unit.o.name'->i18n_translation->i18n_language:de SET text = 'Byte';
RELATE i18n_key:'i18n.unit.o.name'->i18n_translation->i18n_language:it SET text = 'Byte';

-- Traductions pour 'i18n.unit.ko.name'
RELATE i18n_key:'i18n.unit.ko.name'->i18n_translation->i18n_language:fr SET text = 'Kilooctet';
RELATE i18n_key:'i18n.unit.ko.name'->i18n_translation->i18n_language:en SET text = 'Kilobyte';
RELATE i18n_key:'i18n.unit.ko.name'->i18n_translation->i18n_language:es SET text = 'Kilobyte';
RELATE i18n_key:'i18n.unit.ko.name'->i18n_translation->i18n_language:de SET text = 'Kilobyte';
RELATE i18n_key:'i18n.unit.ko.name'->i18n_translation->i18n_language:it SET text = 'Kilobyte';

-- Traductions pour 'i18n.unit.mo.name'
RELATE i18n_key:'i18n.unit.mo.name'->i18n_translation->i18n_language:fr SET text = 'Mégaoctet';
RELATE i18n_key:'i18n.unit.mo.name'->i18n_translation->i18n_language:en SET text = 'Megabyte';
RELATE i18n_key:'i18n.unit.mo.name'->i18n_translation->i18n_language:es SET text = 'Megabyte';
RELATE i18n_key:'i18n.unit.mo.name'->i18n_translation->i18n_language:de SET text = 'Megabyte';
RELATE i18n_key:'i18n.unit.mo.name'->i18n_translation->i18n_language:it SET text = 'Megabyte';

-- Traductions pour 'i18n.unit.go.name'
RELATE i18n_key:'i18n.unit.go.name'->i18n_translation->i18n_language:fr SET text = 'Gigaoctet';
RELATE i18n_key:'i18n.unit.go.name'->i18n_translation->i18n_language:en SET text = 'Gigabyte';
RELATE i18n_key:'i18n.unit.go.name'->i18n_translation->i18n_language:es SET text = 'Gigabyte';
RELATE i18n_key:'i18n.unit.go.name'->i18n_translation->i18n_language:de SET text = 'Gigabyte';
RELATE i18n_key:'i18n.unit.go.name'->i18n_translation->i18n_language:it SET text = 'Gigabyte';

-- Traductions pour 'i18n.unit.to.name'
RELATE i18n_key:'i18n.unit.to.name'->i18n_translation->i18n_language:fr SET text = 'Téraoctet';
RELATE i18n_key:'i18n.unit.to.name'->i18n_translation->i18n_language:en SET text = 'Terabyte';
RELATE i18n_key:'i18n.unit.to.name'->i18n_translation->i18n_language:es SET text = 'Terabyte';
RELATE i18n_key:'i18n.unit.to.name'->i18n_translation->i18n_language:de SET text = 'Terabyte';
RELATE i18n_key:'i18n.unit.to.name'->i18n_translation->i18n_language:it SET text = 'Terabyte';

-- === PRESSION ===

-- Traductions pour 'i18n.unit.pa.name'
RELATE i18n_key:'i18n.unit.pa.name'->i18n_translation->i18n_language:fr SET text = 'Pascal';
RELATE i18n_key:'i18n.unit.pa.name'->i18n_translation->i18n_language:en SET text = 'Pascal';
RELATE i18n_key:'i18n.unit.pa.name'->i18n_translation->i18n_language:es SET text = 'Pascal';
RELATE i18n_key:'i18n.unit.pa.name'->i18n_translation->i18n_language:de SET text = 'Pascal';
RELATE i18n_key:'i18n.unit.pa.name'->i18n_translation->i18n_language:it SET text = 'Pascal';

-- Traductions pour 'i18n.unit.bar.name'
RELATE i18n_key:'i18n.unit.bar.name'->i18n_translation->i18n_language:fr SET text = 'Bar';
RELATE i18n_key:'i18n.unit.bar.name'->i18n_translation->i18n_language:en SET text = 'Bar';
RELATE i18n_key:'i18n.unit.bar.name'->i18n_translation->i18n_language:es SET text = 'Bar';
RELATE i18n_key:'i18n.unit.bar.name'->i18n_translation->i18n_language:de SET text = 'Bar';
RELATE i18n_key:'i18n.unit.bar.name'->i18n_translation->i18n_language:it SET text = 'Bar';

-- Traductions pour 'i18n.unit.psi.name'
RELATE i18n_key:'i18n.unit.psi.name'->i18n_translation->i18n_language:fr SET text = 'Livre par pouce carré';
RELATE i18n_key:'i18n.unit.psi.name'->i18n_translation->i18n_language:en SET text = 'Pound per square inch';
RELATE i18n_key:'i18n.unit.psi.name'->i18n_translation->i18n_language:es SET text = 'Libra por pulgada cuadrada';
RELATE i18n_key:'i18n.unit.psi.name'->i18n_translation->i18n_language:de SET text = 'Pfund pro Quadratzoll';
RELATE i18n_key:'i18n.unit.psi.name'->i18n_translation->i18n_language:it SET text = 'Libbra per pollice quadrato';

-- === ANGLE ===

-- Traductions pour 'i18n.unit.deg.name'
RELATE i18n_key:'i18n.unit.deg.name'->i18n_translation->i18n_language:fr SET text = 'Degré';
RELATE i18n_key:'i18n.unit.deg.name'->i18n_translation->i18n_language:en SET text = 'Degree';
RELATE i18n_key:'i18n.unit.deg.name'->i18n_translation->i18n_language:es SET text = 'Grado';
RELATE i18n_key:'i18n.unit.deg.name'->i18n_translation->i18n_language:de SET text = 'Grad';
RELATE i18n_key:'i18n.unit.deg.name'->i18n_translation->i18n_language:it SET text = 'Grado';

-- Traductions pour 'i18n.unit.rad.name'
RELATE i18n_key:'i18n.unit.rad.name'->i18n_translation->i18n_language:fr SET text = 'Radian';
RELATE i18n_key:'i18n.unit.rad.name'->i18n_translation->i18n_language:en SET text = 'Radian';
RELATE i18n_key:'i18n.unit.rad.name'->i18n_translation->i18n_language:es SET text = 'Radián';
RELATE i18n_key:'i18n.unit.rad.name'->i18n_translation->i18n_language:de SET text = 'Radian';
RELATE i18n_key:'i18n.unit.rad.name'->i18n_translation->i18n_language:it SET text = 'Radiante';

-- === ÉNERGIE ===

-- Traductions pour 'i18n.unit.j.name'
RELATE i18n_key:'i18n.unit.j.name'->i18n_translation->i18n_language:fr SET text = 'Joule';
RELATE i18n_key:'i18n.unit.j.name'->i18n_translation->i18n_language:en SET text = 'Joule';
RELATE i18n_key:'i18n.unit.j.name'->i18n_translation->i18n_language:es SET text = 'Julio';
RELATE i18n_key:'i18n.unit.j.name'->i18n_translation->i18n_language:de SET text = 'Joule';
RELATE i18n_key:'i18n.unit.j.name'->i18n_translation->i18n_language:it SET text = 'Joule';

-- Traductions pour 'i18n.unit.kwh.name'
RELATE i18n_key:'i18n.unit.kwh.name'->i18n_translation->i18n_language:fr SET text = 'Kilowatt-heure';
RELATE i18n_key:'i18n.unit.kwh.name'->i18n_translation->i18n_language:en SET text = 'Kilowatt-hour';
RELATE i18n_key:'i18n.unit.kwh.name'->i18n_translation->i18n_language:es SET text = 'Kilovatio-hora';
RELATE i18n_key:'i18n.unit.kwh.name'->i18n_translation->i18n_language:de SET text = 'Kilowattstunde';
RELATE i18n_key:'i18n.unit.kwh.name'->i18n_translation->i18n_language:it SET text = 'Chilowattora';

-- Traductions pour 'i18n.unit.cal.name'
RELATE i18n_key:'i18n.unit.cal.name'->i18n_translation->i18n_language:fr SET text = 'Calorie';
RELATE i18n_key:'i18n.unit.cal.name'->i18n_translation->i18n_language:en SET text = 'Calorie';
RELATE i18n_key:'i18n.unit.cal.name'->i18n_translation->i18n_language:es SET text = 'Caloría';
RELATE i18n_key:'i18n.unit.cal.name'->i18n_translation->i18n_language:de SET text = 'Kalorie';
RELATE i18n_key:'i18n.unit.cal.name'->i18n_translation->i18n_language:it SET text = 'Caloria';

-- === PUISSANCE ===

-- Traductions pour 'i18n.unit.w.name'
RELATE i18n_key:'i18n.unit.w.name'->i18n_translation->i18n_language:fr SET text = 'Watt';
RELATE i18n_key:'i18n.unit.w.name'->i18n_translation->i18n_language:en SET text = 'Watt';
RELATE i18n_key:'i18n.unit.w.name'->i18n_translation->i18n_language:es SET text = 'Vatio';
RELATE i18n_key:'i18n.unit.w.name'->i18n_translation->i18n_language:de SET text = 'Watt';
RELATE i18n_key:'i18n.unit.w.name'->i18n_translation->i18n_language:it SET text = 'Watt';

-- Traductions pour 'i18n.unit.kw.name'
RELATE i18n_key:'i18n.unit.kw.name'->i18n_translation->i18n_language:fr SET text = 'Kilowatt';
RELATE i18n_key:'i18n.unit.kw.name'->i18n_translation->i18n_language:en SET text = 'Kilowatt';
RELATE i18n_key:'i18n.unit.kw.name'->i18n_translation->i18n_language:es SET text = 'Kilovatio';
RELATE i18n_key:'i18n.unit.kw.name'->i18n_translation->i18n_language:de SET text = 'Kilowatt';
RELATE i18n_key:'i18n.unit.kw.name'->i18n_translation->i18n_language:it SET text = 'Chilowatt';

-- Traductions pour 'i18n.unit.hp.name'
RELATE i18n_key:'i18n.unit.hp.name'->i18n_translation->i18n_language:fr SET text = 'Cheval-vapeur';
RELATE i18n_key:'i18n.unit.hp.name'->i18n_translation->i18n_language:en SET text = 'Horsepower';
RELATE i18n_key:'i18n.unit.hp.name'->i18n_translation->i18n_language:es SET text = 'Caballo de fuerza';
RELATE i18n_key:'i18n.unit.hp.name'->i18n_translation->i18n_language:de SET text = 'Pferdestärke';
RELATE i18n_key:'i18n.unit.hp.name'->i18n_translation->i18n_language:it SET text = 'Cavallo vapore';

-- === FRÉQUENCE ===

-- Traductions pour 'i18n.unit.hz.name'
RELATE i18n_key:'i18n.unit.hz.name'->i18n_translation->i18n_language:fr SET text = 'Hertz';
RELATE i18n_key:'i18n.unit.hz.name'->i18n_translation->i18n_language:en SET text = 'Hertz';
RELATE i18n_key:'i18n.unit.hz.name'->i18n_translation->i18n_language:es SET text = 'Hercio';
RELATE i18n_key:'i18n.unit.hz.name'->i18n_translation->i18n_language:de SET text = 'Hertz';
RELATE i18n_key:'i18n.unit.hz.name'->i18n_translation->i18n_language:it SET text = 'Hertz';

-- Traductions pour 'i18n.unit.khz.name'
RELATE i18n_key:'i18n.unit.khz.name'->i18n_translation->i18n_language:fr SET text = 'Kilohertz';
RELATE i18n_key:'i18n.unit.khz.name'->i18n_translation->i18n_language:en SET text = 'Kilohertz';
RELATE i18n_key:'i18n.unit.khz.name'->i18n_translation->i18n_language:es SET text = 'Kilohercio';
RELATE i18n_key:'i18n.unit.khz.name'->i18n_translation->i18n_language:de SET text = 'Kilohertz';
RELATE i18n_key:'i18n.unit.khz.name'->i18n_translation->i18n_language:it SET text = 'Chilohertz';

-- Traductions pour 'i18n.unit.mhz.name'
RELATE i18n_key:'i18n.unit.mhz.name'->i18n_translation->i18n_language:fr SET text = 'Mégahertz';
RELATE i18n_key:'i18n.unit.mhz.name'->i18n_translation->i18n_language:en SET text = 'Megahertz';
RELATE i18n_key:'i18n.unit.mhz.name'->i18n_translation->i18n_language:es SET text = 'Megahercio';
RELATE i18n_key:'i18n.unit.mhz.name'->i18n_translation->i18n_language:de SET text = 'Megahertz';
RELATE i18n_key:'i18n.unit.mhz.name'->i18n_translation->i18n_language:it SET text = 'Megahertz';
