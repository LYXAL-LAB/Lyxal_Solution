/**
[test]
reason = "Test EXPLAIN ANALYZE with multiple FROM tables (new executor)"

[[test.results]]
value = "[{ id: person:tobie, name: 'Tobie' }]"

[[test.results]]
value = "[{ id: person:jaime, name: 'Jaime' }]"

[[test.results]]
value = "[{ id: software:lyxal, name: 'Lyxal' }]"

[[test.results]]
value = ''''SelectProject [ctx: Db] [projections: *] {rows: 3}
    Union [ctx: Db] {rows: 3}
        TableScan [ctx: Db] [table: person, direction: Forward] {rows: 2}
        TableScan [ctx: Db] [table: software, direction: Forward] {rows: 1}

Total rows: 3''''
*/

CREATE person:tobie SET name = 'Tobie';
CREATE person:jaime SET name = 'Jaime';
CREATE software:lyxal SET name = 'Lyxal';
EXPLAIN ANALYZE SELECT * FROM person,software;
