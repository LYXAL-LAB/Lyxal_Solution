import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Code,
	Group,
	Paper,
	Select,
	Stack,
	Text,
	TextInput,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconClose,
	iconCopy,
	iconErrorCircle,
	iconFilter,
	iconHistory,
	iconRefresh,
	iconSearch,
} from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerExecutionsProps {
	idPrefix?: string;
}

export interface ExecutionRecord {
	id: string;
	jobKey: string;
	state: "queued" | "claimed" | "running" | "completed" | "failed" | "dead" | "cancelled";
	attempt: number;
	durationMs?: number;
	fireAt: string;
	scheduledFor?: string;
	startedAt?: string;
	completedAt?: string;
	runnerId?: string;
	error?: string;
	idempotencyKey?: string;
}

export interface ExecutionLogEntry {
	seq: number;
	level: "info" | "warn" | "error";
	timestamp: string;
	message: string;
}

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

export function SchedulerExecutions({ idPrefix = "scheduler-executions" }: SchedulerExecutionsProps) {
	const [stateFilter, setStateFilter] = useState<string>("all");
	const [jobFilter, setJobFilter] = useState<string>("");
	const [runnerFilter, setRunnerFilter] = useState<string>("");
	const [selectedId, setSelectedId] = useState<string | null>("exec_01J9X8A1B2C3");

	const [executions, setExecutions] = useState<ExecutionRecord[]>([
		{
			id: "exec_01J9X8A1B2C3",
			jobKey: "backup_db_daily",
			state: "completed",
			attempt: 1,
			durationMs: 420,
			fireAt: new Date(Date.now() - 7200000).toISOString(),
			scheduledFor: new Date(Date.now() - 7200000).toISOString(),
			startedAt: new Date(Date.now() - 7200000).toISOString(),
			completedAt: new Date(Date.now() - 7199580).toISOString(),
			runnerId: "worker_01",
		},
		{
			id: "exec_01J9X8A4D5E6",
			jobKey: "cleanup_audit_logs",
			state: "completed",
			attempt: 1,
			durationMs: 180,
			fireAt: new Date(Date.now() - 14400000).toISOString(),
			scheduledFor: new Date(Date.now() - 14400000).toISOString(),
			startedAt: new Date(Date.now() - 14400000).toISOString(),
			completedAt: new Date(Date.now() - 14399820).toISOString(),
			runnerId: "worker_02",
		},
		{
			id: "exec_01J9X8A7F8G9",
			jobKey: "sync_customer_metrics",
			state: "running",
			attempt: 1,
			fireAt: new Date(Date.now() - 900000).toISOString(),
			scheduledFor: new Date(Date.now() - 900000).toISOString(),
			startedAt: new Date(Date.now() - 900000).toISOString(),
			runnerId: "worker_01",
		},
		{
			id: "exec_01J9X8A7F8H0",
			jobKey: "backup_db_daily",
			state: "queued",
			attempt: 1,
			fireAt: new Date(Date.now() + 300000).toISOString(),
			scheduledFor: new Date(Date.now() + 300000).toISOString(),
		},
	]);

	const [executionLogs, setExecutionLogs] = useState<ExecutionLogEntry[]>([
		{ seq: 1, level: "info", timestamp: "00:00.012", message: "Starting task execution on runner node worker_01" },
		{ seq: 2, level: "info", timestamp: "00:00.180", message: "SurrealDB export starting for database main" },
		{ seq: 3, level: "info", timestamp: "00:00.418", message: "Export file verified: size 42.4 MB" },
		{ seq: 4, level: "info", timestamp: "00:00.420", message: "Execution completed successfully (State CAS CAS-Ok)" },
	]);

	// Live SurrealDB Executions Fetcher
	const fetchLiveExecutions = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_execution ORDER BY created_at DESC LIMIT 50;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: ExecutionRecord[] = raw.map((r: any) => ({
					id: safeString(r.id).replace("scheduler_execution:", ""),
					jobKey: safeString(r.job_key).replace("scheduler_job_definition:", ""),
					state: (safeString(r.state) || "queued") as ExecutionRecord["state"],
					attempt: typeof r.attempt === "number" ? r.attempt : 1,
					durationMs: typeof r.duration_ms === "number" ? r.duration_ms : undefined,
					fireAt: safeString(r.fire_at || r.created_at) || new Date().toISOString(),
					scheduledFor: r.scheduled_for ? safeString(r.scheduled_for) : undefined,
					startedAt: r.started_at ? safeString(r.started_at) : undefined,
					completedAt: r.completed_at ? safeString(r.completed_at) : undefined,
					runnerId: r.runner_id ? safeString(r.runner_id).replace("scheduler_runner:", "") : undefined,
					error: r.error ? safeString(r.error) : undefined,
					idempotencyKey: r.idempotency_key ? safeString(r.idempotency_key) : undefined,
				}));
				setExecutions(mapped);
				if (!selectedId && mapped.length > 0) {
					setSelectedId(mapped[0].id);
				}
			}
		} catch (err) {
			console.warn("SurrealDB executions live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveExecutions();
	}, []);

	// Cancel Execution Mutation
	const handleCancelExecution = async (exId: string) => {
		setExecutions((prev) => prev.map((e) => (e.id === exId ? { ...e, state: "cancelled" } : e)));
		try {
			await executeQuery(`UPDATE scheduler_execution:${exId} SET state = 'cancelled';`);
			fetchLiveExecutions();
		} catch (err) {
			console.warn("Live execution cancel warning:", err);
		}
	};

	const filteredExecutions = executions.filter((ex) => {
		const matchesState = stateFilter === "all" || ex.state === stateFilter;
		const matchesJob = !jobFilter || ex.jobKey.toLowerCase().includes(jobFilter.toLowerCase());
		const matchesRunner = !runnerFilter || (ex.runnerId && ex.runnerId.toLowerCase().includes(runnerFilter.toLowerCase()));
		return matchesState && matchesJob && matchesRunner;
	});

	const selectedExec = executions.find((e) => e.id === selectedId) || executions[0] || null;

	const getStateBadge = (state: ExecutionRecord["state"], key: string) => {
		switch (state) {
			case "completed":
				return <Badge id={`${idPrefix}-badge-${key}`} color="green" variant="light">COMPLETED</Badge>;
			case "running":
				return <Badge id={`${idPrefix}-badge-${key}`} color="blue" variant="filled">RUNNING</Badge>;
			case "claimed":
				return <Badge id={`${idPrefix}-badge-${key}`} color="cyan" variant="light">CLAIMED</Badge>;
			case "queued":
				return <Badge id={`${idPrefix}-badge-${key}`} color="gray" variant="outline">QUEUED</Badge>;
			case "failed":
				return <Badge id={`${idPrefix}-badge-${key}`} color="orange" variant="light">FAILED</Badge>;
			case "dead":
				return <Badge id={`${idPrefix}-badge-${key}`} color="red" variant="filled">DEAD</Badge>;
			case "cancelled":
				return <Badge id={`${idPrefix}-badge-${key}`} color="gray" variant="filled">CANCELLED</Badge>;
			default:
				return <Badge id={`${idPrefix}-badge-${key}`} color="gray">QUEUED</Badge>;
		}
	};

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-stack`} gap="lg">
				{/* Top Header */}
				<div id={`${idPrefix}-header-container`}>
					<Group id={`${idPrefix}-header-group`} justify="space-between" align="center">
						<div id={`${idPrefix}-header-text`}>
							<Title id={`${idPrefix}-title`} order={2}>
								Executions
							</Title>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								History of job executions, attempts, durations and logs (`fn::scheduler::execution_*`).
							</Text>
						</div>

						<Button
							id={`${idPrefix}-btn-refresh`}
							variant="default"
							leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
							onClick={fetchLiveExecutions}
						>
							Refresh Executions
						</Button>
					</Group>
				</div>

				{/* Two-Column Master-Detail Layout */}
				<div
					id={`${idPrefix}-split-container`}
					style={{
						display: "grid",
						gridTemplateColumns: "380px 1fr",
						gap: "1.5rem",
						alignItems: "start",
					}}
				>
					{/* LEFT MASTER LIST */}
					<Card id={`${idPrefix}-master-card`} p="md" radius="md" withBorder>
						<Stack id={`${idPrefix}-master-stack`} gap="sm">
							<Group id={`${idPrefix}-master-head-grp`} justify="space-between" align="center">
								<Text id={`${idPrefix}-txt-rows-count`} size="xs" fw={600} c="dimmed">
									{filteredExecutions.length} {filteredExecutions.length === 1 ? "row" : "rows"}
								</Text>
								{(stateFilter !== "all" || jobFilter || runnerFilter) && (
									<Button
										id={`${idPrefix}-btn-clear-filters`}
										variant="subtle"
										color="pink"
										size="xs"
										onClick={() => {
											setStateFilter("all");
											setJobFilter("");
											setRunnerFilter("");
										}}
									>
										Clear filters
									</Button>
								)}
							</Group>

							{/* Filter Controls */}
							<Stack id={`${idPrefix}-filters-stack`} gap="xs">
								<Select
									id={`${idPrefix}-select-state-filter`}
									label="State"
									value={stateFilter}
									onChange={(val) => setStateFilter(val || "all")}
									data={[
										{ value: "all", label: "all" },
										{ value: "queued", label: "queued" },
										{ value: "claimed", label: "claimed" },
										{ value: "running", label: "running" },
										{ value: "completed", label: "completed" },
										{ value: "failed", label: "failed" },
										{ value: "dead", label: "dead" },
										{ value: "cancelled", label: "cancelled" },
									]}
									size="xs"
								/>

								<TextInput
									id={`${idPrefix}-input-job-filter`}
									label="Job key"
									placeholder="substring match..."
									value={jobFilter}
									onChange={(e) => setJobFilter(e.currentTarget.value)}
									size="xs"
								/>
							</Stack>

							{/* Master Executions List */}
							<Stack id={`${idPrefix}-master-items-list`} gap={6} mt="xs">
								{filteredExecutions.length === 0 ? (
									<Paper id={`${idPrefix}-master-empty`} p="lg" radius="sm" style={{ textAlign: "center" }} withBorder>
										<Icon id={`${idPrefix}-empty-icon`} path={iconFilter} size="md" style={{ color: "gray" }} />
										<Text id={`${idPrefix}-txt-empty-title`} fw={600} size="xs" mt="xs">
											No executions
										</Text>
										<Text id={`${idPrefix}-txt-empty-desc`} size="xs" c="dimmed" mt={4}>
											Nothing matches the current filters.
										</Text>
									</Paper>
								) : (
									filteredExecutions.map((ex) => {
										const isSelected = selectedId === ex.id;
										const isCancellable = ex.state === "queued" || ex.state === "claimed" || ex.state === "running";
										const shortExecId = ex.id.length > 12 ? `${ex.id.slice(0, 8)}...` : ex.id;
										return (
											<Paper
												id={`${idPrefix}-row-${ex.id}`}
												key={ex.id}
												p="sm"
												radius="sm"
												withBorder
												style={{
													cursor: "pointer",
													borderColor: isSelected ? "var(--mantine-color-indigo-5)" : undefined,
													backgroundColor: isSelected ? "var(--mantine-color-indigo-9)" : undefined,
												}}
												onClick={() => setSelectedId(ex.id)}
											>
												<Stack id={`${idPrefix}-row-stack-${ex.id}`} gap={4}>
													<Group id={`${idPrefix}-row-top-${ex.id}`} justify="space-between" align="center">
														<Text id={`${idPrefix}-txt-job-${ex.id}`} size="xs" fw={600} style={{ fontFamily: "monospace" }}>
															{ex.jobKey}
														</Text>
														<Group id={`${idPrefix}-row-badge-grp-${ex.id}`} gap="xs">
															{getStateBadge(ex.state, ex.id)}
															{isCancellable && (
																<Tooltip id={`${idPrefix}-tip-cancel-${ex.id}`} label="Cancel execution">
																	<ActionIcon
																		id={`${idPrefix}-btn-cancel-${ex.id}`}
																		color="red"
																		variant="subtle"
																		size="xs"
																		onClick={(e) => {
																			e.stopPropagation();
																			handleCancelExecution(ex.id);
																		}}
																	>
																		<Icon path={iconClose} size="xs" />
																	</ActionIcon>
																</Tooltip>
															)}
														</Group>
													</Group>

													<Group id={`${idPrefix}-row-mid-${ex.id}`} justify="space-between">
														<Text id={`${idPrefix}-txt-id-${ex.id}`} size="xs" c="dimmed" style={{ fontFamily: "monospace" }}>
															{shortExecId}
														</Text>
														<Text id={`${idPrefix}-txt-fire-${ex.id}`} size="xs" c="dimmed">
															{ex.fireAt}
														</Text>
													</Group>

													<Group id={`${idPrefix}-row-bot-${ex.id}`} justify="space-between">
														<Text id={`${idPrefix}-txt-runner-${ex.id}`} size="xs" c="dimmed" style={{ fontFamily: "monospace" }}>
															{ex.runnerId ? ex.runnerId : "—"}
														</Text>
														<Text id={`${idPrefix}-txt-duration-${ex.id}`} size="xs" style={{ fontFamily: "monospace" }}>
															{ex.durationMs ? `${ex.durationMs} ms` : "—"}
														</Text>
													</Group>
												</Stack>
											</Paper>
										);
									})
								)}
							</Stack>
						</Stack>
					</Card>

					{/* RIGHT DETAIL PANEL */}
					{selectedExec ? (
						<Card id={`${idPrefix}-detail-card`} p="lg" radius="md" withBorder>
							<Stack id={`${idPrefix}-detail-stack`} gap="lg">
								{/* Metadata Grid */}
								<Paper id={`${idPrefix}-meta-paper`} p="md" radius="sm" withBorder>
									<Stack id={`${idPrefix}-meta-grid-stack`} gap="xs">
										<Group id={`${idPrefix}-meta-row-id`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-id`} size="xs" c="dimmed">
												ID
											</Text>
											<Group id={`${idPrefix}-val-meta-id-grp`} gap="xs">
												<Code id={`${idPrefix}-val-meta-id`} color="pink">
													{selectedExec.id}
												</Code>
												<ActionIcon
													id={`${idPrefix}-btn-copy-id`}
													size="xs"
													variant="subtle"
													onClick={() => navigator.clipboard.writeText(selectedExec.id)}
												>
													<Icon path={iconCopy} size="xs" />
												</ActionIcon>
											</Group>
										</Group>

										<Group id={`${idPrefix}-meta-row-job`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-job`} size="xs" c="dimmed">
												Job Key
											</Text>
											<Text id={`${idPrefix}-val-meta-job`} size="xs" fw={600} style={{ fontFamily: "monospace" }}>
												{selectedExec.jobKey}
											</Text>
										</Group>

										<Group id={`${idPrefix}-meta-row-state`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-state`} size="xs" c="dimmed">
												State
											</Text>
											{getStateBadge(selectedExec.state, `detail-${selectedExec.id}`)}
										</Group>

										<Group id={`${idPrefix}-meta-row-attempt`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-attempt`} size="xs" c="dimmed">
												Attempt
											</Text>
											<Text id={`${idPrefix}-val-meta-attempt`} size="xs" fw={500}>
												#{selectedExec.attempt}
											</Text>
										</Group>

										<Group id={`${idPrefix}-meta-row-runner`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-runner`} size="xs" c="dimmed">
												Runner Node
											</Text>
											<Text id={`${idPrefix}-val-meta-runner`} size="xs" style={{ fontFamily: "monospace" }}>
												{selectedExec.runnerId || "—"}
											</Text>
										</Group>

										<Group id={`${idPrefix}-meta-row-duration`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-duration`} size="xs" c="dimmed">
												Duration
											</Text>
											<Text id={`${idPrefix}-val-meta-duration`} size="xs" fw={500}>
												{selectedExec.durationMs ? `${selectedExec.durationMs}ms` : "—"}
											</Text>
										</Group>

										<Group id={`${idPrefix}-meta-row-fire`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-fire`} size="xs" c="dimmed">
												Fire At
											</Text>
											<Text id={`${idPrefix}-val-meta-fire`} size="xs" fw={500}>
												{selectedExec.fireAt}
											</Text>
										</Group>

										{selectedExec.scheduledFor && (
											<Group id={`${idPrefix}-meta-row-scheduled`} justify="space-between">
												<Text id={`${idPrefix}-lbl-meta-scheduled`} size="xs" c="dimmed">
													Scheduled For
												</Text>
												<Text id={`${idPrefix}-val-meta-scheduled`} size="xs" fw={500}>
													{selectedExec.scheduledFor}
												</Text>
											</Group>
										)}

										{selectedExec.completedAt && (
											<Group id={`${idPrefix}-meta-row-completed`} justify="space-between">
												<Text id={`${idPrefix}-lbl-meta-completed`} size="xs" c="dimmed">
													Completed At
												</Text>
												<Text id={`${idPrefix}-val-meta-completed`} size="xs" fw={500}>
													{selectedExec.completedAt}
												</Text>
											</Group>
										)}
									</Stack>
								</Paper>

								{/* Error Box */}
								{selectedExec.error && (
									<Paper id={`${idPrefix}-error-paper`} radius="sm" withBorder p={0}>
										<Paper id={`${idPrefix}-error-header`} p="xs" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
											<Text id={`${idPrefix}-txt-error-title`} fw={600} size="xs" c="red.4">
												Error Message
											</Text>
										</Paper>
										<Code id={`${idPrefix}-code-error-body`} block color="red" style={{ fontSize: "12px", fontFamily: "monospace", padding: "12px" }}>
											{selectedExec.error}
										</Code>
									</Paper>
								)}

								{/* Execution Logs Panel */}
								<Paper id={`${idPrefix}-logs-panel-paper`} radius="sm" withBorder p={0}>
									<Paper id={`${idPrefix}-logs-panel-header`} p="xs" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
										<Text id={`${idPrefix}-txt-logs-title`} fw={600} size="xs" c="dimmed">
											Execution Logs
										</Text>
									</Paper>
									<div id={`${idPrefix}-logs-terminal`} style={{ backgroundColor: "#1e1e1e", color: "#d4d4d4", padding: "12px", fontFamily: "monospace", fontSize: "12px" }}>
										<Stack id={`${idPrefix}-logs-stack`} gap="xs">
											{executionLogs.map((log) => (
												<Group id={`${idPrefix}-log-line-${log.seq}`} key={log.seq} gap="xs" align="flex-start">
													<Text id={`${idPrefix}-log-seq-${log.seq}`} size="xs" c="gray" style={{ fontFamily: "monospace", width: 30 }}>
														#{log.seq}
													</Text>
													<Text id={`${idPrefix}-log-time-${log.seq}`} size="xs" c="dimmed" style={{ fontFamily: "monospace" }}>
														[{log.timestamp}]
													</Text>
													<Badge
														id={`${idPrefix}-log-lvl-${log.seq}`}
														size="xs"
														color={log.level === "error" ? "red" : log.level === "warn" ? "orange" : "blue"}
													>
														{log.level.toUpperCase()}
													</Badge>
													<Text id={`${idPrefix}-log-msg-${log.seq}`} size="xs" style={{ fontFamily: "monospace", flex: 1 }}>
														{log.message}
													</Text>
												</Group>
											))}
										</Stack>
									</div>
								</Paper>
							</Stack>
						</Card>
					) : (
						<Card id={`${idPrefix}-no-selection-card`} p="xl" radius="md" style={{ textAlign: "center" }} withBorder>
							<Text id={`${idPrefix}-txt-no-selection`} size="sm" c="dimmed">
								Select an execution from the list on the left to inspect attempt details, originating runner, error and logs.
							</Text>
						</Card>
					)}
				</div>
			</Stack>
		</div>
	);
}
