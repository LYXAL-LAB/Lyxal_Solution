import { Group, Stack, Button, Text } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    iconEye,
    iconPhoto,
    iconSearch,
    iconList2,
    iconTable2
} from "~/util/icons";

export function AffichageRibbon() {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
            {/* Vues */}
            <Group gap={4} wrap="nowrap">
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
                        <Icon path={iconEye} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Lecture</Text>
                    </Stack>
                </Button>
                <Button 
                    variant="light" 
                    color="surreal" 
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
                        <Icon path={iconPhoto} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Page</Text>
                    </Stack>
                </Button>
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
                        <Icon path={iconSearch} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Web</Text>
                    </Stack>
                </Button>
            </Group>

            {/* Afficher */}
            <Stack gap={2}>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconList2} size={14} stroked />
                        <Text size="10px" fw={500}>Règle</Text>
                    </Group>
                </Button>
                <Button variant="subtle" color="slate" size="xs" radius="xs" px={8} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                    <Group gap={4}>
                        <Icon path={iconTable2} size={14} stroked />
                        <Text size="10px" fw={500}>Quadrillage</Text>
                    </Group>
                </Button>
            </Stack>

            {/* Zoom */}
            <Group gap={4} wrap="nowrap">
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
                        <Icon path={iconSearch} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Zoom</Text>
                    </Stack>
                </Button>
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
                        <Icon path={iconSearch} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>100%</Text>
                    </Stack>
                </Button>
            </Group>
        </Group>
    );
}
