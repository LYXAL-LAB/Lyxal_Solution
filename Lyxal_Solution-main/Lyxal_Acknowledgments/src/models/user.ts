export interface UserProps {
    sub: string;
    email: string;
    name: string;
}

export class User {
    sub: string;
    email: string;
    name: string;

    constructor(props: UserProps) {
        this.sub = props.sub;
        this.email = props.email;
        this.name = props.name;
    }

    isValid(): boolean {
        return !!(this.sub?.trim() && this.email?.trim());
    }

    normalizedEmail(): string {
        return this.email.toLowerCase();
    }
}
