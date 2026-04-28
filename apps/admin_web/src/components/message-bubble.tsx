'use client'

import DOMPurify from 'dompurify'

interface MessageBubbleProps {
  content: string
  role: 'user' | 'assistant'
}

export function MessageBubble({ content, role }: MessageBubbleProps) {
  // Sanitize HTML to prevent XSS — AI tutor messages are user-generated content
  const sanitized = DOMPurify.sanitize(content, { ALLOWED_TAGS: [] })

  return (
    <div
      className={`max-w-[80%] rounded-lg px-4 py-2 ${
        role === 'user'
          ? 'bg-blue-500 text-white'
          : 'bg-slate-200 text-slate-900'
      }`}
    >
      <p className="text-xs opacity-70 mb-1">
        {role === 'user' ? 'Child' : 'AI Tutor'}
      </p>
      <p className="text-sm whitespace-pre-wrap">{sanitized}</p>
    </div>
  )
}
