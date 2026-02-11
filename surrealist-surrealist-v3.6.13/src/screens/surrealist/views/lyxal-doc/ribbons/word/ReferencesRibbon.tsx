import { Group, Button, Stack, Text, Menu, Divider, Box } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    iconTableOfContent,
    iconChevronDown,
    iconPlus,
    iconRedo2,
    iconNote,
    iconChevronRight,
    iconEye,
    iconSearch,
    iconText,
    iconList2,
    iconList,
    iconTag,
    iconTable,
    iconListOrdered,
    iconLink2
} from "~/util/icons";

export function ReferencesRibbon() {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
            {/* Table des matières */}
            <Group gap={4} wrap="nowrap">
                <Menu shadow="md" width={220}>
                    <Menu.Target>
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
                                <Icon path={iconTableOfContent} size={20} stroked />
                                <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Table des matières</Text>
                            </Stack>
                        </Button>
                    </Menu.Target>
                    <Menu.Dropdown p="xs">
                        <Menu.Label>Automatique</Menu.Label>
                        <Menu.Item style={{ fontSize: '12px' }}>Table automatique 1</Menu.Item>
                        <Menu.Item style={{ fontSize: '12px' }}>Table automatique 2</Menu.Item>
                        <Menu.Label>Manuelle</Menu.Label>
                        <Menu.Item style={{ fontSize: '12px' }}>Table manuelle</Menu.Item>
                        <Divider />
                        <Menu.Item style={{ fontSize: '12px' }}>Table des matières personnalisée...</Menu.Item>
                        <Menu.Item style={{ fontSize: '12px' }}>Supprimer la table des matières</Menu.Item>
                    </Menu.Dropdown>
                </Menu>
                <Stack gap={2}>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconPlus} size={14} stroked />
                            <Text size="10px" fw={500}>Ajouter le texte</Text>
                        </Group>
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconRedo2} size={14} stroked />
                            <Text size="10px" fw={500}>Mettre à jour la table</Text>
                        </Group>
                    </Button>
                </Stack>
            </Group>
            
            {/* Notes de bas de page */}
            <Group gap={4} wrap="nowrap">
                <Button 
                    variant="subtle" 
                    color="slate" 
                    h={76} 
                    w={75} 
                    p={0} 
                    radius="xs" 
                    styles={{ 
                        inner: { width: '100%', justifyContent: 'center' }, 
                        label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                    }}
                >
                    <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                        <Icon path={iconNote} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Note de bas de page</Text>
                    </Stack>
                </Button>
                <Stack gap={2}>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconNote} size={14} stroked />
                            <Text size="10px" fw={500}>Note de fin</Text>
                        </Group>
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconChevronRight} size={14} stroked />
                            <Text size="10px" fw={500}>Suivante</Text>
                        </Group>
                    </Button>
                </Stack>
            </Group>

            {/* Recherche */}
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
                    <Icon path={iconSearch} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Recherche</Text>
                </Stack>
            </Button>

            {/* Citations et bibliographie */}
            <Group gap={4} wrap="nowrap">
                <Stack gap={2}>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconText} size={14} stroked />
                            <Text size="10px" fw={500}>Citation</Text>
                        </Group>
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconList2} size={14} stroked />
                            <Text size="10px" fw={500}>Sources</Text>
                        </Group>
                    </Button>
                </Stack>
                <Stack gap={2}>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Text size="10px" fw={500}>Style: APA</Text>
                            <Icon path={iconChevronDown} size={10} />
                        </Group>
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconList} size={14} stroked />
                            <Text size="10px" fw={500}>Biblio</Text>
                        </Group>
                    </Button>
                </Stack>
            </Group>

            {/* Légendes */}
            <Group gap={4} wrap="nowrap">
                <Button 
                    variant="subtle" 
                    color="slate" 
                    h={76} 
                    w={65} 
                    p={0} 
                    radius="xs" 
                    styles={{ 
                        inner: { width: '100%', justifyContent: 'center' }, 
                        label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                    }}
                >
                    <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                        <Icon path={iconTag} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Légende</Text>
                    </Stack>
                </Button>
                <Stack gap={2}>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconTable} size={14} stroked />
                            <Text size="10px" fw={500}>Table illustrations</Text>
                        </Group>
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" radius="xs" px={4} h={24} styles={{ inner: { justifyContent: 'flex-start' } }}>
                        <Group gap={4}>
                            <Icon path={iconLink2} size={14} stroked />
                            <Text size="10px" fw={500}>Renvoi</Text>
                        </Group>
                    </Button>
                </Stack>
            </Group>

            {/* Index */}
            <Group gap={2} wrap="nowrap">
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
                        <Icon path={iconTag} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Entrée</Text>
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
                        <Icon path={iconListOrdered} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Index</Text>
                    </Stack>
                </Button>
            </Group>
        </Group>
    );
}
