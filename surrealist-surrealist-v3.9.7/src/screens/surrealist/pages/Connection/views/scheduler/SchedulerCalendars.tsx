import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Code,
	Group,
	Modal,
	Paper,
	Stack,
	Table,
	Text,
	TextInput,
	Textarea,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconClock,
	iconEdit,
	iconErrorCircle,
	iconPlus,
	iconRefresh,
	iconTrash,
} from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerCalendarsProps {
	idPrefix?: string;
}

export interface CalendarDefinitionRecord {
	id: string;
	name: string;
	timezone: string;
	rules: string[];
	managedBy: "api" | "dsl";
	createdAt?: string;
}

type RulesMode = "builder" | "advanced";

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

export function SchedulerCalendars({ idPrefix = "scheduler-calendars" }: SchedulerCalendarsProps) {
	const [calModalOpen, setCalModalOpen] = useState(false);
	const [editingCalendar, setEditingCalendar] = useState<CalendarDefinitionRecord | null>(null);

	// Form State
	const [calId, setCalId] = useState("");
	const [calName, setCalName] = useState("");
	const [calTz, setCalTz] = useState("UTC");
	const [calRulesText, setCalRulesText] = useState("include monday-friday 09:00-18:00\nexclude 2026-12-25");
	const [rulesMode, setRulesMode] = useState<RulesMode>("builder");

	// Initial Default Mock / Seeded Data
	const [calendars, setCalendars] = useState<CalendarDefinitionRecord[]>([
		{
			id: "france_business",
			name: "France - Jours Ouvrés",
			timezone: "Europe/Paris",
			rules: ["include monday-friday 09:00-18:00", "exclude 2026-12-25", "exclude 2026-01-01"],
			managedBy: "api",
			createdAt: new Date().toISOString(),
		},
		{
			id: "us_trading",
			name: "US Stock Market Hours",
			timezone: "America/New_York",
			rules: ["include monday-friday 09:30-16:00", "exclude 2026-07-04"],
			managedBy: "api",
			createdAt: new Date(Date.now() - 3600000).toISOString(),
		},
		{
			id: "24x7_ops",
			name: "24x7 Operations Window",
			timezone: "UTC",
			rules: ["include * 00:00-23:59"],
			managedBy: "dsl",
			createdAt: new Date(Date.now() - 86400000).toISOString(),
		},
	]);

	// Live SurrealDB Data Fetcher
	const fetchLiveCalendars = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_calendar ORDER BY created_at DESC;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: CalendarDefinitionRecord[] = raw.map((c: any) => ({
					id: safeString(c.id).replace("scheduler_calendar:", ""),
					name: safeString(c.name) || "Untitled Calendar",
					timezone: safeString(c.timezone) || "UTC",
					rules: Array.isArray(c.rules) ? c.rules.map((r: any) => safeString(r)) : typeof c.rules === "string" ? [c.rules] : [],
					managedBy: (safeString(c.managed_by) as "api" | "dsl") || "api",
					createdAt: safeString(c.created_at) || new Date().toISOString(),
				}));
				setCalendars(mapped);
			}
		} catch (err) {
			console.warn("SurrealDB calendars live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveCalendars();
	}, []);

	// Reset Form Dialog
	const resetForm = () => {
		setCalId("");
		setCalName("");
		setCalTz("UTC");
		setCalRulesText("include monday-friday 09:00-18:00\nexclude 2026-12-25");
		setRulesMode("builder");
		setEditingCalendar(null);
	};

	// Open Edit Dialog
	const handleOpenEdit = (cal: CalendarDefinitionRecord) => {
		setEditingCalendar(cal);
		setCalId(cal.id);
		setCalName(cal.name);
		setCalTz(cal.timezone || "UTC");
		setCalRulesText(cal.rules.join("\n"));
		setRulesMode("advanced");
		setCalModalOpen(true);
	};

	// Save / Create Calendar Mutation
	const handleSaveCalendar = async () => {
		if (!calName.trim()) return;

		const targetId = editingCalendar ? editingCalendar.id : (calId.trim() || calName.trim().toLowerCase().replace(/\s+/g, "_"));
		const parsedRules = calRulesText.split("\n").map((r) => r.trim()).filter(Boolean);

		const updatedCal: CalendarDefinitionRecord = {
			id: targetId,
			name: calName.trim(),
			timezone: calTz.trim() || "UTC",
			rules: parsedRules,
			managedBy: editingCalendar ? editingCalendar.managedBy : "api",
			createdAt: editingCalendar?.createdAt || new Date().toISOString(),
		};

		setCalendars((prev) => [...prev.filter((c) => c.id !== targetId), updatedCal]);
		setCalModalOpen(false);
		resetForm();

		// Live SurrealDB Mutation
		try {
			const recordId = `scheduler_calendar:${targetId}`;
			await executeQuery(
				`UPSERT ${recordId} SET name = $name, timezone = $timezone, rules = $rules, managed_by = $managedBy, updated_at = time::now();`,
				{
					name: calName.trim(),
					timezone: calTz.trim() || "UTC",
					rules: parsedRules,
					managedBy: updatedCal.managedBy,
				}
			);
			fetchLiveCalendars();
		} catch (err) {
			console.warn("Live calendar upsert warning:", err);
		}
	};

	// Delete Calendar Mutation
	const handleDeleteCalendar = async (id: string) => {
		setCalendars((prev) => prev.filter((c) => c.id !== id));
		try {
			await executeQuery(`DELETE scheduler_calendar:${id};`);
			fetchLiveCalendars();
		} catch (err) {
			console.warn("Live calendar delete warning:", err);
		}
	};

	// Adopt DSL Calendar to API Store
	const handleAdoptCalendar = async (cal: CalendarDefinitionRecord) => {
		const updated: CalendarDefinitionRecord = { ...cal, managedBy: "api" };
		setCalendars((prev) => prev.map((c) => (c.id === cal.id ? updated : c)));
		try {
			await executeQuery(`UPDATE scheduler_calendar:${cal.id} SET managed_by = 'api';`);
			fetchLiveCalendars();
		} catch (err) {
			console.warn("Live calendar adopt warning:", err);
		}
	};

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-stack`} gap="lg">
				{/* Header Section */}
				<div id={`${idPrefix}-header-container`}>
					<Group id={`${idPrefix}-header-group`} justify="space-between" align="center">
						<div id={`${idPrefix}-header-text`}>
							<Title id={`${idPrefix}-title`} order={2}>
								Calendars
							</Title>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								{calendars.length} calendar{calendars.length === 1 ? "" : "s"} defined · attach to jobs to gate firing (`fn::scheduler::calendar_*`).
							</Text>
						</div>

						<Group id={`${idPrefix}-header-actions`} gap="sm">
							<Button
								id={`${idPrefix}-btn-refresh`}
								variant="default"
								leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
								onClick={fetchLiveCalendars}
							>
								Refresh Live Data
							</Button>
							<Button
								id={`${idPrefix}-btn-add-cal`}
								color="pink"
								leftSection={<Icon id={`${idPrefix}-plus-icon`} path={iconPlus} />}
								onClick={() => {
									resetForm();
									setCalModalOpen(true);
								}}
							>
								Add Calendar
							</Button>
						</Group>
					</Group>
				</div>

				{/* Cards List of Calendars */}
				<Stack id={`${idPrefix}-cards-stack`} gap="md">
					{calendars.length === 0 ? (
						<Paper id={`${idPrefix}-empty-paper`} p="xl" withBorder radius="md" style={{ textAlign: "center" }}>
							<Text id={`${idPrefix}-txt-empty-title`} fw={600} size="sm">
								No calendars defined
							</Text>
							<Text id={`${idPrefix}-txt-empty-desc`} size="xs" c="dimmed" mt={4}>
								Calendars let you restrict job execution to specific working windows and holiday dates.
							</Text>
							<Button
								id={`${idPrefix}-btn-empty-add`}
								color="pink"
								size="xs"
								mt="md"
								onClick={() => {
									resetForm();
									setCalModalOpen(true);
								}}
							>
								Add Calendar
							</Button>
						</Paper>
					) : (
						calendars.map((cal) => {
							const isDsl = cal.managedBy === "dsl";
							return (
								<Card id={`${idPrefix}-card-${cal.id}`} key={cal.id} p="md" radius="md" withBorder>
									<Group id={`${idPrefix}-card-group-${cal.id}`} justify="space-between" align="flex-start" wrap="nowrap">
										<Stack id={`${idPrefix}-card-info-stack-${cal.id}`} gap={6} style={{ flex: 1, minWidth: 0 }}>
											<Group id={`${idPrefix}-card-header-${cal.id}`} gap="xs" align="center">
												<Text id={`${idPrefix}-txt-name-${cal.id}`} fw={600} size="sm" style={{ fontFamily: "monospace" }}>
													{cal.name}
												</Text>
												<Badge id={`${idPrefix}-bdg-tz-${cal.id}`} color="gray" variant="light" size="xs">
													{cal.timezone}
												</Badge>
												<Badge
													id={`${idPrefix}-bdg-managed-${cal.id}`}
													color={isDsl ? "violet" : "blue"}
													variant="filled"
													size="xs"
												>
													{cal.managedBy.toUpperCase()}
												</Badge>
											</Group>

											{/* Rules List Preview */}
											{cal.rules && cal.rules.length > 0 && (
												<Group id={`${idPrefix}-rules-group-${cal.id}`} gap={6} mt={2} wrap="wrap">
													{cal.rules.map((r, i) => (
														<Code id={`${idPrefix}-code-rule-${cal.id}-${i}`} key={i} color="violet" style={{ fontSize: "11px" }}>
															{r}
														</Code>
													))}
												</Group>
											)}

											{cal.createdAt && (
												<Text id={`${idPrefix}-txt-created-${cal.id}`} size="xs" c="dimmed" mt={4}>
													Created {cal.createdAt}
												</Text>
											)}
										</Stack>

										{/* Card Action Buttons */}
										<Group id={`${idPrefix}-card-actions-${cal.id}`} gap="xs">
											{isDsl && (
												<Tooltip id={`${idPrefix}-tip-adopt-${cal.id}`} label="Adopt calendar to API store to allow direct edits">
													<Button
														id={`${idPrefix}-btn-adopt-${cal.id}`}
														variant="light"
														color="violet"
														size="xs"
														onClick={() => handleAdoptCalendar(cal)}
													>
														Adopt to API
													</Button>
												</Tooltip>
											)}
											<Button
												id={`${idPrefix}-btn-edit-${cal.id}`}
												variant="subtle"
												color="pink"
												size="xs"
												disabled={isDsl}
												onClick={() => handleOpenEdit(cal)}
											>
												Edit
											</Button>
											<Button
												id={`${idPrefix}-btn-delete-${cal.id}`}
												variant="subtle"
												color="red"
												size="xs"
												disabled={isDsl}
												onClick={() => handleDeleteCalendar(cal.id)}
											>
												Delete
											</Button>
										</Group>
									</Group>
								</Card>
							);
						})
					)}
				</Stack>

				{/* MODAL: ADD / EDIT CALENDAR */}
				<Modal
					id={`${idPrefix}-modal-calendar`}
					opened={calModalOpen}
					onClose={() => {
						setCalModalOpen(false);
						resetForm();
					}}
					title={editingCalendar ? `Edit Calendar — ${editingCalendar.name}` : "Add Calendar"}
					centered
				>
					<Stack id={`${idPrefix}-modal-cal-stack`} gap="md">
						{!editingCalendar && (
							<TextInput
								id={`${idPrefix}-input-cal-id`}
								label="Calendar ID / Key"
								placeholder="eu-business-hours"
								value={calId}
								onChange={(e) => setCalId(e.currentTarget.value)}
							/>
						)}

						<TextInput
							id={`${idPrefix}-input-cal-name`}
							label="Calendar Display Name"
							placeholder="France - Jours Ouvrés"
							value={calName}
							onChange={(e) => setCalName(e.currentTarget.value)}
							required
						/>

						<TextInput
							id={`${idPrefix}-input-cal-tz`}
							label="Timezone (IANA format)"
							placeholder="Europe/Paris or UTC"
							value={calTz}
							onChange={(e) => setCalTz(e.currentTarget.value)}
						/>

						{/* Rules Mode Toggle & Input */}
						<div>
							<Group id={`${idPrefix}-rules-mode-header`} justify="space-between" mb="xs">
								<Text id={`${idPrefix}-lbl-rules-title`} size="xs" fw={500}>
									Rules & Opening Windows
								</Text>
								<Group id={`${idPrefix}-rules-mode-toggle`} gap={4}>
									<Button
										id={`${idPrefix}-btn-mode-builder`}
										size="xs"
										variant={rulesMode === "builder" ? "filled" : "outline"}
										color="pink"
										onClick={() => setRulesMode("builder")}
									>
										Builder
									</Button>
									<Button
										id={`${idPrefix}-btn-mode-advanced`}
										size="xs"
										variant={rulesMode === "advanced" ? "filled" : "outline"}
										color="pink"
										onClick={() => setRulesMode("advanced")}
									>
										Advanced (raw)
									</Button>
								</Group>
							</Group>

							<Textarea
								id={`${idPrefix}-input-cal-rules-text`}
								placeholder={
									rulesMode === "builder"
										? "include monday-friday 09:00-18:00\nexclude 2026-12-25"
										: 'Croniqfile DSL — e.g.\ninclude monday-friday 09:00-18:00\nexclude 2026-01-01\nleave empty for "always on"'
								}
								rows={4}
								value={calRulesText}
								onChange={(e) => setCalRulesText(e.currentTarget.value)}
								style={{ fontFamily: "monospace" }}
							/>
						</div>

						<Group id={`${idPrefix}-modal-cal-actions`} justify="flex-end" mt="md">
							<Button
								id={`${idPrefix}-btn-cancel-cal`}
								variant="subtle"
								onClick={() => {
									setCalModalOpen(false);
									resetForm();
								}}
							>
								Cancel
							</Button>
							<Button
								id={`${idPrefix}-btn-submit-cal`}
								color="pink"
								disabled={!calName.trim()}
								onClick={handleSaveCalendar}
							>
								{editingCalendar ? "Save Changes" : "Save Calendar"}
							</Button>
						</Group>
					</Stack>
				</Modal>
			</Stack>
		</div>
	);
}
