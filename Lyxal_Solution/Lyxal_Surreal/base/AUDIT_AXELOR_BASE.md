# Audit couverture Axelor Base vs Module Base (SurrealDB)

Ce document sert de base de mapping entre les entités Axelor Base et notre implémentation (tables ou tags) dans le module `base`.

## Légende
- Couvert (table): table(s) implémentées et orchestrées
- Couvert (tags): géré via `system_tag`
- Manquant: à implémenter
- À vérifier: présent dans l’arborescence mais non confirmé (ou renommage)

## Synthèse

- Couvert (tables)
  - Workflow & système: Batch, MailBatch, Timer, TimerHistory, SequenceVersion, TraceBack, StopReason, SharingSetting, Routing (+ Action/Create/Line/Rule), ApprovalLevel
  - Système: File, FileType, FileField, FileTab; FileSourceConnector (+ Parameters); Frequency; Duration; ExceptionOrigin; ImportExportInterface; FakerApiField (+ Parameters); ConnectorMapper; SyncContactHistoric; Priority; PermissionAssistant; ManagementObject; CurrencyConversionLine
  - i18n: Language; Locale; DateTimeFormat
  - Géographique: Continent; Region; Country; Timezone; AddressFormat (+ liens Country ↔ Timezone, Country ↔ AddressFormat)
  - Produit: Product; ProductCategory; ProductCompany; ProductFamily; ProductMultipleQty; ProductVariant (+ Attr/Config/Value); PriceList; PartnerPriceList
  - Taxation & Pricing: TaxType; Tax; TaxLine; TaxEquiv; TaxNumber; Pricing; PricingLine; PricingRule; ShippingCoef
  - Recherche & Métadonnées: MetaModel; MetaField; MetaFile; MetaSchedule; MetaGroupMenuAssistant; ResearchRequest; ResearchParameter; ResearchParameterConfig; ResearchResultLine; ResearchPrimaryKey; IndicatorGenerator; IndicatorGeneratorGrouping; ABCAnalysis (+ Class/Line); GlobalTrackingConfigurationLine; GlobalTrackingLog (+ Line); AttributionModel; PeriodType; ReportType
  - Organisation: Team; TeamTask; ICalendar; CalendarManagement; Tour; TourLine

- Couvert (tags)
  - Partner: partner_source_*, partner_category_*, partner_role_*, partner_function_*, partner_department_* (+ tags d’adresse/bank/price_list_type)
  - Communication: media_reach_*, media_category_*, media_type_*
  - Classifications (ex-08_product_extended): industry_*, main_activity_*, business_function_*

- Manquants (prioritaires)
  - Workflow & système: Sequence (table principale) ok
  - Géographique: City, Street, Canton, GeographicalArea, EconomicArea  OK
  - Système: EmailAccount, PaymentMode OK
  - Sécurité (si requis dans Base): Permission, Role ok
  - Temps/Organisation: Period (Axelor), Year OK
  - Impression (si périmètre base): PrintingTemplate*, Print*, Birt* ok
  - Data sharing / Import avancé (si périmètre base): AdvancedExport*, AdvancedImport*, DataSharing* ok

- À vérifier
  - Company, CompanyDepartment, Department (présents sous `base_company/`)
  - App / AppBase (`app_base/`)
  - Bank, BankAddress, BankDetails (partiellement côté partner)
  - EmailAddress présent; EmailAccount manquant ok

---

## Tableau de correspondances (à compléter)

| Axelor (entity) | Statut | Surreal (table/tag) | Fichier(s) | Notes |
|---|---|---|---|---|
| Batch | Couvert (table) | base_batch | base_workflow/base_batch_create_table.surql | |
| MailBatch | Couvert (table) | base_mail_batch | base_workflow/base_mail_batch_create_table.surql | |
| Timer | Couvert (table) | base_timer | base_workflow/base_timer_create_table.surql | |
| TimerHistory | Couvert (table) | base_timer_history | base_workflow/base_timer_history_create_table.surql | |
| SequenceVersion | Couvert (table) | base_sequence_version | base_workflow/base_sequence_version_create_table.surql | |
| Sequence | Manquant | base_sequence (à créer) | - | |
| TraceBack | Couvert (table) | base_trace_back | base_workflow/base_trace_back_create_table.surql | |
| StopReason | Couvert (table) | base_stop_reason | base_workflow/base_stop_reason_create_table.surql | |
| SharingSetting | Couvert (table) | base_sharing_setting | base_workflow/base_sharing_setting_create_table.surql | |
| Routing (+Action/Create/Line/Rule) | Couvert (table) | base_routing* | base_workflow/base_routing_create_tables.surql | |
| ApprovalLevel | Couvert (table) | base_approval_level | base_workflow/base_approval_level_create_table.surql | |
| Language | Couvert (table) | base_language | base_i18n/base_language_create_table.surql | |
| Locale | Couvert (table) | base_locale | base_i18n/base_locale_create_table.surql | addressFormat → record<base_address_format> |
| DateTimeFormat | Couvert (table) | base_datetime_format | base_i18n/base_datetime_format_create_table.surql | seeds présents |
| Continent/Region/Country/Timezone | Couvert (table) | base_* | base_geographic/*_create_table.surql | liens + seeds |
| AddressFormat | Couvert (table) | base_address_format | base_geographic/base_address_format_create_table.surql | seeds + mapping pays |
| City/Street/Canton | Manquant | base_city/base_street/base_canton | - | |
| CurrencyConversionLine | Couvert (table) | base_currency_conversion_line | base_system/base_currency_conversion_line_create_table.surql | |
| File/FileType/FileField/FileTab | Couvert (table) | base_file* | base_system/base_file_create_tables.surql | |
| FileSourceConnector (+Parameters) | Couvert (table) | base_file_source_connector* | base_system/base_file_source_connector_create_tables.surql | |
| Frequency/Duration | Couvert (table) | base_frequency/base_duration | base_system/base_frequency_duration_create_tables.surql | |
| ExceptionOrigin | Couvert (table) | base_exception_origin | base_system/base_exception_origin_create_table.surql | |
| ImportExportInterface | Couvert (table) | base_import_export_interface | base_system/base_import_export_interface_create_table.surql | |
| FakerApiField (+Parameters) | Couvert (table) | base_faker_api_* | base_system/base_faker_api_create_tables.surql | |
| ConnectorMapper | Couvert (table) | base_connector_mapper | base_system/base_connector_mapper_create_table.surql | |
| SyncContactHistoric | Couvert (table) | base_sync_contact_historic | base_system/base_sync_contact_historic_create_table.surql | |
| EmailAccount | Manquant | base_email_account | - | |
| PaymentMode | Manquant | base_payment_mode | - | |
| PermissionAssistant | Couvert (table) | base_permission_assistant | base_system/base_permission_assistant_create_table.surql | |
| ManagementObject | Couvert (table) | base_management_object | base_system/base_management_object_create_table.surql | |
| Permission | Manquant (si requis) | base_permission | - | |
| Role | Manquant (si requis) | base_role | - | |
| Product / Category / Family / Company / MultipleQty | Couvert (table) | base_product* | base_product/* | |
| ProductVariant (+Attr/Config/Value) | Couvert (table) | base_product_variant* | base_product/* | |
| PriceList/PartnerPriceList | Couvert (table) | base_price_list / base_partner_price_list | base_product/*, base_partner/* | |
| TaxType/Tax/TaxLine/TaxEquiv/TaxNumber | Couvert (table) | base_tax_* | base_taxation_pricing/* | |
| Pricing/PricingLine/PricingRule/ShippingCoef | Couvert (table) | base_pricing* / base_shipping_coef | base_taxation_pricing/* | |
| ResearchRequest/Parameter/Config/ResultLine/PrimaryKey | Couvert (table) | base_research_* | base_research_metadata/* | |
| IndicatorGenerator (+Grouping) | Couvert (table) | base_indicator_generator* | base_research_metadata/* | |
| MetaModel/MetaField/MetaFile/MetaSchedule/MetaGroupMenuAssistant | Couvert (table) | base_meta_* | base_research_metadata/* | |
| ABCAnalysis (+Class/Line) | Couvert (table) | base_abc_analysis* | base_research_metadata/* | |
| GlobalTracking* | Couvert (table) | base_global_tracking_* | base_research_metadata/* | |
| AttributionModel | Couvert (table) | base_attribution_model | base_research_metadata/base_attribution_model_create_table.surql | |
| PeriodType | Couvert (table) | base_period_type | base_research_metadata/base_period_type_create_table.surql | |
| ReportType | Couvert (table) | base_report_type | base_research_metadata/base_report_type_create_table.surql | |
| Team/TeamTask | Couvert (table) | base_team_task | base_organisation/* | |
| ICalendar/CalendarManagement | Couvert (table) | base_icalendar / base_calendar_management | base_organisation/* | |
| Period (Axelor) | Manquant | base_period | - | |
| Year | Manquant | base_year | - | |
| Partner / Address / Link / LinkType / Company / Bank | Couvert (table) | base_partner* | base_partner/* | |
| PartnerCategory/PartnerRole | Couvert (tags) | partner_category_*/partner_role_* | base_partner/base_partner_tag_reference.surql | |
| IndustrySector/MainActivity/Function | Couvert (tags) | industry_*/main_activity_*/business_function_* | (tags) | |
| Communication Media (reach/category/type) | Couvert (tags) | media_* | base_communication/base_media_tag_reference.surql | |

> Ajoute/ajuste des lignes au besoin pour compléter la cartographie.

---

## Catalogue Axelor (source) à mapper

Chemin: `axelor-open-suite/axelor-base/src/main/resources/domains`

Extraits principaux (non exhaustif):

- ABCAnalysis, ABCAnalysisClass, ABCAnalysisLine
- AccountManagement, Address, AddressTemplate (+ Line)
- AdvancedExport (+ Line), AdvancedImport
- App, AppBase
- Bank, BankAddress, BankDetails
- Batch, BaseBatch, BatchImportHistory
- CalendarConfiguration, CalendarManagement
- CancelReason, Canton, Citizenship, City
- Company, CompanyDepartment, Department
- ConnectorMapper, Country, Currency, CurrencyConversionLine
- DataBackup, DataSharingReferential (+ Line), DataSharingProductWizard
- DayPlanning, Duration, EconomicArea
- EmailAccount, EmailAddress
- EventsPlanning (+ Line)
- ExceptionOrigin
- FakerApiField (+ Parameters)
- File, FileType, FileField, FileTab
- FileSourceConnector (+ Parameters)
- FiscalPosition, Frequency, Function
- GeographicalArea, GlobalTrackingConfigurationLine, GlobalTrackingLog (+ Line)
- Group, ICalendar (+ Event/User)
- ImportBatch, ImportConfiguration, ImportExportInterface, ImportExportTranslation (+ History)
- IndicatorGenerator (+ Grouping), IndustrySector, Language, Localization
- Mail, MailBatch, MailingListMessage, MailTemplateAssociation, MainActivity
- ManagementObject, Message, MetaField, MetaGroupMenuAssistant, MetaSchedule, ModelEmailLink
- Partner (+ Address/Category/Link/LinkType/PriceList/Role)
- PaymentMode, Period, Permission, PermissionAssistant, PfxCertificate
- PickListEntry, PriceList (+ Line), Pricing (+ Rule/Line), Print (+ Line), PrintingTemplate (+ Line/Wizard), PrintingSettings, PrintTemplate (+ Line)
- Product (+ Category/Company/Family/MultipleQty), ProductVariant (+ Attr/Config/Value)
- Region, RegistrationNumberTemplate
- Research* (Request, Parameter, Config, ResultLine, PrimaryKey)
- Role, Routing (+ Action/Create/Line/Rule)
- Sequence (+ Version), SharingSetting, ShippingCoef, Site, Source, StopReason, Street, SyncContact (+ Historic), Tag
- Tax (+ Line/Equiv/Number/Type), Team (+ Task), Template (+ Context/Rule/RuleLine), Timer (+ History), TraceBack, TradingName (+ PrintingSettings)
- Unit (+ Conversion), User, WeeklyPlanning, Year

Complète la table ci-dessus avec les statuts exacts et les chemins correspondants.
