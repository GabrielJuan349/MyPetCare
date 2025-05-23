export interface User {
  email: string;
  password: string;
  userId: string;
  accountType: AccountType;
  firstName: string;
  lastName: string;
  phone: string;
  locality: string;
  clinicInfo: string;
}
export enum AccountType {
  owner,
  vet,
  clinic,
}
