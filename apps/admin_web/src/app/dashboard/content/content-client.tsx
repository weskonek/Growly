'use client'

import { useState, useTransition } from 'react'
import { Lesson, createLesson, getLessons, updateLesson, deleteLesson, togglePublish } from './actions'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/table'
import {
  BookOpen, Plus, Pencil, Trash2, ArrowUp, ArrowDown,
  Search, X, ChevronLeft, ChevronRight, ArrowLeftRight,
} from 'lucide-react'

type LessonFormData = {
  id?: string
  title: string
  subject: string
  topic: string
  age_group: string
  status: string
  sort_order: string
  steps: string
}

const SUBJECTS = [
  { value: 'reading', label: '📖 Membaca' },
  { value: 'math', label: '🔢 Matematika' },
  { value: 'science', label: '🔬 Sains' },
  { value: 'creative', label: '🎨 Kreativitas' },
  { value: 'language', label: '🗣️ Bahasa' },
  { value: 'general', label: '📚 Umum' },
]

const AGE_GROUPS = [
  { value: '', label: 'Semua Usia' },
  { value: '0', label: 'Batita (2-5)' },
  { value: '1', label: 'Kanak-kanak awal (6-9)' },
  { value: '2', label: 'Kanak-kanak akhir (10-12)' },
  { value: '3', label: 'Remaja (13-18)' },
]

const STATUSES = [
  { value: 'draft', label: 'Draft', variant: 'secondary' as const },
  { value: 'published', label: 'Dipublikasi', variant: 'success' as const },
  { value: 'archived', label: 'Diarsipkan', variant: 'outline' as const },
]

function statusBadge(status: string) {
  const s = STATUSES.find(s => s.value === status)
  if (!s) return <Badge variant="secondary">{status}</Badge>
  return <Badge variant={s.variant}>{s.label}</Badge>
}

function subjectLabel(subject: string) {
  const s = SUBJECTS.find(s => s.value === subject)
  return s ? s.label : subject
}

function ageGroupLabel(ag: number | null) {
  if (ag == null) return 'Semua'
  return AGE_GROUPS.find(a => a.value === String(ag))?.label ?? `Kelompok ${ag}`
}

function LessonModal({
  initial,
  onClose,
}: {
  initial?: Lesson
  onClose: () => void
}) {
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const defaultSteps = initial?.steps
    ? JSON.stringify(initial.steps, null, 2)
    : '[{"order":1,"instruction":"Langkah 1..."}]'

  async function handleSubmit(formData: FormData) {
    setError(null)
    startTransition(async () => {
      const result = initial?.id
        ? await updateLesson(initial.id, formData)
        : await createLesson(formData)
      if (result.success) {
        onClose()
      } else {
        setError(result.error ?? 'Gagal menyimpan.')
      }
    })
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="w-full max-w-2xl rounded-xl bg-background p-6 shadow-xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold">
            {initial ? '✏️ Edit Pelajaran' : '➕ Pelajaran Baru'}
          </h2>
          <button onClick={onClose} className="p-1 hover:bg-muted rounded">
            <X className="h-5 w-5" />
          </button>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-50 border border-red-200 p-3 text-sm text-red-700">
            {error}
          </div>
        )}

        <form
          action={async (formData) => {
            setError(null)
            const result = initial?.id
              ? await updateLesson(initial.id, formData)
              : await createLesson(formData)
            if (result.success) {
              onClose()
            } else {
              setError(result.error ?? 'Gagal menyimpan.')
            }
          }}
          className="space-y-4"
        >
          <input type="hidden" name="id" value={initial?.id ?? ''} />

          <div>
            <label className="text-sm font-medium mb-1 block">Judul *</label>
            <input
              name="title"
              defaultValue={initial?.title ?? ''}
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              placeholder="Contoh: Mengenal Huruf Hijaiyah"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium mb-1 block">Subjek *</label>
              <select
                name="subject"
                defaultValue={initial?.subject ?? 'general'}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                required
              >
                {SUBJECTS.map(s => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm font-medium mb-1 block">Topik *</label>
              <input
                name="topic"
                defaultValue={initial?.topic ?? ''}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                placeholder="Contoh: Alphabet"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="text-sm font-medium mb-1 block">Kelompok Usia</label>
              <select
                name="age_group"
                defaultValue={initial?.age_group != null ? String(initial.age_group) : ''}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              >
                {AGE_GROUPS.map(a => (
                  <option key={a.value} value={a.value}>{a.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm font-medium mb-1 block">Status</label>
              <select
                name="status"
                defaultValue={initial?.status ?? 'draft'}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              >
                {STATUSES.map(s => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm font-medium mb-1 block">Urutan</label>
              <input
                name="sort_order"
                type="number"
                defaultValue={initial?.sort_order ?? 0}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                placeholder="0"
              />
            </div>
          </div>

          <div>
            <label className="text-sm font-medium mb-1 block">Langkah (JSON)</label>
            <textarea
              name="steps"
              defaultValue={defaultSteps}
              rows={6}
              className="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono"
              placeholder='[{"order":1,"instruction":"..."}]'
            />
            <p className="text-xs text-muted-foreground mt-1">
              {'Format JSON array. Contoh: [{"order":1,"instruction":"..."}]'}
            </p>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="outline" onClick={onClose}>Batal</Button>
            <button
              type="submit"
              disabled={isPending}
              className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2"
            >
              {isPending ? 'Menyimpan...' : 'Simpan'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

function DeleteModal({
  lesson,
  onClose,
}: {
  lesson: Lesson
  onClose: () => void
}) {
  const [isPending, startTransition] = useTransition()

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="w-full max-w-sm rounded-xl bg-background p-6 shadow-xl">
        <h2 className="text-lg font-bold mb-2">🗑️ Hapus Pelajaran?</h2>
        <p className="text-sm text-muted-foreground mb-6">
          Pelajaran <strong>"{lesson.title}"</strong> akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.
        </p>
        <div className="flex justify-end gap-3">
          <Button variant="outline" onClick={onClose}>Batal</Button>
          <button
            onClick={() => startTransition(async () => {
              await deleteLesson(lesson.id)
              onClose()
            })}
            disabled={isPending}
            className="inline-flex items-center justify-center rounded-md text-sm font-medium bg-destructive text-destructive-foreground hover:bg-destructive/90 h-10 px-4 py-2 disabled:opacity-50"
          >
            {isPending ? 'Menghapus...' : 'Hapus'}
          </button>
        </div>
      </div>
    </div>
  )
}

export function ContentClient({ initialLessons }: { initialLessons: Lesson[] }) {
  const [lessons, setLessons] = useState<Lesson[]>(initialLessons)
  const [isPending, startTransition] = useTransition()

  const [search, setSearch] = useState('')
  const [filterSubject, setFilterSubject] = useState('')
  const [filterStatus, setFilterStatus] = useState('')
  const [filterAge, setFilterAge] = useState('')
  const [page, setPage] = useState(1)
  const pageSize = 10

  const [modalLesson, setModalLesson] = useState<Lesson | undefined>()
  const [deleteLessonData, setDeleteLessonData] = useState<Lesson | null>(null)

  const filtered = lessons.filter(l => {
    if (search && !l.title.toLowerCase().includes(search.toLowerCase()) &&
        !l.topic.toLowerCase().includes(search.toLowerCase())) return false
    if (filterSubject && l.subject !== filterSubject) return false
    if (filterStatus && l.status !== filterStatus) return false
    if (filterAge && String(l.age_group ?? '') !== filterAge) return false
    return true
  })

  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize))
  const paged = filtered.slice((page - 1) * pageSize, page * pageSize)

  function openCreate() {
    setModalLesson(undefined)
  }
  function openEdit(lesson: Lesson) {
    setModalLesson(lesson)
  }

  async function handleToggle(lesson: Lesson) {
    const newStatus = lesson.status === 'published' ? 'draft' : 'published'
    startTransition(async () => {
      await togglePublish(lesson.id, newStatus)
      setLessons(prev => prev.map(l => l.id === lesson.id ? { ...l, status: newStatus } : l))
    })
  }

  function handleDelete(lesson: Lesson) {
    startTransition(async () => {
      await deleteLesson(lesson.id)
      setLessons(prev => prev.filter(l => l.id !== lesson.id))
      setDeleteLessonData(null)
    })
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">📚 Manajemen Konten</h1>
          <p className="text-muted-foreground">
            Kelola pelajaran dan materi belajar untuk anak-anak
          </p>
        </div>
        <Button onClick={openCreate} className="flex items-center gap-2">
          <Plus className="h-4 w-4" /> Pelajaran Baru
        </Button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1) }}
            placeholder="Cari judul atau topik..."
            className="pl-9"
          />
        </div>
        <select
          value={filterSubject}
          onChange={e => { setFilterSubject(e.target.value); setPage(1) }}
          className="h-10 rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          <option value="">Semua Subjek</option>
          {SUBJECTS.map(s => <option key={s.value} value={s.value}>{s.label}</option>)}
        </select>
        <select
          value={filterStatus}
          onChange={e => { setFilterStatus(e.target.value); setPage(1) }}
          className="h-10 rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          <option value="">Semua Status</option>
          {STATUSES.map(s => <option key={s.value} value={s.value}>{s.label}</option>)}
        </select>
        <select
          value={filterAge}
          onChange={e => { setFilterAge(e.target.value); setPage(1) }}
          className="h-10 rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          {AGE_GROUPS.map(a => <option key={a.value} value={a.value}>{a.label}</option>)}
        </select>
        {(search || filterSubject || filterStatus || filterAge) && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => { setSearch(''); setFilterSubject(''); setFilterStatus(''); setFilterAge(''); setPage(1) }}
          >
            <X className="h-4 w-4 mr-1" /> Reset
          </Button>
        )}
      </div>

      {/* Stats row */}
      <div className="flex gap-3 text-sm">
        {[
          { label: 'Total', count: lessons.length, color: 'text-foreground' },
          { label: 'Draft', count: lessons.filter(l => l.status === 'draft').length, color: 'text-muted-foreground' },
          { label: 'Dipublikasi', count: lessons.filter(l => l.status === 'published').length, color: 'text-green-600' },
          { label: 'Diarsipkan', count: lessons.filter(l => l.status === 'archived').length, color: 'text-orange-600' },
        ].map(({ label, count, color }) => (
          <div key={label} className={`rounded-full border px-3 py-1 font-medium ${color}`}>
            {count} {label}
          </div>
        ))}
      </div>

      {/* Table */}
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[40px]">#</TableHead>
                <TableHead>Judul</TableHead>
                <TableHead>Subjek</TableHead>
                <TableHead>Topik</TableHead>
                <TableHead>Usia</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Urutan</TableHead>
                <TableHead className="text-right">Aksi</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paged.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-12 text-muted-foreground">
                    <BookOpen className="h-10 w-10 mx-auto mb-3 opacity-30" />
                    <p className="font-medium">Belum ada pelajaran</p>
                    <p className="text-sm">Klik "Pelajaran Baru" untuk menambahkan.</p>
                  </TableCell>
                </TableRow>
              ) : (
                paged.map((lesson, i) => (
                  <TableRow key={lesson.id}>
                    <TableCell className="text-muted-foreground text-sm">
                      {(page - 1) * pageSize + i + 1}
                    </TableCell>
                    <TableCell>
                      <div className="font-medium">{lesson.title}</div>
                      <div className="text-xs text-muted-foreground">
                        {lesson.total_steps} langkah · ⭐ {lesson.stars_reward}
                      </div>
                    </TableCell>
                    <TableCell><span className="text-sm">{subjectLabel(lesson.subject)}</span></TableCell>
                    <TableCell><span className="text-sm text-muted-foreground">{lesson.topic}</span></TableCell>
                    <TableCell><span className="text-sm">{ageGroupLabel(lesson.age_group)}</span></TableCell>
                    <TableCell>{statusBadge(lesson.status)}</TableCell>
                    <TableCell><span className="text-sm text-muted-foreground">{lesson.sort_order}</span></TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-1">
                        <button
                          onClick={() => handleToggle(lesson)}
                          title={lesson.status === 'published' ? 'Batalkan publikasi' : 'Publikasi'}
                          className="p-1.5 rounded hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
                        >
                          {lesson.status === 'published' ? <ArrowDown className="h-4 w-4 text-orange-500" /> : <ArrowUp className="h-4 w-4 text-green-500" />}
                        </button>
                        <button
                          onClick={() => openEdit(lesson)}
                          title="Edit"
                          className="p-1.5 rounded hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
                        >
                          <Pencil className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => setDeleteLessonData(lesson)}
                          title="Hapus"
                          className="p-1.5 rounded hover:bg-red-50 text-muted-foreground hover:text-red-500 transition-colors"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">
            Menampilkan {(page - 1) * pageSize + 1}–{Math.min(page * pageSize, filtered.length)} dari {filtered.length}
          </p>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            {Array.from({ length: totalPages }, (_, i) => i + 1).map(p => (
              <Button
                key={p}
                variant={p === page ? 'default' : 'outline'}
                size="sm"
                onClick={() => setPage(p)}
              >
                {p}
              </Button>
            ))}
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}

      {/* Modals */}
      {modalLesson !== undefined && (
        <LessonModal
          key={modalLesson?.id ?? 'new'}
          initial={modalLesson}
          onClose={() => setModalLesson(undefined)}
        />
      )}
      {deleteLessonData && (
        <DeleteModal
          lesson={deleteLessonData}
          onClose={() => setDeleteLessonData(null)}
        />
      )}
    </div>
  )
}