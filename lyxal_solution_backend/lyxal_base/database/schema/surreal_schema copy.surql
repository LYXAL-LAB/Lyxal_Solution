-- SurrealDB Schema Migration (Equivalent to initial_schema.sql)

-- 1. Setup Namespace and Database (Optional, usually handled by connection string or config)
-- USE NS lyxal DB identity;

-- 2. Tenants (Organizations)
DEFINE TABLE tenants SCHEMAFULL;
DEFINE FIELD name ON TABLE tenants TYPE string;
DEFINE FIELD slug ON TABLE tenants TYPE string;
DEFINE FIELD logo ON TABLE tenants TYPE option<string>;
DEFINE FIELD created_at ON TABLE tenants TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE tenants TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_tenant_slug ON TABLE tenants COLUMNS slug UNIQUE;

-- 3. Users
DEFINE TABLE IF NOT EXISTS users TYPE SCHEMAFULL;
DEFINE FIELD username ON TABLE users TYPE option<string>;
DEFINE FIELD primary_email ON TABLE users TYPE option<string>;
DEFINE FIELD is_email_verified ON TABLE users TYPE bool DEFAULT false;
DEFINE FIELD primary_phone ON TABLE users TYPE option<string>;
DEFINE FIELD is_phone_verified ON TABLE users TYPE bool DEFAULT false;
DEFINE FIELD password_hash ON TABLE users TYPE option<string>;
DEFINE FIELD name ON TABLE users TYPE option<string>;
DEFINE FIELD avatar ON TABLE users TYPE option<string>;
DEFINE FIELD custom_data ON TABLE users TYPE option<object>;
DEFINE FIELD last_sign_in_at ON TABLE users TYPE option<datetime>;
DEFINE FIELD created_at ON TABLE users TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE users TYPE datetime DEFAULT time::now();
DEFINE FIELD suspended_at ON TABLE users TYPE option<datetime>;

DEFINE INDEX idx_user_username ON TABLE users COLUMNS username UNIQUE;
DEFINE INDEX idx_user_email ON TABLE users COLUMNS primary_email UNIQUE;
DEFINE INDEX idx_user_phone ON TABLE users COLUMNS primary_phone UNIQUE;

-- 4. Applications
DEFINE TABLE applications SCHEMAFULL;
DEFINE FIELD name ON TABLE applications TYPE string;
DEFINE FIELD secret ON TABLE applications TYPE string;
DEFINE FIELD description ON TABLE applications TYPE option<string>;
DEFINE FIELD is_first_party ON TABLE applications TYPE bool DEFAULT false;
DEFINE FIELD application_type ON TABLE applications TYPE string ASSERT $value IN ['native', 'spa', 'traditional_web', 'machine_to_machine'];
DEFINE FIELD redirect_uris ON TABLE applications TYPE array<string> DEFAULT [];
DEFINE FIELD post_logout_redirect_uris ON TABLE applications TYPE array<string> DEFAULT [];
DEFINE FIELD allowed_cors_origins ON TABLE applications TYPE array<string> DEFAULT [];
DEFINE FIELD created_at ON TABLE applications TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE applications TYPE datetime DEFAULT time::now();

-- 5. Roles
DEFINE TABLE roles SCHEMAFULL;
DEFINE FIELD tenant ON TABLE roles TYPE option<record<tenants>>; -- Relation to tenant
DEFINE FIELD name ON TABLE roles TYPE string;
DEFINE FIELD description ON TABLE roles TYPE option<string>;
DEFINE FIELD is_default ON TABLE roles TYPE bool DEFAULT false;
DEFINE FIELD created_at ON TABLE roles TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE roles TYPE datetime DEFAULT time::now();

-- Compound Unique Index for Role (within a tenant or global)
DEFINE INDEX idx_role_name_tenant ON TABLE roles COLUMNS name, tenant UNIQUE;

-- 6. Permissions
DEFINE TABLE permissions SCHEMAFULL;
DEFINE FIELD name ON TABLE permissions TYPE string;
DEFINE FIELD description ON TABLE permissions TYPE option<string>;
DEFINE FIELD resource_id ON TABLE permissions TYPE string;
DEFINE FIELD action ON TABLE permissions TYPE string;
DEFINE FIELD created_at ON TABLE permissions TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_permission_name ON TABLE permissions COLUMNS name UNIQUE;

-- 7. Relations (Graph style)

-- Role-Permission Mapping (Instead of a table, use RELATE in SurrealDB or just an edge table)
DEFINE TABLE has_permission SCHEMAFULL;
DEFINE FIELD in ON TABLE has_permission TYPE record<roles>;
DEFINE FIELD out ON TABLE has_permission TYPE record<permissions>;
DEFINE INDEX idx_role_perm ON TABLE has_permission COLUMNS in, out UNIQUE;

-- User-Role Mapping
DEFINE TABLE has_role SCHEMAFULL;
DEFINE FIELD in ON TABLE has_role TYPE record<users>;
DEFINE FIELD out ON TABLE has_role TYPE record<roles>;
DEFINE FIELD tenant ON TABLE has_role TYPE option<record<tenants>>;
DEFINE FIELD created_at ON TABLE has_role TYPE datetime DEFAULT time::now();
DEFINE INDEX idx_user_role_tenant ON TABLE has_role COLUMNS in, out, tenant UNIQUE;

-- 8. Refresh Tokens
DEFINE TABLE refresh_tokens SCHEMAFULL;
DEFINE FIELD token ON TABLE refresh_tokens TYPE string;
DEFINE FIELD user ON TABLE refresh_tokens TYPE record<users>;
DEFINE FIELD application ON TABLE refresh_tokens TYPE record<applications>;
DEFINE FIELD expires_at ON TABLE refresh_tokens TYPE datetime;
DEFINE FIELD created_at ON TABLE refresh_tokens TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_refresh_token ON TABLE refresh_tokens COLUMNS token UNIQUE;
