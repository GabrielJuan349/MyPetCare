export interface WorkingDay {
  start: string; // e.g., "9:00"
  end: string; // e.g., "17:00"
}

export interface WorkingHours {
  monday?: WorkingDay;
  tuesday?: WorkingDay;
  wednesday?: WorkingDay;
  thursday?: WorkingDay;
  friday?: WorkingDay;
  saturday?: WorkingDay;
  sunday?: WorkingDay;
}

export interface Vet {
  clinicId: string;
  firstName: string;
  lastName: string;
  specialities: string[]; // e.g., ["Dermatología", "Oftalmología"]
  workingHours: WorkingHours;
  email?: string;
  available?: boolean;
  createdAt?: string; // ISO 8601 string (e.g., "2025-05-10T10:30:00Z")
}
