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
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconClock,
	iconEdit,
	iconErrorCircle,
	iconFilter,
	iconPlus,
	iconRefresh,
	iconSearch,
	iconTrash,
} from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerJobsProps {
	idPrefix?: string;
}

export interface JobDefinitionData {
	key: string;
	title: string;
	description: string;
	cron: string;
	timezone: string;
	isActive: boolean;
	isOverdue: boolean;
	executionMode: "persisted" | "ephemeral";
	suppressedBy?: string;
	configError?: string;
	tags: string[];
	payload: string;
	maxRetries: number;
	timeoutSecs: number;
	managedBy: "api" | "dsl";
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

export function SchedulerJobs({ idPrefix = "scheduler-jobs" }: SchedulerJobsProps) {
	const [searchQuery, setSearchQuery] = useState("");
	const [selectedTag, setSelectedTag] = useState<string | null>(null);
	const [selectedJobKey, setSelectedJobKey] = useState<string>("backup_db_daily");
	const [jobTab, setJobTab] = useState<string | null>("overview");

	// Modals
	const [newJobModalOpen, setNewJobModalOpen] = useState(false);
	const [editJobModalOpen, setEditJobModalOpen] = useState(false);
	const [scheduleModalOpen, setScheduleModalOpen] = useState(false);

	// Form State for Job Creation
	const [formKey, setFormKey] = useState("");
	const [formDesc, setFormDesc] = useState("");
	const [formPayload, setFormPayload] = useState('{\n  "action": "full_backup"\n}');
	const [formExecMode, setFormExecMode] = useState<"persisted" | "ephemeral">("persisted");
	const [formMaxRetries, setFormMaxRetries] = useState<number>(3);
	const [formTimeout, setFormTimeout] = useState<number>(3600);
	const [formTags, setFormTags] = useState("database, backup");

	// Form State for Schedule Trigger Modal
	const [cronExpr, setCronExpr] = useState("0 2 * * *");
	const [timezone, setTimezone] = useState("UTC");

	const [jobsList, setJobsList] = useState<JobDefinitionData[]>([
		{
			key: "backup_db_daily",
			title: "backup_db_daily",
			description: "Automated SurrealDB export to cold storage",
			cron: "0 2 * * *",
			timezone: "UTC",
			isActive: true,
			isOverdue: false,
			executionMode: "persisted",
			tags: ["database", "backup", "production"],
			payload: `{\n  "target": "s3://backups/surreal.db",\n  "compress": true\n}`,
			maxRetries: 3,
			timeoutSecs: 3600,
			managedBy: "api",
		},
		{
			key: "cleanup_audit_logs",
			title: "cleanup_audit_logs",
			description: "Purge audit logs older than 90 days",
			cron: "0 0 * * *",
			timezone: "UTC",
			isActive: true,
			isOverdue: false,
			executionMode: "persisted",
			tags: ["maintenance", "security"],
			payload: `{\n  "retention_days": 90\n}`,
			maxRetries: 5,
			timeoutSecs: 600,
			managedBy: "dsl",
		},
		{
			key: "sync_customer_metrics",
			title: "sync_customer_metrics",
			description: "Aggregate 15-min telemetry buckets",
			cron: "*/15 * * * *",
			timezone: "UTC",
			isActive: true,
			isOverdue: false,
			executionMode: "ephemeral",
			tags: ["telemetry", "analytics"],
			payload: `{\n  "batch_size": 500\n}`,
			maxRetries: 2,
			timeoutSecs: 120,
			managedBy: "api",
		},
	]);

	const fetchJobs = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_job_definition;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: JobDefinitionData[] = raw.map((r: any) => {
					const keyName = safeString(r.job_key) || safeString(r.id).replace("scheduler_job_definition:", "");
					return {
						key: keyName,
						title: keyName || "Untitled Job",
						description: safeString(r.description),
						cron: safeString(r.cron_expression) || "0 2 * * *",
						timezone: safeString(r.timezone) || "UTC",
						isActive: r.is_active ?? true,
						isOverdue: false,
						executionMode: safeString(r.execution_mode) as "persisted" | "ephemeral" || "persisted",
						tags: Array.isArray(r.tags) ? r.tags.map((t: any) => safeString(t)) : [],
						payload: typeof r.payload === "string" ? r.payload : JSON.stringify(r.metadata?.payload || r.payload || {}, null, 2),
						maxRetries: typeof r.max_retries === "number" ? r.max_retries : 3,
						timeoutSecs: typeof r.timeout_secs === "number" ? r.timeout_secs : 3600,
						managedBy: (safeString(r.managed_by) as "api" | "dsl") || "api",
					};
				});
				setJobsList(mapped);
			}
		} catch (err) {
			console.warn("SurrealDB live query fallback to initial state", err);
		}
	};

	useEffect(() => {
		fetchJobs();
	}, []);

	const selectedJob = jobsList.find((j) => j.key === selectedJobKey) || jobsList[0];
	const allTags = Array.from(new Set(jobsList.flatMap((j) => j.tags)));

	const filteredJobs = jobsList.filter((j) => {
		const matchesQuery =
			!searchQuery ||
			j.key.toLowerCase().includes(searchQuery.toLowerCase()) ||
			j.description.toLowerCase().includes(searchQuery.toLowerCase());
		const matchesTag = !selectedTag || j.tags.includes(selectedTag);
		return matchesQuery && matchesTag;
	});

	const handleCreateJob = async () => {
		if (!formKey.trim()) return;
		const parsedTags = formTags.split(",").map((t) => t.trim()).filter(Boolean);

		const newJob: JobDefinitionData = {
			key: formKey.trim(),
			title: formKey.trim(),
			description: formDesc.trim(),
			cron: "0 2 * * *",
			timezone: "UTC",
			isActive: true,
			isOverdue: false,
			executionMode: formExecMode,
			tags: parsedTags,
			payload: formPayload,
			maxRetries: formMaxRetries,
			timeoutSecs: formTimeout,
			managedBy: "api",
		};

		setJobsList((prev) => [...prev.filter((j) => j.key !== newJob.key), newJob]);
		setSelectedJobKey(newJob.key);
		setNewJobModalOpen(false);

		try {
			await executeQuery(
				`CREATE scheduler_job_definition:${newJob.key} SET description = $desc, tags = $tags, metadata = { payload: $payload }, max_retries = $retries, timeout_secs = $timeout, is_active = true;`,
				{
					desc: formDesc.trim(),
					tags: parsedTags,
					payload: formPayload,
					retries: formMaxRetries,
					timeout: formTimeout,
				}
			);
			fetchJobs();
		} catch (err) {
			console.warn("Live create job mutation warning:", err);
		}
	};

	const handleDeleteJob = async (jobKey: string) => {
		setJobsList((prev) => prev.filter((j) => j.key !== jobKey));
		if (selectedJobKey === jobKey && jobsList.length > 1) {
			setSelectedJobKey(jobsList.find((j) => j.key !== jobKey)?.key || "");
		}
		try {
			await executeQuery(`DELETE scheduler_job_definition:${jobKey};`);
			fetchJobs();
		} catch (err) {
			console.warn("Live delete job mutation warning:", err);
		}
	};

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", height: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-main-stack`} gap="lg" style={{ height: "100%" }}>
				{/* Top Header & Actions */}
				<Group id={`${idPrefix}-top-bar`} justify="space-between" align="center">
					<div id={`${idPrefix}-header-title-container`}>
						<Title id={`${idPrefix}-title`} order={2}>
							Job Definitions & Runtime State
						</Title>
						<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm">
							Manage scheduled jobs, execution policies, triggers, and payload DSL (`fn::scheduler::job_*`)
						</Text>
					</div>

					<Group id={`${idPrefix}-header-actions`} gap="sm">
						<Button
							id={`${idPrefix}-btn-refresh`}
							variant="default"
							leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
							onClick={fetchJobs}
						>
							Refresh Live Jobs
						</Button>
						<Button
							id={`${idPrefix}-btn-new-job`}
							color="pink"
							leftSection={<Icon id={`${idPrefix}-new-job-icon`} path={iconPlus} />}
							onClick={() => setNewJobModalOpen(true)}
						>
							New Job Definition
						</Button>
					</Group>
				</Group>

				{/* Two-Panel Layout */}
				<div
					id={`${idPrefix}-panels-container`}
					style={{
						display: "grid",
						gridTemplateColumns: "340px 1fr",
						gap: "1.5rem",
						alignItems: "start",
					}}
				>
					{/* Left Panel: Jobs List & Filters */}
					<Card id={`${idPrefix}-left-card`} p="md" radius="md" withBorder>
						<Stack id={`${idPrefix}-left-stack`} gap="sm">
							<TextInput
								id={`${idPrefix}-search-input`}
								placeholder="Search jobs by key or description..."
								leftSection={<Icon id={`${idPrefix}-search-icon`} path={iconSearch} size="xs" />}
								value={searchQuery}
								onChange={(e) => setSearchQuery(e.currentTarget.value)}
								size="xs"
							/>

							{/* Tag Filters */}
							{allTags.length > 0 && (
								<Group id={`${idPrefix}-tags-group`} gap={4} wrap="wrap">
									<Badge
										id={`${idPrefix}-tag-all`}
										size="xs"
										style={{ cursor: "pointer" }}
										color={selectedTag === null ? "indigo" : "gray"}
										variant={selectedTag === null ? "filled" : "light"}
										onClick={() => setSelectedTag(null)}
									>
										ALL ({jobsList.length})
									</Badge>
									{allTags.map((tag) => (
										<Badge
											id={`${idPrefix}-tag-${tag}`}
											key={tag}
											size="xs"
											style={{ cursor: "pointer" }}
											color={selectedTag === tag ? "indigo" : "gray"}
											variant={selectedTag === tag ? "filled" : "light"}
											onClick={() => setSelectedTag(tag === selectedTag ? null : tag)}
										>
											{tag}
										</Badge>
									))}
								</Group>
							)}

							{/* List of Job Items */}
							<Stack id={`${idPrefix}-jobs-list`} gap={6} mt="xs">
								{filteredJobs.length === 0 ? (
									<Text id={`${idPrefix}-no-jobs-txt`} size="xs" c="dimmed" ta="center" py="md">
										No matching job definitions found.
									</Text>
								) : (
									filteredJobs.map((job) => (
										<Paper
											id={`${idPrefix}-job-item-${job.key}`}
											key={job.key}
											p="sm"
											radius="sm"
											withBorder
											style={{
												cursor: "pointer",
												borderColor: selectedJobKey === job.key ? "var(--mantine-color-indigo-5)" : undefined,
												backgroundColor: selectedJobKey === job.key ? "var(--mantine-color-indigo-9)" : undefined,
											}}
											onClick={() => setSelectedJobKey(job.key)}
										>
											<Group id={`${idPrefix}-job-item-header-${job.key}`} justify="space-between" align="flex-start" wrap="nowrap">
												<div id={`${idPrefix}-job-item-info-${job.key}`}>
													<Text id={`${idPrefix}-txt-job-key-${job.key}`} size="sm" fw={600} style={{ fontFamily: "monospace" }}>
														{job.key}
													</Text>
													<Text id={`${idPrefix}-txt-job-desc-${job.key}`} size="xs" c="dimmed" lineClamp={1}>
														{job.description || "No description"}
													</Text>
												</div>

												<Badge
													id={`${idPrefix}-bdg-status-${job.key}`}
													size="xs"
													color={job.isActive ? "green" : "gray"}
												>
													{job.isActive ? "ACTIVE" : "PAUSED"}
												</Badge>
											</Group>
										</Paper>
									))
								)}
							</Stack>
						</Stack>
					</Card>

					{/* Right Panel: Selected Job Details & 6 Sub-Tabs */}
					{selectedJob ? (
						<Card id={`${idPrefix}-right-card`} p="lg" radius="md" withBorder>
							<Stack id={`${idPrefix}-detail-stack`} gap="md">
								{/* Detail Header */}
								<Group id={`${idPrefix}-detail-header`} justify="space-between" align="flex-start">
									<div id={`${idPrefix}-detail-header-info`}>
										<Group id={`${idPrefix}-detail-key-group`} gap="xs">
											<Title id={`${idPrefix}-detail-title`} order={3} style={{ fontFamily: "monospace" }}>
												{selectedJob.key}
											</Title>
											<Badge id={`${idPrefix}-detail-mode-bdg`} color={selectedJob.executionMode === "persisted" ? "indigo" : "teal"}>
												{selectedJob.executionMode.toUpperCase()} MODE
											</Badge>
											<Badge id={`${idPrefix}-detail-managed-bdg`} variant="outline" color="gray">
												MANAGED BY {selectedJob.managedBy.toUpperCase()}
											</Badge>
										</Group>

										<Text id={`${idPrefix}-detail-desc`} c="dimmed" size="sm" mt={4}>
											{selectedJob.description || "No detailed description available."}
										</Text>
									</div>

									{/* Action Buttons */}
									<Group id={`${idPrefix}-detail-actions`} gap="xs">
										<Button
											id={`${idPrefix}-btn-edit-job`}
											variant="light"
											color="pink"
											size="xs"
											leftSection={<Icon id={`${idPrefix}-edit-icon`} path={iconEdit} size="xs" />}
											onClick={() => setEditJobModalOpen(true)}
										>
											Edit Job
										</Button>
										<Button
											id={`${idPrefix}-btn-schedule-job`}
											variant="light"
											color="blue"
											size="xs"
											leftSection={<Icon id={`${idPrefix}-clock-icon`} path={iconClock} size="xs" />}
											onClick={() => setScheduleModalOpen(true)}
										>
											Schedule & Triggers
										</Button>
										<Button
											id={`${idPrefix}-btn-delete-job`}
											variant="subtle"
											color="red"
											size="xs"
											leftSection={<Icon id={`${idPrefix}-trash-icon`} path={iconTrash} size="xs" />}
											onClick={() => handleDeleteJob(selectedJob.key)}
										>
											Delete
										</Button>
									</Group>
								</Group>

								{/* 6 Sub-Tabs for Job Details */}
								<Tabs
									id={`${idPrefix}-subtabs`}
									value={jobTab}
									onChange={(val) => setJobTab(val || "overview")}
									variant="outline"
									radius="md"
								>
									<Tabs.List id={`${idPrefix}-subtabs-list`}>
										<Tabs.Tab id={`${idPrefix}-tab-overview`} value="overview">
											Overview
										</Tabs.Tab>
										<Tabs.Tab id={`${idPrefix}-tab-executions`} value="executions">
											Executions (History)
										</Tabs.Tab>
										<Tabs.Tab id={`${idPrefix}-tab-schedule`} value="schedule">
											Schedule & Triggers
										</Tabs.Tab>
										<Tabs.Tab id={`${idPrefix}-tab-dsl`} value="dsl">
											Croniqfile DSL
										</Tabs.Tab>
										<Tabs.Tab id={`${idPrefix}-tab-alerts`} value="alerts">
											Alert Rules
										</Tabs.Tab>
										<Tabs.Tab id={`${idPrefix}-tab-audit`} value="audit">
											Audit Trail
										</Tabs.Tab>
									</Tabs.List>
								</Tabs>

								{/* SUB-TAB 1: OVERVIEW */}
								{jobTab === "overview" && (
									<Stack id={`${idPrefix}-overview-stack`} gap="md" mt="xs">
										<Group id={`${idPrefix}-overview-meta-group`} grow>
											<Paper id={`${idPrefix}-meta-cron-card`} p="sm" withBorder radius="sm">
												<Text id={`${idPrefix}-lbl-cron`} size="xs" c="dimmed">
													Cron Schedule Expression
												</Text>
												<Text id={`${idPrefix}-val-cron`} fw={600} size="sm" style={{ fontFamily: "monospace" }}>
													{selectedJob.cron} ({selectedJob.timezone})
												</Text>
											</Paper>

											<Paper id={`${idPrefix}-meta-retry-card`} p="sm" withBorder radius="sm">
												<Text id={`${idPrefix}-lbl-retry`} size="xs" c="dimmed">
													Max Retries Policy
												</Text>
												<Text id={`${idPrefix}-val-retry`} fw={600} size="sm">
													{selectedJob.maxRetries} Retries max
												</Text>
											</Paper>

											<Paper id={`${idPrefix}-meta-timeout-card`} p="sm" withBorder radius="sm">
												<Text id={`${idPrefix}-lbl-timeout`} size="xs" c="dimmed">
													Timeout Duration
												</Text>
												<Text id={`${idPrefix}-val-timeout`} fw={600} size="sm">
													{selectedJob.timeoutSecs} seconds
												</Text>
											</Paper>
										</Group>

										<Paper id={`${idPrefix}-payload-paper`} p="md" withBorder radius="md">
											<Group id={`${idPrefix}-payload-header`} justify="space-between" mb="xs">
												<Text id={`${idPrefix}-txt-payload-title`} fw={600} size="xs">
													JSON Task Payload / Parameters (`metadata.payload`)
												</Text>
											</Group>
											<Code id={`${idPrefix}-code-payload`} block style={{ fontSize: "12px", fontFamily: "monospace" }}>
												{selectedJob.payload}
											</Code>
										</Paper>
									</Stack>
								)}

								{/* SUB-TAB 2: EXECUTIONS */}
								{jobTab === "executions" && (
									<Paper id={`${idPrefix}-tab-exec-paper`} p="md" withBorder radius="md">
										<Text id={`${idPrefix}-txt-exec-title`} fw={600} size="sm" mb="xs">
											Recent Executions for `{selectedJob.key}`
										</Text>
										<Table id={`${idPrefix}-tbl-exec`} verticalSpacing="xs">
											<Table.Thead id={`${idPrefix}-thead-exec`}>
												<Table.Tr id={`${idPrefix}-tr-head-exec`}>
													<Table.Th id={`${idPrefix}-th-exec-id`}>Execution ID</Table.Th>
													<Table.Th id={`${idPrefix}-th-exec-state`}>State</Table.Th>
													<Table.Th id={`${idPrefix}-th-exec-attempt`}>Attempt</Table.Th>
													<Table.Th id={`${idPrefix}-th-exec-duration`}>Duration</Table.Th>
												</Table.Tr>
											</Table.Thead>
											<Table.Tbody id={`${idPrefix}-tbody-exec`}>
												<Table.Tr id={`${idPrefix}-row-exec-sample`}>
													<Table.Td id={`${idPrefix}-td-exec-id`}>
														<Text id={`${idPrefix}-txt-exec-id`} size="xs" style={{ fontFamily: "monospace" }}>
															exec_01J9X8A1B2C3
														</Text>
													</Table.Td>
													<Table.Td id={`${idPrefix}-td-exec-state`}>
														<Badge id={`${idPrefix}-bdg-exec-st`} color="green" size="xs">
															COMPLETED
														</Badge>
													</Table.Td>
													<Table.Td id={`${idPrefix}-td-exec-attempt`}>1 / 3</Table.Td>
													<Table.Td id={`${idPrefix}-td-exec-dur`}>420ms</Table.Td>
												</Table.Tr>
											</Table.Tbody>
										</Table>
									</Paper>
								)}

								{/* SUB-TAB 3: SCHEDULE */}
								{jobTab === "schedule" && (
									<Paper id={`${idPrefix}-tab-sched-paper`} p="md" withBorder radius="md">
										<Text id={`${idPrefix}-txt-sched-title`} fw={600} size="sm" mb="xs">
											Schedule & Triggers Configured
										</Text>
										<Code id={`${idPrefix}-code-cron-expr`} block color="pink">
											CRON "{selectedJob.cron}" TIMEZONE "{selectedJob.timezone}"
										</Code>
									</Paper>
								)}

								{/* SUB-TAB 4: DSL */}
								{jobTab === "dsl" && (
									<Paper id={`${idPrefix}-tab-dsl-paper`} p="md" withBorder radius="md">
										<Text id={`${idPrefix}-txt-dsl-title`} fw={600} size="sm" mb="xs">
											Croniqfile DSL Definition
										</Text>
										<Code id={`${idPrefix}-code-dsl`} block style={{ fontFamily: "monospace" }}>
											{`job "${selectedJob.key}" {\n  description "${selectedJob.description}"\n  schedule "${selectedJob.cron}"\n  timeout "${selectedJob.timeoutSecs}s"\n  max_retries ${selectedJob.maxRetries}\n}`}
										</Code>
									</Paper>
								)}

								{/* SUB-TAB 5: ALERTS */}
								{jobTab === "alerts" && (
									<Paper id={`${idPrefix}-tab-alerts-paper`} p="md" withBorder radius="md">
										<Text id={`${idPrefix}-txt-alerts-title`} fw={600} size="sm">
											Alert Rules Matching `{selectedJob.key}`
										</Text>
										<Badge id={`${idPrefix}-bdg-rule-match`} color="pink" size="xs" mt="xs">
											failure_slack_webhook (#slack-#dev-alerts)
										</Badge>
									</Paper>
								)}

								{/* SUB-TAB 6: AUDIT */}
								{jobTab === "audit" && (
									<Paper id={`${idPrefix}-tab-audit-paper`} p="md" withBorder radius="md">
										<Text id={`${idPrefix}-txt-audit-title`} fw={600} size="sm">
											Audit Log Events
										</Text>
										<Text id={`${idPrefix}-txt-audit-item`} size="xs" c="dimmed" mt="xs">
											• Job created by operator_root (time::now())
										</Text>
									</Paper>
								)}
							</Stack>
						</Card>
					) : null}
				</div>
			</Stack>

			{/* MODAL: NEW JOB DEFINITION */}
			<Modal
				id={`${idPrefix}-modal-new-job`}
				opened={newJobModalOpen}
				onClose={() => setNewJobModalOpen(false)}
				title="Create New Job Definition"
				centered
			>
				<Stack id={`${idPrefix}-modal-new-job-stack`} gap="md">
					<TextInput
						id={`${idPrefix}-input-new-key`}
						label="Job Key / Identifier"
						placeholder="e.g. export_user_reports"
						value={formKey}
						onChange={(e) => setFormKey(e.currentTarget.value)}
						required
					/>
					<TextInput
						id={`${idPrefix}-input-new-desc`}
						label="Description"
						placeholder="Short description of task purpose..."
						value={formDesc}
						onChange={(e) => setFormDesc(e.currentTarget.value)}
					/>
					<Textarea
						id={`${idPrefix}-input-new-payload`}
						label="JSON Payload / Metadata"
						rows={4}
						value={formPayload}
						onChange={(e) => setFormPayload(e.currentTarget.value)}
					/>
					<Group id={`${idPrefix}-modal-new-meta`} grow>
						<NumberInput
							id={`${idPrefix}-input-new-retries`}
							label="Max Retries"
							value={formMaxRetries}
							onChange={(val) => setFormMaxRetries(Number(val) || 3)}
						/>
						<NumberInput
							id={`${idPrefix}-input-new-timeout`}
							label="Timeout (Secs)"
							value={formTimeout}
							onChange={(val) => setFormTimeout(Number(val) || 3600)}
						/>
					</Group>
					<TextInput
						id={`${idPrefix}-input-new-tags`}
						label="Tags (Comma Separated)"
						placeholder="production, backup, telemetry"
						value={formTags}
						onChange={(e) => setFormTags(e.currentTarget.value)}
					/>
					<Group id={`${idPrefix}-modal-new-actions`} justify="flex-end" mt="md">
						<Button id={`${idPrefix}-btn-cancel-new`} variant="subtle" onClick={() => setNewJobModalOpen(false)}>
							Cancel
						</Button>
						<Button id={`${idPrefix}-btn-submit-new`} color="pink" disabled={!formKey.trim()} onClick={handleCreateJob}>
							Create Job Definition
						</Button>
					</Group>
				</Stack>
			</Modal>
		</div>
	);
}
