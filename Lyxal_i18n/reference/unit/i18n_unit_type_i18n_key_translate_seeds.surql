-- =============================================================================================
-- |
-- | Fichier     : i18n_unit_type_i18n_key_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les noms des types d'unités.
-- |
-- =============================================================================================

-- Traductions pour 'i18n.unit_type.weight.name'
RELATE i18n_key:'i18n.unit_type.weight.name'->i18n_translation->i18n_language:fr 
SET text = 'Poids';
RELATE i18n_key:'i18n.unit_type.weight.name'->i18n_translation->i18n_language:en 
SET text = 'Weight';
RELATE i18n_key:'i18n.unit_type.weight.name'->i18n_translation->i18n_language:es 
SET text = 'Peso';
RELATE i18n_key:'i18n.unit_type.weight.name'->i18n_translation->i18n_language:de 
SET text = 'Gewicht';
RELATE i18n_key:'i18n.unit_type.weight.name'->i18n_translation->i18n_language:it 
SET text = 'Peso';

-- Traductions pour 'i18n.unit_type.length.name'
RELATE i18n_key:'i18n.unit_type.length.name'->i18n_translation->i18n_language:fr 
SET text = 'Longueur';
RELATE i18n_key:'i18n.unit_type.length.name'->i18n_translation->i18n_language:en 
SET text = 'Length';
RELATE i18n_key:'i18n.unit_type.length.name'->i18n_translation->i18n_language:es 
SET text = 'Longitud';
RELATE i18n_key:'i18n.unit_type.length.name'->i18n_translation->i18n_language:de 
SET text = 'Länge';
RELATE i18n_key:'i18n.unit_type.length.name'->i18n_translation->i18n_language:it 
SET text = 'Lunghezza';

-- Traductions pour 'i18n.unit_type.volume.name'
RELATE i18n_key:'i18n.unit_type.volume.name'->i18n_translation->i18n_language:fr 
SET text = 'Volume';
RELATE i18n_key:'i18n.unit_type.volume.name'->i18n_translation->i18n_language:en 
SET text = 'Volume';
RELATE i18n_key:'i18n.unit_type.volume.name'->i18n_translation->i18n_language:es 
SET text = 'Volumen';
RELATE i18n_key:'i18n.unit_type.volume.name'->i18n_translation->i18n_language:de 
SET text = 'Volumen';
RELATE i18n_key:'i18n.unit_type.volume.name'->i18n_translation->i18n_language:it 
SET text = 'Volume';

-- Traductions pour 'i18n.unit_type.time.name'
RELATE i18n_key:'i18n.unit_type.time.name'->i18n_translation->i18n_language:fr 
SET text = 'Temps';
RELATE i18n_key:'i18n.unit_type.time.name'->i18n_translation->i18n_language:en 
SET text = 'Time';
RELATE i18n_key:'i18n.unit_type.time.name'->i18n_translation->i18n_language:es 
SET text = 'Tiempo';
RELATE i18n_key:'i18n.unit_type.time.name'->i18n_translation->i18n_language:de 
SET text = 'Zeit';
RELATE i18n_key:'i18n.unit_type.time.name'->i18n_translation->i18n_language:it 
SET text = 'Tempo';

-- Traductions pour 'i18n.unit_type.quantity.name'
RELATE i18n_key:'i18n.unit_type.quantity.name'->i18n_translation->i18n_language:fr 
SET text = 'Quantité';
RELATE i18n_key:'i18n.unit_type.quantity.name'->i18n_translation->i18n_language:en 
SET text = 'Quantity';
RELATE i18n_key:'i18n.unit_type.quantity.name'->i18n_translation->i18n_language:es 
SET text = 'Cantidad';
RELATE i18n_key:'i18n.unit_type.quantity.name'->i18n_translation->i18n_language:de 
SET text = 'Menge';
RELATE i18n_key:'i18n.unit_type.quantity.name'->i18n_translation->i18n_language:it 
SET text = 'Quantità';

-- Traductions pour 'i18n.unit_type.surface.name'
RELATE i18n_key:'i18n.unit_type.surface.name'->i18n_translation->i18n_language:fr SET text = 'Surface';
RELATE i18n_key:'i18n.unit_type.surface.name'->i18n_translation->i18n_language:en SET text = 'Surface';
RELATE i18n_key:'i18n.unit_type.surface.name'->i18n_translation->i18n_language:es SET text = 'Superficie';
RELATE i18n_key:'i18n.unit_type.surface.name'->i18n_translation->i18n_language:de SET text = 'Fläche';
RELATE i18n_key:'i18n.unit_type.surface.name'->i18n_translation->i18n_language:it SET text = 'Superficie';

-- Traductions pour 'i18n.unit_type.speed.name'
RELATE i18n_key:'i18n.unit_type.speed.name'->i18n_translation->i18n_language:fr SET text = 'Vitesse';
RELATE i18n_key:'i18n.unit_type.speed.name'->i18n_translation->i18n_language:en SET text = 'Speed';
RELATE i18n_key:'i18n.unit_type.speed.name'->i18n_translation->i18n_language:es SET text = 'Velocidad';
RELATE i18n_key:'i18n.unit_type.speed.name'->i18n_translation->i18n_language:de SET text = 'Geschwindigkeit';
RELATE i18n_key:'i18n.unit_type.speed.name'->i18n_translation->i18n_language:it SET text = 'Velocità';

-- Traductions pour 'i18n.unit_type.temperature.name'
RELATE i18n_key:'i18n.unit_type.temperature.name'->i18n_translation->i18n_language:fr SET text = 'Température';
RELATE i18n_key:'i18n.unit_type.temperature.name'->i18n_translation->i18n_language:en SET text = 'Temperature';
RELATE i18n_key:'i18n.unit_type.temperature.name'->i18n_translation->i18n_language:es SET text = 'Temperatura';
RELATE i18n_key:'i18n.unit_type.temperature.name'->i18n_translation->i18n_language:de SET text = 'Temperatur';
RELATE i18n_key:'i18n.unit_type.temperature.name'->i18n_translation->i18n_language:it SET text = 'Temperatura';

-- Traductions pour 'i18n.unit_type.data.name'
RELATE i18n_key:'i18n.unit_type.data.name'->i18n_translation->i18n_language:fr SET text = 'Données informatiques';
RELATE i18n_key:'i18n.unit_type.data.name'->i18n_translation->i18n_language:en SET text = 'Computer Data';
RELATE i18n_key:'i18n.unit_type.data.name'->i18n_translation->i18n_language:es SET text = 'Datos informáticos';
RELATE i18n_key:'i18n.unit_type.data.name'->i18n_translation->i18n_language:de SET text = 'Computerdaten';
RELATE i18n_key:'i18n.unit_type.data.name'->i18n_translation->i18n_language:it SET text = 'Dati informatici';

-- Traductions pour 'i18n.unit_type.pressure.name'
RELATE i18n_key:'i18n.unit_type.pressure.name'->i18n_translation->i18n_language:fr SET text = 'Pression';
RELATE i18n_key:'i18n.unit_type.pressure.name'->i18n_translation->i18n_language:en SET text = 'Pressure';
RELATE i18n_key:'i18n.unit_type.pressure.name'->i18n_translation->i18n_language:es SET text = 'Presión';
RELATE i18n_key:'i18n.unit_type.pressure.name'->i18n_translation->i18n_language:de SET text = 'Druck';
RELATE i18n_key:'i18n.unit_type.pressure.name'->i18n_translation->i18n_language:it SET text = 'Pressione';

-- Traductions pour 'i18n.unit_type.angle.name'
RELATE i18n_key:'i18n.unit_type.angle.name'->i18n_translation->i18n_language:fr SET text = 'Angle';
RELATE i18n_key:'i18n.unit_type.angle.name'->i18n_translation->i18n_language:en SET text = 'Angle';
RELATE i18n_key:'i18n.unit_type.angle.name'->i18n_translation->i18n_language:es SET text = 'Ángulo';
RELATE i18n_key:'i18n.unit_type.angle.name'->i18n_translation->i18n_language:de SET text = 'Winkel';
RELATE i18n_key:'i18n.unit_type.angle.name'->i18n_translation->i18n_language:it SET text = 'Angolo';

-- Traductions pour 'i18n.unit_type.energy.name'
RELATE i18n_key:'i18n.unit_type.energy.name'->i18n_translation->i18n_language:fr SET text = 'Énergie';
RELATE i18n_key:'i18n.unit_type.energy.name'->i18n_translation->i18n_language:en SET text = 'Energy';
RELATE i18n_key:'i18n.unit_type.energy.name'->i18n_translation->i18n_language:es SET text = 'Energía';
RELATE i18n_key:'i18n.unit_type.energy.name'->i18n_translation->i18n_language:de SET text = 'Energie';
RELATE i18n_key:'i18n.unit_type.energy.name'->i18n_translation->i18n_language:it SET text = 'Energia';

-- Traductions pour 'i18n.unit_type.power.name'
RELATE i18n_key:'i18n.unit_type.power.name'->i18n_translation->i18n_language:fr SET text = 'Puissance';
RELATE i18n_key:'i18n.unit_type.power.name'->i18n_translation->i18n_language:en SET text = 'Power';
RELATE i18n_key:'i18n.unit_type.power.name'->i18n_translation->i18n_language:es SET text = 'Potencia';
RELATE i18n_key:'i18n.unit_type.power.name'->i18n_translation->i18n_language:de SET text = 'Leistung';
RELATE i18n_key:'i18n.unit_type.power.name'->i18n_translation->i18n_language:it SET text = 'Potenza';

-- Traductions pour 'i18n.unit_type.frequency.name'
RELATE i18n_key:'i18n.unit_type.frequency.name'->i18n_translation->i18n_language:fr SET text = 'Fréquence';
RELATE i18n_key:'i18n.unit_type.frequency.name'->i18n_translation->i18n_language:en SET text = 'Frequency';
RELATE i18n_key:'i18n.unit_type.frequency.name'->i18n_translation->i18n_language:es SET text = 'Frecuencia';
RELATE i18n_key:'i18n.unit_type.frequency.name'->i18n_translation->i18n_language:de SET text = 'Frequenz';
RELATE i18n_key:'i18n.unit_type.frequency.name'->i18n_translation->i18n_language:it SET text = 'Frequenza';
