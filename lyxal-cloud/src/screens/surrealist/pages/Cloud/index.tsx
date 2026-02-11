import { Container, Stack, Tabs, Text, Title, Group, Badge } from "@mantine/core";
import { type FC, useState } from "react";
import { ClusterView } from "./ClusterView";
import { RealmsView } from "./RealmsView";
import { LedgerView } from "./LedgerView";
import { iconCloud, iconServer, iconAccount, iconCreditCard } from "~/util/icons";
import { Icon } from "~/components/Icon";

export const CloudPage: FC = () => {
    const [activeTab, setActiveTab] = useState<string | null>("cluster");

    return (
        <Container size="xl" py="xl">
            <Stack gap="xl">
                <Group justify="space-between">
                    <Stack gap={4}>
                        <Group gap="sm">
                            <Icon path={iconCloud} size={1.5} color="surreal" />
                            <Title order={2}>Lyxal Cloud Cockpit</Title>
                        </Group>
                        <Text c="dimmed">Internal Control Plane for Lyxal Infrastructure</Text>
                    </Stack>
                    <Badge size="xl" variant="filled" color="blue" radius="sm">
                        Cluster: Active
                    </Badge>
                </Group>

                <Tabs value={activeTab} onChange={setActiveTab} variant="outline">
                    <Tabs.List>
                        <Tabs.Tab value="cluster" leftSection={<Icon path={iconServer} size={0.8} />}>
                            Cluster Health
                        </Tabs.Tab>
                        <Tabs.Tab value="realms" leftSection={<Icon path={iconAccount} size={0.8} />}>
                            Realm Manager
                        </Tabs.Tab>
                        <Tabs.Tab value="ledger" leftSection={<Icon path={iconCreditCard} size={0.8} />}>
                            Billing & Ledger
                        </Tabs.Tab>
                    </Tabs.List>

                    <Tabs.Panel value="cluster" pt="xl">
                        <ClusterView />
                    </Tabs.Panel>

                    <Tabs.Panel value="realms" pt="xl">
                        <RealmsView />
                    </Tabs.Panel>

                    <Tabs.Panel value="ledger" pt="xl">
                        <LedgerView />
                    </Tabs.Panel>
                </Tabs>
            </Stack>
        </Container>
    );
};

export default CloudPage;
