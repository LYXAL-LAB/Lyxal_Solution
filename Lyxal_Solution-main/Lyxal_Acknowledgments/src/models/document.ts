export interface DocumentProps {
    id: string;
    title: string;
    url: string;
    checksum: string;
    checksum_algorithm: string;
    description: string;
    created_at: Date;
    updated_at: Date;
    created_by: string;
    deleted_at?: Date;
}

export class Document {
    id: string;
    title: string;
    url: string;
    checksum: string;
    checksum_algorithm: string;
    description: string;
    created_at: Date;
    updated_at: Date;
    created_by: string;
    deleted_at?: Date;

    constructor(props: DocumentProps) {
        this.id = props.id;
        this.title = props.title;
        this.url = props.url;
        this.checksum = props.checksum;
        this.checksum_algorithm = props.checksum_algorithm;
        this.description = props.description;
        this.created_at = props.created_at;
        this.updated_at = props.updated_at;
        this.created_by = props.created_by;
        this.deleted_at = props.deleted_at;
    }

    hasChecksum(): boolean {
        return !!this.checksum;
    }

    getExpectedChecksumLength(): number {
        switch (this.checksum_algorithm) {
            case "SHA-256":
                return 64;
            case "SHA-512":
                return 128;
            case "MD5":
                return 32;
            default:
                return 0;
        }
    }
}
