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
	Textarea,
	Title,
} from "@mantine/core";
import { Icon, iconCheck, iconClose, iconEdit, iconPlus, iconTrash } from "@surrealdb/ui";
import { useEffect, useState } from "react";
import { executeQuery } from "~/screens/surrealist/pages/Connection/connection/connection";

export interface BookingEventTypesProps {
	idPrefix?: string;
}

export function BookingEventTypes({ idPrefix = "booking-event-types" }: BookingEventTypesProps) {
	const [eventTypes, setEventTypes] = useState<any[]>([]);
	const [modalOpen, setModalOpen] = useState(false);
	const [editingId, setEditingId] = useState<string | null>(null);

	// Form State
	const [title, setTitle] = useState("");
	const [slug, setSlug] = useState("");
	const [duration, setDuration] = useState<number>(30);
	const [description, setDescription] = useState("");
	const [bufferBefore, setBufferBefore] = useState<number>(0);
	const [bufferAfter, setBufferAfter] = useState<number>(0);
	const [minNotice, setMinNotice] = useState<number>(0);
	const [maxNoticeDays, setMaxNoticeDays] = useState<number>(60);
	const [locationType, setLocationType] = useState<string>("jitsi_auto");
	const [locationValue, setLocationValue] = useState("");
	const [requiresConfirmation, setRequiresConfirmation] = useState(false);

	const loadEventTypes = async () => {
		try {
			const res = await executeQuery("SELECT * FROM booking_event_type ORDER BY title ASC;");
			if (res && Array.isArray(res[0]?.result)) {
				setEventTypes(res[0].result);
			}
		} catch (e) {
			console.error("Failed to load event types:", e);
		}
	};

	useEffect(() => {
		loadEventTypes();
	}, []);

	const openCreateModal = () => {
		setEditingId(null);
		setTitle("");
		setSlug("");
		setDuration(30);
		setDescription("");
		setBufferBefore(0);
		setBufferAfter(0);
		setMinNotice(0);
		setMaxNoticeDays(60);
		setLocationType("jitsi_auto");
		setLocationValue("");
		setRequiresConfirmation(false);
		setModalOpen(true);
	};

	const openEditModal = (et: any) => {
		setEditingId(et.id);
		setTitle(et.title || "");
		setSlug(et.slug || "");
		setDuration(et.duration_min || 30);
		setDescription(et.description || "");
		setBufferBefore(et.buffer_before || 0);
		setBufferAfter(et.buffer_after || 0);
		setMinNotice(et.min_notice_min || 0);
		setMaxNoticeDays(et.max_notice_days || 60);
		setLocationType(et.location_type || "jitsi_auto");
		setLocationValue(et.location_value || "");
		setRequiresConfirmation(!!et.requires_confirmation);
		setModalOpen(true);
	};

	const handleSave = async () => {
		if (!title.trim() || !slug.trim()) return;

		try {
			if (editingId) {
				await executeQuery(`
					UPDATE ${editingId} SET
						title = '${title.replace(/'/g, "\\'")}',
						slug = '${slug.replace(/'/g, "\\'")}',
						duration_min = ${duration},
						description = '${description.replace(/'/g, "\\'")}',
						buffer_before = ${bufferBefore},
						buffer_after = ${bufferAfter},
						min_notice_min = ${minNotice},
						max_notice_days = ${maxNoticeDays},
						location_type = '${locationType}',
						location_value = '${locationValue.replace(/'/g, "\\'")}',
						requires_confirmation = ${requiresConfirmation};
				`);
			} else {
				await executeQuery(`
					RETURN fn::booking_create_event_type(
						r'booking_account:admin',
						'${title.replace(/'/g, "\\'")}',
						'${slug.replace(/'/g, "\\'")}',
						${duration},
						${bufferBefore},
						${bufferAfter},
						${requiresConfirmation}
					);
				`);
			}
			setModalOpen(false);
			loadEventTypes();
		} catch (e) {
			console.error("Save event type failed:", e);
		}
	};

	const handleToggle = async (eventTypeId: string) => {
		try {
			await executeQuery(`RETURN fn::booking_toggle_event_type('${eventTypeId}');`);
			loadEventTypes();
		} catch (e) {
			console.error("Toggle event type failed:", e);
		}
	};

	const handleDelete = async (eventTypeId: string) => {
		try {
			await executeQuery(`RETURN fn::booking_delete_event_type('${eventTypeId}');`);
			loadEventTypes();
		} catch (e) {
			console.error("Delete event type failed:", e);
		}
	};

	return (
		<Stack gap="md" id={`${idPrefix}-root`}>
			<Group justify="space-between">
				<div>
					<Title order={2}>Types d'Événements & Prestations (`cal.rs` Conforme)</Title>
					<Text c="dimmed" size="sm">
						Gestion des prestations, durées, tampons et règles de prise de RDV
					</Text>
				</div>
				<Group>
					<Button variant="light" onClick={loadEventTypes}>
						Actualiser
					</Button>
					<Button leftSection={<Icon path={iconPlus} />} onClick={openCreateModal}>
						Nouveau Type d'Événement
					</Button>
				</Group>
			</Group>

			<Card withBorder padding="lg" radius="md">
				<Table striped highlightOnHover>
					<Table.Thead>
						<Table.Tr>
							<Table.Th>Titre</Table.Th>
							<Table.Th>Lien / Slug</Table.Th>
							<Table.Th>Durée</Table.Th>
							<Table.Th>Tampons (Avant/Après)</Table.Th>
							<Table.Th>Lieu / Emplacement</Table.Th>
							<Table.Th>Approbation Manuelle</Table.Th>
							<Table.Th>Statut</Table.Th>
							<Table.Th style={{ textAlign: "right" }}>Actions</Table.Th>
						</Table.Tr>
					</Table.Thead>
					<Table.Tbody>
						{eventTypes.map((et: any) => (
							<Table.Tr key={et.id}>
								<Table.Td fw={600}>{et.title || "N/A"}</Table.Td>
								<Table.Td>/{et.slug || "n-a"}</Table.Td>
								<Table.Td>{et.duration_min || 30} min</Table.Td>
								<Table.Td>
									+{et.buffer_before || 0}m / +{et.buffer_after || 0}m
								</Table.Td>
								<Table.Td>{et.location_type || "Jitsi Video"}</Table.Td>
								<Table.Td>
									{et.requires_confirmation ? (
										<Badge color="yellow">Oui</Badge>
									) : (
										<Badge color="gray">Non</Badge>
									)}
								</Table.Td>
								<Table.Td>
									<Badge color={et.enabled !== false ? "green" : "gray"}>
										{et.enabled !== false ? "Actif" : "Inactif"}
									</Badge>
								</Table.Td>
								<Table.Td style={{ textAlign: "right" }}>
									<Group gap="xs" justify="flex-end">
										<ActionIcon variant="subtle" color="blue" onClick={() => openEditModal(et)}>
											<Icon path={iconEdit} />
										</ActionIcon>
										<Button
											size="xs"
											variant="light"
											color={et.enabled !== false ? "orange" : "green"}
											onClick={() => handleToggle(et.id)}
										>
											{et.enabled !== false ? "Désactiver" : "Activer"}
										</Button>
										<ActionIcon variant="subtle" color="red" onClick={() => handleDelete(et.id)}>
											<Icon path={iconTrash} />
										</ActionIcon>
									</Group>
								</Table.Td>
							</Table.Tr>
						))}
						{eventTypes.length === 0 && (
							<Table.Tr>
								<Table.Td colSpan={8} style={{ textAlign: "center" }}>
									<Text c="dimmed">Aucun type d'événement créé.</Text>
								</Table.Td>
							</Table.Tr>
						)}
					</Table.Tbody>
				</Table>
			</Card>

			{/* Modal Form Conforme à event_type_form.html */}
			<Modal
				opened={modalOpen}
				onClose={() => setModalOpen(false)}
				title={editingId ? "Modifier le Type d'Événement" : "Créer un Type d'Événement"}
				size="lg"
			>
				<Stack gap="md">
					<TextInput
						label="Titre de la prestation"
						placeholder="ex: Consultation 30 minutes"
						required
						value={title}
						onChange={(e) => setTitle(e.currentTarget.value)}
					/>
					<TextInput
						label="URL Slug"
						placeholder="ex: consultation-30min"
						required
						value={slug}
						onChange={(e) => setSlug(e.currentTarget.value)}
					/>
					<Group grow>
						<NumberInput
							label="Durée (minutes)"
							min={5}
							max={480}
							value={duration}
							onChange={(v) => setDuration(Number(v) || 30)}
						/>
						<Select
							label="Type d'emplacement / Lieu"
							data={[
								{ value: "jitsi_auto", label: "Visioconférence Jitsi Auto" },
								{ value: "webhook_auto", label: "Webhook Visioconférence" },
								{ value: "in_person", label: "Présentiel (Adresse)" },
								{ value: "phone", label: "Appel Téléphonique" },
							]}
							value={locationType}
							onChange={(v) => setLocationType(v || "jitsi_auto")}
						/>
					</Group>
					<Textarea
						label="Description de l'événement"
						placeholder="Présentation détaillée affichée au client lors de la prise de RDV..."
						value={description}
						onChange={(e) => setDescription(e.currentTarget.value)}
					/>
					<Group grow>
						<NumberInput
							label="Buffer Avant (minutes)"
							min={0}
							value={bufferBefore}
							onChange={(v) => setBufferBefore(Number(v) || 0)}
						/>
						<NumberInput
							label="Buffer Après (minutes)"
							min={0}
							value={bufferAfter}
							onChange={(v) => setBufferAfter(Number(v) || 0)}
						/>
					</Group>
					<Group grow>
						<NumberInput
							label="Préavis Minimum (minutes)"
							min={0}
							value={minNotice}
							onChange={(v) => setMinNotice(Number(v) || 0)}
						/>
						<NumberInput
							label="Fenêtre Max de Réservation (jours)"
							min={1}
							value={maxNoticeDays}
							onChange={(v) => setMaxNoticeDays(Number(v) || 60)}
						/>
					</Group>
					<Checkbox
						label="Exiger une confirmation manuelle de l'hôte avant validation"
						checked={requiresConfirmation}
						onChange={(e) => setRequiresConfirmation(e.currentTarget.checked)}
					/>
					<Group justify="flex-end" mt="md">
						<Button variant="default" onClick={() => setModalOpen(false)}>
							Annuler
						</Button>
						<Button onClick={handleSave}>Enregistrer la Prestation</Button>
					</Group>
				</Stack>
			</Modal>
		</Stack>
	);
}
