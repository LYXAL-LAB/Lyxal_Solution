DEFINE ACCESS admin_manage ON knowledge_topic_keyword
    FOR create, update, delete
    WHERE $auth.role = "admin";