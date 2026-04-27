import type { Metadata } from 'next'
import { Toaster } from 'sonner'
import { cookies } from 'next/headers'
import './globals.css'

export const metadata: Metadata = {
  title: 'Growly Admin',
  description: 'Growly Admin Dashboard',
}

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const cookieStore = await cookies()

  return (
    <html lang="en">
      <body className="min-h-screen bg-background font-sans antialiased">
        {children}
        <Toaster position="top-right" />
      </body>
    </html>
  )
}
