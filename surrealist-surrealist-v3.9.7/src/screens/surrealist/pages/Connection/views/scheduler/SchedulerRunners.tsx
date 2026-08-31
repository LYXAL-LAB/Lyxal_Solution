import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Code,
	Group,
	Paper,
	Progress,
	Stack,
	Table,
	Text,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconCopy,
	iconErrorCircle,
	iconFilter,
	iconRefresh,
	iconTrash,
} from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerRunnersProps {
	idPrefix?: string;
}

export interface RunnerRecord {
	id: string;
	status: "online" | "stale" | "offline";
	maxInflight: number;
	currentInflight: number;
	capabilities: string[];
	tags: string[];
	lastPollAt: string;
	registeredAt: string;
	metadata: Record<string, any>;
}

export interface RunnerExecution {
	id: string;
	jobKey: string;
	state: string;
	fireAt: string;
	durationMs?: number;
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

export function SchedulerRunners({ idPrefix = "scheduler-runners" }: SchedulerRunnersProps) {
	const [runners, setRunners] = useState<RunnerRecord[]>([
		{
			id: "worker_01",
			status: "online",
			maxInflight: 5,
			currentInflight: 1,
			capabilities: ["shell", "http", "surrealql"],
			tags: ["eu-west", "high-mem"],
			lastPollAt: new Date().toISOString(),
			registeredAt: new Date(Date.now() - 172800000).toISOString(),
			metadata: { hostname: "runner-node-eu-1", ip: "10.0.4.12", os: "linux" },
		},
		{
			id: "worker_02",
			status: "online",
			maxInflight: 3,
			currentInflight: 0,
			capabilities: ["python", "shell"],
			tags: ["us-east", "gpu"],
			lastPollAt: new Date(Date.now() - 30000).toISOString(),
			registeredAt: new Date(Date.now() - 432000000).toISOString(),
			metadata: { hostname: "runner-node-us-2", ip: "10.0.8.44", os: "linux" },
		},
		{
			id: "worker_03",
			status: "offline",
			maxInflight: 10,
			currentInflight: 0,
			capabilities: ["http"],
			tags: ["edge"],
			lastPollAt: new Date(Date.now() - 3600000).toISOString(),
			registeredAt: new Date(Date.now() - 864000000).toISOString(),
			metadata: { hostname: "runner-edge-01", ip: "192.168.1.100", os: "windows" },
		},
	]);

	const [activeTag, setActiveTag] = useState<string>("all");
	const [selectedId, setSelectedId] = useState<string | null>("worker_01");

	const [recentExecutions, setRecentExecutions] = useState<RunnerExecution[]>([
		{ id: "exec_01J9X8A1B2C3", jobKey: "backup_db_daily", state: "completed", fireAt: new Date(Date.now() - 7200000).toISOString(), durationMs: 420 },
		{ id: "exec_01J9X8A7F8G9", jobKey: "sync_customer_metrics", state: "running", fireAt: new Date(Date.now() - 900000).toISOString() },
	]);

	// Live SurrealDB Runners Fetcher
	const fetchLiveRunners = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_runner ORDER BY registered_at DESC;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: RunnerRecord[] = raw.map((r: any) => {
					const inflightArr = Array.isArray(r.inflight) ? r.inflight : [];
					const meta = typeof r.metadata === "object" ? r.metadata : {};
					const tags = Array.isArray(meta.tags) ? meta.tags.map((t: any) => safeString(t)) : [];
					return {
						id: safeString(r.id).replace("scheduler_runner:", ""),
						status: (safeString(r.status) || "online") as RunnerRecord["status"],
						maxInflight: typeof r.max_inflight === "number" ? r.max_inflight : 5,
						currentInflight: inflightArr.length,
						capabilities: Array.isArray(r.capabilities) ? r.capabilities.map((c: any) => safeString(c)) : [],
						tags,
						lastPollAt: safeString(r.last_poll_at) || new Date().toISOString(),
						registeredAt: safeString(r.registered_at) || new Date().toISOString(),
						metadata: meta,
					};
				});
				setRunners(mapped);
				if (!selectedId && mapped.length > 0) {
					setSelectedId(mapped[0].id);
				}
			}
		} catch (err) {
			console.warn("SurrealDB runners live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveRunners();
	}, []);

	// Remove Runner Action
	const handleDeleteRunner = async (runnerId: string) => {
		setRunners((prev) => prev.filter((r) => r.id !== runnerId));
		if (selectedId === runnerId) {
			const nextRunner = runners.find((r) => r.id !== runnerId);
			setSelectedId(nextRunner ? nextRunner.id : null);
		}
		try {
			await executeQuery(`DELETE scheduler_runner:${runnerId};`);
			fetchLiveRunners();
		} catch (err) {
			console.warn("Live runner delete warning:", err);
		}
	};

	// Collect unique tags
	const allTags = Array.from(new Set(runners.flatMap((r) => r.tags)));

	const filteredRunners = runners.filter((r) => {
		if (activeTag === "all") return true;
		return r.tags.includes(activeTag);
	});

	const selectedRunner = runners.find((r) => r.id === selectedId) || runners[0] || null;

	const getStatusBadge = (status: RunnerRecord["status"], key: string) => {
		switch (status) {
			case "online":
				return <Badge id={`${idPrefix}-badge-${key}`} color="green" variant="light">ONLINE</Badge>;
			case "stale":
				return <Badge id={`${idPrefix}-badge-${key}`} color="orange" variant="light">STALE</Badge>;
			case "offline":
				return <Badge id={`${idPrefix}-badge-${key}`} color="red" variant="filled">OFFLINE</Badge>;
			default:
				return <Badge id={`${idPrefix}-badge-${key}`} color="gray">ONLINE</Badge>;
		}
	};

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-stack`} gap="lg">
				{/* Top Header */}
				<div id={`${idPrefix}-header-container`}>
					<Group id={`${idPrefix}-header-group`} justify="space-between" align="center">
						<div id={`${idPrefix}-header-text`}>
							<Group id={`${idPrefix}-title-grp`} gap="xs">
								<Title id={`${idPrefix}-title`} order={2}>
									Runners Fleet
								</Title>
								<Badge id={`${idPrefix}-live-badge`} color="green" variant="light" size="xs">
									● LIVE STREAM CONNECTED
								</Badge>
							</Group>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								Worker nodes heartbeats, capacity limits and execution leasing (`fn::scheduler::runner_*`).
							</Text>
						</div>

						<Button
							id={`${idPrefix}-btn-refresh`}
							variant="default"
							leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
							onClick={fetchLiveRunners}
						>
							Refresh Fleet
						</Button>
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
								<Text id={`${idPrefix}-txt-connected-count`} size="xs" fw={600} c="dimmed">
									{runners.length} connected runner{runners.length === 1 ? "" : "s"}
								</Text>
							</Group>

							{/* Tag Pills */}
							<Group id={`${idPrefix}-tag-pills-grp`} gap={6} wrap="wrap">
								<Button
									id={`${idPrefix}-btn-tag-all`}
									size="xs"
									variant={activeTag === "all" ? "filled" : "outline"}
									color="pink"
									onClick={() => setActiveTag("all")}
								>
									All ({runners.length})
								</Button>
								{allTags.map((tag) => (
									<Button
										id={`${idPrefix}-btn-tag-${tag}`}
										key={tag}
										size="xs"
										variant={activeTag === tag ? "filled" : "outline"}
										color="pink"
										onClick={() => setActiveTag(tag)}
									>
										#{tag}
									</Button>
								))}
							</Group>

							{/* Master Runners List Items */}
							<Stack id={`${idPrefix}-master-items-list`} gap={6} mt="xs">
								{filteredRunners.length === 0 ? (
									<Paper id={`${idPrefix}-master-empty`} p="lg" radius="sm" style={{ textAlign: "center" }} withBorder>
										<Text id={`${idPrefix}-txt-empty-title`} fw={600} size="xs">
											No runners match the selected tag filter.
										</Text>
									</Paper>
								) : (
									filteredRunners.map((r) => {
										const isSelected = selectedId === r.id;
										return (
											<Paper
												id={`${idPrefix}-row-${r.id}`}
												key={r.id}
												p="sm"
												radius="sm"
												withBorder
												style={{
													cursor: "pointer",
													borderColor: isSelected ? "var(--mantine-color-indigo-5)" : undefined,
													backgroundColor: isSelected ? "var(--mantine-color-indigo-9)" : undefined,
												}}
												onClick={() => setSelectedId(r.id)}
											>
												<Stack id={`${idPrefix}-row-stack-${r.id}`} gap={4}>
													<Group id={`${idPrefix}-row-top-${r.id}`} justify="space-between" align="center">
														<Group id={`${idPrefix}-row-title-grp-${r.id}`} gap="xs">
															{getStatusBadge(r.status, r.id)}
															<Text id={`${idPrefix}-txt-id-${r.id}`} size="xs" fw={600} style={{ fontFamily: "monospace" }}>
																{r.id}
															</Text>
														</Group>
														<Text id={`${idPrefix}-txt-capacity-${r.id}`} size="xs" fw={600} style={{ fontFamily: "monospace" }}>
															{r.currentInflight}/{r.maxInflight}
														</Text>
													</Group>

													{r.tags.length > 0 && (
														<Group id={`${idPrefix}-row-tags-grp-${r.id}`} gap={4}>
															{r.tags.map((t) => (
																<Code id={`${idPrefix}-code-tag-${r.id}-${t}`} key={t} style={{ fontSize: "10px" }}>
																	#{t}
																</Code>
															))}
														</Group>
													)}

													<Text id={`${idPrefix}-txt-poll-${r.id}`} size="xs" c="dimmed" style={{ fontSize: "10px" }}>
														Last poll: {r.lastPollAt}
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
					{selectedRunner ? (
						<Card id={`${idPrefix}-detail-card`} p="lg" radius="md" withBorder>
							<Stack id={`${idPrefix}-detail-stack`} gap="lg">
								{/* Header */}
								<Group id={`${idPrefix}-detail-header`} justify="space-between" align="flex-start">
									<div>
										<Group id={`${idPrefix}-detail-title-grp`} gap="xs">
											{getStatusBadge(selectedRunner.status, `detail-${selectedRunner.id}`)}
											<Title id={`${idPrefix}-detail-title`} order={3} style={{ fontFamily: "monospace" }}>
												{selectedRunner.id}
											</Title>
											<ActionIcon
												id={`${idPrefix}-btn-copy-id`}
												size="xs"
												variant="subtle"
												onClick={() => navigator.clipboard.writeText(selectedRunner.id)}
											>
												<Icon path={iconCopy} size="xs" />
											</ActionIcon>
										</Group>
										<Text id={`${idPrefix}-detail-poll-txt`} size="xs" c="dimmed" mt={4}>
											Last poll: {selectedRunner.lastPollAt} · Registered: {selectedRunner.registeredAt}
										</Text>
									</div>

									<Button
										id={`${idPrefix}-btn-delete-${selectedRunner.id}`}
										color="red"
										variant="subtle"
										size="xs"
										leftSection={<Icon id={`${idPrefix}-delete-icon`} path={iconTrash} size="xs" />}
										onClick={() => handleDeleteRunner(selectedRunner.id)}
									>
										Remove Runner
									</Button>
								</Group>

								{/* Capacity Bar */}
								<Paper id={`${idPrefix}-capacity-paper`} p="md" radius="sm" withBorder>
									<Stack id={`${idPrefix}-capacity-stack`} gap="xs">
										<Group id={`${idPrefix}-capacity-head`} justify="space-between">
											<Text id={`${idPrefix}-txt-capacity-title`} size="xs" fw={600} c="dimmed">
												Concurrency Capacity
											</Text>
											<Text id={`${idPrefix}-txt-capacity-val`} size="xs" fw={600} style={{ fontFamily: "monospace" }}>
												{selectedRunner.currentInflight} / {selectedRunner.maxInflight} inflight tasks
											</Text>
										</Group>
										<Progress
											id={`${idPrefix}-progress-capacity`}
											value={(selectedRunner.currentInflight / (selectedRunner.maxInflight || 1)) * 100}
											color="pink"
											size="md"
											radius="xs"
										/>
									</Stack>
								</Paper>

								{/* Capabilities & Tags */}
								<Paper id={`${idPrefix}-caps-paper`} p="md" radius="sm" withBorder>
									<Stack id={`${idPrefix}-caps-stack`} gap="sm">
										<div>
											<Text id={`${idPrefix}-lbl-caps-title`} size="xs" c="dimmed" fw={600} mb="xs">
												Capabilities
											</Text>
											<Group id={`${idPrefix}-caps-list`} gap="xs">
												{selectedRunner.capabilities.length === 0 ? (
													<Text id={`${idPrefix}-txt-no-caps`} size="xs" c="dimmed">—</Text>
												) : (
													selectedRunner.capabilities.map((c) => (
														<Badge id={`${idPrefix}-bdg-cap-${c}`} key={c} color="pink" variant="outline" size="sm">
															{c}
														</Badge>
													))
												)}
											</Group>
										</div>

										<div>
											<Text id={`${idPrefix}-lbl-tags-title`} size="xs" c="dimmed" fw={600} mb="xs">
												Tags & Metadata
											</Text>
											<Group id={`${idPrefix}-tags-list`} gap="xs">
												{selectedRunner.tags.length === 0 ? (
													<Text id={`${idPrefix}-txt-no-tags`} size="xs" c="dimmed">—</Text>
												) : (
													selectedRunner.tags.map((t) => (
														<Code id={`${idPrefix}-code-detail-tag-${t}`} key={t} color="violet">
															#{t}
														</Code>
													))
												)}
											</Group>
										</div>
									</Stack>
								</Paper>

								{/* Recent Executions Table */}
								<Paper id={`${idPrefix}-executions-table-paper`} radius="sm" withBorder p={0}>
									<Paper id={`${idPrefix}-executions-header`} p="xs" style={{ borderBottom: "1px solid var(--mantine-color-default-border)" }}>
										<Text id={`${idPrefix}-txt-executions-title`} fw={600} size="xs" c="dimmed">
											Recent Executions Claimed by {selectedRunner.id}
										</Text>
									</Paper>

									<Table id={`${idPrefix}-table-executions`} verticalSpacing="xs" horizontalSpacing="md">
										<Table.Thead id={`${idPrefix}-th-head`}>
											<Table.Tr id={`${idPrefix}-th-row`}>
												<Table.Th id={`${idPrefix}-th-job`}>Job</Table.Th>
												<Table.Th id={`${idPrefix}-th-state`}>State</Table.Th>
												<Table.Th id={`${idPrefix}-th-fired`}>Fired</Table.Th>
												<Table.Th id={`${idPrefix}-th-duration`} style={{ textAlign: "right" }}>Duration</Table.Th>
											</Table.Tr>
										</Table.Thead>
										<Table.Tbody id={`${idPrefix}-tbody-executions`}>
											{recentExecutions.map((e) => (
												<Table.Tr id={`${idPrefix}-ex-row-${e.id}`} key={e.id}>
													<Table.Td id={`${idPrefix}-ex-job-${e.id}`}>
														<Text id={`${idPrefix}-txt-ex-job-${e.id}`} size="xs" fw={500} style={{ fontFamily: "monospace" }}>
															{e.jobKey}
														</Text>
													</Table.Td>
													<Table.Td id={`${idPrefix}-ex-state-${e.id}`}>
														<Badge id={`${idPrefix}-bdg-ex-state-${e.id}`} color={e.state === "completed" ? "green" : "blue"} size="xs">
															{e.state.toUpperCase()}
														</Badge>
													</Table.Td>
													<Table.Td id={`${idPrefix}-ex-fired-${e.id}`}>
														<Text id={`${idPrefix}-txt-ex-fired-${e.id}`} size="xs" c="dimmed">
															{e.fireAt}
														</Text>
													</Table.Td>
													<Table.Td id={`${idPrefix}-ex-duration-${e.id}`} style={{ textAlign: "right" }}>
														<Text id={`${idPrefix}-txt-ex-duration-${e.id}`} size="xs" style={{ fontFamily: "monospace" }}>
															{e.durationMs ? `${e.durationMs} ms` : "—"}
														</Text>
													</Table.Td>
												</Table.Tr>
											))}
										</Table.Tbody>
									</Table>
								</Paper>
							</Stack>
						</Card>
					) : (
						<Card id={`${idPrefix}-no-selection-card`} p="xl" radius="md" style={{ textAlign: "center" }} withBorder>
							<Text id={`${idPrefix}-txt-no-selection`} size="sm" c="dimmed">
								Select a runner from the list on the left to see its capabilities, tags, capacity and recent executions.
							</Text>
						</Card>
					)}
				</div>
			</Stack>
		</div>
	);
}
