-- cash-management_indexes.surql

DEFINE INDEX forecast_seq_idx ON forecast FIELDS forecastSeq UNIQUE;
DEFINE INDEX forecast_recap_seq_idx ON forecast_recap FIELDS forecastRecapSeq, company UNIQUE;
DEFINE INDEX forecast_recap_line_type_name_idx ON forecast_recap_line_type FIELDS name;
DEFINE INDEX forecast_generator_company_bank_idx ON forecast_generator FIELDS company, bankDetails;
DEFINE INDEX forecast_recap_line_date_idx ON forecast_recap_line FIELDS estimatedDate;
DEFINE INDEX forecast_recap_line_type_idx ON forecast_recap_line FIELDS forecastRecapLineType;
