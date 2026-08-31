import {
	Badge,
	Button,
	Card,
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
import { Icon, iconCopy, iconPlus, iconTrash } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingInvitesProps {
	idPrefix?: string;
}

export function BookingInvites({ idPrefix = "booking-invites" }: BookingInvitesProps) {
	const [invites, setInvites] = useState<any[]>([]);
	const [eventTypes, setEventTypes] = useState<any[]>([]);
	const [modalOpen, setModalOpen] = useState(false);

	// Form State
	const [selectedEventType, setSelectedEventType] = useState<string>("");
	const [maxUses, setMaxUses] = useState<number>(1);
	const [expiresInDays, setExpiresInDays] = useState<number>(7);

	const loadData = async () => {
		try {
			const invRes = await executeQuery("SELECT * FROM booking_invite ORDER BY created_at DESC;");
			if (invRes && Array.isArray(invRes[0]?.result)) {
				setInvites(invRes[0].result);
			}

			const etRes = await executeQuery("SELECT id, title FROM booking_event_type WHERE enabled = true;");
			if (etRes && Array.isArray(etRes[0]?.result)) {
				setEventTypes(etRes[0].result);
				if (etRes[0].result.length > 0) {
					setSelectedEventType(etRes[0].result[0].id);
				}
			}
		} catch (e) {
			console.error("Failed to load invites/event-types:", e);
		}
	};

	useEffect(() => {
		loadData();
	}, []);

	const openCreateModal = () => {
		setMaxUses(1);
		setExpiresInDays(7);
		setModalOpen(true);
	};

	const handleCreateInvite = async () => {
		if (!selectedEventType) return;

		const token = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
		try {
			await executeQuery(`
				CREATE booking_invite CONTENT {
					event_type: ${selectedEventType},
					token: '${token}',
					uses: 0,
					max_uses: ${maxUses},
					expires_at: time::now() + ${expiresInDays}d
				};
			`);
			setModalOpen(false);
			loadData();
		} catch (e) {
			console.error("Create invite failed:", e);
		}
	};

	const handleDelete = async (inviteId: string) => {
		try {
			await executeQuery(`DELETE ${inviteId};`);
			loadData();
		} catch (e) {
			console.error("Delete invite failed:", e);
		}
	};

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Invitations Privées & Liens Éphémères (`invite_form.html` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Génération et contrôle d'expiration des liens éphémères (`fn::booking_validate_invite`)
					</Text>
				</div>
				<Group>
					<Button variant="light" onClick={loadData}>
						Actualiser
					</Button>
					<Button leftSection={<Icon path={iconPlus} />} onClick={openCreateModal}>
						Générer un Lien Privé
					</Button>
				</Group>
			</Group>

			<Card withBorder padding="lg" radius="md">
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Jeton / Token Privé</Table.Th>
							<Table.Th>Type d'Événement</Table.Th>
							<Table.Th>Utilisations (Effectuées / Max)</Table.Th>
							<Table.Th>Expiration</Table.Th>
							<Table.Th>Statut</Table.Th>
							<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{invites.map((inv: any) => (
							<Table.Tr key={inv.id}>
								<Table.Td fw={600}>{inv.token || "N/A"}</Table.Td>
								<Table.Td>{String(inv.event_type || "").replace("booking_event_type:", "")}</Table.Td>
								<Table.Td>
									{inv.uses || 0} / {inv.max_uses || 1}
								</Table.Td>
								<Table.Td>{inv.expires_at || "Sans expiration"}</Table.Td>
								<Table.Td>
									<Badge color={(inv.uses || 0) >= (inv.max_uses || 1) ? "gray" : "green"}>
										{(inv.uses || 0) >= (inv.max_uses || 1) ? "Épuisé" : "Valide"}
									</Badge>
								</Table.Td>
								<Table.Td style={{ textAlign: "right" }}>
									<Group gap="xs" justify="flex-end">
										<Button
											size="xs"
											variant="light"
											leftSection={<Icon path={iconCopy} />}
											onClick={() => {
												navigator.clipboard.writeText(inv.token);
											}}
										>
											Copier Jeton
										</Button>
										<ActionIcon variant="subtle" color="red" onClick={() => handleDelete(inv.id)}>
											<Icon path={iconTrash} />
										</ActionIcon>
									</Group>
								</Table.Td>
							</Table.Tr>
						))}
						{invites.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={6} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucun lien d'invitation privé n'a été généré.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Modal Form Conforme à invite_form.html */}
			<Modal opened={modalOpen} onClose={() => setModalOpen(false)} title="Générer un Lien Privé Éphémère" size="md">
				<Stack gap="md">
					<Select
						label="Type d'événement associé"
						data={eventTypes.map((et) => ({ value: et.id, label: et.title }))}
						value={selectedEventType}
						onChange={(v) => setSelectedEventType(v || "")}
					/>
					<NumberInput
						label="Nombre maximal d'utilisations"
						min={1}
						max={100}
						value={maxUses}
						onChange={(v) => setMaxUses(Number(v) || 1)}
					/>
					<NumberInput
						label="Expiration dans (jours)"
						min={1}
						max={365}
						value={expiresInDays}
						onChange={(v) => setExpiresInDays(Number(v) || 7)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setModalOpen(false)}>
							Annuler
						</Button>
						<Button onClick={handleCreateInvite}>Créer le Lien Privé</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
