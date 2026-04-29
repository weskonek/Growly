'use client'

import { createLesson, updateLesson, deleteLesson, togglePublish } from './actions'
import { useFormStatus } from 'react-dom'

function SubmitButton({ label }: { label: string }) {
  const { pending } = useFormStatus()
  return (
    <button
      type="submit"
      disabled={pending}
      className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2"
    >
      {pending ? 'Menyimpan...' : label}
    </button>
  )
}

export { createLesson, updateLesson, deleteLesson, togglePublish, SubmitButton }