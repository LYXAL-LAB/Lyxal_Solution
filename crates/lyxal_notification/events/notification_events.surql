-- ============================================================================
-- EVENTS : lyxal_notification
-- MODULE : lyxal_notification
-- RÔLE   : Publication des événements notification.* vers le bus lyxal_event
-- ============================================================================
-- Publiés par la base dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ; une
-- publication refusée fait échouer la mutation. Jamais de contenu, d'objet ni de secret.

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
WHEN $event = "UPDATE" AND $before.status != "failed" AND $after.status = "failed"
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
            channel: $after.channel,
            attempts: $after.attempts,
            error_class: $after.last_error.class,
            error_code: $after.last_error.code
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
            address: $after.address,
            reason: $after.reason
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};
