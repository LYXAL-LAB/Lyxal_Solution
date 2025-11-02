DEFINE ACCESS admin_manage ON knowledge_topic
    FOR create, update, delete
    WHERE $auth.role = "admin";