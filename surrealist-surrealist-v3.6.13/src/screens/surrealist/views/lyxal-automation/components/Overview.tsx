import { SimpleGrid, Text, Group, Stack, TextInput, Button, Select } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { mdiMagnify, mdiPlus } from "@mdi/js";
import { WorkflowCard } from "./WorkflowCard";

// Mock data for workflows
const MOCK_WORKFLOWS = [
    { id: '1', name: 'Sync Customers to CRM', active: true, updated: '2 hours ago', tags: ['crm', 'sync'] },
    { id: '2', name: 'Email Notification on New Lead', active: false, updated: '1 day ago', tags: ['email'] },
    { id: '3', name: 'Backup Database to S3', active: true, updated: '3 days ago', tags: ['backup', 'aws'] },
    { id: '4', name: 'Process Stripe Webhooks', active: true, updated: '5 hours ago', tags: ['payment'] },
];

export function Overview() {
    return (
        <Stack gap="xl" p="xl">
            <Group justify="space-between" align="flex-end">
                <Stack gap={0}>
                    <Text size="xl" fw={700}>Workflows</Text>
                </Stack>
                <Button 
                    variant="filled" 
                    color="orange"
                    leftSection={<Icon path={mdiPlus} />}
                    radius="md"
                >
                    Add workflow
                </Button>
            </Group>

            <Group>
                <TextInput 
                    placeholder="Search workflows..." 
                    leftSection={<Icon path={mdiMagnify} size={0.8} />}
                    style={{ flex: 1 }}
                    radius="md"
                />
                <Select
                    placeholder="Status"
                    data={['All', 'Active', 'Inactive']}
                    w={150}
                    defaultValue="All"
                    radius="md"
                />
                <Select
                    placeholder="Sort by"
                    data={['Last updated', 'Name (A-Z)', 'Name (Z-A)']}
                    w={180}
                    defaultValue="Last updated"
                    radius="md"
                />
            </Group>

            <SimpleGrid cols={{ base: 1, sm: 2, lg: 3, xl: 4 }} spacing="lg">
                {MOCK_WORKFLOWS.map((workflow) => (
                    <WorkflowCard
                        key={workflow.id}
                        name={workflow.name}
                        active={workflow.active}
                        updatedAt={workflow.updated}
                        tags={workflow.tags}
                    />
                ))}
            </SimpleGrid>
        </Stack>
    );
}

