#### DOCUMENTATION OFFICIEL SURREAL ####

## DEFINE STATEMENTS ##

# DEFINE ACCESS #
DEFINE ACCESS [ OVERWRITE | IF NOT EXISTS ] @name
  ON [ ROOT | NAMESPACE | DATABASE ]
  TYPE [
    JWT [ ALGORITHM @algorithm KEY @key | URL @url ]
    | RECORD
      [ SIGNUP @expression ]
      [ SIGNIN @expression ]
      [ WITH JWT
        [ ALGORITHM @algorithm KEY @key | URL @url ]
        [ WITH ISSUER KEY @key ]
      ]
      [ WITH REFRESH ]
    | BEARER FOR [ USER | RECORD ]
  [ AUTHENTICATE @expression ]
  [ DURATION
    [ FOR GRANT @duration ]
    [ FOR TOKEN @duration ]
    [ FOR SESSION @duration ]
  ]
  [ COMMENT @string ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/access

DEFINE ACCESS ... TYPE BEARER

DEFINE ACCESS [ OVERWRITE | IF NOT EXISTS ] @name
  ON [ NAMESPACE | DATABASE ]
  TYPE BEARER FOR [ USER | RECORD ]
  [ AUTHENTICATE @expression ]
  [ DURATION
    [ FOR GRANT @duration ]
    [ FOR TOKEN @duration ]
    [ FOR SESSION @duration ]
  ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/access/bearer

DEFINE ACCESS ... TYPE JWT

DEFINE ACCESS [ OVERWRITE | IF NOT EXISTS ] @name
  ON [ ROOT | NAMESPACE | DATABASE ]
  TYPE JWT [ ALGORITHM @algorithm KEY @key | URL @url ]
  [ AUTHENTICATE @expression ]
  [ DURATION FOR SESSION @duration ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/access/jwt

DEFINE ACCESS ... TYPE RECORD

DEFINE ACCESS [ OVERWRITE | IF NOT EXISTS ] @name
  ON DATABASE TYPE RECORD
    [ SIGNUP @expression ]
    [ SIGNIN @expression ]
    [ WITH JWT
      [ ALGORITHM @algorithm KEY @key | URL @url ]
      [ WITH ISSUER KEY @key ]
    ]
    [ WITH REFRESH ]
  [ AUTHENTICATE @expression ]
  [ DURATION
    [ FOR TOKEN @duration ]
    [ FOR SESSION @duration ]
  ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/access/record

# DEFINE BUCKET #

DEFINE BUCKET [ OVERWRITE | IF NOT EXISTS ] @name [ @backend ]
[ PERMISSIONS ] @expression [ COMMENT @string ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/bucket

# DEFINE FIELD #

Regular fields

DEFINE FIELD [ OVERWRITE | IF NOT EXISTS ] @name ON [ TABLE ] @table
	[ [ FLEXIBLE ] TYPE @type ]
	[ REFERENCE 
		[   ON DELETE REJECT | 
			ON DELETE CASCADE | 
			ON DELETE IGNORE |
			ON DELETE UNSET | 
			ON DELETE THEN @expression ]
	]
	[ DEFAULT [ALWAYS] @expression ]
  [ READONLY ]
	[ VALUE @expression ]
	[ ASSERT @expression ]
	[ PERMISSIONS [ NONE | FULL
		| FOR select @expression
		| FOR create @expression
		| FOR update @expression
	] ]
  [ COMMENT @string ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/field#regular-fields

Computed fields

DEFINE FIELD [ OVERWRITE | IF NOT EXISTS ] @name ON [ TABLE ] @table
	[ [ FLEXIBLE ] TYPE @type ]
	[ REFERENCE 
		[   ON DELETE REJECT | 
			ON DELETE CASCADE | 
			ON DELETE IGNORE |
			ON DELETE UNSET | 
			ON DELETE THEN @expression ]
	]
	[ DEFAULT [ALWAYS] @expression ]
  [ READONLY ]
	[ VALUE @expression ]
	[ ASSERT @expression ]
	[ PERMISSIONS [ NONE | FULL
		| FOR select @expression
		| FOR create @expression
		| FOR update @expression
	] ]
  [ COMMENT @string ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/field#computed-fields

# DEFINE INDEX #

DEFINE INDEX [ OVERWRITE | IF NOT EXISTS ] @name
    ON [ TABLE ] @table 
    [ FIELDS | COLUMNS ] @fields
    [ @special_clause ]
    [ COMMENT @string ]
    [ CONCURRENTLY ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/indexes

# DEFINE TABLE #
DEFINE TABLE [ OVERWRITE | IF NOT EXISTS ] @name
	[ DROP ]
	[ SCHEMAFULL | SCHEMALESS ]
	[ TYPE [ ANY | NORMAL | RELATION [ IN | FROM ] @table [ OUT | TO ] @table [ ENFORCED ]]]
	[ AS SELECT @projections
		FROM @tables
		[ WHERE @condition ]
		[ GROUP [ BY @groups | ALL ] ]
	]
	[ CHANGEFEED @duration [ INCLUDE ORIGINAL ] ]
	[ PERMISSIONS [ NONE | FULL
		| FOR select @expression
		| FOR create @expression
		| FOR update @expression
		| FOR delete @expression
	] ]
    [ COMMENT @string ]

Source supplémentaire : https://surrealdb.com/docs/surrealql/statements/define/table