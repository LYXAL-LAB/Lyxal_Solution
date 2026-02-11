DEFINE ACCESS admin_manage ON knowledge_domain
    FOR create, update, delete
    WHERE $auth.role = "admin";