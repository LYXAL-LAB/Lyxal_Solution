-- ======================================================================
-- TABLE : WIKI
-- cf : communication/wiki/structures/wiki.surql
-- ======================================================================

-- Relations
DEFINE FIELD project_id ON wiki TYPE option<record<project>>;
DEFINE FIELD project_template_id ON wiki TYPE option<record<project_template>>;

-- Index

DEFINE INDEX idx_wiki_project ON wiki COLUMNS project_id;
DEFINE INDEX idx_wiki_template ON wiki COLUMNS project_template_id;