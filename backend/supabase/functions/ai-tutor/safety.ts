// Content safety filter for AI tutor

const BLOCKED_PATTERNS = [
  /violence|pertarungan|pertempuran|membunuh|combat/i,
  /adult|konten dewasa|18\+|seks/i,
  /gambling|judol|kasino|lotre/i,
  /drug|narkoba|heroin|cocaine|weed|ganja/i,
  /suicide|bunuh diri|melukai diri|self.?harm/i,
  /hate|kelompok|rasis|diskriminasi/i,
  /weapon|bom|senjata|pistol|pedang/i,
  /phishing|scam|penipuan|penipuan.?online/i,
  /password|kata.?sandi|hack|retas/i,
  /kill| bunuh|roasting|cyberbullying/i,
]

const PROMPT_INJECTION_PATTERNS = [
  /ignore previous instructions/i,
  /ignore all previous/i,
  /you are now/i,
  /disregard previous/i,
  /system prompt/i,
  /[A-Z]+:.*role.*:.*admin/i,
]

export class SafetyFilter {
  private blockedPatterns = BLOCKED_PATTERNS
  private injectionPatterns = PROMPT_INJECTION_PATTERNS

  isSafe(input: string): boolean {
    // Check for blocked content
    for (const pattern of this.blockedPatterns) {
      if (pattern.test(input)) {
        console.log(`Blocked content detected: ${pattern}`)
        return false
      }
    }

    // Check for prompt injection
    if (this.containsPromptInjection(input)) {
      console.log('Prompt injection detected')
      return false
    }

    // Check length (prevent very long inputs)
    if (input.length > 5000) {
      console.log('Input too long')
      return false
    }

    return true
  }

  isOutputSafe(output: string): boolean {
    // Check for blocked content in output
    for (const pattern of this.blockedPatterns) {
      if (pattern.test(output)) {
        console.log(`Blocked content in output: ${pattern}`)
        return false
      }
    }

    // Check for prompt injection attempts in output
    if (this.containsPromptInjection(output)) {
      console.log('Prompt injection in output detected')
      return false
    }

    // Check for very long outputs
    if (output.length > 10000) {
      console.log('Output too long')
      return false
    }

    return true
  }

  private containsPromptInjection(text: string): boolean {
    for (const pattern of this.injectionPatterns) {
      if (pattern.test(text)) {
        return true
      }
    }
    return false
  }

  getBlockedReason(input: string): string | null {
    for (const pattern of this.blockedPatterns) {
      if (pattern.test(input)) {
        return `Content violates safety policy: ${pattern.source}`
      }
    }

    if (this.containsPromptInjection(input)) {
      return 'Prompt injection detected'
    }

    if (input.length > 5000) {
      return 'Input exceeds maximum length'
    }

    return null
  }

  sanitizeOutput(output: string): string {
    // Remove any potential prompt injection attempts
    let sanitized = output

    for (const pattern of this.injectionPatterns) {
      sanitized = sanitized.replace(pattern, '[content removed]')
    }

    // Truncate if too long
    if (sanitized.length > 10000) {
      sanitized = sanitized.substring(0, 10000) + '... (respons terlalu panjang)'
    }

    return sanitized
  }
}

// Export singleton for convenience
export const safetyFilter = new SafetyFilter()