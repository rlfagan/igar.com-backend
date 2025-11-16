import pool from './index';

// AI Catalog - Available models, tools, datasets, and use cases
// This matches the frontend ai-catalog.ts structure

const catalogItems = [
  // OpenAI Models
  { id: 'openai:gpt-4o', name: 'GPT-4o', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial', 'multimodal'] },
  { id: 'openai:gpt-4o-mini', name: 'GPT-4o Mini', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial', 'cost-effective'] },
  { id: 'openai:gpt-4-turbo', name: 'GPT-4 Turbo', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'openai:gpt-4', name: 'GPT-4', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'openai:gpt-3.5-turbo', name: 'GPT-3.5 Turbo', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial', 'cost-effective'] },
  { id: 'openai:o1', name: 'o1', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial', 'reasoning'] },
  { id: 'openai:o1-mini', name: 'o1 Mini', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial', 'reasoning', 'cost-effective'] },
  { id: 'openai:o3-mini', name: 'o3 Mini', provider: 'OpenAI', category: 'model', tags: ['llm', 'commercial', 'reasoning'] },

  // Anthropic Models
  { id: 'anthropic:claude-sonnet-4', name: 'Claude Sonnet 4', provider: 'Anthropic', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'anthropic:claude-3.7-sonnet', name: 'Claude 3.7 Sonnet', provider: 'Anthropic', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'anthropic:claude-3.5-sonnet', name: 'Claude 3.5 Sonnet', provider: 'Anthropic', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'anthropic:claude-3.5-haiku', name: 'Claude 3.5 Haiku', provider: 'Anthropic', category: 'model', tags: ['llm', 'commercial', 'fast'] },
  { id: 'anthropic:claude-3-opus', name: 'Claude 3 Opus', provider: 'Anthropic', category: 'model', tags: ['llm', 'commercial'] },

  // Google Models
  { id: 'google:gemini-2.0-flash-exp', name: 'Gemini 2.0 Flash Experimental', provider: 'Google', category: 'model', tags: ['llm', 'commercial', 'multimodal', 'experimental'] },
  { id: 'google:gemini-exp-1206', name: 'Gemini Experimental 1206', provider: 'Google', category: 'model', tags: ['llm', 'commercial', 'experimental'] },
  { id: 'google:gemini-1.5-pro', name: 'Gemini 1.5 Pro', provider: 'Google', category: 'model', tags: ['llm', 'commercial', 'multimodal'] },
  { id: 'google:gemini-1.5-flash', name: 'Gemini 1.5 Flash', provider: 'Google', category: 'model', tags: ['llm', 'commercial', 'fast'] },

  // Meta Llama Models
  { id: 'meta:llama-3.3-70b', name: 'Llama 3.3 70B', provider: 'Meta', category: 'model', tags: ['llm', 'open-weights'] },
  { id: 'meta:llama-3.1-405b', name: 'Llama 3.1 405B', provider: 'Meta', category: 'model', tags: ['llm', 'open-weights', 'large'] },
  { id: 'meta:llama-3.1-70b', name: 'Llama 3.1 70B', provider: 'Meta', category: 'model', tags: ['llm', 'open-weights'] },
  { id: 'meta:llama-3.1-8b', name: 'Llama 3.1 8B', provider: 'Meta', category: 'model', tags: ['llm', 'open-weights', 'small'] },
  { id: 'meta:llama-3-70b', name: 'Llama 3 70B', provider: 'Meta', category: 'model', tags: ['llm', 'open-weights'] },
  { id: 'meta:llama-3-8b', name: 'Llama 3 8B', provider: 'Meta', category: 'model', tags: ['llm', 'open-weights', 'small'] },

  // Mistral Models
  { id: 'mistral:mistral-large-2', name: 'Mistral Large 2', provider: 'Mistral AI', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'mistral:mistral-small', name: 'Mistral Small', provider: 'Mistral AI', category: 'model', tags: ['llm', 'commercial', 'cost-effective'] },
  { id: 'mistral:mixtral-8x22b', name: 'Mixtral 8x22B', provider: 'Mistral AI', category: 'model', tags: ['llm', 'open-weights'] },
  { id: 'mistral:mixtral-8x7b', name: 'Mixtral 8x7B', provider: 'Mistral AI', category: 'model', tags: ['llm', 'open-weights'] },

  // Cohere Models
  { id: 'cohere:command-r-plus', name: 'Command R+', provider: 'Cohere', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'cohere:command-r', name: 'Command R', provider: 'Cohere', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'cohere:command', name: 'Command', provider: 'Cohere', category: 'model', tags: ['llm', 'commercial'] },

  // AWS Bedrock Models
  { id: 'aws:bedrock-titan-text-premier', name: 'Bedrock Titan Text Premier', provider: 'AWS', category: 'model', tags: ['llm', 'commercial'] },
  { id: 'aws:bedrock-titan-text-express', name: 'Bedrock Titan Text Express', provider: 'AWS', category: 'model', tags: ['llm', 'commercial'] },

  // DeepSeek Models
  { id: 'deepseek:deepseek-v3', name: 'DeepSeek V3', provider: 'DeepSeek', category: 'model', tags: ['llm', 'open-weights'] },
  { id: 'deepseek:deepseek-r1', name: 'DeepSeek R1', provider: 'DeepSeek', category: 'model', tags: ['llm', 'open-weights', 'reasoning'] },

  // Qwen Models
  { id: 'qwen:qwen2.5-72b', name: 'Qwen 2.5 72B', provider: 'Alibaba Cloud', category: 'model', tags: ['llm', 'open-weights'] },
  { id: 'qwen:qwq-32b', name: 'QwQ 32B', provider: 'Alibaba Cloud', category: 'model', tags: ['llm', 'open-weights', 'reasoning'] },

  // High-Risk / Wildcard Models
  { id: 'llama-uncensored-*', name: 'Llama Uncensored (Wildcard)', provider: 'Community', category: 'model', tags: ['uncensored', 'high-risk'] },
  { id: 'wizardlm-uncensored-*', name: 'WizardLM Uncensored (Wildcard)', provider: 'Community', category: 'model', tags: ['uncensored', 'high-risk'] },
  { id: 'gpt4free-*', name: 'GPT4Free (Wildcard)', provider: 'Community', category: 'model', tags: ['reverse-engineered', 'high-risk'] },
  { id: 'stable-diffusion-raw-*', name: 'Stable Diffusion Raw (Wildcard)', provider: 'Stability AI', category: 'model', tags: ['image-gen', 'uncensored'] },

  // Tools
  { id: 'github:copilot-enterprise', name: 'GitHub Copilot Enterprise', provider: 'GitHub', category: 'tool', tags: ['code-assistant', 'enterprise'] },
  { id: 'openai:enterprise', name: 'OpenAI Enterprise', provider: 'OpenAI', category: 'tool', tags: ['llm-api', 'enterprise'] },
  { id: 'perplexity:enterprise', name: 'Perplexity Enterprise', provider: 'Perplexity', category: 'tool', tags: ['search', 'enterprise'] },
  { id: 'microsoft:365-copilot-enterprise', name: 'Microsoft 365 Copilot Enterprise', provider: 'Microsoft', category: 'tool', tags: ['productivity', 'enterprise'] },
  { id: 'huggingface:inference-api', name: 'HuggingFace Inference API', provider: 'HuggingFace', category: 'tool', tags: ['ml-api', 'cloud'] },
  { id: 'local-inference', name: 'Local Inference', provider: 'Self-hosted', category: 'tool', tags: ['self-hosted', 'privacy'] },
  { id: 'characterai:*', name: 'Character.AI (Wildcard)', provider: 'Character.AI', category: 'tool', tags: ['chatbot', 'consumer'] },
  { id: 'midjourney:*', name: 'Midjourney (Wildcard)', provider: 'Midjourney', category: 'tool', tags: ['image-gen', 'consumer'] },
  { id: 'replika:*', name: 'Replika (Wildcard)', provider: 'Replika', category: 'tool', tags: ['chatbot', 'consumer'] },

  // Open Source Software
  { id: 'huggingface/transformers', name: 'Transformers', provider: 'HuggingFace', category: 'oss', tags: ['library', 'apache-2.0'] },
  { id: 'huggingface/diffusers', name: 'Diffusers', provider: 'HuggingFace', category: 'oss', tags: ['library', 'apache-2.0', 'image-gen'] },
  { id: 'langchain', name: 'LangChain', provider: 'LangChain', category: 'oss', tags: ['framework', 'mit'] },
  { id: 'pytorch', name: 'PyTorch', provider: 'Meta', category: 'oss', tags: ['framework', 'bsd'] },
  { id: 'tensorflow', name: 'TensorFlow', provider: 'Google', category: 'oss', tags: ['framework', 'apache-2.0'] },
  { id: 'llama.cpp', name: 'llama.cpp', provider: 'Community', category: 'oss', tags: ['inference', 'mit'] },
  { id: 'vllm', name: 'vLLM', provider: 'UC Berkeley', category: 'oss', tags: ['inference', 'apache-2.0'] },
  { id: 'any:GPL-3.0', name: 'Any GPL-3.0 Software', provider: 'Various', category: 'oss', tags: ['gpl', 'copyleft'] },
  { id: 'hf:model:no-license', name: 'HF Models Without License', provider: 'HuggingFace', category: 'oss', tags: ['no-license', 'high-risk'] },
  { id: 'hf:dataset:no-docs', name: 'HF Datasets Without Docs', provider: 'HuggingFace', category: 'oss', tags: ['no-docs', 'high-risk'] },

  // Datasets
  { id: 'hf:financial-sentiment-verified', name: 'Financial Sentiment (Verified)', provider: 'HuggingFace', category: 'dataset', tags: ['finance', 'verified'] },
  { id: 'hf:ms-marco-v1', name: 'MS MARCO v1', provider: 'Microsoft', category: 'dataset', tags: ['search', 'qa'] },
  { id: 'hf:wiki-en-cleaned', name: 'Wikipedia EN (Cleaned)', provider: 'Wikimedia', category: 'dataset', tags: ['knowledge', 'cleaned'] },
  { id: 'openclimate:climate-risk-dataset-v2', name: 'Climate Risk Dataset v2', provider: 'OpenClimate', category: 'dataset', tags: ['climate', 'risk'] },
  { id: 'customer-data-derived', name: 'Customer Data (Derived)', provider: 'Internal', category: 'dataset', tags: ['customer', 'pii'] },
  { id: 'user-uploaded', name: 'User Uploaded Data', provider: 'Internal', category: 'dataset', tags: ['user-generated', 'review-required'] },

  // Use Cases
  { id: 'fraud-detection', name: 'Fraud Detection', category: 'use_case', tags: ['finance', 'high-risk'] },
  { id: 'credit-eligibility', name: 'Credit Eligibility', category: 'use_case', tags: ['finance', 'high-risk', 'ecoa'] },
  { id: 'aml-bsa', name: 'AML/BSA Compliance', category: 'use_case', tags: ['finance', 'compliance'] },
  { id: 'hr-screening', name: 'HR Candidate Screening', category: 'use_case', tags: ['hr', 'high-risk'] },
  { id: 'customer-service', name: 'Customer Service / Support', category: 'use_case', tags: ['customer', 'low-risk'] },
  { id: 'internal-productivity', name: 'Internal Productivity Tools', category: 'use_case', tags: ['internal', 'low-risk'] },
  { id: 'code-generation', name: 'Code Generation / Development', category: 'use_case', tags: ['developer', 'medium-risk'] },
  { id: 'content-creation', name: 'Content Creation / Marketing', category: 'use_case', tags: ['marketing', 'low-risk'] },
  { id: 'data-analysis', name: 'Data Analysis / BI', category: 'use_case', tags: ['analytics', 'medium-risk'] },
  { id: 'research', name: 'Research & Development', category: 'use_case', tags: ['research', 'medium-risk'] },
  { id: 'legal-review', name: 'Legal Document Review', category: 'use_case', tags: ['legal', 'high-risk'] },
  { id: 'risk-assessment', name: 'Risk Assessment', category: 'use_case', tags: ['risk', 'high-risk'] },
  { id: 'biometric-identification', name: 'Biometric Identification', category: 'use_case', tags: ['biometric', 'prohibited'] },
  { id: 'autonomous-medical-diagnosis', name: 'Autonomous Medical Diagnosis', category: 'use_case', tags: ['medical', 'prohibited'] },
  { id: 'political-profiling', name: 'Political Profiling', category: 'use_case', tags: ['political', 'prohibited'] },
  { id: 'unexplainable-credit-decisions', name: 'Unexplainable Credit Decisions', category: 'use_case', tags: ['credit', 'prohibited'] },
];

async function seedCatalog() {
  console.log('🌱 Seeding AI catalog...');

  let created = 0;
  let updated = 0;
  let skipped = 0;

  for (const item of catalogItems) {
    try {
      // Check if exists
      const existingResult = await pool.query(
        'SELECT id FROM ai_catalog_items WHERE catalog_id = $1',
        [item.id]
      );

      if (existingResult.rows.length > 0) {
        // Update existing
        await pool.query(
          `UPDATE ai_catalog_items SET
            name = $1,
            provider = $2,
            tags = $3,
            updated_at = CURRENT_TIMESTAMP
          WHERE catalog_id = $4`,
          [item.name, item.provider || null, item.tags || [], item.id]
        );
        updated++;
      } else {
        // Create new
        await pool.query(
          `INSERT INTO ai_catalog_items (catalog_id, name, provider, category, tags)
          VALUES ($1, $2, $3, $4, $5)`,
          [item.id, item.name, item.provider || null, item.category, item.tags || []]
        );
        created++;
      }
    } catch (error) {
      console.error(`Error seeding item ${item.id}:`, error);
      skipped++;
    }
  }

  console.log(`✅ Catalog seeding complete:`);
  console.log(`   - Created: ${created}`);
  console.log(`   - Updated: ${updated}`);
  console.log(`   - Skipped: ${skipped}`);
  console.log(`   - Total: ${catalogItems.length}`);
}

// Run if called directly
if (require.main === module) {
  seedCatalog()
    .then(() => {
      console.log('✅ Done!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Error seeding catalog:', error);
      process.exit(1);
    });
}

export { seedCatalog, catalogItems };
