import { TextInput } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { mdiMagnify } from "@mdi/js";

export function SearchBar() {
    return (
        <TextInput
            id="lyxal-search-input"
            placeholder="Rechercher 'chats', 'été 2023', 'Paris'..."
            leftSection={<Icon path={mdiMagnify} />}
            variant="filled"
            radius="xl"
            size="md"
            style={{ width: "100%", maxWidth: "720px" }}
        />
    );
}
