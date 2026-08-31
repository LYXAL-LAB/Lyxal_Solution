import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Checkbox,
	Code,
	Group,
	Modal,
	Paper,
	PasswordInput,
	SimpleGrid,
	Stack,
	Table,
	Tabs,
	Text,
	TextInput,
	Title,
	Tooltip,
} from "@mantine/core";
import {
	Icon,
	iconCheck,
	iconCopy,
	iconEdit,
	iconErrorCircle,
	iconPlus,
	iconRefresh,
	iconTrash,
} from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

interface SchedulerSettingsProps {
	idPrefix?: string;
}

export interface ApiClientRecord {
	client_id: string;
	name: string;
	is_active: boolean;
	scopes: string[];
}

export interface UserRecord {
	id: string;
	name: string;
	email: string;
	role: "admin" | "operator" | "viewer";
	createdAt: string;
}

export interface AuditRecord {
	id: string;
	ts: string;
	actorType: string;
	actorId: string;
	action: string;
	targetType: string;
	targetId: string;
	ipAddress?: string;
	diffJson?: Record<string, any>;
}

// Scope groups matching Croniq SCOPE_GROUPS
const SCOPE_GROUPS = [
	{
		label: "Admin",
		scopes: [{ value: "admin", hint: "Grants every scope below" }],
	},
	{
		label: "Jobs",
		scopes: [
			{ value: "jobs:read" },
			{ value: "jobs:write" },
			{ value: "jobs:register", hint: "POST /v1/jobs/register (runner SDK)" },
			{ value: "jobs:trigger", hint: "POST /v1/trigger (manual fire)" },
		],
	},
	{
		label: "Schedules",
		scopes: [{ value: "schedules:read" }, { value: "schedules:write" }],
	},
	{
		label: "Calendars",
		scopes: [{ value: "calendars:read" }, { value: "calendars:write" }],
	},
	{
		label: "Executions",
		scopes: [{ value: "executions:read", hint: "Includes /executions/{id}/logs" }],
	},
	{
		label: "Dead letters",
		scopes: [{ value: "dead-letters:read" }, { value: "dead-letters:write", hint: "Replay + delete" }],
	},
	{
		label: "Runners",
		scopes: [
			{ value: "runners:read", hint: "Includes /runners/stream (SSE)" },
			{ value: "runners:write" },
			{ value: "runners:heartbeat" },
		],
	},
	{
		label: "Runner pull-protocol",
		scopes: [
			{ value: "work:poll" },
			{ value: "work:ack" },
			{ value: "work:renew" },
			{ value: "work:events" },
		],
	},
	{
		label: "Identity / auth management",
		scopes: [{ value: "api-clients:admin" }, { value: "api-keys:admin" }],
	},
];

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

export function SchedulerSettings({ idPrefix = "scheduler-settings" }: SchedulerSettingsProps) {
	const [activeTab, setActiveTab] = useState<string>("clients");

	// Profile State
	const [profName, setProfName] = useState("Root Operator");
	const [profEmail, setProfEmail] = useState("root@lyxal.internal");
	const [currentPass, setCurrentPass] = useState("");
	const [newPass, setNewPass] = useState("");
	const [confirmPass, setConfirmPass] = useState("");
	const [passSuccess, setPassSuccess] = useState(false);

	// Users State
	const [users, setUsers] = useState<UserRecord[]>([
		{ id: "usr_01", name: "Root Operator", email: "root@lyxal.internal", role: "admin", createdAt: "2026-07-01" },
		{ id: "usr_02", name: "Dev Engineer", email: "dev@lyxal.internal", role: "operator", createdAt: "2026-07-15" },
	]);
	const [userModalOpen, setUserModalOpen] = useState(false);
	const [newUserName, setNewUserName] = useState("");
	const [newUserEmail, setNewUserEmail] = useState("");
	const [newUserRole, setNewUserRole] = useState<"admin" | "operator" | "viewer">("operator");

	// API Clients State
	const [apiClients, setApiClients] = useState<ApiClientRecord[]>([
		{ client_id: "client_runner_prod", name: "Production Runner SDK Node", is_active: true, scopes: ["jobs:read", "jobs:register", "work:poll", "work:ack"] },
		{ client_id: "client_analytics_ingest", name: "Analytics Metrics Pipeline", is_active: true, scopes: ["jobs:trigger", "executions:read"] },
		{ client_id: "client_admin_cli", name: "Croniq Operator CLI", is_active: true, scopes: ["admin"] },
	]);
	const [clientModalOpen, setClientModalOpen] = useState(false);
	const [editingClient, setEditingClient] = useState<ApiClientRecord | null>(null);
	const [clientName, setClientName] = useState("");
	const [selectedScopes, setSelectedScopes] = useState<string[]>(["jobs:read", "executions:read"]);
	const [issuedKey, setIssuedKey] = useState<{ rawKey: string; keyId: string } | null>(null);

	// Audit Logs State
	const [auditLogs, setAuditLogs] = useState<AuditRecord[]>([
		{
			id: "audit_setting_01",
			ts: new Date().toISOString(),
			actorType: "user",
			actorId: "operator_root",
			action: "api_client.created",
			targetType: "api_client",
			targetId: "client_runner_prod",
			ipAddress: "127.0.0.1",
			diffJson: { scopes: ["jobs:read", "jobs:register", "work:poll"] },
		},
		{
			id: "audit_setting_02",
			ts: new Date(Date.now() - 7200000).toISOString(),
			actorType: "user",
			actorId: "admin",
			action: "user.role_updated",
			targetType: "user",
			targetId: "dev_user_01",
			ipAddress: "192.168.1.50",
			diffJson: { role: "operator" },
		},
	]);

	// Fetch Live Audit Logs
	const fetchLiveAudit = async () => {
		try {
			const res = await executeQuery("SELECT * FROM scheduler_audit_log ORDER BY created_at DESC LIMIT 50;");
			const raw = res[0]?.result;
			if (Array.isArray(raw) && raw.length > 0) {
				const mapped: AuditRecord[] = raw.map((r: any) => ({
					id: safeString(r.id).replace("scheduler_audit_log:", ""),
					ts: safeString(r.created_at) || new Date().toISOString(),
					actorType: safeString(r.actor_type) || "user",
					actorId: safeString(r.actor_id) || "system",
					action: safeString(r.action) || "audit.event",
					targetType: safeString(r.target_type) || "resource",
					targetId: safeString(r.target_id) || "target",
					ipAddress: r.ip_address ? safeString(r.ip_address) : undefined,
					diffJson: typeof r.diff_json === "object" ? r.diff_json : undefined,
				}));
				setAuditLogs(mapped);
			}
		} catch (err) {
			console.warn("SurrealDB audit log live fetch fallback:", err);
		}
	};

	useEffect(() => {
		fetchLiveAudit();
	}, []);

	// Password Update Handler
	const handleUpdatePassword = () => {
		if (!newPass || newPass !== confirmPass) return;
		setPassSuccess(true);
		setCurrentPass("");
		setNewPass("");
		setConfirmPass("");
		setTimeout(() => setPassSuccess(false), 3000);
	};

	// Add User Handler
	const handleAddUser = () => {
		if (!newUserName.trim() || !newUserEmail.trim()) return;
		const newUser: UserRecord = {
			id: `usr_${Date.now()}`,
			name: newUserName.trim(),
			email: newUserEmail.trim(),
			role: newUserRole,
			createdAt: new Date().toISOString().slice(0, 10),
		};
		setUsers((prev) => [...prev, newUser]);
		setUserModalOpen(false);
		setNewUserName("");
		setNewUserEmail("");
		setNewUserRole("operator");
	};

	// Save Client Handler
	const handleSaveClient = () => {
		if (!clientName.trim() || selectedScopes.length === 0) return;
		const targetId = editingClient ? editingClient.client_id : `client_${clientName.trim().toLowerCase().replace(/\s+/g, "_")}`;
		const newRecord: ApiClientRecord = {
			client_id: targetId,
			name: clientName.trim(),
			is_active: true,
			scopes: selectedScopes,
		};
		setApiClients((prev) => [...prev.filter((c) => c.client_id !== targetId), newRecord]);
		setClientModalOpen(false);
		setEditingClient(null);
		setClientName("");
		setSelectedScopes(["jobs:read", "executions:read"]);
	};

	// Issue Key Handler
	const handleIssueToken = (client: ApiClientRecord) => {
		const rawKey = `croniq_${Math.random().toString(36).substring(2)}${Math.random().toString(36).substring(2)}`;
		const keyId = `key_${Math.random().toString(36).substring(2, 10)}`;
		setIssuedKey({ rawKey, keyId });
	};

	// Toggle Scope Helper
	const toggleScope = (scope: string) => {
		setSelectedScopes((prev) => (prev.includes(scope) ? prev.filter((s) => s !== scope) : [...prev, scope]));
	};

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", padding: "1.5rem" }}>
			<Stack id={`${idPrefix}-stack`} gap="lg">
				{/* Top Header */}
				<div id={`${idPrefix}-header-container`}>
					<Group id={`${idPrefix}-header-group`} justify="space-between" align="center">
						<div id={`${idPrefix}-header-text`}>
							<Title id={`${idPrefix}-title`} order={2}>
								Settings
							</Title>
							<Text id={`${idPrefix}-subtitle`} c="dimmed" size="sm" mt={4}>
								Profile, users, API clients and audit trail (`fn::scheduler::*`).
							</Text>
						</div>

						<Button
							id={`${idPrefix}-btn-refresh`}
							variant="default"
							leftSection={<Icon id={`${idPrefix}-refresh-icon`} path={iconRefresh} />}
							onClick={fetchLiveAudit}
						>
							Refresh Audit Logs
						</Button>
					</Group>
				</div>

				{/* Navigation Sub-Tabs */}
				<Tabs id={`${idPrefix}-tabs`} value={activeTab} onChange={(val) => setActiveTab(val || "clients")}>
					<Tabs.List id={`${idPrefix}-tabs-list`}>
						<Tabs.Tab id={`${idPrefix}-tab-profile`} value="profile">
							Profile
						</Tabs.Tab>
						<Tabs.Tab id={`${idPrefix}-tab-users`} value="users">
							Users
						</Tabs.Tab>
						<Tabs.Tab id={`${idPrefix}-tab-clients`} value="clients">
							API Clients ({apiClients.length})
						</Tabs.Tab>
						<Tabs.Tab id={`${idPrefix}-tab-audit`} value="audit">
							Audit Log ({auditLogs.length})
						</Tabs.Tab>
					</Tabs.List>

					{/* 1. PROFILE TAB */}
					<Tabs.Panel id={`${idPrefix}-panel-profile`} value="profile" pt="md">
						<Paper id={`${idPrefix}-profile-paper`} p="lg" radius="md" withBorder style={{ maxWidth: 650 }}>
							<Stack id={`${idPrefix}-profile-stack`} gap="md">
								<Group id={`${idPrefix}-profile-info-grp`} align="center" gap="md">
									<Icon id={`${idPrefix}-profile-user-icon`} path={iconEdit} size="lg" style={{ color: "var(--mantine-color-indigo-4)" }} />
									<div>
										<Text id={`${idPrefix}-txt-prof-name`} fw={600} size="md">
											{profName}
										</Text>
										<Text id={`${idPrefix}-txt-prof-email`} size="xs" c="dimmed">
											{profEmail}
										</Text>
										<Badge id={`${idPrefix}-bdg-prof-role`} color="pink" size="xs" mt={4}>
											ADMIN OPERATOR
										</Badge>
									</div>
								</Group>

								<Paper id={`${idPrefix}-password-paper`} p="md" radius="sm" withBorder mt="sm">
									<Stack id={`${idPrefix}-password-stack`} gap="xs">
										<Text id={`${idPrefix}-txt-pass-title`} fw={600} size="sm">
											Update Password
										</Text>
										<PasswordInput
											id={`${idPrefix}-input-curr-pass`}
											label="Current Password"
											value={currentPass}
											onChange={(e) => setCurrentPass(e.currentTarget.value)}
										/>
										<PasswordInput
											id={`${idPrefix}-input-new-pass`}
											label="New Password"
											value={newPass}
											onChange={(e) => setNewPass(e.currentTarget.value)}
										/>
										<PasswordInput
											id={`${idPrefix}-input-confirm-pass`}
											label="Confirm New Password"
											value={confirmPass}
											onChange={(e) => setConfirmPass(e.currentTarget.value)}
										/>
										{passSuccess && (
											<Text id={`${idPrefix}-txt-pass-success`} size="xs" c="green.4">
												Password updated successfully!
											</Text>
										)}
										<Group id={`${idPrefix}-pass-actions`} justify="flex-end" mt="xs">
											<Button
												id={`${idPrefix}-btn-submit-pass`}
												color="pink"
												disabled={!newPass || newPass !== confirmPass}
												onClick={handleUpdatePassword}
											>
												Update Password
											</Button>
										</Group>
									</Stack>
								</Paper>
							</Stack>
						</Paper>
					</Tabs.Panel>

					{/* 2. USERS TAB */}
					<Tabs.Panel id={`${idPrefix}-panel-users`} value="users" pt="md">
						<Card id={`${idPrefix}-users-card`} p="md" radius="md" withBorder style={{ maxWidth: 750 }}>
							<Stack id={`${idPrefix}-users-stack`} gap="md">
								<Group id={`${idPrefix}-users-header`} justify="space-between" align="center">
									<Text id={`${idPrefix}-txt-users-title`} fw={600} size="sm">
										System User Accounts
									</Text>
									<Button
										id={`${idPrefix}-btn-add-user`}
										color="pink"
										size="xs"
										leftSection={<Icon id={`${idPrefix}-plus-user-icon`} path={iconPlus} size="xs" />}
										onClick={() => setUserModalOpen(true)}
									>
										Add User
									</Button>
								</Group>

								<Table id={`${idPrefix}-table-users`} verticalSpacing="xs" horizontalSpacing="md">
									<Table.Thead id={`${idPrefix}-th-users-head`}>
										<Table.Tr id={`${idPrefix}-th-users-row`}>
											<Table.Th id={`${idPrefix}-th-u-name`}>User</Table.Th>
											<Table.Th id={`${idPrefix}-th-u-email`}>Email</Table.Th>
											<Table.Th id={`${idPrefix}-th-u-role`}>Role</Table.Th>
											<Table.Th id={`${idPrefix}-th-u-created`}>Created</Table.Th>
											<Table.Th id={`${idPrefix}-th-u-actions`} style={{ textAlign: "right" }}>Actions</Table.Th>
										</Table.Tr>
									</Table.Thead>
									<Table.Tbody id={`${idPrefix}-tbody-users`}>
										{users.map((u) => (
											<Table.Tr id={`${idPrefix}-user-row-${u.id}`} key={u.id}>
												<Table.Td id={`${idPrefix}-td-u-name-${u.id}`}>
													<Text id={`${idPrefix}-txt-u-name-${u.id}`} size="xs" fw={600}>
														{u.name}
													</Text>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-u-email-${u.id}`}>
													<Text id={`${idPrefix}-txt-u-email-${u.id}`} size="xs" c="dimmed">
														{u.email}
													</Text>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-u-role-${u.id}`}>
													<Badge id={`${idPrefix}-bdg-u-role-${u.id}`} color={u.role === "admin" ? "indigo" : "blue"} size="xs">
														{u.role.toUpperCase()}
													</Badge>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-u-created-${u.id}`}>
													<Text id={`${idPrefix}-txt-u-created-${u.id}`} size="xs">
														{u.createdAt}
													</Text>
												</Table.Td>
												<Table.Td id={`${idPrefix}-td-u-actions-${u.id}`} style={{ textAlign: "right" }}>
													<ActionIcon
														id={`${idPrefix}-btn-del-user-${u.id}`}
														color="red"
														variant="subtle"
														size="xs"
														onClick={() => setUsers((prev) => prev.filter((item) => item.id !== u.id))}
													>
														<Icon path={iconTrash} size="xs" />
													</ActionIcon>
												</Table.Td>
											</Table.Tr>
										))}
									</Table.Tbody>
								</Table>
							</Stack>
						</Card>
					</Tabs.Panel>

					{/* 3. API CLIENTS TAB */}
					<Tabs.Panel id={`${idPrefix}-panel-clients`} value="clients" pt="md">
						<Stack id={`${idPrefix}-clients-stack`} gap="md" style={{ maxWidth: 800 }}>
							<Card id={`${idPrefix}-clients-card`} p="md" radius="md" withBorder>
								<Stack id={`${idPrefix}-clients-inner-stack`} gap="md">
									<Group id={`${idPrefix}-clients-header`} justify="space-between" align="center">
										<div>
											<Text id={`${idPrefix}-txt-clients-title`} fw={600} size="sm">
												API Clients
											</Text>
											<Text id={`${idPrefix}-txt-clients-subtitle`} size="xs" c="dimmed">
												Scoped OAuth2 / API Clients for runner SDKs and trigger endpoints.
											</Text>
										</div>
										<Button
											id={`${idPrefix}-btn-new-client`}
											color="pink"
											size="xs"
											leftSection={<Icon id={`${idPrefix}-plus-client-icon`} path={iconPlus} size="xs" />}
											onClick={() => {
												setEditingClient(null);
												setClientName("");
												setSelectedScopes(["jobs:read", "executions:read"]);
												setClientModalOpen(true);
											}}
										>
											New Client
										</Button>
									</Group>

									{/* Clients List */}
									<Stack id={`${idPrefix}-clients-list`} gap="xs">
										{apiClients.map((c) => (
											<Paper id={`${idPrefix}-client-row-${c.client_id}`} key={c.client_id} p="sm" radius="sm" withBorder>
												<Group id={`${idPrefix}-client-row-grp-${c.client_id}`} justify="space-between" align="flex-start">
													<Stack id={`${idPrefix}-client-info-stack-${c.client_id}`} gap={4} style={{ flex: 1 }}>
														<Group id={`${idPrefix}-client-name-grp-${c.client_id}`} gap="xs">
															<Text id={`${idPrefix}-txt-client-name-${c.client_id}`} fw={600} size="sm">
																{c.name}
															</Text>
															<Badge id={`${idPrefix}-bdg-client-status-${c.client_id}`} color="green" size="xs">
																ACTIVE
															</Badge>
														</Group>

														<Group id={`${idPrefix}-client-id-grp-${c.client_id}`} gap="xs">
															<Code id={`${idPrefix}-code-client-id-${c.client_id}`} color="pink" style={{ fontSize: "11px" }}>
																{c.client_id}
															</Code>
															<ActionIcon
																id={`${idPrefix}-btn-copy-client-${c.client_id}`}
																size="xs"
																variant="subtle"
																onClick={() => navigator.clipboard.writeText(c.client_id)}
															>
																<Icon path={iconCopy} size="xs" />
															</ActionIcon>
														</Group>

														<Group id={`${idPrefix}-client-scopes-grp-${c.client_id}`} gap={4} mt={2} wrap="wrap">
															{c.scopes.map((sc) => (
																<Code id={`${idPrefix}-code-scope-${c.client_id}-${sc}`} key={sc} color="violet" style={{ fontSize: "10px" }}>
																	{sc}
																</Code>
															))}
														</Group>
													</Stack>

													<Group id={`${idPrefix}-client-actions-${c.client_id}`} gap="xs">
														<Button
															id={`${idPrefix}-btn-issue-key-${c.client_id}`}
															variant="light"
															color="pink"
															size="xs"
															onClick={() => handleIssueToken(c)}
														>
															Issue Key
														</Button>
														<ActionIcon
															id={`${idPrefix}-btn-edit-client-${c.client_id}`}
															variant="subtle"
															color="pink"
															size="xs"
															onClick={() => {
																setEditingClient(c);
																setClientName(c.name);
																setSelectedScopes(c.scopes);
																setClientModalOpen(true);
															}}
														>
															<Icon path={iconEdit} size="xs" />
														</ActionIcon>
														<ActionIcon
															id={`${idPrefix}-btn-del-client-${c.client_id}`}
															variant="subtle"
															color="red"
															size="xs"
															onClick={() => setApiClients((prev) => prev.filter((item) => item.client_id !== c.client_id))}
														>
															<Icon path={iconTrash} size="xs" />
														</ActionIcon>
													</Group>
												</Group>
											</Paper>
										))}
									</Stack>
								</Stack>
							</Card>

							{/* Issued API Key Reveal Card */}
							{issuedKey && (
								<Paper id={`${idPrefix}-issued-key-paper`} p="md" radius="md" bg="dark.7" withBorder style={{ borderColor: "var(--mantine-color-indigo-5)" }}>
									<Stack id={`${idPrefix}-issued-key-stack`} gap="xs">
										<Text id={`${idPrefix}-txt-issued-title`} fw={600} size="sm" c="indigo.2">
											New API Key Issued — copy now, it won't be shown again
										</Text>

										<Group id={`${idPrefix}-issued-key-val-grp`} justify="space-between" align="center">
											<Code id={`${idPrefix}-code-raw-key`} color="pink" block style={{ fontSize: "13px", fontFamily: "monospace", flex: 1 }}>
												{issuedKey.rawKey}
											</Code>
											<Button
												id={`${idPrefix}-btn-copy-raw-key`}
												color="pink"
												size="xs"
												leftSection={<Icon id={`${idPrefix}-copy-raw-icon`} path={iconCopy} size="xs" />}
												onClick={() => navigator.clipboard.writeText(issuedKey.rawKey)}
											>
												Copy Key
											</Button>
										</Group>

										<Group id={`${idPrefix}-issued-key-meta`} justify="space-between" mt="xs">
											<Text id={`${idPrefix}-txt-key-id`} size="xs" c="dimmed" style={{ fontFamily: "monospace" }}>
												Key ID: {issuedKey.keyId}
											</Text>
											<Button id={`${idPrefix}-btn-dismiss-key`} variant="subtle" color="gray" size="xs" onClick={() => setIssuedKey(null)}>
												Dismiss
											</Button>
										</Group>
									</Stack>
								</Paper>
							)}
						</Stack>
					</Tabs.Panel>

					{/* 4. AUDIT TAB */}
					<Tabs.Panel id={`${idPrefix}-panel-audit`} value="audit" pt="md">
						<Card id={`${idPrefix}-audit-card`} p={0} radius="md" withBorder style={{ maxWidth: 950 }}>
							<Table id={`${idPrefix}-table-audit`} verticalSpacing="xs" horizontalSpacing="md">
								<Table.Thead id={`${idPrefix}-th-audit-head`}>
									<Table.Tr id={`${idPrefix}-th-audit-row`}>
										<Table.Th id={`${idPrefix}-th-a-ts`}>Timestamp</Table.Th>
										<Table.Th id={`${idPrefix}-th-a-actor`}>Actor</Table.Th>
										<Table.Th id={`${idPrefix}-th-a-action`}>Action</Table.Th>
										<Table.Th id={`${idPrefix}-th-a-target`}>Target</Table.Th>
										<Table.Th id={`${idPrefix}-th-a-ip`}>IP Address</Table.Th>
										<Table.Th id={`${idPrefix}-th-a-diff`}>Payload Details</Table.Th>
									</Table.Tr>
								</Table.Thead>
								<Table.Tbody id={`${idPrefix}-tbody-audit`}>
									{auditLogs.map((a) => (
										<Table.Tr id={`${idPrefix}-audit-row-${a.id}`} key={a.id}>
											<Table.Td id={`${idPrefix}-td-a-ts-${a.id}`}>
												<Text id={`${idPrefix}-txt-a-ts-${a.id}`} size="xs" c="dimmed" style={{ fontFamily: "monospace" }}>
													{a.ts.slice(0, 19)}
												</Text>
											</Table.Td>
											<Table.Td id={`${idPrefix}-td-a-actor-${a.id}`}>
												<Badge id={`${idPrefix}-bdg-a-actor-${a.id}`} color="gray" size="xs">
													{a.actorType}: {a.actorId}
												</Badge>
											</Table.Td>
											<Table.Td id={`${idPrefix}-td-a-action-${a.id}`}>
												<Badge id={`${idPrefix}-bdg-a-action-${a.id}`} color="pink" variant="light" size="xs">
													{a.action}
												</Badge>
											</Table.Td>
											<Table.Td id={`${idPrefix}-td-a-target-${a.id}`}>
												<Text id={`${idPrefix}-txt-a-target-${a.id}`} size="xs" style={{ fontFamily: "monospace" }}>
													{a.targetType}:{a.targetId}
												</Text>
											</Table.Td>
											<Table.Td id={`${idPrefix}-td-a-ip-${a.id}`}>
												<Text id={`${idPrefix}-txt-a-ip-${a.id}`} size="xs" c="dimmed">
													{a.ipAddress || "—"}
												</Text>
											</Table.Td>
											<Table.Td id={`${idPrefix}-td-a-diff-${a.id}`}>
												{a.diffJson ? (
													<Code id={`${idPrefix}-code-a-diff-${a.id}`} style={{ fontSize: "10px" }}>
														{JSON.stringify(a.diffJson)}
													</Code>
												) : (
													"—"
												)}
											</Table.Td>
										</Table.Tr>
									))}
								</Table.Tbody>
							</Table>
						</Card>
					</Tabs.Panel>
				</Tabs>

				{/* MODAL: ADD / EDIT API CLIENT */}
				<Modal
					id={`${idPrefix}-modal-client`}
					opened={clientModalOpen}
					onClose={() => {
						setClientModalOpen(false);
						setEditingClient(null);
					}}
					title={editingClient ? `Edit API Client — ${editingClient.name}` : "New API Client"}
					size="lg"
					centered
				>
					<Stack id={`${idPrefix}-modal-client-stack`} gap="md">
						<TextInput
							id={`${idPrefix}-input-client-name`}
							label="Client Display Name"
							placeholder="e.g. runner-node-sdk"
							value={clientName}
							onChange={(e) => setClientName(e.currentTarget.value)}
							required
						/>

						{/* Scope Group Picker */}
						<div>
							<Group id={`${idPrefix}-lbl-scopes-grp`} justify="space-between" mb="xs">
								<Text id={`${idPrefix}-txt-scopes-title`} size="xs" fw={600}>
									Scopes & Permissions ({selectedScopes.length} selected)
								</Text>
								{selectedScopes.length > 0 && (
									<Button id={`${idPrefix}-btn-clear-scopes`} variant="subtle" size="xs" color="gray" onClick={() => setSelectedScopes([])}>
										Clear All
									</Button>
								)}
							</Group>

							<Paper id={`${idPrefix}-scopes-box`} p="sm" radius="sm" withBorder style={{ maxHeight: 320, overflowY: "auto" }}>
								<Stack id={`${idPrefix}-scopes-groups-stack`} gap="md">
									{SCOPE_GROUPS.map((grp) => (
										<div id={`${idPrefix}-scope-grp-${grp.label}`} key={grp.label}>
											<Text id={`${idPrefix}-txt-grp-lbl-${grp.label}`} size="xs" fw={700} c="indigo.4" mb={4}>
												{grp.label}
											</Text>
											<Stack id={`${idPrefix}-scope-items-${grp.label}`} gap={4}>
												{grp.scopes.map((s) => {
													const isChecked = selectedScopes.includes(s.value) || selectedScopes.includes("admin");
													return (
														<Checkbox
															id={`${idPrefix}-chk-scope-${s.value}`}
															key={s.value}
															label={
																<Text id={`${idPrefix}-lbl-chk-${s.value}`} size="xs" style={{ fontFamily: "monospace" }}>
																	{s.value} {s.hint ? <span style={{ color: "gray" }}> — {s.hint}</span> : null}
																</Text>
															}
															checked={isChecked}
															onChange={() => toggleScope(s.value)}
														/>
													);
												})}
											</Stack>
										</div>
									))}
								</Stack>
							</Paper>
						</div>

						<Group id={`${idPrefix}-modal-client-actions`} justify="flex-end" mt="md">
							<Button id={`${idPrefix}-btn-cancel-client`} variant="subtle" onClick={() => setClientModalOpen(false)}>
								Cancel
							</Button>
							<Button
								id={`${idPrefix}-btn-submit-client`}
								color="pink"
								disabled={!clientName.trim() || selectedScopes.length === 0}
								onClick={handleSaveClient}
							>
								{editingClient ? "Save Changes" : "Create Client"}
							</Button>
						</Group>
					</Stack>
				</Modal>

				{/* MODAL: ADD USER */}
				<Modal
					id={`${idPrefix}-modal-user`}
					opened={userModalOpen}
					onClose={() => setUserModalOpen(false)}
					title="Add New System User"
					centered
				>
					<Stack id={`${idPrefix}-modal-user-stack`} gap="md">
						<TextInput
							id={`${idPrefix}-input-user-name`}
							label="Full Name"
							placeholder="Jane Doe"
							value={newUserName}
							onChange={(e) => setNewUserName(e.currentTarget.value)}
							required
						/>
						<TextInput
							id={`${idPrefix}-input-user-email`}
							label="Email Address"
							placeholder="jane@lyxal.internal"
							value={newUserEmail}
							onChange={(e) => setNewUserEmail(e.currentTarget.value)}
							required
						/>

						<Group id={`${idPrefix}-modal-user-actions`} justify="flex-end" mt="md">
							<Button id={`${idPrefix}-btn-cancel-user`} variant="subtle" onClick={() => setUserModalOpen(false)}>
								Cancel
							</Button>
							<Button id={`${idPrefix}-btn-submit-user`} color="pink" disabled={!newUserName.trim()} onClick={handleAddUser}>
								Create User
							</Button>
						</Group>
					</Stack>
				</Modal>
			</Stack>
		</div>
	);
}
