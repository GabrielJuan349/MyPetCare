export interface Treatment {
  id_pet: string;
  id_vet: string;
  name: string;
  date_start: Date;
  date_end: Date;
  createdAt?: Date;
}
