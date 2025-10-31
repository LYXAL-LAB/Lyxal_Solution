-- ======================================================================
-- TABLE : TOPIC
-- cf : communication/topic/structures/topic.surql
-- ======================================================================

-- Relations
DEFINE FIELD project_id ON topic TYPE option<record<project>>;

-- Index

DEFINE INDEX idx_topic_project ON topic COLUMNS project_id;