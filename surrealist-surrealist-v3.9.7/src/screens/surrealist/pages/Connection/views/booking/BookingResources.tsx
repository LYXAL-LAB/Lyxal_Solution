import {
	ActionIcon,
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
import { Icon, iconEdit, iconPlus, iconTrash } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingResourcesProps {
	idPrefix?: string;
}

export function BookingResources({ idPrefix = "booking-resources" }: BookingResourcesProps) {
	const [resources, setResources] = useState<any[]>([]);
	const [modalOpen, setModalOpen] = useState(false);
	const [editingId, setEditingId] = useState<string | null>(null);

	// Resource Form State
	const [name, setName] = useState("");
	const [resourceType, setResourceType] = useState("Meeting Room");
	const [capacity, setCapacity] = useState<number>(1);

	const loadResources = async () => {
		try {
			const res = await executeQuery("SELECT * FROM booking_resource ORDER BY name ASC;");
			if (res && Array.isArray(res[0]?.result)) {
				setResources(res[0].result);
			}
		} catch (e) {
			console.error("Failed to load resources:", e);
		}
	};

	useEffect(() => {
		loadResources();
	}, []);

	const openCreateModal = () => {
		setEditingId(null);
		setName("");
		setResourceType("Meeting Room");
		setCapacity(1);
		setModalOpen(true);
	};

	const openEditModal = (r: any) => {
		setEditingId(r.id);
		setName(r.name || "");
		setResourceType(r.resource_type || "Meeting Room");
		setCapacity(r.capacity || 1);
		setModalOpen(true);
	};

	const handleSave = async () => {
		if (!name.trim()) return;

		try {
			if (editingId) {
				await executeQuery(`
					UPDATE ${editingId} SET
						name = '${name.replace(/'/g, "\\'")}',
						resource_type = '${resourceType}',
						capacity = ${capacity};
				`);
			} else {
				await executeQuery(`
					CREATE booking_resource CONTENT {
						name: '${name.replace(/'/g, "\\'")}',
						resource_type: '${resourceType}',
						capacity: ${capacity},
						enabled: true
					};
				`);
			}
			setModalOpen(false);
			loadResources();
		} catch (e) {
			console.error("Save resource failed:", e);
		}
	};

	const handleDelete = async (resId: string) => {
		try {
			await executeQuery(`DELETE ${resId};`);
			loadResources();
		} catch (e) {
			console.error("Delete resource failed:", e);
		}
	};

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Ressources Partagées (Salles & Matériel - `cal.rs` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Réservation physique et prévention des doublons de réservation (`fn::booking_allocate_resource`)
					</Text>
				</div>
				<Group>
					<Button variant="light" onClick={loadResources}>
						Actualiser
					</Button>
					<Button leftSection={<Icon path={iconPlus} />} onClick={openCreateModal}>
						Ajouter une Ressource
					</Button>
				</Group>
			</Group>

			<Card withBorder padding="lg" radius="md">
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Nom de la Ressource</Table.Th>
							<Table.Th>Type / Catégorie</Table.Th>
							<Table.Th>Capacité / Quantité</Table.Th>
							<Table.Th>Statut</Table.Th>
							<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{resources.map((r: any) => (
							<Table.Tr key={r.id}>
								<Table.Td fw={600}>{r.name || "N/A"}</Table.Td>
								<Table.Td>{r.resource_type || "Général"}</Table.Td>
								<Table.Td>{r.capacity || 1}</Table.Td>
								<Table.Td>
									<Badge color={r.enabled !== false ? "green" : "gray"}>
										{r.enabled !== false ? "Disponible" : "Hors Service"}
									</Badge>
								</Table.Td>
								<Table.Td style={{ textAlign: "right" }}>
									<Group gap="xs" justify="flex-end">
										<ActionIcon variant="subtle" color="blue" onClick={() => openEditModal(r)}>
											<Icon path={iconEdit} />
										</ActionIcon>
										<ActionIcon variant="subtle" color="red" onClick={() => handleDelete(r.id)}>
											<Icon path={iconTrash} />
										</ActionIcon>
									</Group>
								</Table.Td>
							</Table.Tr>
						))}
						{resources.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={5} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucune ressource physique configurée.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Modal Form Conforme */}
			<Modal
				opened={modalOpen}
				onClose={() => setModalOpen(false)}
				title={editingId ? "Modifier la Ressource" : "Ajouter une Ressource"}
				size="md"
			>
				<Stack gap="md">
					<TextInput
						label="Nom de la ressource"
						placeholder="ex: Salle de Réunion A, Projecteur 4K"
						required
						value={name}
						onChange={(e) => setName(e.currentTarget.value)}
					/>
					<Select
						label="Type de ressource"
						data={[
							{ value: "Meeting Room", label: "Salle de Réunion" },
							{ value: "Equipment", label: "Équipement / Matériel" },
							{ value: "Vehicle", label: "Véhicule de Service" },
						]}
						value={resourceType}
						onChange={(v) => setResourceType(v || "Meeting Room")}
					/>
					<NumberInput
						label="Capacité / Quantité disponible"
						min={1}
						value={capacity}
						onChange={(v) => setCapacity(Number(v) || 1)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setModalOpen(false)}>
							Annuler
						</Button>
						<Button onClick={handleSave}>Enregistrer la Ressource</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
