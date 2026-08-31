import {
	Button,
	Card,
	Group,
	Modal,
	NumberInput,
	PasswordInput,
	Select,
	Stack,
	Table,
	Tabs,
	Text,
	TextInput,
	Textarea,
	Title,
} from "@mantine/core";
import { Icon, iconCheck, iconPlus, iconTrash } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingSettingsProps {
	idPrefix?: string;
}

export function BookingSettings({ idPrefix = "booking-settings" }: BookingSettingsProps) {
	const [settings, setSettings] = useState<Record<string, string>>({});

	// General
	const [baseUrl, setBaseUrl] = useState("");
	const [allowPrivateHosts, setAllowPrivateHosts] = useState("");

	// SMTP
	const [smtpHost, setSmtpHost] = useState("");
	const [smtpPort, setSmtpPort] = useState<number>(587);
	const [smtpUser, setSmtpUser] = useState("");
	const [smtpPass, setSmtpPass] = useState("");
	const [smtpFromEmail, setSmtpFromEmail] = useState("");
	const [smtpFromName, setSmtpFromName] = useState("");

	// Sources
	const [sources, setSources] = useState<any[]>([]);
	const [sourceModalOpen, setSourceModalOpen] = useState(false);
	const [sourceUrl, setSourceUrl] = useState("");
	const [sourceUser, setSourceUser] = useState("");
	const [sourcePass, setSourcePass] = useState("");
	const [sourceProvider, setSourceProvider] = useState("caldav");

	const loadData = async () => {
		try {
			const setRes = await executeQuery("SELECT * FROM booking_setting;");
			if (setRes && Array.isArray(setRes[0]?.result)) {
				const map: Record<string, string> = {};
				setRes[0].result.forEach((item: any) => {
					if (item.setting_key) {
						map[item.setting_key] = item.value || "";
					}
				});
				setSettings(map);
				setBaseUrl(map["base_url"] || "");
				setAllowPrivateHosts(map["allow_private_hosts"] || "");
				setSmtpHost(map["smtp_host"] || "");
				setSmtpPort(Number(map["smtp_port"]) || 587);
				setSmtpUser(map["smtp_user"] || "");
				setSmtpFromEmail(map["smtp_from_email"] || "");
				setSmtpFromName(map["smtp_from_name"] || "");
			}

			const srcRes = await executeQuery("SELECT * FROM booking_caldav_source;");
			if (srcRes && Array.isArray(srcRes[0]?.result)) {
				setSources(srcRes[0].result);
			}
		} catch (e) {
			console.error("Failed to load settings/sources:", e);
		}
	};

	useEffect(() => {
		loadData();
	}, []);

	const handleSaveSetting = async (key: string, val: string) => {
		try {
			await executeQuery(`
				UPSERT booking_setting SET
					setting_key = '${key}',
					value = '${val.replace(/'/g, "\\'")}',
					updated_at = time::now()
				WHERE setting_key = '${key}';
			`);
			loadData();
		} catch (e) {
			console.error("Save setting failed:", e);
		}
	};

	const handleSaveGeneral = async () => {
		await handleSaveSetting("base_url", baseUrl);
		await handleSaveSetting("allow_private_hosts", allowPrivateHosts);
	};

	const handleSaveSmtp = async () => {
		await handleSaveSetting("smtp_host", smtpHost);
		await handleSaveSetting("smtp_port", String(smtpPort));
		await handleSaveSetting("smtp_user", smtpUser);
		if (smtpPass) {
			await handleSaveSetting("smtp_pass", smtpPass);
		}
		await handleSaveSetting("smtp_from_email", smtpFromEmail);
		await handleSaveSetting("smtp_from_name", smtpFromName);
	};

	const handleAddSource = async () => {
		if (!sourceUrl.trim()) return;

		try {
			await executeQuery(`
				RETURN fn::booking_create_caldav_source(
					r'booking_account:admin',
					'${sourceProvider}',
					'${sourceUrl.replace(/'/g, "\\'")}',
					'${sourceUser.replace(/'/g, "\\'")}',
					'${sourcePass.replace(/'/g, "\\'")}'
				);
			`);
			setSourceModalOpen(false);
			loadData();
		} catch (e) {
			console.error("Add source failed:", e);
		}
	};

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Réglages Globaux (`settings.html` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Paramètres système, configuration SMTP, sources de synchronisation CalDAV/Google (`fn::booking_get_setting`)
					</Text>
				</div>
				<Button variant="light" onClick={loadData}>
					Actualiser
				</Button>
			</Group>

			<Card withBorder padding="lg" radius="md">
				<Tabs defaultValue="general">
					<Tabs.List mb="md">
						<Tabs.Tab value="general">Général</Tabs.Tab>
						<Tabs.Tab value="smtp">Serveur SMTP / Mail</Tabs.Tab>
						<Tabs.Tab value="sources">Sources CalDAV / Google</Tabs.Tab>
					</Tabs.List>

					<Tabs.Panel value="general">
						<Stack gap="md" style={{ maxWidth: 600 }}>
							<TextInput
								label="URL Publique de Réservation (CALRS_BASE_URL)"
								placeholder="https://booking.example.com"
								value={baseUrl}
								onChange={(e) => setBaseUrl(e.currentTarget.value)}
							/>
							<TextInput
								label="Hôtes Privés Autorisés (SSRF Allowlist)"
								placeholder="127.0.0.1, radicale, stalwart"
								value={allowPrivateHosts}
								onChange={(e) => setAllowPrivateHosts(e.currentTarget.value)}
							/>
							<Button style={{ alignSelf: "flex-start" }} onClick={handleSaveGeneral}>
								Enregistrer les Réglages Généraux
							</Button>
						</Stack>
					</Tabs.Panel>

					<Tabs.Panel value="smtp">
						<Stack gap="md" style={{ maxWidth: 600 }}>
							<Group grow>
								<TextInput
									label="Hôte SMTP"
									placeholder="smtp.example.com"
									value={smtpHost}
									onChange={(e) => setSmtpHost(e.currentTarget.value)}
								/>
								<NumberInput
									label="Port SMTP"
									value={smtpPort}
									onChange={(v) => setSmtpPort(Number(v) || 587)}
								/>
							</Group>
							<Group grow>
								<TextInput
									label="Utilisateur SMTP"
									placeholder="user@example.com"
									value={smtpUser}
									onChange={(e) => setSmtpUser(e.currentTarget.value)}
								/>
								<PasswordInput
									label="Mot de passe SMTP"
									placeholder="••••••••"
									value={smtpPass}
									onChange={(e) => setSmtpPass(e.currentTarget.value)}
								/>
							</Group>
							<Group grow>
								<TextInput
									label="Adresse E-mail d'Expéditeur"
									placeholder="booking@example.com"
									value={smtpFromEmail}
									onChange={(e) => setSmtpFromEmail(e.currentTarget.value)}
								/>
								<TextInput
									label="Nom d'Expéditeur"
									placeholder="Lyxal Booking"
									value={smtpFromName}
									onChange={(e) => setSmtpFromName(e.currentTarget.value)}
								/>
							</Group>
							<Button style={{ alignSelf: "flex-start" }} onClick={handleSaveSmtp}>
								Enregistrer la Configuration SMTP
							</Button>
						</Stack>
					</Tabs.Panel>

					<Tabs.Panel value="sources">
						<Stack gap="md">
							<Group justify="space-between">
								<Text size="sm" c="dimmed">
									Sources de calendrier connectées pour la détection de conflit (CalDAV / Stalwart / Google)
								</Text>
								<Button leftSection={<Icon path={iconPlus} />} onClick={() => setSourceModalOpen(true)}>
									Ajouter une Source
								</Button>
							</Group>

							<Table striped highlightOnHover>
								<Table.Thead>
									<Table.Tr>
										<Table.Th>Fournisseur</Table.Th>
										<Table.Th>URL du Serveur</Table.Th>
										<Table.Th>Utilisateur</Table.Th>
										<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
									</Table.Tr>
								</Table.Thead>
								<Table.Tbody>
									{sources.map((src: any) => (
										<Table.Tr key={src.id}>
											<Table.Td fw={600}>{src.provider_type || "CalDAV"}</Table.Td>
											<Table.Td>{src.url || "N/A"}</Table.Td>
											<Table.Td>{src.username || "N/A"}</Table.Td>
											<Table.Td style={{ textAlign: "right" }}>
												<Button
													size="xs"
													variant="subtle"
													color="red"
													onClick={async () => {
														await executeQuery(`RETURN fn::booking_delete_caldav_source('${src.id}');`);
														loadData();
													}}
												>
													Supprimer
												</Button>
											</Table.Td>
										</Table.Tr>
									))}
									{sources.length === 0 && (
										<Table.Tr>
											<Table.Td colSpan={4} style={{ textAlign: "center" }}>
												<Text c="dimmed">Aucune source de calendrier distante connectée.</Text>
											</Table.Td>
										</Table.Tr>
									)}
								</Table.Tbody>
							</Table>
						</Stack>
					</Tabs.Panel>
				</Tabs>
			</Card>

			{/* Modal Source Form Conforme à source_form.html */}
			<Modal opened={sourceModalOpen} onClose={() => setSourceModalOpen(false)} title="Connecter une Source CalDAV / Google">
				<Stack gap="md">
					<Select
						label="Type de fournisseur"
						data={[
							{ value: "caldav", label: "Serveur CalDAV / Stalwart" },
							{ value: "google", label: "Google Calendar" },
						]}
						value={sourceProvider}
						onChange={(v) => setSourceProvider(v || "caldav")}
					/>
					<TextInput
						label="URL du serveur"
						placeholder="https://caldav.example.com/principals/"
						required
						value={sourceUrl}
						onChange={(e) => setSourceUrl(e.currentTarget.value)}
					/>
					<TextInput
						label="Nom d'utilisateur"
						placeholder="user@example.com"
						value={sourceUser}
						onChange={(e) => setSourceUser(e.currentTarget.value)}
					/>
					<PasswordInput
						label="Mot de passe / Jeton"
						placeholder="••••••••"
						value={sourcePass}
						onChange={(e) => setSourcePass(e.currentTarget.value)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setSourceModalOpen(false)}>
							Annuler
						</Button>
						<Button onClick={handleAddSource}>Connecter la Source</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
