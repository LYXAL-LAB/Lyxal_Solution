-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT resource_booking_updated ON TABLE resource_booking WHEN $event = "UPDATE" THEN {
    UPDATE resource_booking SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour vérifier la disponibilité des ressources
DEFINE EVENT check_resource_availability ON TABLE resource_booking WHEN $event = "CREATE" THEN {
    LET $conflicts = (SELECT * FROM resource_booking 
                     WHERE resource_id = $after.resource_id 
                     AND id != $after.id
                     AND from_date <= $after.to_date 
                     AND to_date >= $after.from_date);
    IF array::length($conflicts) > 0 THEN {
        THROW "Resource conflict: Resource is already booked for the specified period";
    };
};