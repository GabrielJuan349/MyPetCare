
export interface AppointmentsIdAll{
    petId:string,
    vetId:string,
}
export interface AppointmentsInfoAll{
    id: string;
    date: string;
    time: string;
    petName?: string;
    vetName?: string;
    clinicName?: string;
}
export interface AppDataById{
    id: string,
    date:string,
    time:string,
    vetName:string,
    clinicName:string,
    petName:string,
    petType:string,
    petBreed:string,
    ownerName:string,
    ownerEmail:string,
    ownerPhone:string,
    ownerId:string,
    clinicId:string,
    vetId:string,
    petId:string
}
