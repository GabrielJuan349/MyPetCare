export enum AccountType {
    owner,
    vet,
    clinic,
}

export interface User {
    id: string;
    name: string;
    email: string;
    accountType: AccountType;
    phone: string;
}