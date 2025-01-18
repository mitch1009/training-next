import { NextResponse } from "next/server";

export async function GET() {
  const user = { email: "test@test.com", password: "test" };
  return NextResponse.json(user);
}
