import { getLessons } from './actions'
import { ContentClient } from './content-client'

export default async function ContentPage() {
  const lessons = await getLessons()
  return <ContentClient initialLessons={lessons} />
}