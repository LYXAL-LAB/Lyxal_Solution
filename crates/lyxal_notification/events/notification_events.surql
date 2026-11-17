-- ============================================================================
-- EVENTS : lyxal_notification
-- MODULE : lyxal_notification
-- RÔLE   : Publication des événements notification.* vers le bus lyxal_event
-- ============================================================================
-- Publiés par la base dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ; une
-- publication refusée fait échouer la mutation. Jamais de contenu, d'objet ni de secret.

-- ----------------------------------------------------------------------------
-- Langue de l'organisation, notée sur le déclenchement
-- ----------------------------------------------------------------------------
-- Un événement s'exécute avec tous les droits : la langue est lue quels que soient les droits
-- de qui déclenche, et le worker (compte de service) n'a pas à lire l'organisation.

DEFINE EVENT OVERWRITE notification_run_organization_locale ON TABLE notification_run
WHEN $event = "CREATE" AND $after.tenant IS NOT NONE
THEN {
    UPDATE $after.id SET organization_locale = (SELECT VALUE locale FROM ONLY $after.tenant);
};

DEFINE EVENT OVERWRITE notification_message_sent_event ON TABLE notification_message
WHEN $event = "CREATE" AND $after.status = "sent"
THEN {
    LET $run = (SELECT tenant, workflow FROM ONLY $after.run);
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.message.sent",
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            message_id: <string> $after.id,
            run_id: <string> $after.run,
            job_id: <string> $after.job,
            workflow_id: <string> $run.workflow,
            tenant: IF $run.tenant IS NONE { NONE } ELSE { <string> $run.tenant },
            channel: $after.channel
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE notification_message_failed_event ON TABLE notification_job
WHEN $event = "UPDATE" AND $before.status != "failed" AND $after.status = "failed" AND $after.type IN fn::notification_channels({})
THEN {
    LET $run = (SELECT tenant, workflow FROM ONLY $after.run);
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.message.failed",
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            run_id: <string> $after.run,
            job_id: <string> $after.id,
            workflow_id: <string> $run.workflow,
            tenant: IF $run.tenant IS NONE { NONE } ELSE { <string> $run.tenant },
            channel: $after.type,
            attempts: $after.attempts,
            error_class: $after.last_error.class,
            error_code: $after.last_error.code
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- Déclenchements annulés ou fusionnés dans un regroupement (identifiants seulement)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE notification_run_canceled_event ON TABLE notification_run
WHEN $event = "UPDATE" AND $before.status != "canceled" AND $after.status = "canceled"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.run.canceled",
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            run_id: <string> $after.id,
            tenant: IF $after.tenant IS NONE { NONE } ELSE { <string> $after.tenant },
            workflow_id: <string> $after.workflow
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE notification_run_merged_event ON TABLE notification_run
WHEN $event = "UPDATE" AND $before.status != "merged" AND $after.status = "merged"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.run.merged",
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            run_id: <string> $after.id,
            digest_id: IF $after.digest IS NONE { NONE } ELSE { <string> $after.digest }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE notification_address_suppressed_event ON TABLE notification_suppression
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.address.suppressed",
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            suppression_id: <string> $after.id,
            tenant: IF $after.tenant IS NONE { NONE } ELSE { <string> $after.tenant },
            channel: $after.channel,
            -- Un numéro de téléphone ne voyage jamais dans un événement (canal sms : identifiants seulement)
            address: IF $after.channel = "email" { $after.address } ELSE { NONE },
            reason: $after.reason
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- Abonnés, préférences, abonnements aux sujets (identifiants seulement : jamais l'adresse, le
-- téléphone ni le nom ; la clé d'un abonné est aléatoire)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE notification_subscriber_changed_event ON TABLE notification_subscriber
WHEN $event = "CREATE" OR $event = "DELETE"
    OR ($event = "UPDATE" AND ($before.email != $after.email OR $before.phone != $after.phone
        OR $before.first_name != $after.first_name OR $before.last_name != $after.last_name
        OR $before.locale != $after.locale OR $before.timezone != $after.timezone OR $before.data != $after.data))
THEN {
    -- Un compte n'est lié qu'à son identifiant auth:<identité> : personne ne crée l'abonné d'un
    -- autre à son propre compte pour lire ensuite ses informations et ses préférences
    IF $event = "CREATE" AND $after.identity IS NOT NONE
        AND $after.subscriber_id != string::concat("auth:", <string> record::id($after.identity)) {
        THROW "NOTIFICATION_SUBSCRIBER_IDENTITY_MISMATCH";
    };
    LET $record = IF $event = "DELETE" { $before } ELSE { $after };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: IF $event = "CREATE" { "notification.subscriber.created" } ELSE IF $event = "DELETE" { "notification.subscriber.deleted" } ELSE { "notification.subscriber.updated" },
        producer: "lyxal_notification",
        source: $record.id,
        payload: {
            subscriber_id: <string> $record.id,
            tenant: IF $record.tenant IS NONE { NONE } ELSE { <string> $record.tenant },
            identity_id: IF $record.identity IS NONE { NONE } ELSE { <string> $record.identity }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE notification_preference_updated_event ON TABLE notification_preference
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.channels != $after.channels OR $before.quiet_hours != $after.quiet_hours))
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.preference.updated",
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            preference_id: <string> $after.id,
            tenant: IF $after.tenant IS NONE { NONE } ELSE { <string> $after.tenant },
            level: $after.level,
            subscriber_id: IF $after.subscriber IS NONE { NONE } ELSE { <string> $after.subscriber },
            workflow_id: IF $after.workflow IS NONE { NONE } ELSE { <string> $after.workflow },
            category_id: IF $after.category IS NONE { NONE } ELSE { <string> $after.category }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE notification_topic_member_event ON TABLE notification_topic_member
WHEN $event = "CREATE" OR $event = "DELETE"
THEN {
    -- Un compte n'est lié qu'à son identifiant auth:<identité> : personne ne crée l'abonné d'un
    -- autre à son propre compte pour lire ensuite ses informations et ses préférences
    IF $event = "CREATE" AND $after.identity IS NOT NONE
        AND $after.subscriber_id != string::concat("auth:", <string> record::id($after.identity)) {
        THROW "NOTIFICATION_SUBSCRIBER_IDENTITY_MISMATCH";
    };
    LET $record = IF $event = "DELETE" { $before } ELSE { $after };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: IF $event = "CREATE" { "notification.topic.subscribed" } ELSE { "notification.topic.unsubscribed" },
        producer: "lyxal_notification",
        source: $record.id,
        payload: {
            topic_id: <string> $record.topic,
            subscriber_id: <string> $record.subscriber
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- Intégrations (identifiants seulement, jamais de chemin de secret ni de réglage)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE notification_integration_changed_event ON TABLE notification_integration
THEN {
    LET $record = IF $event = "DELETE" { $before } ELSE { $after };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: IF $event = "CREATE" { "notification.integration.created" } ELSE IF $event = "DELETE" { "notification.integration.deleted" } ELSE { "notification.integration.updated" },
        producer: "lyxal_notification",
        source: $record.id,
        payload: {
            integration_id: <string> $record.id,
            tenant: IF $record.tenant IS NONE { NONE } ELSE { <string> $record.tenant },
            channel: $record.channel
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- Adresses de messagerie et web (identifiants seulement : jamais l'adresse, l'hôte ni la clé ;
-- le résultat du dernier appel noté par le worker n'est pas une modification)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE notification_endpoint_changed_event ON TABLE notification_endpoint
WHEN $event = "CREATE" OR $event = "DELETE"
    OR ($event = "UPDATE" AND ($before.name != $after.name OR $before.active != $after.active
        OR $before.chat_id != $after.chat_id OR $before.secret_rotated_at != $after.secret_rotated_at))
THEN {
    LET $record = IF $event = "DELETE" { $before } ELSE { $after };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: IF $event = "CREATE" { "notification.endpoint.created" } ELSE IF $event = "DELETE" { "notification.endpoint.deleted" } ELSE { "notification.endpoint.updated" },
        producer: "lyxal_notification",
        source: $record.id,
        payload: {
            endpoint_id: <string> $record.id,
            subscriber_id: <string> $record.subscriber,
            tenant: IF $record.tenant IS NONE { NONE } ELSE { <string> $record.tenant },
            channel: $record.channel
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- Retours des fournisseurs : message délivré, rejeté, plainte (identifiants seulement, jamais
-- l'adresse)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE notification_message_status_event ON TABLE notification_message
WHEN $event = "UPDATE" AND $before.status != $after.status AND $after.status IN ["delivered", "bounced", "complained"]
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: string::concat("notification.message.", $after.status),
        producer: "lyxal_notification",
        source: $after.id,
        payload: {
            message_id: <string> $after.id,
            run_id: <string> $after.run,
            integration_id: IF $after.integration IS NONE { NONE } ELSE { <string> $after.integration }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};
