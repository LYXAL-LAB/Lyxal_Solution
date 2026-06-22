-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

CREATE TABLE IF NOT EXISTS mcaptcha_users (
    secret varchar(50) NOT NULL UNIQUE,
);





-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

CREATE TABLE IF NOT EXISTS mcaptcha_pow_fetched_stats (
	config_id INTEGER references mcaptcha_config(config_id)  ON DELETE CASCADE,
	time timestamptz NOT NULL DEFAULT now()
);

-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

CREATE TABLE IF NOT EXISTS mcaptcha_pow_solved_stats (
	config_id INTEGER references mcaptcha_config(config_id)  ON DELETE CASCADE,
	time timestamptz NOT NULL DEFAULT now()
);

-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

CREATE TABLE IF NOT EXISTS mcaptcha_pow_confirmed_stats (
	config_id INTEGER references mcaptcha_config(config_id)  ON DELETE CASCADE,
	time timestamptz NOT NULL DEFAULT now()
);

-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

-- Add migration script here
CREATE TABLE IF NOT EXISTS mcaptcha_notifications (
	id SERIAL PRIMARY KEY NOT NULL,
	tx INTEGER NOT NULL references mcaptcha_users(ID) ON DELETE CASCADE,
	rx INTEGER NOT NULL references mcaptcha_users(ID) ON DELETE CASCADE,
	heading varchar(30) NOT NULL,
	message varchar(250) NOT NULL,
	read BOOLEAN DEFAULT NULL,
	received timestamptz NOT NULL DEFAULT now()
);

-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

CREATE TABLE IF NOT EXISTS mcaptcha_sitekey_user_provided_avg_traffic (
	config_id INTEGER PRIMARY KEY UNIQUE NOT NULL references mcaptcha_config(config_id)  ON DELETE CASCADE,
	avg_traffic INTEGER DEFAULT NULL,
	peak_sustainable_traffic INTEGER DEFAULT NULL,
	broke_my_site_traffic INTEGER DEFAULT NULL
);

-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

ALTER TABLE mcaptcha_sitekey_user_provided_avg_traffic 
	ALTER COLUMN avg_traffic SET NOT NULL,
	ALTER COLUMN peak_sustainable_traffic SET NOT NULL;

-- SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
--
-- SPDX-License-Identifier: AGPL-3.0-or-later

-- Add migration script here
ALTER TABLE mcaptcha_notifications ALTER COLUMN heading TYPE varchar(100),
ALTER COLUMN heading SET NOT NULL;


CREATE TABLE IF NOT EXISTS mcaptcha_pow_analytics (
	config_id INTEGER references mcaptcha_config(config_id)  ON DELETE CASCADE,
	time INTEGER NOT NULL,
	difficulty_factor INTEGER NOT NULL,
	worker_type VARCHAR(100) NOT NULL,
	ID SERIAL PRIMARY KEY NOT NULL
);


CREATE TABLE IF NOT EXISTS mcaptcha_psuedo_campaign_id (
	id SERIAL PRIMARY KEY NOT NULL,
	config_id INTEGER NOT NULL references mcaptcha_config(config_id) ON DELETE CASCADE,
	psuedo_id varchar(100) NOT NULL UNIQUE
);

-- Add migration script here
CREATE TABLE IF NOT EXISTS mcaptcha_track_nonce (
	nonce INTEGER NOT NULL DEFAULT 0,
	level_id INTEGER references mcaptcha_levels(level_id)  ON DELETE CASCADE,
	ID SERIAL PRIMARY KEY NOT NULL
);
