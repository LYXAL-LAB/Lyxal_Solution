import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Code,
	Group,
	Modal,
	NumberInput,
	Paper,
	Stack,
	Table,
	Tabs,
	Text,
	TextInput,
	Textarea,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconErrorCircle,
	iconFilter,
	iconRefresh,
	iconTrash,
	iconWarning,
} from "@surrealdb/ui";
import { useEffect, useMemo, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerAlertsProps {
	idPrefix?: string;
}

export type AlertChannelKind =
	| { type: "webhook"; url: string; timeout_secs: number }
	| { type: "shell"; command: string }
	| { type: "unknown"; reason?: string };

export interface AlertChannelConfig {
	name: string;
	kind: AlertChannelKind;
}

export interface AlertRuleConfig {
	name: string;
	trigger: string;
	job_key_glob: string;
	channels: string[];
	min_attempts?: number;
	dead_letter_only?: boolean;
	throttle?: string;
	expected_within?: string;
}

export interface AlertRuleOverride {
	rule_name: string;
	enabled?: boolean | null;
	snooze_until?: string | null;
	throttle_secs?: number | null;
	note: string;
	set_by: string;
	set_at: string;
	expires_at?: string | null;
}

export interface AlertDeliveryRecord {
	id: string;
	rule_name: string;
	channel_name: string;
	job_key: string;
	execution_id?: string;
	state: "delivered" | "failed" | "throttled";
	error?: string;
	fired_at: string;
	delivered_at?: string;
}

type OverrideMode = "snooze" | "disable" | "throttle";

function safeString(val: any): string {
	if (val === null || val === undefined) return "";
	if (typeof val === "string") return val;
	if (typeof val === "number" || typeof val === "boolean") return String(val);
	if (val instanceof Date) return val.toISOString();
	if (typeof val === "object") {
		if (typeof val.id === "string") return val.id;
		if (typeof val.id === "object" && val.id) return safeString(val.id);
		if (val.tb && val.id) return `${val.tb}:${safeString(val.id)}`;
		if (typeof val.toString === "function" && val.toString() !== "[object Object]") {
			return val.toString();
		}
		try {
			return JSON.stringify(val);
		} catch {
			return String(val);
		}
	}
	return String(val);
}

export function SchedulerAlerts({ idPrefix = "scheduler-alerts" }: SchedulerAlertsProps) {
	const [activeTab, setActiveTab] = useState<string>("config");
	const [stateFilter, setStateFilter] = useState<string>("all");
	const [jobKeySearch, setJobKeySearch] = useState<string>("");
	const [overrideModalOpen, setOverrideModalOpen] = useState(false);
	const [selectedRuleForOverride, setSelectedRuleForOverride] = useState<AlertRuleConfig | null>(null);

	// Override Form State
	const [overrideMode, setOverrideMode] = useState<OverrideMode>("snooze");
	const [overrideNote, setOverrideNote] = useState("");
	const [snoozeUntil, setSnoozeUntil] = useState("");
	const [throttleInputSecs, setThrottleInputSecs] = useState<number>(300);
	const [expiresAtInput, setExpiresAtInput] = useState("");

	// Default Mock/Config Data
	const [channels] = useState<AlertChannelConfig[]>([
		{
			name: "slack-#dev-alerts",
			kind: { type: "webhook", url: "https://hooks.slack.com/services/T00/B00/X00", timeout_secs: 10 },
		},
		{
			name: "pagerduty-ops",
			kind: { type: "webhook", url: "https://events.pagerduty.com/v2/enqueue", timeout_secs: 15 },
		},
		{
			name: "on-call-shell",
			kind: { type: "shell", command: "/usr/local/bin/notify_oncall.sh" },
		},
	]);

	const [rules] = useState<AlertRuleConfig[]>([
		{
			name: "failure_slack_webhook",
			trigger: "on_failure",
			job_key_glob: "*",
			channels: ["slack-#dev-alerts"],
			throttle: "5m",
		},
		{
			name: "sla_miss_pagerduty",
			trigger: "on_sla_miss",
			job_key_glob: "prod_*",
			channels: ["pagerduty-ops"],
			expected_within: "1h",
		},
		{
			name: "critical_dead_letter_script",
			trigger: "on_failure",
			job_key_glob: "database_*",
			dead_letter_only: true,
			channels: ["on-call-shell"],
		},
	]);

	const [overrides, setOverrides] = useState<AlertRuleOverride[]>([
		{
			rule_name: "failure_slack_webhook",
			enabled: false,
			snooze_until: new Date(Date.now() + 86400000).toISOString(),
			throttle_secs: 300,
			note: "Snoozed for planned database maintenance",
			set_by: "operator_root",
			set_at: new Date().toISOString(),
			expires_at: new Date(Date.now() + 86400000).toISOString(),
		},
	]);

	const [deliveries, setDeliveries] = useState<AlertDeliveryRecord[]>([
		{
			id: "del_01J9X8H1K2L3",
			rule_name: "failure_slack_webhook",
			channel_name: "slack-#dev-alerts",
			job_key: "backup_db_daily",
			execution_id: "exec_01J9X8A1B2C3",
			state: "delivered",
			fired_at: new Date().toISOString(),
			delivered_at: new Date().toISOString(),
		},
		{
			id: "del_01J9X8H1K2L4",
			rule_name: "sla_miss_pagerduty",
			channel_name: "pagerduty-ops",
			job_key: "cleanup_audit_logs",
			execution_id: "exec_01J9X8A4D5E6",
			state: "failed",
			error: "Webhook endpoint returned HTTP 503 Service Unavailable",
			fired_at: new Date(Date.now() - 600000).toISOString(),
		},
	]);

	// Live SurrealDB Data Fetcher
	const fetchLiveAlertData = async () => {
		try {
			// 1. Fetch Overrides
			const ovRes = await executeQuery("SELECT * FROM scheduler_alert_override ORDER BY set_at DESC;");
			const rawOverrides = ovRes[0]?.result;
			if (Array.isArray(rawOverrides) && rawOverrides.length > 0) {
				const mappedOverrides: AlertRuleOverride[] = rawOverrides.map((o: any) => ({
					rule_name: safeString(o.id || o.rule_name).replace("scheduler_alert_override:", ""),
					enabled: o.enabled,
					snooze_until: o.snooze_until ? safeString(o.snooze_until) : null,
					throttle_secs: typeof o.throttle_secs === "number" ? o.throttle_secs : null,
					note: safeString(o.note) || "No note provided",
					set_by: safeString(o.set_by) || "operator",
					set_at: safeString(o.set_at) || new Date().toISOString(),
					expires_at: o.expires_at ? safeString(o.expires_at) : null,
				}));
				setOverrides(mappedOverrides);
			}

			// 2. Fetch Deliveries
			const delRes = await executeQuery("SELECT * FROM scheduler_alert_delivery ORDER BY fired_at DESC LIMIT 200;");
			const rawDeliveries = delRes[0]?.result;
			if (Array.isArray(rawDeliveries) && rawDeliveries.length > 0) {
				const mappedDeliveries: AlertDeliveryRecord[] = rawDeliveries.map((d: any) => ({
					id: safeString(d.id).replace("scheduler_alert_delivery:", ""),
					rule_name: safeString(d.rule_name) || "unknown_rule",
					channel_name: safeString(d.channel_name) || "default_channel",
					job_key: safeString(d.job_key).replace("scheduler_job_definition:", ""),
					execution_id: d.execution_id ? safeString(d.execution_id).replace("scheduler_execution:", "") : undefined,
					state: (safeString(d.state) || "delivered") as "delivered" | "failed" | "throttled",
					error: d.error ? safeString(d.error) : undefined,
					fired_at: safeString(d.fired_at) || new Date().toISOString(),
					delivered_at: d.delivered_at ? safeString(d.delivered_at) : undefined,
				}));
				setDeliveries(mappedDeliveries);
			}
		} catch (err) {
			console.warn("SurrealDB alert live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveAlertData();
	}, []);

	// Save Override Mutation
	const handleSaveOverride = async () => {
		if (!selectedRuleForOverride || !overrideNote.trim()) return;

		const rName = selectedRuleForOverride.name;
		const isEnabled = overrideMode === "disable" ? false : null;
		const sUntil = overrideMode === "snooze" && snoozeUntil ? new Date(snoozeUntil).toISOString() : null;
		const tSecs = overrideMode === "throttle" ? throttleInputSecs : null;
		const expAt = expiresAtInput ? new Date(expiresAtInput).toISOString() : sUntil;

		// Local State Optimistic Update
		const updatedOv: AlertRuleOverride = {
			rule_name: rName,
			enabled: isEnabled,
			snooze_until: sUntil,
			throttle_secs: tSecs,
			note: overrideNote.trim(),
			set_by: "operator_root",
			set_at: new Date().toISOString(),
			expires_at: expAt,
		};

		setOverrides((prev) => [...prev.filter((o) => o.rule_name !== rName), updatedOv]);
		setOverrideModalOpen(false);

		// SurrealDB Live Mutation
		try {
			const recordId = `scheduler_alert_override:${rName}`;
			await executeQuery(
				`UPSERT ${recordId} SET enabled = $enabled, snooze_until = $snooze_until, throttle_secs = $throttle_secs, note = $note, set_by = 'operator_root', set_at = time::now(), expires_at = $expires_at;`,
				{
					enabled: isEnabled,
					snooze_until: sUntil,
					throttle_secs: tSecs,
					note: overrideNote.trim(),
					expires_at: expAt,
				}
			);
			fetchLiveAlertData();
		} catch (err) {
			console.warn("Live override upsert warning:", err);
		}
	};

	// Delete Override Mutation
	const handleClearOverride = async (rName: string) => {
		setOverrides((prev) => prev.filter((o) => o.rule_name !== rName));
		try {
			await executeQuery(`DELETE scheduler_alert_override:${rName};`);
			fetchLiveAlertData();
		} catch (err) {
			console.warn("Live override delete warning:", err);
		}
	};

	// Open Override Dialog
	const handleOpenOverrideModal = (rule: AlertRuleConfig) => {
		setSelectedRuleForOverride(rule);
		setOverrideNote("");
		setSnoozeUntil("");
		setThrottleInputSecs(300);
		setExpiresAtInput("");
		setOverrideModalOpen(true);
	};

	// Map overrides per rule
	const overrideByRule = useMemo(() => {
		const m = new Map<string, AlertRuleOverride>();
		for (const ov of overrides) {
			if (!m.has(ov.rule_name)) m.set(ov.rule_name, ov);
		}
		return m;
	}, [overrides]);

	// Filtered Deliveries
	const filteredDeliveries = useMemo(() => {
		return deliveries.filter((d) => {
			const matchesState = stateFilter === "all" || d.state === stateFilter;
			const matchesJob = !jobKeySearch.trim() || d.job_key.toLowerCase().includes(jobKeySearch.trim().toLowerCase());
			return matchesState && matchesJob;
		});
	}, [deliveries, stateFilter, jobKeySearch]);

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-stack`} gap="lg">
				{/* Header Section */}
				<div id={`${idPrefix}-header-container`}>
					<Group id={`${idPrefix}-header-group`} justify="space-between" align="center">
						<div id={`${idPrefix}-header-text`}>
							<Group id={`${idPrefix}-title-group`} gap="xs">
								<Icon id={`${idPrefix}-header-icon`} path={iconWarning} size="lg" style={{ color: "var(--mantine-color-indigo-4)" }} />
								<Title id={`${idPrefix}-title`} order={2}>
									Failure Alerts & Notifications
								</Title>
							</Group>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								Read-only view of configured rules & channels, active operational overrides (`fn::scheduler::alert_*`), and delivery log.
							</Text>
						</div>

						<Group id={`${idPrefix}-header-actions`} gap="sm">
							<Button
								id={`${idPrefix}-btn-refresh`}
								variant="default"
								leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
								onClick={fetchLiveAlertData}
							>
								Refresh Live Data
							</Button>
						</Group>
					</Group>
				</div>

				{/* Navigation Tabs */}
				<Tabs
					id={`${idPrefix}-nav-tabs`}
					value={activeTab}
					onChange={(val) => setActiveTab(val || "config")}
					variant="outline"
					radius="md"
				>
					<Tabs.List id={`${idPrefix}-nav-tabs-list`}>
						<Tabs.Tab id={`${idPrefix}-tab-config`} value="config">
							Configuration ({rules.length} Rules, {channels.length} Channels)
						</Tabs.Tab>
						<Tabs.Tab id={`${idPrefix}-tab-deliveries`} value="deliveries">
							Recent Deliveries ({deliveries.length})
						</Tabs.Tab>
					</Tabs.List>
				</Tabs>

				{/* TAB 1: CONFIGURATION (CHANNELS & RULES) */}
				{activeTab === "config" && (
					<Stack id={`${idPrefix}-config-stack`} gap="xl">
						{/* CHANNELS SECTION */}
						<Card id={`${idPrefix}-channels-card`} radius="md" withBorder p={0}>
							<Paper id={`${idPrefix}-channels-header`} p="md" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
								<Group id={`${idPrefix}-channels-header-group`} justify="space-between">
									<div>
										<Text id={`${idPrefix}-txt-channels-title`} fw={600} size="sm">
											Notification Channels ({channels.length})
										</Text>
										<Text id={`${idPrefix}-txt-channels-subtitle`} size="xs" c="dimmed">
											Channels are referenced by name from alert rules.
										</Text>
									</div>
								</Group>
							</Paper>

							<Table id={`${idPrefix}-channels-table`} verticalSpacing="sm" horizontalSpacing="md">
								<Table.Thead id={`${idPrefix}-channels-thead`}>
									<Table.Tr id={`${idPrefix}-channels-tr-head`}>
										<Table.Th id={`${idPrefix}-th-ch-name`}>Channel Name</Table.Th>
										<Table.Th id={`${idPrefix}-th-ch-type`}>Type</Table.Th>
										<Table.Th id={`${idPrefix}-th-ch-detail`}>Target / Command Detail</Table.Th>
									</Table.Tr>
								</Table.Thead>
								<Table.Tbody id={`${idPrefix}-channels-tbody`}>
									{channels.map((ch) => (
										<Table.Tr id={`${idPrefix}-ch-row-${ch.name}`} key={ch.name}>
											<Table.Td id={`${idPrefix}-ch-td-name-${ch.name}`}>
												<Text id={`${idPrefix}-ch-txt-name-${ch.name}`} size="sm" fw={600} style={{ fontFamily: "monospace" }}>
													{ch.name}
												</Text>
											</Table.Td>
											<Table.Td id={`${idPrefix}-ch-td-type-${ch.name}`}>
												<Badge
													id={`${idPrefix}-ch-bdg-type-${ch.name}`}
													color={ch.kind.type === "webhook" ? "blue" : "grape"}
													variant="light"
													size="xs"
												>
													{ch.kind.type.toUpperCase()}
												</Badge>
											</Table.Td>
											<Table.Td id={`${idPrefix}-ch-td-detail-${ch.name}`}>
												{ch.kind.type === "webhook" && (
													<Code id={`${idPrefix}-ch-code-detail-${ch.name}`} color="blue">
														POST {ch.kind.url} (timeout {ch.kind.timeout_secs}s)
													</Code>
												)}
												{ch.kind.type === "shell" && (
													<Code id={`${idPrefix}-ch-code-detail-${ch.name}`} color="grape">
														EXEC {ch.kind.command}
													</Code>
												)}
											</Table.Td>
										</Table.Tr>
									))}
								</Table.Tbody>
							</Table>
						</Card>

						{/* RULES SECTION */}
						<Card id={`${idPrefix}-rules-card`} radius="md" withBorder p={0}>
							<Paper id={`${idPrefix}-rules-header`} p="md" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
								<Group id={`${idPrefix}-rules-header-group`} justify="space-between">
									<div>
										<Text id={`${idPrefix}-txt-rules-title`} fw={600} size="sm">
											Alert Rules & Overrides ({rules.length})
										</Text>
										<Text id={`${idPrefix}-txt-rules-subtitle`} size="xs" c="dimmed">
											Triggered by failure events. Operational overrides permit snoozing, disabling, or throttling per rule.
										</Text>
									</div>
								</Group>
							</Paper>

							<Stack id={`${idPrefix}-rules-list-stack`} gap={0}>
								{rules.map((rule) => {
									const ov = overrideByRule.get(rule.name);
									const isOvActive = ov != null;

									return (
										<Paper
											id={`${idPrefix}-rule-item-${rule.name}`}
											key={rule.name}
											p="md"
											style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}
										>
											<Stack id={`${idPrefix}-rule-stack-${rule.name}`} gap="xs">
												<Group id={`${idPrefix}-rule-row-top-${rule.name}`} justify="space-between" align="center">
													<Group id={`${idPrefix}-rule-left-group-${rule.name}`} gap="xs">
														<Text id={`${idPrefix}-rule-name-${rule.name}`} fw={600} size="sm" style={{ fontFamily: "monospace" }}>
															{rule.name}
														</Text>
														<Badge id={`${idPrefix}-rule-trigger-bdg-${rule.name}`} color="pink" size="xs">
															{rule.trigger}
														</Badge>

														{/* Active Override Pill */}
														{isOvActive && ov && (
															<Badge
																id={`${idPrefix}-rule-ov-bdg-${rule.name}`}
																color={ov.enabled === false ? "red" : "orange"}
																variant="filled"
																size="xs"
															>
																{ov.enabled === false ? "DISABLED" : ov.snooze_until ? "SNOOZED" : `THROTTLED ${ov.throttle_secs}s`}
															</Badge>
														)}
													</Group>

													{/* Actions */}
													<Group id={`${idPrefix}-rule-actions-${rule.name}`} gap="xs">
														<Button
															id={`${idPrefix}-btn-ov-${rule.name}`}
															variant="light"
															color="pink"
															size="xs"
															onClick={() => handleOpenOverrideModal(rule)}
														>
															{isOvActive ? "Change Override" : "+ Add Override / Snooze"}
														</Button>
														{isOvActive && (
															<Button
																id={`${idPrefix}-btn-clear-ov-${rule.name}`}
																variant="subtle"
																color="red"
																size="xs"
																onClick={() => handleClearOverride(rule.name)}
															>
																Clear
															</Button>
														)}
													</Group>
												</Group>

												{/* Details Line */}
												<Group id={`${idPrefix}-rule-details-${rule.name}`} gap="lg">
													<Text id={`${idPrefix}-txt-glob-${rule.name}`} size="xs" c="dimmed">
														job_key match: <Code id={`${idPrefix}-code-glob-${rule.name}`}>{rule.job_key_glob}</Code>
													</Text>
													{rule.throttle && (
														<Text id={`${idPrefix}-txt-throttle-${rule.name}`} size="xs" c="dimmed">
															Throttle: <Code id={`${idPrefix}-code-throttle-${rule.name}`}>{rule.throttle}</Code>
														</Text>
													)}
													{rule.expected_within && (
														<Text id={`${idPrefix}-txt-expected-${rule.name}`} size="xs" c="dimmed">
															Expected within: <Code id={`${idPrefix}-code-exp-${rule.name}`}>{rule.expected_within}</Code>
														</Text>
													)}
													{rule.dead_letter_only && (
														<Badge id={`${idPrefix}-bdg-dlq-${rule.name}`} color="gray" size="xs">
															Dead Letter Only
														</Badge>
													)}

													<Group id={`${idPrefix}-rule-channels-${rule.name}`} gap={4}>
														<Text id={`${idPrefix}-txt-channels-label-${rule.name}`} size="xs" c="dimmed">
															Channels:
														</Text>
														{rule.channels.map((cName) => (
															<Badge id={`${idPrefix}-bdg-ch-${rule.name}-${cName}`} key={cName} color="blue" size="xs" variant="light">
																#{cName}
															</Badge>
														))}
													</Group>
												</Group>

												{/* Override Context Note */}
												{isOvActive && ov && (
													<Paper id={`${idPrefix}-ov-note-paper-${rule.name}`} p="xs" bg="dark.6" radius="xs" mt={4}>
														<Text id={`${idPrefix}-txt-ov-note-${rule.name}`} size="xs" c="orange.3">
															“{ov.note}” — set by <span style={{ fontWeight: 600 }}>{ov.set_by}</span>
														</Text>
													</Paper>
												)}
											</Stack>
										</Paper>
									);
								})}
							</Stack>
						</Card>
					</Stack>
				)}

				{/* TAB 2: RECENT DELIVERIES LOG */}
				{activeTab === "deliveries" && (
					<Stack id={`${idPrefix}-deliveries-stack`} gap="md">
						{/* Filter Toolbar */}
						<Card id={`${idPrefix}-deliveries-filter-card`} radius="md" withBorder p="sm">
							<Group id={`${idPrefix}-deliveries-filter-group`} justify="space-between" align="center">
								<Group id={`${idPrefix}-state-filters-group`} gap="xs">
									<Icon id={`${idPrefix}-filter-icon`} path={iconFilter} size="sm" />
									<Text id={`${idPrefix}-txt-filter-label`} size="xs" fw={600} c="dimmed">
										Filter State:
									</Text>

									{["all", "delivered", "failed", "throttled"].map((st) => (
										<Button
											id={`${idPrefix}-btn-filter-st-${st}`}
											key={st}
											size="xs"
											variant={stateFilter === st ? "filled" : "light"}
											color={st === "delivered" ? "green" : st === "failed" ? "red" : st === "throttled" ? "orange" : "indigo"}
											onClick={() => setStateFilter(st)}
										>
											{st.toUpperCase()}
										</Button>
									))}
								</Group>

								<Group id={`${idPrefix}-search-filter-group`} gap="md">
									<TextInput
										id={`${idPrefix}-input-search-job`}
										placeholder="Filter by job_key..."
										leftSection={<Icon id={`${idPrefix}-search-icon`} path={iconFilter} size="xs" />}
										value={jobKeySearch}
										onChange={(e) => setJobKeySearch(e.currentTarget.value)}
										size="xs"
										style={{ width: 220 }}
									/>
									<Text id={`${idPrefix}-txt-rows-count`} size="xs" c="dimmed">
										Showing {filteredDeliveries.length} of {deliveries.length} records
									</Text>
								</Group>
							</Group>
						</Card>

						{/* Deliveries Table */}
						<Card id={`${idPrefix}-deliveries-card`} p={0} radius="md" withBorder>
							<Table id={`${idPrefix}-deliveries-table`} verticalSpacing="sm" horizontalSpacing="md">
								<Table.Thead id={`${idPrefix}-deliveries-thead`}>
									<Table.Tr id={`${idPrefix}-deliveries-tr-head`}>
										<Table.Th id={`${idPrefix}-th-del-fired`}>Fired At / When</Table.Th>
										<Table.Th id={`${idPrefix}-th-del-job`}>Job Key</Table.Th>
										<Table.Th id={`${idPrefix}-th-del-rule`}>Rule Name</Table.Th>
										<Table.Th id={`${idPrefix}-th-del-channel`}>Channel</Table.Th>
										<Table.Th id={`${idPrefix}-th-del-state`}>State</Table.Th>
										<Table.Th id={`${idPrefix}-th-del-error`}>Notes / Delivery Error</Table.Th>
									</Table.Tr>
								</Table.Thead>
								<Table.Tbody id={`${idPrefix}-deliveries-tbody`}>
									{filteredDeliveries.length === 0 ? (
										<Table.Tr id={`${idPrefix}-row-empty`}>
											<Table.Td id={`${idPrefix}-td-empty`} colSpan={6} style={{ textAlign: "center", padding: "2rem" }}>
												<Text id={`${idPrefix}-txt-empty`} size="sm" c="dimmed">
													No alert deliveries matching selected filters.
												</Text>
											</Table.Td>
										</Table.Tr>
									) : (
										filteredDeliveries.map((del) => (
											<Table.Tr id={`${idPrefix}-row-del-${del.id}`} key={del.id}>
												<Table.Td id={`${idPrefix}-td-del-fired-${del.id}`}>
													<Text id={`${idPrefix}-txt-del-fired-${del.id}`} size="xs" c="dimmed">
														{del.fired_at}
													</Text>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-del-job-${del.id}`}>
													<Text id={`${idPrefix}-txt-del-job-${del.id}`} size="sm" fw={600} style={{ fontFamily: "monospace" }}>
														{del.job_key}
													</Text>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-del-rule-${del.id}`}>
													<Text id={`${idPrefix}-txt-del-rule-${del.id}`} size="sm">
														{del.rule_name}
													</Text>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-del-channel-${del.id}`}>
													<Badge id={`${idPrefix}-bdg-del-chan-${del.id}`} color="blue" variant="light" size="xs">
														{del.channel_name}
													</Badge>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-del-state-${del.id}`}>
													<Badge
														id={`${idPrefix}-bdg-del-st-${del.id}`}
														color={del.state === "delivered" ? "green" : del.state === "failed" ? "red" : "orange"}
														size="xs"
													>
														{del.state.toUpperCase()}
													</Badge>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-del-error-${del.id}`}>
													{del.error ? (
														<Text id={`${idPrefix}-txt-del-err-${del.id}`} size="xs" c="red.4">
															{del.error}
														</Text>
													) : (
														<Text id={`${idPrefix}-txt-del-ok-${del.id}`} size="xs" c="green.4">
															Delivered OK
														</Text>
													)}
												</Table.Td>
											</Table.Tr>
										))
									)}
								</Table.Tbody>
							</Table>
						</Card>
					</Stack>
				)}
			</Stack>

			{/* MODAL: ADD / EDIT ALERT OVERRIDE */}
			<Modal
				id={`${idPrefix}-modal-override`}
				opened={overrideModalOpen}
				onClose={() => setOverrideModalOpen(false)}
				title={selectedRuleForOverride ? `Override Rule: ${selectedRuleForOverride.name}` : "Add Alert Override"}
				centered
			>
				<Stack id={`${idPrefix}-modal-override-stack`} gap="md">
					<Text id={`${idPrefix}-modal-ov-desc`} size="xs" c="dimmed">
						Operational overrides temporarily alter pure Croniqfile behavior. Choose snooze deadline, disable rule, or custom throttle duration.
					</Text>

					{/* Mode Buttons */}
					<Group id={`${idPrefix}-modal-ov-modes`} justify="space-between">
						<Button
							id={`${idPrefix}-btn-mode-snooze`}
							size="xs"
							variant={overrideMode === "snooze" ? "filled" : "outline"}
							color="pink"
							onClick={() => setOverrideMode("snooze")}
						>
							Snooze
						</Button>
						<Button
							id={`${idPrefix}-btn-mode-disable`}
							size="xs"
							variant={overrideMode === "disable" ? "filled" : "outline"}
							color="red"
							onClick={() => setOverrideMode("disable")}
						>
							Disable Force
						</Button>
						<Button
							id={`${idPrefix}-btn-mode-throttle`}
							size="xs"
							variant={overrideMode === "throttle" ? "filled" : "outline"}
							color="orange"
							onClick={() => setOverrideMode("throttle")}
						>
							Throttle Window
						</Button>
					</Group>

					{overrideMode === "snooze" && (
						<TextInput
							id={`${idPrefix}-input-snooze-until`}
							label="Snooze Until (ISO / Date)"
							type="datetime-local"
							value={snoozeUntil}
							onChange={(e) => setSnoozeUntil(e.currentTarget.value)}
							required
						/>
					)}

					{overrideMode === "throttle" && (
						<NumberInput
							id={`${idPrefix}-input-throttle-secs`}
							label="Throttle Duration (Seconds)"
							value={throttleInputSecs}
							onChange={(val) => setThrottleInputSecs(Number(val) || 300)}
							required
						/>
					)}

					{(overrideMode === "disable" || overrideMode === "throttle") && (
						<TextInput
							id={`${idPrefix}-input-expires-at`}
							label="Auto-Clear At (Optional Expiration)"
							type="datetime-local"
							value={expiresAtInput}
							onChange={(e) => setExpiresAtInput(e.currentTarget.value)}
						/>
					)}

					<Textarea
						id={`${idPrefix}-input-ov-note`}
						label="Note / Operator Reason (Required)"
						placeholder="e.g. Snoozed during INC-9812 database migration"
						value={overrideNote}
						onChange={(e) => setOverrideNote(e.currentTarget.value)}
						rows={2}
						required
					/>

					<Group id={`${idPrefix}-modal-ov-actions`} justify="flex-end" mt="md">
						<Button id={`${idPrefix}-btn-cancel-ov`} variant="subtle" onClick={() => setOverrideModalOpen(false)}>
							Cancel
						</Button>
						<Button
							id={`${idPrefix}-btn-submit-ov`}
							color="pink"
							disabled={!overrideNote.trim()}
							onClick={handleSaveOverride}
						>
							Save Override
						</Button>
					</Group>
				</Stack>
			</Modal>
		</div>
	);
}
