
export interface AppointmentsIdAll{
    petId:string,
    vetId:string,
}
export interface getDateInfoReturn{
    databaseIndex:string,
    day:string,  
    buttonId:number
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
    type:string,
    reason:string,
    userId:string,
    clinicId:string,
    vetId:string,
    petId:string
}

export interface functionResponse {
    error?: {
        status: number;
        body: {
            error: string;
            details: string|unknown;
        };
    };
    done: boolean;
}