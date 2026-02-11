# Script pour supprimer les clés i18n et traductions des doublons commentés

$basePath = "C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations\reference\credentials\credential_type"

# Liste des patterns de clés i18n à supprimer (basé sur les doublons commentés)
$patternsToRemove = @(
    # batch3 - Microsoft
    "credential_type_microsoft_onedrive_oauth2_api",
    "credential_type_microsoft_sharepoint_oauth2_api",
    "credential_type_microsoft_todo_oauth2_api",
    
    # batch4 - WhatsApp
    "credential_type_whatsapp_api",
    "credential_type_whatsapp_trigger_api",
    
    # batch5 - CircleCI
    "credential_type_circleci_api",
    "credential_type_circle_ci_api",
    
    # batch7 - Databases
    "credential_type_mysql",
    "credential_type_mongodb",
    "credential_type_rabbitmq",
    "credential_type_cratedb",
    "credential_type_questdb",
    "credential_type_timescaledb",
    
    # batch8 - KoBoToolbox
    "credential_type_kobotoolbox_api",
    "credential_type_ko_bo_toolbox_api",
    
    # batch9 - LinkedIn
    "credential_type_linkedin_oauth2_api",
    "credential_type_linked_in_oauth2_api",
    "credential_type_linkedin_community_management_oauth2_api",
    "credential_type_linked_in_community_management_oauth2_api",
    
    # batch20 - BambooHR
    "credential_type_bamboohr_api",
    "credential_type_bamboo_hr_api",
    
    # batch24 - ClickUp, ConvertKit
    "credential_type_circle_ci_api",
    "credential_type_clickup_api",
    "credential_type_click_up_api",
    "credential_type_click_up_oauth2_api",
    "credential_type_convert_kit_api",
    
    # batch25 - GetResponse, Google BigQuery, HelpScout, JotForm
    "credential_type_getresponse_api",
    "credential_type_get_response_api",
    "credential_type_get_response_oauth2_api",
    "credential_type_google_big_query_oauth2_api",
    "credential_type_help_scout_oauth2_api",
    "credential_type_jotform_api",
    "credential_type_jot_form_api",
    
    # batch26 - MailerLite
    "credential_type_mailerlite_api",
    "credential_type_mailer_lite_api",
    
    # batch29 - OAuth1, OAuth2
    "credential_type_oauth1_api",
    "credential_type_o_auth1_api",
    "credential_type_oauth2_api",
    "credential_type_o_auth2_api",
    
    # batch30 - PostHog, ProfitWell
    "credential_type_posthog_api",
    "credential_type_post_hog_api",
    "credential_type_profitwell_api",
    "credential_type_profit_well_api",
    
    # batch33 - SurveyMonkey
    "credential_type_surveymonkey_api",
    "credential_type_survey_monkey_api",
    "credential_type_survey_monkey_oauth2_api"
)

# Fonction pour supprimer les blocs complets de clés i18n (3 lignes + commentaires)
function Remove-I18nBlock {
    param(
        [string]$filePath,
        [string]$pattern
    )
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        
        # Pattern pour supprimer la section complète avec commentaires (format batch3)
        # Supprime de "-- =====================================================" jusqu'à "-- ====================================================="
        # qui contient le pattern
        $escapedPattern = [regex]::Escape($pattern)
        $sectionPattern = "(?s)-- =+.*?$escapedPattern.*?-- =+.*?\r?\n"
        
        # Pattern pour supprimer les 3 lignes CREATE i18n_key avec le pattern (format batch24/25)
        $createPattern = "(?m)^CREATE i18n_key:$escapedPattern_(name|description|tooltip) SET.*?\r?\n"
        
        # Pattern pour supprimer les lignes orphelines avec juste "description = ..." (format batch3 incomplet)
        $orphanPattern = "(?m)^\s+description = `".*?$escapedPattern.*?`";\r?\n"
        
        # Pattern pour supprimer les lignes simples contenant le pattern
        $simplePattern = "(?m)^.*$escapedPattern.*\r?\n"
        
        # Supprimer les sections complètes
        $content = $content -replace $sectionPattern, ""
        
        # Supprimer les lignes CREATE i18n_key
        $content = $content -replace $createPattern, ""
        
        # Supprimer les lignes orphelines de description
        $content = $content -replace $orphanPattern, ""
        
        # Supprimer les lignes simples contenant le pattern
        $content = $content -replace $simplePattern, ""
        
        # Nettoyer les lignes vides multiples (max 2 lignes vides consécutives)
        $content = $content -replace "(\r?\n\s*){3,}", "`r`n`r`n"
        
        Set-Content -Path $filePath -Value $content -NoNewline -Encoding UTF8
        Write-Host "  [OK] Supprimé: $pattern dans $(Split-Path $filePath -Leaf)"
    }
}

# Traiter les fichiers i18n_keys
Write-Host "`n[INFO] Suppression des clés i18n..."
$keyFiles = @(
    "credential_type_batch3_i18n_keys.surql",
    "credential_type_batch4_i18n_keys.surql",
    "credential_type_batch5_i18n_keys.surql",
    "credential_type_batch7_i18n_keys.surql",
    "credential_type_batch8_i18n_keys.surql",
    "credential_type_batch9_i18n_keys.surql",
    "credential_type_batch20_i18n_keys.surql",
    "credential_type_batch24_i18n_keys.surql",
    "credential_type_batch25_i18n_keys.surql",
    "credential_type_batch26_i18n_keys.surql",
    "credential_type_batch29_i18n_keys.surql",
    "credential_type_batch30_i18n_keys.surql",
    "credential_type_batch33_i18n_keys.surql"
)

foreach ($file in $keyFiles) {
    $filePath = Join-Path $basePath $file
    if (Test-Path $filePath) {
        Write-Host "`n[INFO] Traitement: $file"
        foreach ($pattern in $patternsToRemove) {
            Remove-I18nBlock -filePath $filePath -pattern $pattern
        }
    }
}

# Traiter les fichiers i18n_translations
Write-Host "`n[INFO] Suppression des traductions i18n..."
$translationFiles = @(
    "credential_type_batch3_i18n_translations.surql",
    "credential_type_batch4_i18n_translations.surql",
    "credential_type_batch5_i18n_translations.surql",
    "credential_type_batch7_i18n_translations.surql",
    "credential_type_batch8_i18n_translations.surql",
    "credential_type_batch9_i18n_translations.surql",
    "credential_type_batch20_i18n_translations.surql",
    "credential_type_batch24_i18n_translations.surql",
    "credential_type_batch25_i18n_translations.surql",
    "credential_type_batch26_i18n_translations.surql",
    "credential_type_batch29_i18n_translations.surql",
    "credential_type_batch30_i18n_translations.surql",
    "credential_type_batch33_i18n_translations.surql"
)

foreach ($file in $translationFiles) {
    $filePath = Join-Path $basePath $file
    if (Test-Path $filePath) {
        Write-Host "`n[INFO] Traitement: $file"
        foreach ($pattern in $patternsToRemove) {
            Remove-I18nBlock -filePath $filePath -pattern $pattern
        }
    }
}

Write-Host "`n[OK] Suppression terminée!"

