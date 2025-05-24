export interface Prescription {
  text: string;
  name: string;
  createdAt: Date;
  id_pet: string;
  id_vet: string;
  milligrams: number;
}
