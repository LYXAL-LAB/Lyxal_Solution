-- cash-management_triggers.surql

-- Auto génération forecastSeq
DEFINE EVENT forecast_autoseq ON TABLE forecast WHEN $event = "CREATE" AND $after.forecastSeq = NONE THEN {
  LET $seq = string::pad(sequence::next("forecast_seq"), 5, "0", "left");
  LET $val = "FC-" + $seq;
  UPDATE $this SET forecastSeq = $val;
};

-- Auto génération forecastRecapSeq
DEFINE EVENT forecast_recap_autoseq ON TABLE forecast_recap WHEN $event = "CREATE" AND $after.forecastRecapSeq = NONE THEN {
  LET $seq = string::pad(sequence::next("forecast_recap_seq"), 5, "0", "left");
  LET $val = "RC-" + $seq;
  UPDATE $this SET forecastRecapSeq = $val;
};

-- Marquer recap comme complété avec date
DEFINE EVENT recap_auto_complete ON TABLE forecast_recap WHEN $after.endingBalance != NONE AND $after.isComplete = false THEN {
  UPDATE $this SET isComplete = true, calculationDate = time::now();
};

-- Récupération automatique du nom pour la ligne de recap
DEFINE EVENT recap_line_autoname ON TABLE forecast_recap_line WHEN $before.relatedToSelectId != $after.relatedToSelectId OR $before.relatedToSelect != $after.relatedToSelect THEN {
  LET $name = $after.relatedToSelect + ":" + string::from($after.relatedToSelectId);
  UPDATE $this SET relatedToSelectName = $name;
};
