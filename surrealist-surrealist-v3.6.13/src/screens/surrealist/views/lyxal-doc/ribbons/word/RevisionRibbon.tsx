import { Group, Stack, Button, Text } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    iconCheck2,
    iconSearch,
    iconList2,
    iconPlus,
    iconEye
} from "~/util/icons";

export function RevisionRibbon() {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
            {/* Vérification */}
            <Stack gap={2}>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconCheck2} size={14} stroked />
                        <Text size="10px" fw={500}>Grammaire</Text>
                    </Group>
                </Button>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconSearch} size={14} stroked />
                        <Text size="10px" fw={500}>Synonymes</Text>
                    </Group>
                </Button>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconList2} size={14} stroked />
                        <Text size="10px" fw={500}>Statistiques</Text>
                    </Group>
                </Button>
            </Stack>

            {/* Commentaires */}
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={70} 
                p={0} 
                radius="xs" 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconPlus} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Commentaire</Text>
                </Stack>
            </Button>

            {/* Suivi */}
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={70} 
                p={0} 
                radius="xs" 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconEye} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Suivi</Text>
                </Stack>
            </Button>
        </Group>
    );
}
