/**
 * useSchedulerInit — Scheduler Schema Auto-Initializer
 *
 * On first mount, checks whether the SurrealDB database already contains the
 * `scheduler_job_definition` table. If absent, all 13 `.surql` schema files
 * (bundled by Vite at build time) are applied in alphabetical order via
 * `executeQuery()` — the same connection already used by every other scheduler
 * view. Each file uses `DEFINE … IF NOT EXISTS`, so re-applying is fully safe.
 */

import { useEffect, useRef, useState } from "react";
import {
	executeQuery,
	executeQuerySingle,
} from "~/screens/surrealist/pages/Connection/connection/connection";

// Vite bundles all .surql files in the schema/ directory as raw strings.
// Keys are like: "./schema/scheduler_execution.surql"
const SCHEMA_MODULES = import.meta.glob("./schema/*.surql", {
	query: "?raw",
	import: "default",
	eager: true,
}) as Record<string, string>;

// Sort the files alphabetically so DEFINE statements always run in a
// deterministic order (tables before indexes that reference them, etc.)
const SORTED_SCHEMA_ENTRIES = Object.entries(SCHEMA_MODULES).sort(([a], [b]) =>
	a.localeCompare(b),
);

export interface SchedulerInitState {
	/** True while the schema is being applied for the first time. */
	isInitializing: boolean;
	/** Non-null when an unrecoverable error occurred during init. */
	initError: string | null;
}

/**
 * Returns `{ isInitializing, initError }`.
 *
 * The caller should:
 *   - Show a loading overlay while `isInitializing === true`.
 *   - Show an error banner when `initError` is set.
 *   - Render the normal dashboard content otherwise.
 */
export function useSchedulerInit(): SchedulerInitState {
	const [isInitializing, setIsInitializing] = useState(true);
	const [initError, setInitError] = useState<string | null>(null);
	const hasRun = useRef(false);

	useEffect(() => {
		if (hasRun.current) return;
		hasRun.current = true;

		let cancelled = false;

		(async () => {
			try {
				// ----- 1. Check if scheduler tables are already present -----
				// INFO FOR DB returns an object whose `tables` key lists all table names.
				const info = await executeQuerySingle<{ tables: Record<string, unknown> }>(
					"INFO FOR DB",
				);

				const tables = info?.tables ?? {};
				const alreadyInitialized = "scheduler_job_definition" in tables;

				if (alreadyInitialized) {
					// Nothing to do — schema was applied in a previous session.
					if (!cancelled) setIsInitializing(false);
					return;
				}

				// ----- 2. Apply all schema files in order -----
				for (const [filename, sql] of SORTED_SCHEMA_ENTRIES) {
					if (cancelled) return;
					if (!sql?.trim()) continue;

					try {
						await executeQuery(sql);
					} catch (fileErr) {
						// Surface the file name for easier debugging.
						const name = filename.replace("./schema/", "");
						throw new Error(`Failed to apply schema file "${name}": ${fileErr}`);
					}
				}

				if (!cancelled) setIsInitializing(false);
			} catch (err: unknown) {
				if (!cancelled) {
					setInitError(
						err instanceof Error ? err.message : `Unexpected error: ${String(err)}`,
					);
					setIsInitializing(false);
				}
			}
		})();

		return () => {
			cancelled = true;
		};
	}, []);

	return { isInitializing, initError };
}
