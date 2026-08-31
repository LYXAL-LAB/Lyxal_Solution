import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Code,
	Group,
	Paper,
	Stack,
	Text,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconCopy,
	iconErrorCircle,
	iconRefresh,
	iconTrash,
	iconWarning,
} from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerDeadLettersProps {
	idPrefix?: string;
}

export interface DeadLetterRecord {
	id: string;
	jobKey: string;
	executionId: string;
	attempt: number;
	deadReason: string;
	error: string;
	scheduledFor?: string;
	createdAt: string;
	expiresAt?: string;
	metadata?: Record<string, any>;
	status?: string;
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

export function SchedulerDeadLetters({ idPrefix = "scheduler-dlq" }: SchedulerDeadLettersProps) {
	const [deadLetters, setDeadLetters] = useState<DeadLetterRecord[]>([
		{
			id: "dl_01J9X8H1K201",
			jobKey: "backup_db_daily",
			executionId: "exec_01J9X8A1B2C3",
			attempt: 3,
			deadReason: "max_retries_exceeded",
			error: "S3 bucket connection timeout after 3 retries (HTTP 504 Gateway Timeout)",
			scheduledFor: new Date(Date.now() - 3600000).toISOString(),
			createdAt: new Date(Date.now() - 3600000).toISOString(),
			expiresAt: new Date(Date.now() + 2592000000).toISOString(),
			metadata: { bucket: "s3://backups/surreal.db", region: "eu-west-1" },
			status: "pending",
		},
		{
			id: "dl_01J9X8H1K202",
			jobKey: "cleanup_audit_logs",
			executionId: "exec_01J9X8A4D5E6",
			attempt: 5,
			deadReason: "max_retries_exceeded",
			error: "SurrealQL transaction deadlock detected on scheduler_audit_log table lock",
			scheduledFor: new Date(Date.now() - 10800000).toISOString(),
			createdAt: new Date(Date.now() - 10800000).toISOString(),
			expiresAt: new Date(Date.now() + 2592000000).toISOString(),
			metadata: { retention_days: 90 },
			status: "pending",
		},
		{
			id: "dl_01J9X8H1K203",
			jobKey: "sync_customer_metrics",
			executionId: "exec_01J9X8A7F8G9",
			attempt: 2,
			deadReason: "timeout",
			error: "Remote API endpoint rate limit exceeded (HTTP 429 Too Many Requests)",
			scheduledFor: new Date(Date.now() - 1800000).toISOString(),
			createdAt: new Date(Date.now() - 1800000).toISOString(),
			expiresAt: new Date(Date.now() + 2592000000).toISOString(),
			metadata: { batch_size: 500, endpoint: "https://api.analytics.com/v1/ingest" },
			status: "pending",
		},
	]);

	const [selectedId, setSelectedId] = useState<string | null>("dl_01J9X8H1K201");
	const [lastReplay, setLastReplay] = useState<{ jobKey: string; executionId: string; attempt: number } | null>(null);

	// Live Fetcher from SurrealDB
	const fetchLiveDeadLetters = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_dead_letter ORDER BY created_at DESC;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: DeadLetterRecord[] = raw.map((d: any) => ({
					id: safeString(d.id).replace("scheduler_dead_letter:", ""),
					jobKey: safeString(d.job_key).replace("scheduler_job_definition:", ""),
					executionId: safeString(d.execution_id).replace("scheduler_execution:", ""),
					attempt: typeof d.attempt === "number" ? d.attempt : 1,
					deadReason: safeString(d.dead_reason) || "max_retries_exceeded",
					error: safeString(d.error) || "Unknown execution failure",
					scheduledFor: d.scheduled_for ? safeString(d.scheduled_for) : undefined,
					createdAt: safeString(d.created_at) || new Date().toISOString(),
					expiresAt: d.expires_at ? safeString(d.expires_at) : undefined,
					metadata: typeof d.metadata === "object" ? d.metadata : {},
					status: safeString(d.status) || "pending",
				}));
				setDeadLetters(mapped);
				if (!selectedId && mapped.length > 0) {
					setSelectedId(mapped[0].id);
				}
			}
		} catch (err) {
			console.warn("SurrealDB dead letters live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveDeadLetters();
	}, []);

	const selectedDL = deadLetters.find((d) => d.id === selectedId) || deadLetters[0] || null;

	// Replay Action
	const handleReplay = async (dl: DeadLetterRecord) => {
		const newExecId = `exec_replay_${Date.now()}`;
		setLastReplay({
			jobKey: dl.jobKey,
			executionId: newExecId,
			attempt: dl.attempt + 1,
		});

		setDeadLetters((prev) => prev.filter((item) => item.id !== dl.id));
		if (selectedId === dl.id) {
			const nextDL = deadLetters.find((item) => item.id !== dl.id);
			setSelectedId(nextDL ? nextDL.id : null);
		}

		try {
			await executeQuery(
				`UPDATE scheduler_dead_letter:${dl.id} SET status = 'replayed', replayed_at = time::now();
				 CREATE scheduler_execution:${newExecId} SET job_key = scheduler_job_definition:${dl.jobKey}, fire_at = time::now(), attempt = ${dl.attempt + 1}, state = 'queued', created_at = time::now();`
			);
			fetchLiveDeadLetters();
		} catch (err) {
			console.warn("Live replay mutation warning:", err);
		}
	};

	// Delete Single Action
	const handleDelete = async (dlId: string) => {
		setDeadLetters((prev) => prev.filter((item) => item.id !== dlId));
		if (selectedId === dlId) {
			const nextDL = deadLetters.find((item) => item.id !== dlId);
			setSelectedId(nextDL ? nextDL.id : null);
		}
		try {
			await executeQuery(`DELETE scheduler_dead_letter:${dlId};`);
			fetchLiveDeadLetters();
		} catch (err) {
			console.warn("Live dead letter delete warning:", err);
		}
	};

	// Clear All Action
	const handleClearAll = async () => {
		setDeadLetters([]);
		setSelectedId(null);
		try {
			await executeQuery(`DELETE scheduler_dead_letter;`);
			fetchLiveDeadLetters();
		} catch (err) {
			console.warn("Live dead letters clear all warning:", err);
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
								Dead Letter Queue (DLQ)
							</Title>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								Exhausted retry tasks awaiting manual inspection, replay or purge (`fn::scheduler::dead_letter_*`).
							</Text>
						</div>

						<Group id={`${idPrefix}-header-actions`} gap="sm">
							<Button
								id={`${idPrefix}-btn-refresh`}
								variant="default"
								leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
								onClick={fetchLiveDeadLetters}
							>
								Refresh Queue
							</Button>
							{deadLetters.length > 0 && (
								<Button
									id={`${idPrefix}-btn-clear-all`}
									color="red"
									variant="subtle"
									leftSection={<Icon id={`${idPrefix}-trash-all-icon`} path={iconTrash} />}
									onClick={handleClearAll}
								>
									Clear All Dead Letters
								</Button>
							)}
						</Group>
					</Group>
				</div>

				{/* Two-Column Master-Detail Layout */}
				<div
					id={`${idPrefix}-split-container`}
					style={{
						display: "grid",
						gridTemplateColumns: "360px 1fr",
						gap: "1.5rem",
						alignItems: "start",
					}}
				>
					{/* LEFT MASTER LIST */}
					<Card id={`${idPrefix}-master-card`} p="md" radius="md" withBorder>
						<Stack id={`${idPrefix}-master-stack`} gap="sm">
							<Group id={`${idPrefix}-master-head-grp`} justify="space-between" align="center">
								<Text id={`${idPrefix}-txt-pending-count`} size="xs" fw={600} c="dimmed">
									{deadLetters.length} pending dead letter{deadLetters.length === 1 ? "" : "s"}
								</Text>
							</Group>

							{/* Replay Queued Success Banner */}
							{lastReplay && (
								<Paper id={`${idPrefix}-replay-banner`} p="xs" bg="green.9" radius="sm" withBorder style={{ borderColor: "var(--mantine-color-green-6)" }}>
									<Group id={`${idPrefix}-replay-banner-grp`} justify="space-between" align="center">
										<div>
											<Text id={`${idPrefix}-txt-replay-msg`} size="xs" fw={600} c="green.1">
												Replay queued for {lastReplay.jobKey} · attempt {lastReplay.attempt}
											</Text>
											<Code id={`${idPrefix}-code-new-exec`} color="green" style={{ fontSize: "10px" }}>
												ID: {lastReplay.executionId}
											</Code>
										</div>
										<ActionIcon id={`${idPrefix}-btn-close-replay`} variant="subtle" color="gray" size="xs" onClick={() => setLastReplay(null)}>
											×
										</ActionIcon>
									</Group>
								</Paper>
							)}

							{/* Items List */}
							<Stack id={`${idPrefix}-master-items-list`} gap={6} mt="xs">
								{deadLetters.length === 0 ? (
									<Paper id={`${idPrefix}-master-empty`} p="lg" radius="sm" style={{ textAlign: "center" }} withBorder>
										<Text id={`${idPrefix}-txt-master-empty-title`} fw={600} size="xs" c="green.4">
											No dead letters
										</Text>
										<Text id={`${idPrefix}-txt-master-empty-desc`} size="xs" c="dimmed" mt={4}>
											Failed executions that exhaust retries appear here.
										</Text>
									</Paper>
								) : (
									deadLetters.map((dl) => {
										const isSelected = selectedId === dl.id;
										return (
											<Paper
												id={`${idPrefix}-item-${dl.id}`}
												key={dl.id}
												p="sm"
												radius="sm"
												withBorder
												style={{
													cursor: "pointer",
													borderColor: isSelected ? "var(--mantine-color-indigo-5)" : undefined,
													backgroundColor: isSelected ? "var(--mantine-color-indigo-9)" : undefined,
												}}
												onClick={() => setSelectedId(dl.id)}
											>
												<Stack id={`${idPrefix}-item-stack-${dl.id}`} gap={4}>
													<Group id={`${idPrefix}-item-head-${dl.id}`} justify="space-between" align="center">
														<Group id={`${idPrefix}-item-title-grp-${dl.id}`} gap="xs">
															{dl.deadReason === "max_retries_exceeded" && (
																<Icon id={`${idPrefix}-icon-warn-${dl.id}`} path={iconWarning} size="xs" style={{ color: "var(--mantine-color-red-4)" }} />
															)}
															<Text id={`${idPrefix}-txt-job-${dl.id}`} size="sm" fw={600} style={{ fontFamily: "monospace" }}>
																{dl.jobKey}
															</Text>
														</Group>
														<Text id={`${idPrefix}-txt-attempt-${dl.id}`} size="xs" c="dimmed">
															attempt {dl.attempt}
														</Text>
													</Group>

													<Text id={`${idPrefix}-txt-err-snippet-${dl.id}`} size="xs" c="red.3" lineClamp={1}>
														{dl.error}
													</Text>

													<Text id={`${idPrefix}-txt-created-${dl.id}`} size="xs" c="dimmed" style={{ fontSize: "10px" }}>
														Failed {dl.createdAt}
													</Text>
												</Stack>
											</Paper>
										);
									})
								)}
							</Stack>
						</Stack>
					</Card>

					{/* RIGHT DETAIL PANEL */}
					{selectedDL ? (
						<Card id={`${idPrefix}-detail-card`} p="lg" radius="md" withBorder>
							<Stack id={`${idPrefix}-detail-stack`} gap="lg">
								{/* Detail Header & Action Buttons */}
								<Group id={`${idPrefix}-detail-header`} justify="space-between" align="flex-start">
									<div>
										<Group id={`${idPrefix}-detail-title-grp`} gap="xs">
											<Title id={`${idPrefix}-detail-title`} order={3} style={{ fontFamily: "monospace" }}>
												{selectedDL.jobKey}
											</Title>
											<Badge id={`${idPrefix}-detail-reason-bdg`} color="red" size="xs">
												{selectedDL.deadReason}
											</Badge>
											<Badge id={`${idPrefix}-detail-attempt-bdg`} color="gray" size="xs" variant="outline">
												ATTEMPT #{selectedDL.attempt}
											</Badge>
										</Group>
										<Text id={`${idPrefix}-detail-id-txt`} size="xs" c="dimmed" mt={4} style={{ fontFamily: "monospace" }}>
											Dead Letter ID: {selectedDL.id}
										</Text>
									</div>

									<Group id={`${idPrefix}-detail-actions`} gap="xs">
										<Button
											id={`${idPrefix}-btn-replay-${selectedDL.id}`}
											color="pink"
											size="xs"
											leftSection={<Icon id={`${idPrefix}-replay-icon`} path={iconRefresh} size="xs" />}
											onClick={() => handleReplay(selectedDL)}
										>
											Replay Execution
										</Button>
										<Button
											id={`${idPrefix}-btn-delete-${selectedDL.id}`}
											color="red"
											variant="subtle"
											size="xs"
											leftSection={<Icon id={`${idPrefix}-delete-icon`} path={iconTrash} size="xs" />}
											onClick={() => handleDelete(selectedDL.id)}
										>
											Delete
										</Button>
									</Group>
								</Group>

								{/* Execution Metadata Table Grid */}
								<Paper id={`${idPrefix}-meta-paper`} p="md" radius="sm" withBorder>
									<Stack id={`${idPrefix}-meta-grid-stack`} gap="xs">
										<Group id={`${idPrefix}-meta-row-exec`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-exec`} size="xs" c="dimmed">
												Original Execution ID
											</Text>
											<Group id={`${idPrefix}-val-meta-exec-grp`} gap="xs">
												<Code id={`${idPrefix}-val-meta-exec`} color="pink">
													{selectedDL.executionId}
												</Code>
											</Group>
										</Group>
										<Group id={`${idPrefix}-meta-row-scheduled`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-scheduled`} size="xs" c="dimmed">
												Originally Scheduled For
											</Text>
											<Text id={`${idPrefix}-val-meta-scheduled`} size="xs" fw={500}>
												{selectedDL.scheduledFor || selectedDL.createdAt}
											</Text>
										</Group>
										<Group id={`${idPrefix}-meta-row-created`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-created`} size="xs" c="dimmed">
												Landed in DLQ At
											</Text>
											<Text id={`${idPrefix}-val-meta-created`} size="xs" fw={500}>
												{selectedDL.createdAt}
											</Text>
										</Group>
										<Group id={`${idPrefix}-meta-row-expires`} justify="space-between">
											<Text id={`${idPrefix}-lbl-meta-expires`} size="xs" c="dimmed">
												Auto Purge Expiration
											</Text>
											<Text id={`${idPrefix}-val-meta-expires`} size="xs" fw={500}>
												{selectedDL.expiresAt || "Never"}
											</Text>
										</Group>
									</Stack>
								</Paper>

								{/* Full Error Box */}
								<Paper id={`${idPrefix}-error-paper`} radius="sm" withBorder p={0}>
									<Paper id={`${idPrefix}-error-header`} p="xs" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
										<Text id={`${idPrefix}-txt-error-title`} fw={600} size="xs" c="red.4">
											Execution Error & Stack Trace
										</Text>
									</Paper>
									<Code id={`${idPrefix}-code-error-body`} block color="red" style={{ fontSize: "12px", fontFamily: "monospace", padding: "12px" }}>
										{selectedDL.error}
									</Code>
								</Paper>

								{/* Metadata JSON Box */}
								{selectedDL.metadata && Object.keys(selectedDL.metadata).length > 0 && (
									<Paper id={`${idPrefix}-metadata-paper`} radius="sm" withBorder p={0}>
										<Paper id={`${idPrefix}-metadata-header`} p="xs" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
											<Text id={`${idPrefix}-txt-metadata-title`} fw={600} size="xs" c="dimmed">
												Task Context Metadata
											</Text>
										</Paper>
										<Code id={`${idPrefix}-code-metadata-body`} block style={{ fontSize: "12px", fontFamily: "monospace", padding: "12px" }}>
											{JSON.stringify(selectedDL.metadata, null, 2)}
										</Code>
									</Paper>
								)}
							</Stack>
						</Card>
					) : (
						<Card id={`${idPrefix}-no-selection-card`} p="xl" radius="md" style={{ textAlign: "center" }} withBorder>
							<Text id={`${idPrefix}-txt-no-selection`} size="sm" c="dimmed">
								Select a dead letter from the list on the left to inspect error details and replay.
							</Text>
						</Card>
					)}
				</div>
			</Stack>
		</div>
	);
}
