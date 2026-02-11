import { Group, Stack, Button, Text } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { iconHelp } from "~/util/icons";

export function AideRibbon() {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
            {/* Aide */}
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconHelp} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Aide</Text>
                </Stack>
            </Button>

            {/* Support */}
            <Stack gap={2}>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconHelp} size={14} stroked />
                        <Text size="10px" fw={500}>Contact</Text>
                    </Group>
                </Button>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconHelp} size={14} stroked />
                        <Text size="10px" fw={500}>Commentaires</Text>
                    </Group>
                </Button>
            </Stack>
        </Group>
    );
}
