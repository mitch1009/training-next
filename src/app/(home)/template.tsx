export default function HomeLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <div>
      <h1>Home Navigation</h1>
      {children}
    </div>
  );
}
