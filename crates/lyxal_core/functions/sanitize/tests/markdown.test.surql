-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: conversion en texte brut
RETURN fn::sanitize_markdown("# Titre\n> Voir [doc](http://x) et ![logo](l.png) `code` <b>!</b>") == "Titre\nVoir doc et logo code !";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown(42);
