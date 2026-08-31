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
	Textarea,
	Title,
} from "@mantine/core";
import { Icon, iconEdit, iconPlus, iconTrash } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingTeamsProps {
	idPrefix?: string;
}

export function BookingTeams({ idPrefix = "booking-teams" }: BookingTeamsProps) {
	const [teams, setTeams] = useState<any[]>([]);
	const [modalOpen, setModalOpen] = useState(false);
	const [editingId, setEditingId] = useState<string | null>(null);

	// Team Form State
	const [name, setName] = useState("");
	const [slug, setSlug] = useState("");
	const [description, setDescription] = useState("");

	const loadTeams = async () => {
		try {
			const res = await executeQuery(
				"SELECT *, (SELECT * FROM booking_team_member WHERE team = $parent.id) AS members FROM booking_team ORDER BY name ASC;",
			);
			if (res && Array.isArray(res[0]?.result)) {
				setTeams(res[0].result);
			}
		} catch (e) {
			console.error("Failed to load teams:", e);
		}
	};

	useEffect(() => {
		loadTeams();
	}, []);

	const openCreateModal = () => {
		setEditingId(null);
		setName("");
		setSlug("");
		setDescription("");
		setModalOpen(true);
	};

	const openEditModal = (t: any) => {
		setEditingId(t.id);
		setName(t.name || "");
		setSlug(t.slug || "");
		setDescription(t.description || "");
		setModalOpen(true);
	};

	const handleSave = async () => {
		if (!name.trim() || !slug.trim()) return;

		try {
			if (editingId) {
				await executeQuery(`
					UPDATE ${editingId} SET
						name = '${name.replace(/'/g, "\\'")}',
						slug = '${slug.replace(/'/g, "\\'")}',
						description = '${description.replace(/'/g, "\\'")}';
				`);
			} else {
				await executeQuery(`
					CREATE booking_team CONTENT {
						name: '${name.replace(/'/g, "\\'")}',
						slug: '${slug.replace(/'/g, "\\'")}',
						description: '${description.replace(/'/g, "\\'")}'
					};
				`);
			}
			setModalOpen(false);
			loadTeams();
		} catch (e) {
			console.error("Save team failed:", e);
		}
	};

	const handleDelete = async (teamId: string) => {
		try {
			await executeQuery(`DELETE ${teamId};`);
			loadTeams();
		} catch (e) {
			console.error("Delete team failed:", e);
		}
	};

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Équipes & Distribution Round-Robin (`cal.rs` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Groupes d'hôtes et algorithme d'attribution automatique (`team_form.html`)
					</Text>
				</div>
				<Group>
					<Button variant="light" onClick={loadTeams}>
						Actualiser
					</Button>
					<Button leftSection={<Icon path={iconPlus} />} onClick={openCreateModal}>
						Nouvelle Équipe
					</Button>
				</Group>
			</Group>

			<Card withBorder padding="lg" radius="md">
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Nom de l'Équipe</Table.Th>
							<Table.Th>URL Slug</Table.Th>
							<Table.Th>Membres & Rôles</Table.Th>
							<Table.Th>Nombre de Membres</Table.Th>
							<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{teams.map((t: any) => (
							<Table.Tr key={t.id}>
								<Table.Td fw={600}>{t.name || "N/A"}</Table.Td>
								<Table.Td>/{t.slug || "n-a"}</Table.Td>
								<Table.Td>
									<Group gap="xs">
										{Array.isArray(t.members) && t.members.length > 0 ? (
											t.members.map((m: any, idx: number) => (
												<Badge key={idx} variant="outline" size="sm">
													{m.role || "membre"} (poids: {m.weight || 100})
												</Badge>
											))
										) : (
											<Text size="xs" c="dimmed">
												Aucun membre
											</Text>
										)}
									</Group>
								</Table.Td>
								<Table.Td>{Array.isArray(t.members) ? t.members.length : 0}</Table.Td>
								<Table.Td style={{ textAlign: "right" }}>
									<Group gap="xs" justify="flex-end">
										<ActionIcon variant="subtle" color="blue" onClick={() => openEditModal(t)}>
											<Icon path={iconEdit} />
										</ActionIcon>
										<ActionIcon variant="subtle" color="red" onClick={() => handleDelete(t.id)}>
											<Icon path={iconTrash} />
										</ActionIcon>
									</Group>
								</Table.Td>
							</Table.Tr>
						))}
						{teams.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={5} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucune équipe configurée.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Modal Form Conforme à team_form.html */}
			<Modal
				opened={modalOpen}
				onClose={() => setModalOpen(false)}
				title={editingId ? "Modifier l'Équipe" : "Créer une Équipe"}
				size="md"
			>
				<Stack gap="md">
					<TextInput
						label="Nom de l'équipe"
						placeholder="ex: Équipe Commerciale"
						required
						value={name}
						onChange={(e) => setName(e.currentTarget.value)}
					/>
					<TextInput
						label="URL Slug de l'équipe"
						placeholder="ex: equipe-commerciale"
						required
						value={slug}
						onChange={(e) => setSlug(e.currentTarget.value)}
					/>
					<Textarea
						label="Description de l'équipe"
						placeholder="Présentation des objectifs ou spécialités de l'équipe..."
						value={description}
						onChange={(e) => setDescription(e.currentTarget.value)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setModalOpen(false)}>
							Annuler
						</Button>
						<Button onClick={handleSave}>Enregistrer l'Équipe</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
