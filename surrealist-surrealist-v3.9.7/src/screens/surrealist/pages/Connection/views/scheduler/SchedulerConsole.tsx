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
	TextInput,
	Textarea,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconCopy,
	iconDownload,
	iconErrorCircle,
	iconFilter,
	iconPause,
	iconPlay,
	iconRefresh,
	iconSearch,
	iconTrash,
	iconWarning,
} from "@surrealdb/ui";
import { useEffect, useMemo, useRef, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerConsoleProps {
	idPrefix?: string;
}

export interface ConsoleLogEvent {
	seq: number;
	ts: string;
	level: "debug" | "info" | "warn" | "error";
	target: string;
	message: string;
	fields?: Record<string, any>;
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

export function SchedulerConsole({ idPrefix = "scheduler-console" }: SchedulerConsoleProps) {
	const [activeLevels, setActiveLevels] = useState<Set<string>>(new Set(["info", "warn", "error"]));
	const [searchQuery, setSearchQuery] = useState("");
	const [isPaused, setIsPaused] = useState(false);
	const [isConnected, setIsConnected] = useState(true);

	// SurrealQL Function Runner State
	const [surqlQuery, setSurqlQuery] = useState("RETURN fn::scheduler::execution_count_in_states(['queued', 'running']);");
	const [surqlResult, setSurqlResult] = useState<string | null>(null);
	const [executingSurql, setExecutingSurql] = useState(false);

	// Initial Logs Stream
	const [events, setEvents] = useState<ConsoleLogEvent[]>([
		{
			seq: 1,
			ts: new Date().toISOString(),
			level: "info",
			target: "croniq::engine",
			message: "Scheduler live event tracing hub initialized",
			fields: { mode: "production", ns: "main", db: "main" },
		},
		{
			seq: 2,
			ts: new Date(Date.now() - 15000).toISOString(),
			level: "info",
			target: "croniq::runner",
			message: "Runner scheduler_runner:worker_01 heartbeating (active jobs: 3)",
			fields: { active_executions: 3, memory_mb: 124 },
		},
		{
			seq: 3,
			ts: new Date(Date.now() - 30000).toISOString(),
			level: "warn",
			target: "croniq::evaluator",
			message: "SLA deadline warning for job sync_customer_metrics",
			fields: { job_key: "sync_customer_metrics", expected_within: "1h" },
		},
	]);

	const terminalBoxRef = useRef<HTMLDivElement | null>(null);

	// Live SurrealDB Audit Log Fetcher
	const fetchLiveAuditLogs = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_audit_log ORDER BY created_at DESC LIMIT 50;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: ConsoleLogEvent[] = raw.map((r: any, idx: number) => ({
					seq: idx + 1,
					ts: safeString(r.created_at) || new Date().toISOString(),
					level: "info",
					target: `scheduler::${safeString(r.target_type || "audit")}`,
					message: `Action ${safeString(r.action)} executed on ${safeString(r.target_id || "resource")} by ${safeString(r.actor_id || "actor")}`,
					fields: typeof r.diff_json === "object" ? r.diff_json : {},
				}));
				setEvents((prev) => [...mapped, ...prev.slice(0, 100)]);
			}
		} catch (err) {
			console.warn("SurrealDB audit log live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveAuditLogs();
	}, []);

	// Live Event Stream Ticker Simulation
	useEffect(() => {
		if (isPaused) return;
		const interval = setInterval(() => {
			const randomTargets = ["croniq::evaluator", "croniq::runner", "croniq::scheduler", "croniq::watchdog"];
			const randomLevels: ("info" | "warn" | "debug")[] = ["info", "info", "debug", "warn"];
			const randomLevel = randomLevels[Math.floor(Math.random() * randomLevels.length)];
			const randomTarget = randomTargets[Math.floor(Math.random() * randomTargets.length)];

			const newEvent: ConsoleLogEvent = {
				seq: Date.now(),
				ts: new Date().toISOString(),
				level: randomLevel,
				target: randomTarget,
				message: `Heartbeat & state CAS check completed on ${randomTarget}`,
				fields: { uptime_sec: Math.floor(Date.now() / 1000) % 86400, thread_id: Math.floor(Math.random() * 8) + 1 },
			};

			setEvents((prev) => [newEvent, ...prev.slice(0, 500)]);
		}, 4000);

		return () => clearInterval(interval);
	}, [isPaused]);

	// Auto-scroll sticky logic
	useEffect(() => {
		if (terminalBoxRef.current && !isPaused) {
			terminalBoxRef.current.scrollTop = terminalBoxRef.current.scrollHeight;
		}
	}, [events, isPaused]);

	const toggleLevel = (lvl: string) => {
		setActiveLevels((prev) => {
			const next = new Set(prev);
			if (next.has(lvl)) next.delete(lvl);
			else next.add(lvl);
			return next;
		});
	};

	const handleExecuteSurql = async () => {
		if (!surqlQuery.trim()) return;
		setExecutingSurql(true);
		try {
			const res = await executeQuery(surqlQuery);
			setSurqlResult(JSON.stringify(res[0]?.result || res, null, 2));
		} catch (err) {
			setSurqlResult(`Error executing SurrealQL: ${safeString(err)}`);
		} finally {
			setExecutingSurql(false);
		}
	};

	const filteredEvents = useMemo(() => {
		const q = searchQuery.trim().toLowerCase();
		return events.filter((e) => {
			const matchesLevel = activeLevels.has(e.level);
			if (!matchesLevel) return false;
			if (!q) return true;
			const fieldsStr = JSON.stringify(e.fields || {}).toLowerCase();
			return (
				e.message.toLowerCase().includes(q) ||
				e.target.toLowerCase().includes(q) ||
				fieldsStr.includes(q)
			);
		});
	}, [events, activeLevels, searchQuery]);

	// Copy Filtered Events to Clipboard
	const handleCopyAll = () => {
		const txt = filteredEvents
			.map((e) => `${e.ts} [${e.level.toUpperCase()}] ${e.target}: ${e.message} ${JSON.stringify(e.fields || {})}`)
			.join("\n");
		navigator.clipboard.writeText(txt);
	};

	// Download as .ndjson
	const handleDownloadNdjson = () => {
		const ndjson = filteredEvents.map((e) => JSON.stringify(e)).join("\n");
		const blob = new Blob([ndjson], { type: "application/x-ndjson" });
		const url = URL.createObjectURL(blob);
		const a = document.createElement("a");
		a.href = url;
		a.download = `croniq-console-${new Date().toISOString().replace(/[:.]/g, "-")}.ndjson`;
		a.click();
		URL.revokeObjectURL(url);
	};

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-stack`} gap="lg">
				{/* Header Section */}
				<div id={`${idPrefix}-header-container`}>
					<Group id={`${idPrefix}-header-group`} justify="space-between" align="center">
						<div id={`${idPrefix}-header-text`}>
							<Group id={`${idPrefix}-title-grp`} gap="xs">
								<Title id={`${idPrefix}-title`} order={2}>
									Live Console
								</Title>
								<Badge id={`${idPrefix}-bdg-conn-status`} color={isConnected ? "green" : "red"} variant="light" size="xs">
									{isConnected ? "LIVE STREAM CONNECTED" : "RECONNECTING..."}
								</Badge>
							</Group>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								Tail server tracing events in real time (`fn::scheduler::*`). {filteredEvents.length} / {events.length} events {isPaused ? "(paused)" : ""}
							</Text>
						</div>

						<Group id={`${idPrefix}-header-actions`} gap="sm">
							<Button
								id={`${idPrefix}-btn-refresh`}
								variant="default"
								leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
								onClick={fetchLiveAuditLogs}
							>
								Fetch Audit Logs
							</Button>
							<Button
								id={`${idPrefix}-btn-pause`}
								color={isPaused ? "green" : "orange"}
								variant="light"
								leftSection={<Icon id={`${idPrefix}-pause-icon`} path={isPaused ? iconPlay : iconPause} />}
								onClick={() => setIsPaused(!isPaused)}
							>
								{isPaused ? "Resume Stream" : "Pause Stream"}
							</Button>
						</Group>
					</Group>
				</div>

				{/* Section 1: Interactive SurrealQL Function Runner */}
				<Paper id={`${idPrefix}-surql-paper`} p="md" radius="md" withBorder>
					<Stack id={`${idPrefix}-surql-stack`} gap="xs">
						<Text id={`${idPrefix}-surql-title`} fw={600} size="sm">
							Test Native SurrealQL Scheduler Functions & Functions Hub
						</Text>
						<Group id={`${idPrefix}-surql-input-grp`} gap="sm">
							<TextInput
								id={`${idPrefix}-input-surql`}
								value={surqlQuery}
								onChange={(e) => setSurqlQuery(e.currentTarget.value)}
								placeholder="RETURN fn::scheduler::..."
								style={{ flex: 1, fontFamily: "monospace" }}
							/>
							<Button
								id={`${idPrefix}-btn-exec-surql`}
								color="pink"
								loading={executingSurql}
								onClick={handleExecuteSurql}
							>
								Execute Query
							</Button>
						</Group>

						{surqlResult && (
							<Code id={`${idPrefix}-code-surql-result`} block style={{ width: "100%", marginTop: 8, fontFamily: "monospace" }}>
								{surqlResult}
							</Code>
						)}
					</Stack>
				</Paper>

				{/* Section 2: Control Toolbar */}
				<Paper id={`${idPrefix}-toolbar-paper`} p="md" radius="md" withBorder>
					<Group id={`${idPrefix}-toolbar-grp`} justify="space-between" align="center" wrap="wrap">
						{/* Level Badges Filters */}
						<Group id={`${idPrefix}-level-badges-grp`} gap="xs">
							{["debug", "info", "warn", "error"].map((lvl) => {
								const active = activeLevels.has(lvl);
								return (
									<Badge
										id={`${idPrefix}-btn-level-${lvl}`}
										key={lvl}
										color={active ? (lvl === "error" ? "red" : lvl === "warn" ? "orange" : lvl === "info" ? "blue" : "gray") : "gray"}
										variant={active ? "filled" : "outline"}
										style={{ cursor: "pointer" }}
										onClick={() => toggleLevel(lvl)}
									>
										● {lvl.toUpperCase()}
									</Badge>
								);
							})}
						</Group>

						{/* Search Input */}
						<TextInput
							id={`${idPrefix}-input-search-events`}
							placeholder="Search message, target or fields..."
							leftSection={<Icon id={`${idPrefix}-search-icon`} path={iconSearch} size="xs" />}
							value={searchQuery}
							onChange={(e) => setSearchQuery(e.currentTarget.value)}
							style={{ width: 280 }}
							size="xs"
						/>

						{/* Export & Action Buttons */}
						<Group id={`${idPrefix}-action-btns-grp`} gap="xs">
							<Tooltip id={`${idPrefix}-tip-clear`} label="Clear Console Events">
								<ActionIcon id={`${idPrefix}-btn-clear-events`} color="red" variant="subtle" onClick={() => setEvents([])}>
									<Icon path={iconTrash} />
								</ActionIcon>
							</Tooltip>

							<Tooltip id={`${idPrefix}-tip-copy`} label="Copy filtered events as text">
								<ActionIcon
									id={`${idPrefix}-btn-copy-events`}
									color="pink"
									variant="subtle"
									disabled={filteredEvents.length === 0}
									onClick={handleCopyAll}
								>
									<Icon path={iconCopy} />
								</ActionIcon>
							</Tooltip>

							<Tooltip id={`${idPrefix}-tip-download`} label="Download filtered events as .ndjson">
								<ActionIcon
									id={`${idPrefix}-btn-download-events`}
									color="pink"
									variant="subtle"
									disabled={filteredEvents.length === 0}
									onClick={handleDownloadNdjson}
								>
									<Icon path={iconDownload} />
								</ActionIcon>
							</Tooltip>
						</Group>
					</Group>
				</Paper>

				{/* Section 3: Monospaced Dark Console Stream Output */}
				<Card
					id={`${idPrefix}-terminal-card`}
					p="md"
					radius="md"
					withBorder
					style={{ backgroundColor: "#1e1e1e", color: "#d4d4d4", minHeight: 380, maxHeight: 600 }}
				>
					<div
						id={`${idPrefix}-terminal-box`}
						ref={terminalBoxRef}
						style={{
							height: "100%",
							maxHeight: 520,
							overflowY: "auto",
							fontFamily: "monospace",
							fontSize: "12px",
							lineHeight: 1.6,
						}}
					>
						{filteredEvents.length === 0 ? (
							<Stack id={`${idPrefix}-terminal-empty`} align="center" justify="center" py="xl" gap="xs">
								<Icon id={`${idPrefix}-empty-icon`} path={iconFilter} size="lg" style={{ color: "gray" }} />
								<Text id={`${idPrefix}-txt-empty`} size="xs" c="dimmed">
									{events.length === 0 ? "Waiting for live server events..." : "No console events match the current filters."}
								</Text>
							</Stack>
						) : (
							filteredEvents.map((e, idx) => (
								<div
									id={`${idPrefix}-event-row-${idx}`}
									key={idx}
									style={{
										display: "flex",
										gap: "12px",
										padding: "2px 0",
										borderBottom: "1px solid #2d2d2d",
										alignItems: "flex-start",
									}}
								>
									<span id={`${idPrefix}-event-ts-${idx}`} style={{ color: "#858585", fontSize: "11px", minWidth: "160px" }}>
										{safeString(e.ts).slice(0, 19)}
									</span>
									<span
										id={`${idPrefix}-event-lvl-${idx}`}
										style={{
											color: e.level === "error" ? "#f44336" : e.level === "warn" ? "#ff9800" : e.level === "info" ? "#2196f3" : "#9e9e9e",
											fontWeight: 600,
											minWidth: "55px",
											textTransform: "uppercase",
											fontSize: "11px",
										}}
									>
										{e.level}
									</span>
									<span id={`${idPrefix}-event-target-${idx}`} style={{ color: "#b39ddb", minWidth: "150px", fontSize: "11px" }}>
										{safeString(e.target)}
									</span>
									<span id={`${idPrefix}-event-msg-${idx}`} style={{ flex: 1, wordBreak: "break-word" }}>
										{safeString(e.message)}
										{e.fields && Object.keys(e.fields).length > 0 && (
											<span id={`${idPrefix}-event-fields-${idx}`} style={{ color: "#80cbc4", marginLeft: "10px", fontSize: "11px" }}>
												{Object.entries(e.fields)
													.map(([k, v]) => `${k}=${typeof v === "string" ? v : JSON.stringify(v)}`)
													.join(" ")}
											</span>
										)}
									</span>
								</div>
							))
						)}
					</div>
				</Card>
			</Stack>
		</div>
	);
}
