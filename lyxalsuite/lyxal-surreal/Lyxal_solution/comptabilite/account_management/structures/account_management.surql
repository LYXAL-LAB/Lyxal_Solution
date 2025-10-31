-- =============================================================================
-- TABLE: account_management (AccountManagement)
-- Gestion comptable
-- =============================================================================
DEFINE TABLE account_management SCHEMAFULL;

DEFINE FIELD product ON account_management TYPE option<record<product>>;
DEFINE FIELD productFamily ON account_management TYPE option<record<product_family>>;
DEFINE FIELD company ON account_management TYPE record<company>;

-- Index
DEFINE INDEX idx_account_management_product ON account_management COLUMNS product;
DEFINE INDEX idx_account_management_family ON account_management COLUMNS productFamily;
DEFINE INDEX idx_account_management_company ON account_management COLUMNS company;