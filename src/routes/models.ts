import { Router } from 'express'
import axios from 'axios'

const router = Router()

interface HuggingFaceModelData {
  modelId: string
  tags: string[]
  pipeline_tag?: string
  library_name?: string
  license?: string
  cardData?: any
  siblings?: Array<{ rfilename: string }>
  author?: string
  downloads?: number
  likes?: number
  createdAt?: string
  lastModified?: string
}

// Fetch metadata from HuggingFace API
router.post('/fetch-metadata', async (req, res) => {
  try {
    const { url, source } = req.body

    if (!url) {
      return res.status(400).json({
        success: false,
        error: 'URL is required'
      })
    }

    if (source === 'huggingface') {
      // Extract model ID from URL
      const modelIdMatch = url.match(/huggingface\.co\/([^/?]+)/)

      if (!modelIdMatch) {
        return res.status(400).json({
          success: false,
          error: 'Invalid HuggingFace URL'
        })
      }

      const modelId = modelIdMatch[1]

      // Fetch model data from HuggingFace API
      const modelResponse = await axios.get<HuggingFaceModelData>(
        `https://huggingface.co/api/models/${modelId}`,
        {
          headers: {
            'Accept': 'application/json'
          },
          timeout: 10000
        }
      )

      const modelData = modelResponse.data

      // Fetch model card (README) for additional metadata
      let modelCardText = ''
      try {
        const readmeResponse = await axios.get(
          `https://huggingface.co/${modelId}/raw/main/README.md`,
          {
            timeout: 10000
          }
        )
        modelCardText = readmeResponse.data
      } catch (error) {
        console.log('Could not fetch README:', error)
      }

      // Parse and extract metadata
      const metadata = {
        model_name: modelId,
        vendor: modelData.author || modelId.split('/')[0] || 'HuggingFace',
        model_origin: 'opensource',
        model_type: inferModelType(modelData.pipeline_tag, modelData.tags),
        license_type: modelData.license || extractLicenseFromCard(modelCardText) || 'unknown',
        model_version: extractVersionFromCard(modelCardText) || 'latest',
        model_card_url: url,
        description: extractDescriptionFromCard(modelCardText) || `HuggingFace model: ${modelId}`,
        library_name: modelData.library_name,
        tags: modelData.tags || [],
        pipeline_tag: modelData.pipeline_tag,
        downloads: modelData.downloads,
        likes: modelData.likes,
        created_at: modelData.createdAt,
        last_modified: modelData.lastModified,
        has_model_card: !!modelCardText,
        training_data: extractTrainingDataFromCard(modelCardText),
        intended_use: extractIntendedUseFromCard(modelCardText),
        limitations: extractLimitationsFromCard(modelCardText),
        bias_risks: extractBiasRisksFromCard(modelCardText),
      }

      return res.json({
        success: true,
        metadata
      })
    } else if (source === 'openai') {
      // For OpenAI, we'll return known metadata based on model name
      const modelName = req.body.modelName || ''

      const openAIModels: Record<string, any> = {
        'gpt-4-turbo': {
          model_name: 'gpt-4-turbo',
          vendor: 'OpenAI',
          model_origin: 'commercial',
          model_type: 'llm',
          license_type: 'commercial',
          description: 'Most capable GPT-4 model with 128k context window and improved instruction following',
          context_window: 128000,
          training_cutoff: '2023-12',
          capabilities: ['text-generation', 'chat', 'function-calling', 'json-mode'],
          intended_use: 'General-purpose language understanding and generation for commercial applications',
          limitations: 'May produce incorrect information, has knowledge cutoff, potential for bias'
        },
        'gpt-4': {
          model_name: 'gpt-4',
          vendor: 'OpenAI',
          model_origin: 'commercial',
          model_type: 'llm',
          license_type: 'commercial',
          description: 'GPT-4 base model with 8k context window',
          context_window: 8192,
          training_cutoff: '2023-09',
          capabilities: ['text-generation', 'chat', 'function-calling'],
          intended_use: 'General-purpose language understanding and generation',
          limitations: 'May produce incorrect information, has knowledge cutoff'
        },
        'gpt-3.5-turbo': {
          model_name: 'gpt-3.5-turbo',
          vendor: 'OpenAI',
          model_origin: 'commercial',
          model_type: 'llm',
          license_type: 'commercial',
          description: 'Fast and efficient model optimized for chat',
          context_window: 16385,
          training_cutoff: '2023-09',
          capabilities: ['text-generation', 'chat', 'function-calling'],
          intended_use: 'Chat applications and efficient language tasks',
          limitations: 'Less capable than GPT-4, may produce incorrect information'
        },
        'dall-e-3': {
          model_name: 'dall-e-3',
          vendor: 'OpenAI',
          model_origin: 'commercial',
          model_type: 'image-generation',
          license_type: 'commercial',
          description: 'Advanced text-to-image generation with improved prompt following',
          capabilities: ['image-generation'],
          intended_use: 'Creative image generation from text descriptions',
          limitations: 'Content policy restrictions, may refuse certain prompts'
        },
        'whisper-v3': {
          model_name: 'whisper-v3',
          vendor: 'OpenAI',
          model_origin: 'commercial',
          model_type: 'audio',
          license_type: 'mit',
          description: 'Speech recognition and transcription model',
          capabilities: ['speech-to-text', 'translation'],
          intended_use: 'Audio transcription and translation',
          limitations: 'Accuracy varies by language and audio quality'
        }
      }

      const metadata = openAIModels[modelName.toLowerCase()] || {
        model_name: modelName,
        vendor: 'OpenAI',
        model_origin: 'commercial',
        model_type: 'llm',
        license_type: 'commercial',
        description: `OpenAI model: ${modelName}`,
        intended_use: 'Commercial AI applications',
        limitations: 'Subject to OpenAI usage policies'
      }

      return res.json({
        success: true,
        metadata
      })
    } else if (source === 'anthropic') {
      const modelName = req.body.modelName || ''

      const anthropicModels: Record<string, any> = {
        'claude-sonnet-4-5': {
          model_name: 'claude-sonnet-4-5',
          vendor: 'Anthropic',
          model_origin: 'commercial',
          model_type: 'llm',
          license_type: 'commercial',
          description: 'Latest Claude model with improved reasoning and analysis capabilities',
          context_window: 200000,
          capabilities: ['text-generation', 'chat', 'analysis', 'coding'],
          intended_use: 'Complex reasoning, analysis, and content generation',
          limitations: 'Knowledge cutoff, potential for incorrect information'
        },
        'claude-3-opus': {
          model_name: 'claude-3-opus',
          vendor: 'Anthropic',
          model_origin: 'commercial',
          model_type: 'llm',
          license_type: 'commercial',
          description: 'Most capable Claude 3 model for complex tasks',
          context_window: 200000,
          capabilities: ['text-generation', 'chat', 'analysis', 'coding'],
          intended_use: 'High-complexity tasks requiring deep understanding',
          limitations: 'Higher cost, knowledge cutoff'
        }
      }

      const metadata = anthropicModels[modelName.toLowerCase()] || {
        model_name: modelName,
        vendor: 'Anthropic',
        model_origin: 'commercial',
        model_type: 'llm',
        license_type: 'commercial',
        description: `Anthropic Claude model: ${modelName}`,
        intended_use: 'Commercial AI applications',
        limitations: 'Subject to Anthropic usage policies'
      }

      return res.json({
        success: true,
        metadata
      })
    }

    return res.status(400).json({
      success: false,
      error: 'Unsupported source'
    })
  } catch (error: any) {
    console.error('Fetch metadata error:', error)
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to fetch metadata'
    })
  }
})

// Helper functions to parse model cards

function inferModelType(pipelineTag?: string, tags?: string[]): string {
  if (pipelineTag) {
    const typeMap: Record<string, string> = {
      'text-generation': 'llm',
      'text2text-generation': 'llm',
      'conversational': 'llm',
      'fill-mask': 'language-model',
      'text-classification': 'classifier',
      'token-classification': 'ner',
      'question-answering': 'qa',
      'translation': 'translation',
      'summarization': 'summarization',
      'image-classification': 'vision',
      'object-detection': 'vision',
      'image-segmentation': 'vision',
      'image-to-text': 'vision-language',
      'text-to-image': 'image-generation',
      'automatic-speech-recognition': 'audio',
      'audio-classification': 'audio',
      'text-to-speech': 'audio'
    }
    return typeMap[pipelineTag] || pipelineTag
  }

  if (tags && tags.length > 0) {
    const tagStr = tags.join(' ').toLowerCase()
    if (tagStr.includes('llm') || tagStr.includes('language-model')) return 'llm'
    if (tagStr.includes('vision')) return 'vision'
    if (tagStr.includes('audio') || tagStr.includes('speech')) return 'audio'
    if (tagStr.includes('multimodal')) return 'multimodal'
  }

  return 'unknown'
}

function extractLicenseFromCard(cardText: string): string | null {
  const licenseMatch = cardText.match(/license:\s*([a-z0-9\-\.]+)/i)
  if (licenseMatch) return licenseMatch[1]

  const commonLicenses = ['mit', 'apache-2.0', 'gpl', 'cc-by', 'bsd']
  for (const license of commonLicenses) {
    if (cardText.toLowerCase().includes(license)) {
      return license
    }
  }

  return null
}

function extractVersionFromCard(cardText: string): string | null {
  const versionMatch = cardText.match(/version:\s*([0-9\.]+)/i)
  if (versionMatch) return versionMatch[1]

  const vMatch = cardText.match(/v([0-9]+\.[0-9]+\.?[0-9]*)/i)
  if (vMatch) return vMatch[1]

  return null
}

function extractDescriptionFromCard(cardText: string): string | null {
  // Try to extract from YAML frontmatter
  const yamlMatch = cardText.match(/---\n(.*?)\n---/s)
  if (yamlMatch) {
    const yamlContent = yamlMatch[1]
    const descMatch = yamlContent.match(/description:\s*["']?(.*?)["']?$/m)
    if (descMatch) return descMatch[1].trim()
  }

  // Try to get first paragraph after title
  const lines = cardText.split('\n')
  let foundTitle = false
  for (const line of lines) {
    if (line.startsWith('#')) {
      foundTitle = true
      continue
    }
    if (foundTitle && line.trim().length > 20) {
      return line.trim().substring(0, 200)
    }
  }

  return null
}

function extractTrainingDataFromCard(cardText: string): string[] {
  const datasets: string[] = []
  const datasetMatches = cardText.matchAll(/dataset[s]?:?\s*([a-zA-Z0-9\-\/\s,]+)/gi)

  for (const match of datasetMatches) {
    const datasetNames = match[1].split(/[,\n]/).map(d => d.trim()).filter(d => d.length > 0)
    datasets.push(...datasetNames)
  }

  return [...new Set(datasets)]
}

function extractIntendedUseFromCard(cardText: string): string | null {
  const sections = [
    'intended use',
    'intended uses',
    'use cases',
    'applications'
  ]

  for (const section of sections) {
    const regex = new RegExp(`##?\\s*${section}[:\n]([\\s\\S]{0,500}?)(?=##|$)`, 'i')
    const match = cardText.match(regex)
    if (match) {
      return match[1].trim().substring(0, 300)
    }
  }

  return null
}

function extractLimitationsFromCard(cardText: string): string | null {
  const sections = [
    'limitations',
    'limitations and bias',
    'known limitations',
    'caveats'
  ]

  for (const section of sections) {
    const regex = new RegExp(`##?\\s*${section}[:\n]([\\s\\S]{0,500}?)(?=##|$)`, 'i')
    const match = cardText.match(regex)
    if (match) {
      return match[1].trim().substring(0, 300)
    }
  }

  return null
}

function extractBiasRisksFromCard(cardText: string): string | null {
  const sections = [
    'bias',
    'bias risks',
    'ethical considerations',
    'fairness'
  ]

  for (const section of sections) {
    const regex = new RegExp(`##?\\s*${section}[:\n]([\\s\\S]{0,500}?)(?=##|$)`, 'i')
    const match = cardText.match(regex)
    if (match) {
      return match[1].trim().substring(0, 300)
    }
  }

  return null
}

export default router
