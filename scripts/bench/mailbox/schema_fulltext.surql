-- Index plein texte du banc (installé après les mesures de base, pour mesurer son coût à part).
DEFINE ANALYZER OVERWRITE bench_mail_text TOKENIZERS class FILTERS lowercase, ascii;
DEFINE INDEX OVERWRITE bench_message_subject_ft ON TABLE bench_message FIELDS subject FULLTEXT ANALYZER bench_mail_text BM25;
DEFINE INDEX OVERWRITE bench_message_from_name_ft ON TABLE bench_message FIELDS from_name FULLTEXT ANALYZER bench_mail_text BM25;
