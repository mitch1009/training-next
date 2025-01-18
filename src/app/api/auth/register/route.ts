import { NextResponse } from "next/server";
import { AuthService } from "@/app/server/auth/service";

export async function POST(request: Request) {
  const user = await request.json();
  const response = await AuthService.register(user);
  return NextResponse.json(response);
}
