import { prisma } from "@/core/database";
import { User } from "@prisma/client";

declare interface UserWithPassword extends User {
    password: string;
}

export class AuthService {

    static async register(imput: UserWithPassword) {
       try {
        const {password, ...rest} = imput;
        await prisma.user.create({
            data: { ...rest, auth: { create: { password } } },
        });
        return {
            message: "User registered successfully",
            success: true,
        };
       } catch (error) {
        return {
            message: "Error registering user",
            success: false,
        };
       }
    }

    
}


