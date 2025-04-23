// import { User } from "./user.interface";
export interface Clinic {
  id: number;
  name: string;
  address: string;
  phone: string;
  email: string;
  website: string;
  description: string;
  image: string;
  coordenates: Coordenates;
  categories: Categories[];
  vet: User[] | null;
  created_at: Date;
  updated_at: Date;
}
export interface Categories {
  id: number;
  name: string;
  description: string;
  image: string;
  created_at: Date;
  updated_at: Date;
}
export interface Coordenates {
  lat: number;
  lng: number;
}
export interface Clinic_Short {
  id: number;
  name: string;
  address: string;
  phone: string;
  coordenates: Coordenates;
}
