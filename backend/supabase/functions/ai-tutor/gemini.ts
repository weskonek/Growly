// Gemini API client for Edge Functions

interface Part {
  text: string
}

interface Content {
  role: string
  parts: Part[]
}

interface GenerationConfig {
  temperature?: number
  maxOutputTokens?: number
  topP?: number
  topK?: number
}

interface GenerateContentRequest {
  contents: Content[]
  generationConfig?: GenerationConfig
  safetySettings?: SafetySetting[]
}

interface SafetySetting {
  category: string
  threshold: string
}

interface Candidate {
  content: {
    parts: Part[]
    role: string
  }
  finishReason: string
  safetyRatings: SafetyRating[]
}

interface SafetyRating {
  category: string
  probability: string
}

interface UsageMetadata {
  promptTokenCount: number
  candidatesTokenCount: number
  totalTokenCount: number
}

interface GenerateContentResponse {
  candidates?: Candidate[]
  usageMetadata?: UsageMetadata
  promptFeedback?: {
    safetyRatings: SafetyRating[]
  }
}

export class GeminiClient {
  private apiKey: string
  private baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models'

  constructor(apiKey: string) {
    this.apiKey = apiKey
  }

  async generateContent(request: GenerateContentRequest): Promise<GenerateContentResponse> {
    const url = `${this.baseUrl}/gemini-1.5-flash:generateContent?key=${this.apiKey}`

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(request)
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Gemini API error: ${response.status} - ${errorText}`)
    }

    const data = await response.json() as GenerateContentResponse

    // Check for safety blockages
    if (data.promptFeedback?.safetyRatings?.length) {
      const blocked = data.promptFeedback.safetyRatings.some(
        rating => rating.probability === 'NEGLIGIBLE' === false
      )
      if (blocked) {
        console.warn('Content was blocked due to safety settings')
      }
    }

    return data
  }

  async generateContentStream(request: GenerateContentRequest): Promise<ReadableStream> {
    const url = `${this.baseUrl}/gemini-1.5-flash:streamGenerateContent?key=${this.apiKey}&alt=sse`

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(request)
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Gemini API streaming error: ${response.status} - ${errorText}`)
    }

    return response.body!
  }
}