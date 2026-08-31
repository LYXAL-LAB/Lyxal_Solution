import {
	ActionIcon,
	Badge,
	Button,
	Card,
	Group,
	Modal,
	Select,
	Stack,
	Table,
	Tabs,
	Text,
	TextInput,
	Textarea,
	Title,
} from "@mantine/core";
import { Icon, iconCheck, iconClose, iconClock, iconEdit } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingListProps {
	idPrefix?: string;
}

export function BookingList({ idPrefix = "booking-list" }: BookingListProps) {
	const [bookings, setBookings] = useState<any[]>([]);
	const [activeTab, setActiveTab] = useState<string>("all");

	// Modals State
	const [cancelModalOpen, setCancelModalOpen] = useState(false);
	const [selectedCancelToken, setSelectedCancelToken] = useState("");
	const [cancelReason, setCancelReason] = useState("");

	const [rescheduleModalOpen, setRescheduleModalOpen] = useState(false);
	const [selectedRescheduleId, setSelectedRescheduleId] = useState("");
	const [newStartAt, setNewStartAt] = useState("");
	const [newEndAt, setNewEndAt] = useState("");

	const loadBookings = async () => {
		try {
			const res = await executeQuery("SELECT * FROM booking ORDER BY start_at DESC;");
			if (res && Array.isArray(res[0]?.result)) {
				setBookings(res[0].result);
			}
		} catch (e) {
			console.error("Failed to load bookings:", e);
		}
	};

	useEffect(() => {
		loadBookings();
	}, []);

	const handleConfirm = async (bookingId: string) => {
		try {
			await executeQuery(`RETURN fn::booking_confirm_pending('${bookingId}');`);
			loadBookings();
		} catch (e) {
			console.error("Confirm booking failed:", e);
		}
	};

	const openCancelModal = (b: any) => {
		setSelectedCancelToken(b.cancel_token || b.id);
		setCancelReason("Annulé depuis l'interface d'administration Surrealist");
		setCancelModalOpen(true);
	};

	const handleCancelSubmit = async () => {
		if (!selectedCancelToken) return;

		try {
			await executeQuery(
				`RETURN fn::booking_cancel_booking('${selectedCancelToken}', '${cancelReason.replace(/'/g, "\\'")}');`,
			);
			setCancelModalOpen(false);
			loadBookings();
		} catch (e) {
			console.error("Cancel booking failed:", e);
		}
	};

	const openRescheduleModal = (b: any) => {
		setSelectedRescheduleId(b.id);
		setNewStartAt(b.start_at || "");
		setNewEndAt(b.end_at || "");
		setRescheduleModalOpen(true);
	};

	const handleRescheduleSubmit = async () => {
		if (!selectedRescheduleId || !newStartAt || !newEndAt) return;

		try {
			await executeQuery(`
				RETURN fn::booking_reschedule_booking(
					'${selectedRescheduleId}',
					time::from::rfc3339('${newStartAt}'),
					time::from::rfc3339('${newEndAt}')
				);
			`);
			setRescheduleModalOpen(false);
			loadBookings();
		} catch (e) {
			console.error("Reschedule booking failed:", e);
		}
	};

	const filteredBookings = bookings.filter((b) => {
		if (activeTab === "confirmed") return b.status === "confirmed";
		if (activeTab === "pending") return b.status === "pending";
		if (activeTab === "cancelled") return b.status === "cancelled";
		return true;
	});

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Liste des Réservations (`dashboard_bookings.html` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Gestion complète des rendez-vous client, confirmations, annulations et reprogrammations
					</Text>
				</div>
				<Button variant="light" onClick={loadBookings}>
					Actualiser
				</Button>
			</Group>

			<Card withBorder padding="lg" radius="md">
				<Tabs value={activeTab} onChange={(v) => setActiveTab(v || "all")}>
					<Tabs.List mb="md">
						<Tabs.Tab value="all">Toutes ({bookings.length})</Tabs.Tab>
						<Tabs.Tab value="confirmed">
							Confirmées ({bookings.filter((b) => b.status === "confirmed").length})
						</Tabs.Tab>
						<Tabs.Tab value="pending">
							En Attente ({bookings.filter((b) => b.status === "pending").length})
						</Tabs.Tab>
						<Tabs.Tab value="cancelled">
							Annulées ({bookings.filter((b) => b.status === "cancelled").length})
						</Tabs.Tab>
					</Tabs.List>
				</Tabs>

				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>ID</Table.Th>
							<Table.Th>Nom Client</Table.Th>
							<Table.Th>Email Client</Table.Th>
							<Table.Th>Fuseau Horaire</Table.Th>
							<Table.Th>Début</Table.Th>
							<Table.Th>Fin</Table.Th>
							<Table.Th>Statut</Table.Th>
							<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{filteredBookings.map((b: any) => {
							const bId = String(b.id || "").replace("booking:", "");
							return (
								<Table.Tr key={b.id}>
									<Table.Td>{bId}</Table.Td>
									<Table.Td fw={600}>{b.guest_name || "N/A"}</Table.Td>
									<Table.Td>{b.guest_email || "N/A"}</Table.Td>
									<Table.Td>{b.guest_timezone || "UTC"}</Table.Td>
									<Table.Td>{b.start_at || "N/A"}</Table.Td>
									<Table.Td>{b.end_at || "N/A"}</Table.Td>
									<Table.Td>
										<Badge
											color={
												b.status === "confirmed"
													? "green"
													: b.status === "cancelled"
														? "red"
														: "yellow"
											}
										>
											{b.status || "pending"}
										</Badge>
									</Table.Td>
									<Table.Td style={{ textAlign: "right" }}>
										<Group gap="xs" justify="flex-end">
											{b.status === "pending" && (
												<ActionIcon
													color="green"
													variant="subtle"
													onClick={() => handleConfirm(b.id)}
													title="Confirmer la Réservation"
												>
													<Icon path={iconCheck} />
												</ActionIcon>
											)}
											{b.status !== "cancelled" && (
												<>
													<ActionIcon
														color="blue"
														variant="subtle"
														onClick={() => openRescheduleModal(b)}
														title="Reprogrammer"
													>
														<Icon path={iconClock} />
													</ActionIcon>
													<ActionIcon
														color="red"
														variant="subtle"
														onClick={() => openCancelModal(b)}
														title="Annuler"
													>
														<Icon path={iconClose} />
													</ActionIcon>
												</>
											)}
										</Group>
									</Table.Td>
								</Table.Tr>
							);
						})}
						{filteredBookings.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={8} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucune réservation ne correspond aux critères.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Modal Annulation Conforme à booking_cancel_form.html */}
			<Modal opened={cancelModalOpen} onClose={() => setCancelModalOpen(false)} title="Annuler la Réservation">
				<Stack gap="md">
					<Text size="sm">Voulez-vous vraiment annuler ce rendez-vous ? Un courriel de notification sera envoyé au client.</Text>
					<Textarea
						label="Motif de l'annulation"
						placeholder="ex: Imprévu, indisponibilité de l'hôte..."
						required
						value={cancelReason}
						onChange={(e) => setCancelReason(e.currentTarget.value)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setCancelModalOpen(false)}>
							Fermer
						</Button>
						<Button color="red" onClick={handleCancelSubmit}>
							Confirmer l'Annulation
						</Button>
					</Group>
				</Stack>
			</Modal>

			{/* Modal Reprogrammation Conforme à booking_reschedule_confirm.html */}
			<Modal
				opened={rescheduleModalOpen}
				onClose={() => setRescheduleModalOpen(false)}
				title="Reprogrammer la Réservation"
			>
				<Stack gap="md">
					<TextInput
						label="Nouvelle Date & Heure de Début (ISO/RFC3339)"
						placeholder="2026-08-01T10:00:00Z"
						required
						value={newStartAt}
						onChange={(e) => setNewStartAt(e.currentTarget.value)}
					/>
					<TextInput
						label="Nouvelle Date & Heure de Fin (ISO/RFC3339)"
						placeholder="2026-08-01T10:30:00Z"
						required
						value={newEndAt}
						onChange={(e) => setNewEndAt(e.currentTarget.value)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setRescheduleModalOpen(false)}>
							Annuler
						</Button>
						<Button color="blue" onClick={handleRescheduleSubmit}>
							Enregistrer le Report
						</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
