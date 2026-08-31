import { Box, Button, Card, Group, SimpleGrid, Stack, Table, Text, Title } from "@mantine/core";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingDashboardProps {
	idPrefix?: string;
}

export function BookingDashboard({ idPrefix = "booking-dashboard" }: BookingDashboardProps) {
	const [metrics, setMetrics] = useState({
		totalBookings: 0,
		confirmedBookings: 0,
		pendingBookings: 0,
		cancelledBookings: 0,
		totalEventTypes: 0,
		totalTeams: 0,
	});
	const [recentBookings, setRecentBookings] = useState<any[]>([]);

	const loadData = async () => {
		try {
			const bRes = await executeQuery("SELECT * FROM booking ORDER BY start_at DESC LIMIT 10;");
			const etRes = await executeQuery("SELECT COUNT() FROM booking_event_type GROUP ALL;");
			const tmRes = await executeQuery("SELECT COUNT() FROM booking_team GROUP ALL;");

			if (bRes && Array.isArray(bRes[0]?.result)) {
				const bookings = bRes[0].result;
				setRecentBookings(bookings);
				setMetrics((prev) => ({
					...prev,
					totalBookings: bookings.length,
					confirmedBookings: bookings.filter((b: any) => b.status === "confirmed").length,
					pendingBookings: bookings.filter((b: any) => b.status === "pending").length,
					cancelledBookings: bookings.filter((b: any) => b.status === "cancelled").length,
				}));
			}

			if (etRes && etRes[0]?.result?.[0]?.count) {
				setMetrics((prev) => ({ ...prev, totalEventTypes: etRes[0].result[0].count }));
			}
			if (tmRes && tmRes[0]?.result?.[0]?.count) {
				setMetrics((prev) => ({ ...prev, totalTeams: tmRes[0].result[0].count }));
			}
		} catch (e) {
			console.error("Failed to load booking dashboard metrics:", e);
		}
	};

	useEffect(() => {
		loadData();
	}, []);

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Tableau de Bord Lyxal Booking</Title>
					<Text c="dimmed" size="sm">
						Vue d'ensemble des réservations, hôtes et prestations actives (`fn::booking_*`)
					</Text>
				</div>
				<Button variant="light" onClick={loadData}>
					Actualiser
				</Button>
			</Group>

			<SimpleGrid cols={{ base: 1, sm: 2, md: 4 }}>
				<Card withBorder padding="lg" radius="md">
					<Text size="xs" c="dimmed" tt="uppercase" fw={700}>
						Réservations Totales
					</Text>
					<Text fz="xl" fw={700}>
						{metrics.totalBookings}
					</Text>
				</Card>
				<Card withBorder padding="lg" radius="md">
					<Text size="xs" c="dimmed" tt="uppercase" fw={700}>
						Confirmées
					</Text>
					<Text fz="xl" fw={700} c="green">
						{metrics.confirmedBookings}
					</Text>
				</Card>
				<Card withBorder padding="lg" radius="md">
					<Text size="xs" c="dimmed" tt="uppercase" fw={700}>
						En Attente
					</Text>
					<Text fz="xl" fw={700} c="yellow">
						{metrics.pendingBookings}
					</Text>
				</Card>
				<Card withBorder padding="lg" radius="md">
					<Text size="xs" c="dimmed" tt="uppercase" fw={700}>
						Prestations Actives
					</Text>
					<Text fz="xl" fw={700} c="blue">
						{metrics.totalEventTypes}
					</Text>
				</Card>
			</SimpleGrid>

			<Card withBorder padding="lg" radius="md">
				<Title order={4} mb="md">
					Dernières Réservations
				</Title>
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Client / Guest</Table.Th>
							<Table.Th>Email</Table.Th>
							<Table.Th>Début</Table.Th>
							<Table.Th>Fin</Table.Th>
							<Table.Th>Statut</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{recentBookings.map((b: any) => (
							<Table.Tr key={b.id}>
								<Table.Td>{b.guest_name || "N/A"}</Table.Td>
								<Table.Td>{b.guest_email || "N/A"}</Table.Td>
								<Table.Td>{b.start_at || "N/A"}</Table.Td>
								<Table.Td>{b.end_at || "N/A"}</Table.Td>
								<Table.Td>
									<Text
										c={
											b.status === "confirmed"
												? "green"
												: b.status === "cancelled"
													? "red"
													: "yellow"
										}
										fw={600}
									>
										{b.status || "pending"}
									</Text>
								</Table.Td>
							</Table.Tr>
						))}
						{recentBookings.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={5} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucune réservation enregistrée.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>
		</Stack>
	);
}
