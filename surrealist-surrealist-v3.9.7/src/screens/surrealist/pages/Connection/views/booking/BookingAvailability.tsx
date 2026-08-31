import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Checkbox,
	Group,
	Modal,
	NumberInput,
	Select,
	Stack,
	Table,
	Text,
	TextInput,
	Title,
} from "@mantine/core";
import { Icon, iconPlus, iconTrash } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingAvailabilityProps {
	idPrefix?: string;
}

const DAYS_OF_WEEK = [
	{ id: 1, name: "Lundi" },
	{ id: 2, name: "Mardi" },
	{ id: 3, name: "Mercredi" },
	{ id: 4, name: "Jeudi" },
	{ id: 5, name: "Vendredi" },
	{ id: 6, name: "Samedi" },
	{ id: 0, name: "Dimanche" },
];

export function BookingAvailability({ idPrefix = "booking-availability" }: BookingAvailabilityProps) {
	const [rules, setRules] = useState<any[]>([]);
	const [overrides, setOverrides] = useState<any[]>([]);
	const [modalOpen, setModalOpen] = useState(false);

	// Override Form State
	const [overrideDate, setOverrideDate] = useState("");
	const [startTime, setStartTime] = useState("09:00");
	const [endTime, setEndTime] = useState("17:00");
	const [isUnavailable, setIsUnavailable] = useState(false);

	const loadData = async () => {
		try {
			const ruleRes = await executeQuery("SELECT * FROM booking_availability_rule ORDER BY day_of_week ASC;");
			if (ruleRes && Array.isArray(ruleRes[0]?.result)) {
				setRules(ruleRes[0].result);
			}

			const overRes = await executeQuery("SELECT * FROM booking_availability_override ORDER BY date ASC;");
			if (overRes && Array.isArray(overRes[0]?.result)) {
				setOverrides(overRes[0].result);
			}
		} catch (e) {
			console.error("Failed to load availability rules/overrides:", e);
		}
	};

	useEffect(() => {
		loadData();
	}, []);

	const handleAddOverride = async () => {
		if (!overrideDate.trim()) return;

		try {
			await executeQuery(`
				CREATE booking_availability_override CONTENT {
					account: r'booking_account:admin',
					date: d'${overrideDate}',
					start_time: '${startTime}',
					end_time: '${endTime}',
					is_unavailable: ${isUnavailable}
				};
			`);
			setModalOpen(false);
			loadData();
		} catch (e) {
			console.error("Add override failed:", e);
		}
	};

	const handleDeleteOverride = async (id: string) => {
		try {
			await executeQuery(`DELETE ${id};`);
			loadData();
		} catch (e) {
			console.error("Delete override failed:", e);
		}
	};

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Disponibilités & Dérogations (`overrides.html` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Heures de travail hebdomadaires récurrentes et blocages de dates spécifiques (`fn::booking_get_available_slots`)
					</Text>
				</div>
				<Group>
					<Button variant="light" onClick={loadData}>
						Actualiser
					</Button>
					<Button leftSection={<Icon path={iconPlus} />} onClick={() => setModalOpen(true)}>
						Ajouter une Dérogation de Date
					</Button>
				</Group>
			</Group>

			{/* Working Hours Card */}
			<Card withBorder padding="lg" radius="md">
				<Title order={4} mb="md">
					Heures de Travail Hebdomadaires
				</Title>
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Jour de la semaine</Table.Th>
							<Table.Th>Heure de Début</Table.Th>
							<Table.Th>Heure de Fin</Table.Th>
							<Table.Th>Statut</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{DAYS_OF_WEEK.map((d) => {
							const matchedRule = rules.find((r) => r.day_of_week === d.id);
							return (
								<Table.Tr key={d.id}>
									<Table.Td fw={600}>{d.name}</Table.Td>
									<Table.Td>{matchedRule?.start_time || "09:00"}</Table.Td>
									<Table.Td>{matchedRule?.end_time || "17:00"}</Table.Td>
									<Table.Td>
										<Badge color={matchedRule ? "green" : "gray"}>
											{matchedRule ? "Ouvert" : "Par défaut (9h-17h)"}
										</Badge>
									</Table.Td>
								</Table.Tr>
							);
						})}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Date Overrides Card */}
			<Card withBorder padding="lg" radius="md">
				<Title order={4} mb="md">
					Dérogations de Dates Spécifiques & Congés
				</Title>
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Date</Table.Th>
							<Table.Th>Plage Horaire</Table.Th>
							<Table.Th>Type de Dérogation</Table.Th>
							<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{overrides.map((ov: any) => (
							<Table.Tr key={ov.id}>
								<Table.Td fw={600}>{ov.date || "N/A"}</Table.Td>
								<Table.Td>
									{ov.start_time || "00:00"} - {ov.end_time || "23:59"}
								</Table.Td>
								<Table.Td>
									<Badge color={ov.is_unavailable ? "red" : "blue"}>
										{ov.is_unavailable ? "Congé / Indisponible" : "Horaires Personnalisés"}
									</Badge>
								</Table.Td>
								<Table.Td style={{ textAlign: "right" }}>
									<ActionIcon variant="subtle" color="red" onClick={() => handleDeleteOverride(ov.id)}>
										<Icon path={iconTrash} />
									</ActionIcon>
								</Table.Td>
							</Table.Tr>
						))}
						{overrides.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={4} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucune dérogation de date configurée.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Modal Form Conforme à overrides.html */}
			<Modal opened={modalOpen} onClose={() => setModalOpen(false)} title="Ajouter une Dérogation de Date">
				<Stack gap="md">
					<TextInput
						label="Date (YYYY-MM-DD)"
						placeholder="ex: 2026-12-25"
						required
						value={overrideDate}
						onChange={(e) => setOverrideDate(e.currentTarget.value)}
					/>
					<Group grow>
						<TextInput
							label="Heure de Début"
							placeholder="09:00"
							value={startTime}
							onChange={(e) => setStartTime(e.currentTarget.value)}
						/>
						<TextInput
							label="Heure de Fin"
							placeholder="17:00"
							value={endTime}
							onChange={(e) => setEndTime(e.currentTarget.value)}
						/>
					</Group>
					<Checkbox
						label="Marquer toute la journée comme indisponible (Congé/Férié)"
						checked={isUnavailable}
						onChange={(e) => setIsUnavailable(e.currentTarget.checked)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setModalOpen(false)}>
							Annuler
						</Button>
						<Button onClick={handleAddOverride}>Enregistrer la Dérogation</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
