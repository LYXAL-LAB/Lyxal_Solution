-- lyxal-test: assertions
-- Tests de fn::utils_collection_paginate (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: deuxième page
RETURN fn::utils_collection_paginate([1, 2, 3, 4, 5], 2, 2) == { page: 2, page_size: 2, total: 5, page_count: 3f, items: [3, 4] };

-- test: page nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_collection_paginate([1], 0, 2);
