DEFINE FUNCTION IF NOT EXISTS fn::base_media_tag_reference_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: seeds de tags Media (types, catégories, portée)', { run_id: $run_id, parent_run_id: $parent_run_id });

-- media_reach_*
LET $r1 = fn::system_tag_create_record('media_reach_local', 'Media Reach: Local', 'Portée locale', '#60a5fa', false);
LET $r2 = fn::system_tag_create_record('media_reach_regional', 'Media Reach: Regional', 'Portée régionale', '#22c55e', false);
LET $r3 = fn::system_tag_create_record('media_reach_national', 'Media Reach: National', 'Portée nationale', '#f59e0b', false);
LET $r4 = fn::system_tag_create_record('media_reach_international', 'Media Reach: International', 'Portée internationale', '#ef4444', false);

-- media_category_*
LET $c1 = fn::system_tag_create_record('media_category_digital', 'Media Category: Digital', 'Média numérique (web, social, email, display)', '#3b82f6', true);
LET $c2 = fn::system_tag_create_record('media_category_print', 'Media Category: Print', 'Média imprimé (journaux, magazines)', '#6b7280', false);
LET $c3 = fn::system_tag_create_record('media_category_broadcast', 'Media Category: Broadcast', 'Diffusion (TV, Radio)', '#a78bfa', false);
LET $c4 = fn::system_tag_create_record('media_category_ooh', 'Media Category: Out Of Home', 'Affichage extérieur (OOH)', '#84cc16', false);
LET $c5 = fn::system_tag_create_record('media_category_event', 'Media Category: Event', 'Événementiel', '#eab308', false);

-- media_type_*
LET $t1 = fn::system_tag_create_record('media_type_email', 'Media Type: Email', 'Email marketing', '#2563eb', true);
LET $t2 = fn::system_tag_create_record('media_type_phone', 'Media Type: Phone', 'Appel téléphonique', '#0ea5e9', false);
LET $t3 = fn::system_tag_create_record('media_type_web', 'Media Type: Web', 'Site web / Landing', '#22c55e', true);
LET $t4 = fn::system_tag_create_record('media_type_social', 'Media Type: Social', 'Réseaux sociaux (post, ad)', '#9333ea', true);
LET $t5 = fn::system_tag_create_record('media_type_push', 'Media Type: Push', 'Notifications push', '#f59e0b', true);
LET $t6 = fn::system_tag_create_record('media_type_sms', 'Media Type: SMS', 'Campagnes SMS', '#e11d48', true);
LET $t7 = fn::system_tag_create_record('media_type_tv', 'Media Type: TV', 'Télévision', '#ef4444', false);
LET $t8 = fn::system_tag_create_record('media_type_radio', 'Media Type: Radio', 'Radio', '#06b6d4', false);
LET $t9 = fn::system_tag_create_record('media_type_newspaper', 'Media Type: Newspaper', 'Presse quotidienne', '#f97316', false);
LET $t10 = fn::system_tag_create_record('media_type_magazine', 'Media Type: Magazine', 'Magazine', '#64748b', false);
LET $t11 = fn::system_tag_create_record('media_type_billboard', 'Media Type: Billboard', 'Affichage / OOH', '#14b8a6', false);
LET $t12 = fn::system_tag_create_record('media_type_event', 'Media Type: Event', 'Événement / Salon', '#84cc16', false);
LET $t13 = fn::system_tag_create_record('media_type_display', 'Media Type: Display', 'Bannières display', '#22d3ee', true);
LET $t14 = fn::system_tag_create_record('media_type_video_ad', 'Media Type: Video Ad', 'Publicité vidéo (pre/mid/post-roll)', '#dc2626', true);

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_communication' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_failure'], 'Erreur: sous-module base_communication introuvable pour builder_function (tags media)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $f_rec = fn::builder_function_create_record('base_media_tag_reference_initialise', $sm.id, 'Initialise les tags de référence Media', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour base_media_tag_reference_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: seeds de tags Media', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise les tags de référence Media (reach/category/type)'
PERMISSIONS FULL;

