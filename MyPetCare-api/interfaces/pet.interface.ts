import { DocumentReference } from "firebase-admin/firestore";

export interface Pet {
  id: string;
  name: string;
  type: "dog" | "cat" | "rodent" | "other";
  breed: string;
  birthDate: string;
  age: number;
  weight: number;
  owner: DocumentReference;
  photoUrls: string[];
  createdAt: Date;
  lastUpdated: Date;
}
