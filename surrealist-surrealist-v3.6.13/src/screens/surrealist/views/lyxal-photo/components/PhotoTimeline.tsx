import { SimpleGrid, Image, AspectRatio } from "@mantine/core";

// Mock data based on Lyxal Photo DTO
const MOCK_PHOTOS = Array.from({ length: 20 }).map((_, i) => ({
    id: `photo-${i}`,
    url: `https://picsum.photos/seed/${i}/400/400`,
    title: `Photo ${i}`
}));

export function PhotoTimeline() {
    return (
        <SimpleGrid cols={{ base: 2, sm: 3, md: 4, lg: 5 }} spacing="xs">
            {MOCK_PHOTOS.map((photo) => (
                <AspectRatio key={photo.id} ratio={1}>
                    <Image 
                        src={photo.url} 
                        radius="md" 
                        alt={photo.title}
                        style={{ cursor: "pointer", transition: "transform 0.2s" }}
                    />
                </AspectRatio>
            ))}
        </SimpleGrid>
    );
}
