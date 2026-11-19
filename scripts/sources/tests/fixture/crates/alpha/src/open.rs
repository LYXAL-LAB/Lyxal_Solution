/*
 * SPDX-FileCopyrightText: 2026 Exemple
 *
 * SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-SEL
 */

pub fn open() -> u32 {
    let mut total = 1;
    // SPDX-SnippetBegin
    // SPDX-FileCopyrightText: 2026 Exemple
    // SPDX-License-Identifier: LicenseRef-SEL
    #[cfg(feature = "enterprise")]
    {
        total += 41;
    } // SPDX-SnippetEnd
    // SPDX-SnippetBegin
    // SPDX-FileCopyrightText: 2019 Tiers
    // SPDX-License-Identifier: MIT
    total += 1;
    // SPDX-SnippetEnd
    total
}
