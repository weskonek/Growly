'use server'

import { supabaseAdmin } from '@/lib/supabase/admin'
import { revalidatePath } from 'next/cache'

export type Lesson = {
  id: string
  title: string
  subject: string
  topic: string
  age_group: number | null
  status: string
  sort_order: number
  steps: unknown
  total_steps: number
  stars_reward: number
  created_at: string
  updated_at: string | null
  content: Record<string, unknown> | null
}

const SUBJECTS = ['reading', 'math', 'science', 'creative', 'language', 'general'] as const
const AGE_GROUPS = ['Batita (2-5)', 'Kanak-kanak awal (6-9)', 'Kanak-kanak akhir (10-12)', 'Remaja (13-18)'] as const
const STATUSES = ['draft', 'published', 'archived'] as const

export async function getLessons(): Promise<Lesson[]> {
  const { data } = await supabaseAdmin
    .from('lessons')
    .select('*')
    .order('sort_order', { ascending: true })
    .order('created_at', { ascending: false })
  return (data as unknown as Lesson[]) ?? []
}

export async function createLesson(formData: FormData): Promise<{ success: boolean; error?: string }> {
  const title = formData.get('title') as string
  const subject = formData.get('subject') as string
  const topic = formData.get('topic') as string
  const ageGroup = formData.get('age_group') as string
  const status = formData.get('status') as string
  const sortOrder = formData.get('sort_order') as string
  const steps = formData.get('steps') as string

  if (!title?.trim() || !subject || !topic?.trim()) {
    return { success: false, error: 'Judul, subjek, dan topik wajib diisi.' }
  }
  if (!SUBJECTS.includes(subject as typeof SUBJECTS[number])) {
    return { success: false, error: 'Subjek tidak valid.' }
  }
  if (!STATUSES.includes(status as typeof STATUSES[number])) {
    return { success: false, error: 'Status tidak valid.' }
  }

  const stepsParsed = steps?.trim() ? JSON.parse(steps) : [{ instruction: 'Pelajari materi ini', order: 1 }]

  const { error } = await supabaseAdmin.from('lessons').insert({
    title: title.trim(),
    subject,
    topic: topic.trim(),
    age_group: ageGroup ? parseInt(ageGroup) : null,
    status,
    sort_order: sortOrder ? parseInt(sortOrder) : 0,
    steps: stepsParsed,
    total_steps: Array.isArray(stepsParsed) ? stepsParsed.length : 1,
    stars_reward: 10,
  })

  if (error) {
    return { success: false, error: error.message }
  }

  revalidatePath('/dashboard/content')
  return { success: true }
}

export async function updateLesson(id: string, formData: FormData): Promise<{ success: boolean; error?: string }> {
  const title = formData.get('title') as string
  const subject = formData.get('subject') as string
  const topic = formData.get('topic') as string
  const ageGroup = formData.get('age_group') as string
  const status = formData.get('status') as string
  const sortOrder = formData.get('sort_order') as string
  const steps = formData.get('steps') as string

  if (!title?.trim() || !subject || !topic?.trim()) {
    return { success: false, error: 'Judul, subjek, dan topik wajib diisi.' }
  }

  const stepsParsed = steps?.trim() ? JSON.parse(steps) : undefined

  const updates: Record<string, unknown> = {
    title: title.trim(),
    subject,
    topic: topic.trim(),
    age_group: ageGroup ? parseInt(ageGroup) : null,
    status,
    sort_order: sortOrder ? parseInt(sortOrder) : 0,
  }
  if (stepsParsed) {
    updates.steps = stepsParsed
    updates.total_steps = Array.isArray(stepsParsed) ? stepsParsed.length : 1
  }

  const { error } = await supabaseAdmin
    .from('lessons')
    .update(updates)
    .eq('id', id)

  if (error) {
    return { success: false, error: error.message }
  }

  revalidatePath('/dashboard/content')
  return { success: true }
}

export async function deleteLesson(id: string): Promise<{ success: boolean; error?: string }> {
  const { error } = await supabaseAdmin.from('lessons').delete().eq('id', id)
  if (error) {
    return { success: false, error: error.message }
  }
  revalidatePath('/dashboard/content')
  return { success: true }
}

export async function togglePublish(id: string, newStatus: string): Promise<{ success: boolean; error?: string }> {
  const { error } = await supabaseAdmin
    .from('lessons')
    .update({ status: newStatus })
    .eq('id', id)

  if (error) {
    return { success: false, error: error.message }
  }
  revalidatePath('/dashboard/content')
  return { success: true }
}