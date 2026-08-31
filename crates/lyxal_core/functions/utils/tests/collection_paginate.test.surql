-- ============================================================================
-- TESTS — fn::utils_collection_paginate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_paginate(
    [1,2,3,4,5],
    2,
    2
);
