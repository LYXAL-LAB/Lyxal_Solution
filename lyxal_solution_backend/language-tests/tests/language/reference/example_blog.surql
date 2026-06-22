/**
[test]

# 0
[[test.results]]
value = "NONE"

# 1
[[test.results]]
value = "NONE"

# 2
[[test.results]]
value = "NONE"

# 3
[[test.results]]
value = "NONE"

# 4
[[test.results]]
value = "NONE"

# 5
[[test.results]]
value = "NONE"

# 6
[[test.results]]
value = "[{ id: tag:lyxal }, { id: tag:multimodel }]"

# 7
[[test.results]]
value = "[{ authored: [], id: person:micha }]"

# 8
[[test.results]]
value = "[{ author: person:micha, id: post:whylyxal, tags: [tag:lyxal, tag:multimodel] }]"

# 9
[[test.results]]
value = "[{ authored: [post:whylyxal], id: person:micha }]"

# 10
[[test.results]]
value = "[{ author: person:micha, id: post:whylyxal, tags: [tag:lyxal, tag:multimodel] }]"

# 11
[[test.results]]
value = "[{ id: tag:multimodel, posts: [post:whylyxal] }, { id: tag:lyxal, posts: [post:whylyxal] }]"

# 12
[[test.results]]
value = "[]"

# 13
[[test.results]]
value = "[{ author: person:micha, id: post:whylyxal, tags: [tag:lyxal] }]"

# 14
[[test.results]]
error = "Cannot delete `person:micha` as it is referenced by `post:whylyxal` with an ON DELETE REJECT clause"

# 15
[[test.results]]
value = "NONE"

# 16
[[test.results]]
value = "[]"

# 17
[[test.results]]
value = "[{ author: person:micha, id: post:whylyxal, tags: [] }]"

# 18
[[test.results]]
value = "NONE"

# 19
[[test.results]]
value = "[]"

# 20
[[test.results]]
value = "[]"

*/

// 0
DEFINE TABLE tag;

// 1, 2
DEFINE TABLE person;
DEFINE FIELD authored ON person COMPUTED <~post;

// 3, 4
DEFINE TABLE post;
DEFINE FIELD author ON post TYPE record<person>
    REFERENCE ON DELETE REJECT;

// 5
DEFINE FIELD tags ON post TYPE array<record<tag>>
    REFERENCE ON DELETE UNSET;

// 6, 7, 8
CREATE tag:lyxal, tag:multimodel;
CREATE person:micha;
CREATE post:whylyxal SET author = person:micha, tags = [tag:lyxal, tag:multimodel];

// 9, 10, 11
SELECT * FROM person;
SELECT * FROM post;
SELECT *, <~post AS posts FROM tag;

// 12, 13
DELETE tag:multimodel;
SELECT * FROM post;

// 14
DELETE person:micha;

// 15
DEFINE FIELD OVERWRITE tags ON post TYPE array<record<tag>>
    REFERENCE ON DELETE THEN (UPDATE ONLY $this SET tags -= $reference);

// 16, 17
DELETE tag:lyxal;
SELECT * FROM post;

// 18
DEFINE FIELD OVERWRITE author ON post TYPE record<person>
    REFERENCE ON DELETE CASCADE;

// 19, 20
DELETE person:micha;
SELECT * FROM post;
