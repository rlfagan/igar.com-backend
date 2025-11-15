import pool from './index';
import dotenv from 'dotenv';

dotenv.config();

const seedData = {
  // Common AI Model Options
  commonModels: [
    // === COTS / VENDOR MODELS ===

    // OpenAI Models
    { name: 'GPT-4', vendor: 'OpenAI', type: 'llm', version: 'gpt-4', category: 'vendor', parameters: '1.76T', description: 'Large multimodal model that accepts image and text inputs, with strong reasoning and broad general knowledge', use_cases: 'Complex reasoning, code generation, creative writing, detailed analysis', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/gpt-4' },
    { name: 'GPT-4 Turbo', vendor: 'OpenAI', type: 'llm', version: 'gpt-4-turbo', category: 'vendor', parameters: '1.76T', description: 'Optimized version of GPT-4 with longer context window (128K tokens) and lower cost', use_cases: 'Long-form content, detailed analysis, multi-document tasks', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/gpt-4-turbo' },
    { name: 'GPT-4o', vendor: 'OpenAI', type: 'multimodal', version: 'gpt-4o', category: 'vendor', parameters: 'Unknown', description: 'Flagship multimodal model with vision capabilities and fast response times', use_cases: 'Image understanding, OCR, multimodal tasks, real-time applications', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/gpt-4o' },
    { name: 'GPT-4o Mini', vendor: 'OpenAI', type: 'llm', version: 'gpt-4o-mini', category: 'vendor', parameters: 'Unknown', description: 'Compact multimodal model optimized for speed and cost-efficiency with strong performance', use_cases: 'High-volume applications, chatbots, content generation, API integrations', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/gpt-4o-mini' },
    { name: 'GPT-3.5 Turbo', vendor: 'OpenAI', type: 'llm', version: 'gpt-3.5-turbo', category: 'vendor', parameters: '175B', description: 'Fast and cost-effective language model suitable for most conversational and text generation tasks', use_cases: 'Chatbots, content creation, summarization, basic coding assistance', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/gpt-3-5-turbo' },
    { name: 'text-embedding-3-large', vendor: 'OpenAI', type: 'embedding', version: 'text-embedding-3-large', category: 'vendor', parameters: 'Unknown', description: 'High-dimensional embedding model with 3072 dimensions for semantic search and retrieval', use_cases: 'Semantic search, document retrieval, clustering, recommendation systems', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/embeddings' },
    { name: 'text-embedding-3-small', vendor: 'OpenAI', type: 'embedding', version: 'text-embedding-3-small', category: 'vendor', parameters: 'Unknown', description: 'Efficient embedding model with 1536 dimensions balancing performance and cost', use_cases: 'Semantic search, classification, clustering, similarity matching', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/embeddings' },
    { name: 'DALL-E 3', vendor: 'OpenAI', type: 'vision', version: 'dall-e-3', category: 'vendor', parameters: 'Unknown', description: 'Advanced text-to-image generation model with improved prompt following and detail', use_cases: 'Image generation, creative design, marketing materials, concept visualization', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/dall-e' },
    { name: 'Whisper', vendor: 'OpenAI', type: 'other', version: 'whisper-1', category: 'vendor', parameters: '1.5B', description: 'Automatic speech recognition model trained on multilingual and multitask supervised data', use_cases: 'Speech-to-text transcription, audio translation, voice assistants, meeting transcription', license: 'Proprietary', documentation_url: 'https://platform.openai.com/docs/models/whisper' },

    // Anthropic Models
    { name: 'Claude 3.5 Sonnet', vendor: 'Anthropic', type: 'llm', version: 'claude-3-5-sonnet-20241022', category: 'vendor', parameters: 'Unknown', description: 'Most intelligent Claude model with enhanced reasoning, coding, and analysis capabilities', use_cases: 'Complex analysis, code generation, research tasks, agentic workflows', license: 'Proprietary', documentation_url: 'https://docs.anthropic.com/en/docs/models-overview' },
    { name: 'Claude 3.5 Haiku', vendor: 'Anthropic', type: 'llm', version: 'claude-3-5-haiku-20241022', category: 'vendor', parameters: 'Unknown', description: 'Fastest and most compact Claude model optimized for speed and efficiency', use_cases: 'High-throughput tasks, real-time applications, cost-effective deployments', license: 'Proprietary', documentation_url: 'https://docs.anthropic.com/en/docs/models-overview' },
    { name: 'Claude 3 Opus', vendor: 'Anthropic', type: 'llm', version: 'claude-3-opus-20240229', category: 'vendor', parameters: 'Unknown', description: 'Most capable Claude 3 model for highly complex tasks requiring deep reasoning and analysis', use_cases: 'Advanced reasoning, complex research, technical writing, detailed code review', license: 'Proprietary', documentation_url: 'https://docs.anthropic.com/en/docs/models-overview' },
    { name: 'Claude 3 Sonnet', vendor: 'Anthropic', type: 'llm', version: 'claude-3-sonnet-20240229', category: 'vendor', parameters: 'Unknown', description: 'Balanced Claude 3 model offering strong performance with improved speed and cost-effectiveness', use_cases: 'Data processing, analysis, content generation, coding assistance', license: 'Proprietary', documentation_url: 'https://docs.anthropic.com/en/docs/models-overview' },
    { name: 'Claude 3 Haiku', vendor: 'Anthropic', type: 'llm', version: 'claude-3-haiku-20240307', category: 'vendor', parameters: 'Unknown', description: 'Fastest Claude 3 model designed for near-instant responsiveness and high-throughput use cases', use_cases: 'Customer support, quick content moderation, simple extraction, real-time chat', license: 'Proprietary', documentation_url: 'https://docs.anthropic.com/en/docs/models-overview' },

    // Google Models
    { name: 'Gemini 1.5 Pro', vendor: 'Google', type: 'multimodal', version: 'gemini-1.5-pro', category: 'vendor', parameters: 'Unknown', description: 'Advanced multimodal model with 1M+ token context window for complex reasoning and analysis', use_cases: 'Long document analysis, code reasoning, multimodal understanding, video analysis', license: 'Proprietary', documentation_url: 'https://ai.google.dev/gemini-api/docs/models/gemini' },
    { name: 'Gemini 1.5 Flash', vendor: 'Google', type: 'multimodal', version: 'gemini-1.5-flash', category: 'vendor', parameters: 'Unknown', description: 'Fast and efficient multimodal model optimized for speed with long context support', use_cases: 'High-frequency tasks, real-time applications, summarization, data extraction', license: 'Proprietary', documentation_url: 'https://ai.google.dev/gemini-api/docs/models/gemini' },
    { name: 'Gemini Pro', vendor: 'Google', type: 'llm', version: 'gemini-pro', category: 'vendor', parameters: 'Unknown', description: 'Production-ready text generation model with strong reasoning capabilities', use_cases: 'Text generation, summarization, question answering, content creation', license: 'Proprietary', documentation_url: 'https://ai.google.dev/gemini-api/docs/models/gemini' },
    { name: 'Gemini Pro Vision', vendor: 'Google', type: 'multimodal', version: 'gemini-pro-vision', category: 'vendor', parameters: 'Unknown', description: 'Multimodal model combining text and vision understanding capabilities', use_cases: 'Image captioning, visual question answering, document understanding, OCR', license: 'Proprietary', documentation_url: 'https://ai.google.dev/gemini-api/docs/models/gemini' },
    { name: 'PaLM 2', vendor: 'Google', type: 'llm', version: 'text-bison-001', category: 'vendor', parameters: '340B', description: 'Pathways Language Model optimized for reasoning, coding, and multilingual tasks', use_cases: 'Text generation, translation, code generation, reasoning tasks', license: 'Proprietary', documentation_url: 'https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/text' },
    { name: 'Vertex AI Vision', vendor: 'Google', type: 'vision', version: 'imagetext@001', category: 'vendor', parameters: 'Unknown', description: 'Computer vision model for image analysis and text extraction from images', use_cases: 'Image classification, object detection, OCR, visual inspection', license: 'Proprietary', documentation_url: 'https://cloud.google.com/vision/docs' },
    { name: 'Chirp (Speech)', vendor: 'Google', type: 'other', version: 'chirp-v2', category: 'vendor', parameters: 'Unknown', description: 'Universal speech model supporting 100+ languages for transcription and translation', use_cases: 'Speech-to-text, transcription, multilingual speech recognition, voice assistants', license: 'Proprietary', documentation_url: 'https://cloud.google.com/speech-to-text/docs' },

    // Microsoft Azure OpenAI
    { name: 'Azure OpenAI GPT-4', vendor: 'Microsoft Azure', type: 'llm', version: 'gpt-4', category: 'vendor', parameters: '1.76T', description: 'Enterprise-grade GPT-4 deployment with enhanced security, compliance, and regional availability', use_cases: 'Enterprise applications, secure AI deployment, compliance-required tasks, regulated industries', license: 'Proprietary', documentation_url: 'https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models' },
    { name: 'Azure OpenAI GPT-4 Turbo', vendor: 'Microsoft Azure', type: 'llm', version: 'gpt-4-turbo', category: 'vendor', parameters: '1.76T', description: 'Azure-hosted GPT-4 Turbo with enterprise SLA, data residency, and enhanced security', use_cases: 'Enterprise long-form content, secure multi-document analysis, compliance workflows', license: 'Proprietary', documentation_url: 'https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models' },
    { name: 'Azure OpenAI GPT-3.5', vendor: 'Microsoft Azure', type: 'llm', version: 'gpt-35-turbo', category: 'vendor', parameters: '175B', description: 'Cost-effective GPT-3.5 on Azure with enterprise security and data protection', use_cases: 'Enterprise chatbots, customer service automation, content generation at scale', license: 'Proprietary', documentation_url: 'https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models' },
    { name: 'Azure Cognitive Services Vision', vendor: 'Microsoft Azure', type: 'vision', version: 'computer-vision-v3.2', category: 'vendor', parameters: 'Unknown', description: 'Computer vision API for image analysis, OCR, and spatial analysis with enterprise features', use_cases: 'Image tagging, OCR, object detection, facial recognition, spatial analysis', license: 'Proprietary', documentation_url: 'https://learn.microsoft.com/en-us/azure/cognitive-services/computer-vision/' },
    { name: 'Azure Document Intelligence', vendor: 'Microsoft Azure', type: 'other', version: 'form-recognizer-v3', category: 'vendor', parameters: 'Unknown', description: 'AI-powered document processing for extraction and analysis of structured data from forms', use_cases: 'Invoice processing, form extraction, document digitization, data entry automation', license: 'Proprietary', documentation_url: 'https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/' },
    { name: 'Azure Speech Services', vendor: 'Microsoft Azure', type: 'other', version: 'speech-v1', category: 'vendor', parameters: 'Unknown', description: 'Speech-to-text, text-to-speech, and speech translation with 100+ languages', use_cases: 'Voice assistants, transcription services, call center analytics, accessibility features', license: 'Proprietary', documentation_url: 'https://learn.microsoft.com/en-us/azure/ai-services/speech-service/' },

    // AWS Bedrock Models
    { name: 'Amazon Titan Text', vendor: 'AWS', type: 'llm', version: 'amazon.titan-text-express-v1', category: 'vendor', parameters: 'Unknown', description: 'Amazon-developed text generation model optimized for English with summarization and generation', use_cases: 'Content creation, summarization, question answering, chatbots', license: 'Proprietary', documentation_url: 'https://docs.aws.amazon.com/bedrock/latest/userguide/titan-text-models.html' },
    { name: 'Amazon Titan Embeddings', vendor: 'AWS', type: 'embedding', version: 'amazon.titan-embed-text-v1', category: 'vendor', parameters: 'Unknown', description: 'Embeddings model supporting 25+ languages with 1536-dimensional vectors', use_cases: 'Semantic search, document retrieval, recommendation systems, RAG applications', license: 'Proprietary', documentation_url: 'https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html' },
    { name: 'AWS Bedrock Claude', vendor: 'AWS', type: 'llm', version: 'anthropic.claude-3-sonnet', category: 'vendor', parameters: 'Unknown', description: 'Claude 3 Sonnet available through AWS Bedrock with AWS security and compliance', use_cases: 'Enterprise AI applications, data processing, analysis, secure deployments', license: 'Proprietary', documentation_url: 'https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude.html' },
    { name: 'AWS Rekognition', vendor: 'AWS', type: 'vision', version: 'rekognition-v1', category: 'vendor', parameters: 'Unknown', description: 'Computer vision service for image and video analysis with facial recognition capabilities', use_cases: 'Facial recognition, object detection, content moderation, celebrity recognition', license: 'Proprietary', documentation_url: 'https://docs.aws.amazon.com/rekognition/' },
    { name: 'AWS Textract', vendor: 'AWS', type: 'other', version: 'textract-v1', category: 'vendor', parameters: 'Unknown', description: 'Document analysis service that extracts text, forms, and tables from scanned documents', use_cases: 'Document processing, form extraction, invoice processing, automated data entry', license: 'Proprietary', documentation_url: 'https://docs.aws.amazon.com/textract/' },
    { name: 'AWS Comprehend', vendor: 'AWS', type: 'classification', version: 'comprehend-v1', category: 'vendor', parameters: 'Unknown', description: 'Natural language processing service for entity extraction, sentiment analysis, and topic modeling', use_cases: 'Sentiment analysis, entity recognition, topic modeling, document classification', license: 'Proprietary', documentation_url: 'https://docs.aws.amazon.com/comprehend/' },

    // Cohere Models
    { name: 'Command R+', vendor: 'Cohere', type: 'llm', version: 'command-r-plus', category: 'vendor', parameters: '104B', description: 'Most capable Command model optimized for RAG, multilingual tasks, and complex reasoning', use_cases: 'Retrieval augmented generation, multi-step reasoning, coding, multilingual applications', license: 'Proprietary', documentation_url: 'https://docs.cohere.com/docs/command-r-plus' },
    { name: 'Command R', vendor: 'Cohere', type: 'llm', version: 'command-r', category: 'vendor', parameters: '35B', description: 'Scalable model optimized for long-context RAG and tool use at enterprise scale', use_cases: 'RAG applications, conversational AI, tool use, enterprise chatbots', license: 'Proprietary', documentation_url: 'https://docs.cohere.com/docs/command-r' },
    { name: 'Command', vendor: 'Cohere', type: 'llm', version: 'command', category: 'vendor', parameters: '52B', description: 'General-purpose language model for text generation and conversational applications', use_cases: 'Content generation, summarization, chatbots, classification', license: 'Proprietary', documentation_url: 'https://docs.cohere.com/docs/command-beta' },
    { name: 'Command Light', vendor: 'Cohere', type: 'llm', version: 'command-light', category: 'vendor', parameters: '6B', description: 'Lightweight and fast model optimized for speed and cost-effectiveness', use_cases: 'High-volume tasks, simple classification, content moderation, quick responses', license: 'Proprietary', documentation_url: 'https://docs.cohere.com/docs/command-beta' },
    { name: 'Embed v3', vendor: 'Cohere', type: 'embedding', version: 'embed-english-v3.0', category: 'vendor', parameters: 'Unknown', description: 'State-of-the-art embeddings with compression and multi-lingual support', use_cases: 'Semantic search, clustering, classification, recommendation systems', license: 'Proprietary', documentation_url: 'https://docs.cohere.com/docs/embed-2' },
    { name: 'Rerank v3', vendor: 'Cohere', type: 'other', version: 'rerank-english-v3.0', category: 'vendor', parameters: 'Unknown', description: 'Reranking model for improving search relevance and result ordering', use_cases: 'Search result reranking, document relevance scoring, retrieval optimization', license: 'Proprietary', documentation_url: 'https://docs.cohere.com/docs/rerank-2' },

    // Mistral AI (Commercial)
    { name: 'Mistral Large 2', vendor: 'Mistral AI', type: 'llm', version: 'mistral-large-2407', category: 'vendor', parameters: '123B', description: 'Flagship Mistral model with advanced reasoning, coding, and multilingual capabilities', use_cases: 'Complex reasoning, code generation, multilingual tasks, advanced analysis', license: 'Proprietary', documentation_url: 'https://docs.mistral.ai/platform/endpoints/' },
    { name: 'Mistral Large', vendor: 'Mistral AI', type: 'llm', version: 'mistral-large-latest', category: 'vendor', parameters: '123B', description: 'Top-tier Mistral model for high-complexity tasks with broad capabilities', use_cases: 'Enterprise applications, complex reasoning, code generation, multilingual support', license: 'Proprietary', documentation_url: 'https://docs.mistral.ai/platform/endpoints/' },
    { name: 'Mistral Medium', vendor: 'Mistral AI', type: 'llm', version: 'mistral-medium-latest', category: 'vendor', parameters: 'Unknown', description: 'Balanced model offering strong performance with improved efficiency', use_cases: 'General text generation, summarization, question answering, analysis', license: 'Proprietary', documentation_url: 'https://docs.mistral.ai/platform/endpoints/' },
    { name: 'Mistral Small', vendor: 'Mistral AI', type: 'llm', version: 'mistral-small-latest', category: 'vendor', parameters: '22B', description: 'Cost-effective model optimized for low latency and high throughput', use_cases: 'Simple classification, content moderation, lightweight chatbots, API integrations', license: 'Proprietary', documentation_url: 'https://docs.mistral.ai/platform/endpoints/' },

    // Perplexity AI
    { name: 'Perplexity Sonar Large', vendor: 'Perplexity AI', type: 'llm', version: 'sonar-large-online', category: 'vendor', parameters: 'Unknown', description: 'Large online model with real-time web search and fact-checking capabilities', use_cases: 'Research, fact-checking, current events analysis, web-connected Q&A', license: 'Proprietary', documentation_url: 'https://docs.perplexity.ai/docs/model-cards' },
    { name: 'Perplexity Sonar Medium', vendor: 'Perplexity AI', type: 'llm', version: 'sonar-medium-online', category: 'vendor', parameters: 'Unknown', description: 'Medium-sized online model balancing speed and accuracy for web-connected tasks', use_cases: 'Quick research, information retrieval, summarization, web-based queries', license: 'Proprietary', documentation_url: 'https://docs.perplexity.ai/docs/model-cards' },

    // AI21 Labs
    { name: 'Jurassic-2 Ultra', vendor: 'AI21 Labs', type: 'llm', version: 'j2-ultra', category: 'vendor', parameters: '178B', description: 'Most powerful Jurassic model with superior language understanding and generation', use_cases: 'Complex text generation, long-form content, advanced reasoning, creative writing', license: 'Proprietary', documentation_url: 'https://docs.ai21.com/docs/jurassic-2-models' },
    { name: 'Jurassic-2 Mid', vendor: 'AI21 Labs', type: 'llm', version: 'j2-mid', category: 'vendor', parameters: '80B', description: 'Mid-tier Jurassic model balancing performance and cost for production use', use_cases: 'Content generation, summarization, classification, chatbots', license: 'Proprietary', documentation_url: 'https://docs.ai21.com/docs/jurassic-2-models' },
    { name: 'Jamba', vendor: 'AI21 Labs', type: 'llm', version: 'jamba-instruct', category: 'vendor', parameters: '52B', description: 'Hybrid SSM-Transformer model with 256K context window for long-context tasks', use_cases: 'Long document analysis, extensive context reasoning, complex conversations', license: 'Proprietary', documentation_url: 'https://docs.ai21.com/docs/jamba-models' },

    // Stability AI
    { name: 'Stable Diffusion XL', vendor: 'Stability AI', type: 'vision', version: 'stable-diffusion-xl-1024-v1-0', category: 'vendor', parameters: '3.5B', description: 'High-resolution text-to-image model generating detailed 1024x1024 images with improved composition', use_cases: 'High-quality image generation, art creation, product visualization, marketing materials', license: 'CreativeML Open RAIL++-M', documentation_url: 'https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0' },
    { name: 'Stable Diffusion 3', vendor: 'Stability AI', type: 'vision', version: 'stable-diffusion-3-medium', category: 'vendor', parameters: '2B', description: 'Latest generation diffusion model with improved prompt understanding and text rendering', use_cases: 'Advanced image generation, text-in-image rendering, creative design, visual content', license: 'Stability AI Community License', documentation_url: 'https://huggingface.co/stabilityai/stable-diffusion-3-medium' },

    // Midjourney
    { name: 'Midjourney v6', vendor: 'Midjourney', type: 'vision', version: 'v6', category: 'vendor', parameters: 'Unknown', description: 'State-of-the-art image generation model with photorealistic output and enhanced prompt adherence', use_cases: 'Professional art generation, creative design, conceptual visualization, marketing imagery', license: 'Proprietary', documentation_url: 'https://docs.midjourney.com/' },

    // Anthropic Specific Tools
    { name: 'Claude with Vision', vendor: 'Anthropic', type: 'multimodal', version: 'claude-3-opus-vision', category: 'vendor', parameters: 'Unknown', description: 'Claude 3 Opus with vision capabilities for image understanding and multimodal reasoning', use_cases: 'Image analysis, document processing, visual question answering, diagram interpretation', license: 'Proprietary', documentation_url: 'https://docs.anthropic.com/en/docs/vision' },

    // === OPEN SOURCE MODELS ===

    // Meta/Llama Models
    { name: 'Llama 3.3 70B', vendor: 'Meta', type: 'llm', version: 'llama-3.3-70b-instruct', category: 'open_source', parameters: '70B', description: 'Latest Llama 3 model with 70B parameters, optimized for instruction following and reasoning', use_cases: 'Chat, instruction following, coding, reasoning tasks', license: 'Llama 3 Community License', documentation_url: 'https://huggingface.co/meta-llama/llama-3.3-70b-instruct' },
    { name: 'Llama 3.2 90B', vendor: 'Meta', type: 'multimodal', version: 'llama-3.2-90b-vision', category: 'open_source', parameters: '90B', description: 'Multimodal Llama model with vision capabilities for image understanding', use_cases: 'Image captioning, visual question answering, multimodal chat', license: 'Llama 3.2 Community License', documentation_url: 'https://huggingface.co/meta-llama/llama-3.2-90b-vision' },
    { name: 'Llama 3.2 11B', vendor: 'Meta', type: 'multimodal', version: 'llama-3.2-11b-vision', category: 'open_source', parameters: '11B', description: 'Compact multimodal Llama model with vision capabilities for image understanding', use_cases: 'Image captioning, visual Q&A, document understanding, edge deployment', license: 'Llama 3.2 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-3.2-11B-Vision' },
    { name: 'Llama 3.2 3B', vendor: 'Meta', type: 'llm', version: 'llama-3.2-3b', category: 'open_source', parameters: '3B', description: 'Lightweight Llama model optimized for on-device and edge deployments', use_cases: 'Edge AI, mobile applications, low-resource environments, summarization', license: 'Llama 3.2 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-3.2-3B' },
    { name: 'Llama 3.2 1B', vendor: 'Meta', type: 'llm', version: 'llama-3.2-1b', category: 'open_source', parameters: '1B', description: 'Ultra-compact Llama model for resource-constrained environments and mobile devices', use_cases: 'Mobile AI, IoT devices, edge computing, lightweight chatbots', license: 'Llama 3.2 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-3.2-1B' },
    { name: 'Llama 3.1 405B', vendor: 'Meta', type: 'llm', version: 'llama-3.1-405b', category: 'open_source', parameters: '405B', description: 'Largest Llama model with state-of-the-art performance on complex reasoning and generation tasks', use_cases: 'Advanced reasoning, complex coding, research, synthetic data generation', license: 'Llama 3.1 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-3.1-405B' },
    { name: 'Llama 3.1 70B', vendor: 'Meta', type: 'llm', version: 'llama-3.1-70b', category: 'open_source', parameters: '70B', description: 'High-performance Llama model with 128K context window for long-form content', use_cases: 'Long-document analysis, coding, content generation, complex reasoning', license: 'Llama 3.1 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-3.1-70B' },
    { name: 'Llama 3.1 8B', vendor: 'Meta', type: 'llm', version: 'llama-3.1-8b', category: 'open_source', parameters: '8B', description: 'Efficient Llama model balancing performance and computational requirements', use_cases: 'Chatbots, summarization, content generation, general-purpose NLP', license: 'Llama 3.1 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-3.1-8B' },
    { name: 'Llama 3 70B', vendor: 'Meta', type: 'llm', version: 'llama-3-70b', category: 'open_source', parameters: '70B', description: 'Llama 3 large model with strong reasoning and multilingual capabilities', use_cases: 'Complex reasoning, multilingual tasks, coding, content creation', license: 'Llama 3 Community License', documentation_url: 'https://huggingface.co/meta-llama/Meta-Llama-3-70B' },
    { name: 'Llama 3 8B', vendor: 'Meta', type: 'llm', version: 'llama-3-8b', category: 'open_source', parameters: '8B', description: 'Llama 3 base model offering strong performance for general-purpose tasks', use_cases: 'Text generation, question answering, summarization, chatbots', license: 'Llama 3 Community License', documentation_url: 'https://huggingface.co/meta-llama/Meta-Llama-3-8B' },
    { name: 'Llama 2 70B', vendor: 'Meta', type: 'llm', version: 'llama-2-70b', category: 'open_source', parameters: '70B', description: 'Llama 2 large model fine-tuned for dialogue and instruction following', use_cases: 'Conversational AI, instruction following, content generation, Q&A', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-2-70b-hf' },
    { name: 'Llama 2 13B', vendor: 'Meta', type: 'llm', version: 'llama-2-13b', category: 'open_source', parameters: '13B', description: 'Mid-sized Llama 2 model providing good balance of quality and efficiency', use_cases: 'Chatbots, text generation, summarization, general NLP tasks', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-2-13b-hf' },
    { name: 'Llama 2 7B', vendor: 'Meta', type: 'llm', version: 'llama-2-7b', category: 'open_source', parameters: '7B', description: 'Compact Llama 2 model suitable for efficient deployment and fine-tuning', use_cases: 'Resource-efficient chatbots, fine-tuning, domain adaptation, text generation', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/meta-llama/Llama-2-7b-hf' },

    // Mistral Open Source
    { name: 'Mixtral 8x22B', vendor: 'Mistral AI', type: 'llm', version: 'mixtral-8x22b-instruct-v0.1', category: 'open_source', parameters: '141B', description: 'Large mixture-of-experts model with 8 experts of 22B parameters each for high performance', use_cases: 'Complex reasoning, multilingual tasks, code generation, advanced analysis', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/mistralai/Mixtral-8x22B-Instruct-v0.1' },
    { name: 'Mixtral 8x7B', vendor: 'Mistral AI', type: 'llm', version: 'mixtral-8x7b-instruct-v0.1', category: 'open_source', parameters: '46.7B', description: 'Efficient mixture-of-experts model outperforming larger models while using fewer active parameters', use_cases: 'Multilingual tasks, code generation, reasoning, general text generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1' },
    { name: 'Mistral 7B', vendor: 'Mistral AI', type: 'llm', version: 'mistral-7b-instruct-v0.3', category: 'open_source', parameters: '7B', description: 'Compact open-source model with strong performance and efficient inference', use_cases: 'Chatbots, text generation, summarization, instruction following', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.3' },
    { name: 'Mistral Nemo', vendor: 'Mistral AI', type: 'llm', version: 'mistral-nemo-instruct-2407', category: 'open_source', parameters: '12B', description: 'Mid-size model developed with NVIDIA, optimized for reasoning and multilingual tasks', use_cases: 'Chatbots, multilingual applications, reasoning tasks, code generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/mistralai/Mistral-Nemo-Instruct-2407' },

    // Google Open Source
    { name: 'Gemma 2 27B', vendor: 'Google', type: 'llm', version: 'gemma-2-27b-it', category: 'open_source', parameters: '27B', description: 'Largest Gemma 2 model with advanced capabilities for complex reasoning and generation', use_cases: 'Complex reasoning, code generation, long-form content, research tasks', license: 'Gemma License', documentation_url: 'https://huggingface.co/google/gemma-2-27b-it' },
    { name: 'Gemma 2 9B', vendor: 'Google', type: 'llm', version: 'gemma-2-9b-it', category: 'open_source', parameters: '9B', description: 'Mid-sized Gemma 2 model balancing performance and efficiency for production use', use_cases: 'Chatbots, content generation, question answering, summarization', license: 'Gemma License', documentation_url: 'https://huggingface.co/google/gemma-2-9b-it' },
    { name: 'Gemma 2 2B', vendor: 'Google', type: 'llm', version: 'gemma-2-2b-it', category: 'open_source', parameters: '2B', description: 'Compact Gemma 2 model optimized for edge deployment and resource-constrained environments', use_cases: 'Edge AI, mobile applications, lightweight chatbots, on-device inference', license: 'Gemma License', documentation_url: 'https://huggingface.co/google/gemma-2-2b-it' },
    { name: 'Gemma 7B', vendor: 'Google', type: 'llm', version: 'gemma-7b-it', category: 'open_source', parameters: '7B', description: 'First-generation Gemma model with strong instruction-following capabilities', use_cases: 'Instruction following, text generation, chatbots, Q&A', license: 'Gemma License', documentation_url: 'https://huggingface.co/google/gemma-7b-it' },
    { name: 'Gemma 2B', vendor: 'Google', type: 'llm', version: 'gemma-2b-it', category: 'open_source', parameters: '2B', description: 'Lightweight Gemma model for efficient deployment and fine-tuning', use_cases: 'Resource-efficient applications, fine-tuning, lightweight inference', license: 'Gemma License', documentation_url: 'https://huggingface.co/google/gemma-2b-it' },
    { name: 'T5 XXL', vendor: 'Google', type: 'llm', version: 't5-11b', category: 'open_source', parameters: '11B', description: 'Largest T5 encoder-decoder model for text-to-text transfer learning tasks', use_cases: 'Translation, summarization, question answering, text generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/google-t5/t5-11b' },
    { name: 'T5 Large', vendor: 'Google', type: 'llm', version: 't5-large', category: 'open_source', parameters: '770M', description: 'Large T5 model for diverse text-to-text tasks with good performance-efficiency balance', use_cases: 'Translation, summarization, text classification, NLP tasks', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/google-t5/t5-large' },
    { name: 'T5 Base', vendor: 'Google', type: 'llm', version: 't5-base', category: 'open_source', parameters: '220M', description: 'Base T5 encoder-decoder model for efficient text-to-text transfer learning', use_cases: 'General NLP tasks, fine-tuning, text processing, classification', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/google-t5/t5-base' },
    { name: 'FLAN-T5 XXL', vendor: 'Google', type: 'llm', version: 'flan-t5-xxl', category: 'open_source', parameters: '11B', description: 'T5 model fine-tuned on instruction tasks with improved zero-shot performance', use_cases: 'Instruction following, zero-shot tasks, multi-task learning, reasoning', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/google/flan-t5-xxl' },

    // Alibaba Qwen
    { name: 'Qwen2.5 72B', vendor: 'Alibaba', type: 'llm', version: 'qwen2.5-72b-instruct', category: 'open_source', parameters: '72B', description: 'Largest Qwen 2.5 model with advanced multilingual and reasoning capabilities', use_cases: 'Complex reasoning, multilingual tasks, code generation, long-context analysis', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/Qwen/Qwen2.5-72B-Instruct' },
    { name: 'Qwen2.5 32B', vendor: 'Alibaba', type: 'llm', version: 'qwen2.5-32b-instruct', category: 'open_source', parameters: '32B', description: 'Mid-large Qwen model balancing performance and computational efficiency', use_cases: 'Multilingual applications, coding, content generation, reasoning', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/Qwen/Qwen2.5-32B-Instruct' },
    { name: 'Qwen2.5 14B', vendor: 'Alibaba', type: 'llm', version: 'qwen2.5-14b-instruct', category: 'open_source', parameters: '14B', description: 'Mid-sized Qwen model with strong multilingual and reasoning performance', use_cases: 'Chatbots, multilingual NLP, code assistance, general text generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/Qwen/Qwen2.5-14B-Instruct' },
    { name: 'Qwen2.5 7B', vendor: 'Alibaba', type: 'llm', version: 'qwen2.5-7b-instruct', category: 'open_source', parameters: '7B', description: 'Efficient Qwen model optimized for multilingual tasks and coding', use_cases: 'Multilingual chatbots, code generation, text generation, Q&A', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/Qwen/Qwen2.5-7B-Instruct' },

    // Microsoft Phi
    { name: 'Phi-4', vendor: 'Microsoft', type: 'llm', version: 'phi-4', category: 'open_source', parameters: '14B', description: 'Latest Phi model with enhanced reasoning and problem-solving capabilities', use_cases: 'Reasoning tasks, coding, mathematical problem solving, Q&A', license: 'MIT', documentation_url: 'https://huggingface.co/microsoft/phi-4' },
    { name: 'Phi-3.5 MoE', vendor: 'Microsoft', type: 'llm', version: 'phi-3.5-moe-instruct', category: 'open_source', parameters: '42B', description: 'Mixture-of-experts Phi model with 16 experts for efficient inference', use_cases: 'Complex reasoning, multilingual tasks, coding, long-context applications', license: 'MIT', documentation_url: 'https://huggingface.co/microsoft/Phi-3.5-MoE-instruct' },
    { name: 'Phi-3 Medium', vendor: 'Microsoft', type: 'llm', version: 'phi-3-medium-128k-instruct', category: 'open_source', parameters: '14B', description: 'Mid-sized Phi-3 with 128K context window for long-context tasks', use_cases: 'Long document analysis, coding, reasoning, extended conversations', license: 'MIT', documentation_url: 'https://huggingface.co/microsoft/Phi-3-medium-128k-instruct' },
    { name: 'Phi-3 Small', vendor: 'Microsoft', type: 'llm', version: 'phi-3-small-128k-instruct', category: 'open_source', parameters: '7B', description: 'Compact Phi-3 model with 128K context window balancing size and capability', use_cases: 'Chatbots, reasoning, coding assistance, summarization', license: 'MIT', documentation_url: 'https://huggingface.co/microsoft/Phi-3-small-128k-instruct' },
    { name: 'Phi-3 Mini', vendor: 'Microsoft', type: 'llm', version: 'phi-3-mini-128k-instruct', category: 'open_source', parameters: '3.8B', description: 'Ultra-compact Phi-3 model optimized for edge and mobile deployment', use_cases: 'Edge AI, mobile applications, lightweight inference, resource-constrained environments', license: 'MIT', documentation_url: 'https://huggingface.co/microsoft/Phi-3-mini-128k-instruct' },

    // Databricks DBRX
    { name: 'DBRX Instruct', vendor: 'Databricks', type: 'llm', version: 'dbrx-instruct', category: 'open_source', parameters: '132B', description: 'Large MoE model with 36B active parameters optimized for instruction following', use_cases: 'Complex instructions, code generation, reasoning, enterprise applications', license: 'Databricks Open Model License', documentation_url: 'https://huggingface.co/databricks/dbrx-instruct' },
    { name: 'DBRX Base', vendor: 'Databricks', type: 'llm', version: 'dbrx-base', category: 'open_source', parameters: '132B', description: 'Base DBRX model for fine-tuning on domain-specific tasks', use_cases: 'Fine-tuning, domain adaptation, custom model development', license: 'Databricks Open Model License', documentation_url: 'https://huggingface.co/databricks/dbrx-base' },

    // Falcon
    { name: 'Falcon 180B', vendor: 'TII', type: 'llm', version: 'falcon-180b', category: 'open_source', parameters: '180B', description: 'Largest open-source Falcon model with strong multilingual capabilities', use_cases: 'Complex reasoning, multilingual tasks, research, large-scale generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/tiiuae/falcon-180B' },
    { name: 'Falcon 40B', vendor: 'TII', type: 'llm', version: 'falcon-40b', category: 'open_source', parameters: '40B', description: 'Mid-sized Falcon model with strong performance across diverse tasks', use_cases: 'Text generation, reasoning, chatbots, multilingual applications', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/tiiuae/falcon-40b' },
    { name: 'Falcon 7B', vendor: 'TII', type: 'llm', version: 'falcon-7b', category: 'open_source', parameters: '7B', description: 'Compact Falcon model suitable for efficient deployment and fine-tuning', use_cases: 'Chatbots, text generation, fine-tuning, resource-efficient applications', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/tiiuae/falcon-7b' },

    // MPT (MosaicML)
    { name: 'MPT 30B', vendor: 'MosaicML', type: 'llm', version: 'mpt-30b-instruct', category: 'open_source', parameters: '30B', description: 'MosaicML Pretrained Transformer optimized for long-context understanding', use_cases: 'Long-context tasks, instruction following, chatbots, content generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/mosaicml/mpt-30b-instruct' },
    { name: 'MPT 7B', vendor: 'MosaicML', type: 'llm', version: 'mpt-7b-instruct', category: 'open_source', parameters: '7B', description: 'Efficient MPT model with commercial-friendly license and strong performance', use_cases: 'Chatbots, instruction following, commercial applications, text generation', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/mosaicml/mpt-7b-instruct' },

    // Vicuna
    { name: 'Vicuna 33B', vendor: 'LMSYS', type: 'llm', version: 'vicuna-33b-v1.3', category: 'open_source', parameters: '33B', description: 'Large Vicuna model fine-tuned from Llama with conversational capabilities', use_cases: 'Conversational AI, chatbots, instruction following, research', license: 'Non-commercial', documentation_url: 'https://huggingface.co/lmsys/vicuna-33b-v1.3' },
    { name: 'Vicuna 13B', vendor: 'LMSYS', type: 'llm', version: 'vicuna-13b-v1.5', category: 'open_source', parameters: '13B', description: 'Mid-sized Vicuna model with strong conversational performance', use_cases: 'Chatbots, conversational AI, research, instruction following', license: 'Non-commercial', documentation_url: 'https://huggingface.co/lmsys/vicuna-13b-v1.5' },

    // Hugging Face Models (NLP)
    { name: 'BERT Large', vendor: 'Google', type: 'classification', version: 'google-bert/bert-large-uncased', category: 'open_source', parameters: '340M', description: 'Large bidirectional transformer for language understanding, pretrained on BookCorpus and Wikipedia', use_cases: 'Sequence classification, token classification, question answering, masked language modeling', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/google-bert/bert-large-uncased' },
    { name: 'BERT Base', vendor: 'Google', type: 'classification', version: 'google-bert/bert-base-uncased', category: 'open_source', parameters: '110M', description: 'Base BERT model pretrained on English text in self-supervised fashion with MLM and NSP objectives', use_cases: 'Fine-tuning for NLP tasks, feature extraction, sentence classification, named entity recognition', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/google-bert/bert-base-uncased' },
    { name: 'RoBERTa Large', vendor: 'Hugging Face', type: 'classification', version: 'roberta-large', category: 'open_source', parameters: '355M', description: 'Robustly optimized BERT model trained longer with more data and no NSP objective', use_cases: 'Text classification, sentiment analysis, NER, question answering', license: 'MIT', documentation_url: 'https://huggingface.co/FacebookAI/roberta-large' },
    { name: 'RoBERTa Base', vendor: 'Hugging Face', type: 'classification', version: 'roberta-base', category: 'open_source', parameters: '125M', description: 'Base RoBERTa model with improved training methodology over BERT', use_cases: 'Fine-tuning for classification, NER, sentiment analysis, Q&A', license: 'MIT', documentation_url: 'https://huggingface.co/FacebookAI/roberta-base' },
    { name: 'DistilBERT', vendor: 'Hugging Face', type: 'classification', version: 'distilbert-base-uncased', category: 'open_source', parameters: '66M', description: 'Distilled version of BERT retaining 97% performance with 40% fewer parameters', use_cases: 'Resource-efficient NLP, classification, NER, lightweight deployments', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/distilbert/distilbert-base-uncased' },
    { name: 'ALBERT XXL', vendor: 'Hugging Face', type: 'classification', version: 'albert-xxlarge-v2', category: 'open_source', parameters: '235M', description: 'A Lite BERT with parameter sharing for improved efficiency and performance', use_cases: 'NLP tasks, classification, question answering, low-resource training', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/albert/albert-xxlarge-v2' },
    { name: 'DeBERTa V3 Large', vendor: 'Microsoft', type: 'classification', version: 'deberta-v3-large', category: 'open_source', parameters: '435M', description: 'Decoding-enhanced BERT with disentangled attention and enhanced mask decoder', use_cases: 'Advanced NLP tasks, classification, NER, benchmarking', license: 'MIT', documentation_url: 'https://huggingface.co/microsoft/deberta-v3-large' },
    { name: 'XLM-RoBERTa', vendor: 'Facebook', type: 'classification', version: 'xlm-roberta-large', category: 'open_source', parameters: '559M', description: 'Multilingual RoBERTa trained on 100 languages for cross-lingual understanding', use_cases: 'Multilingual NLP, cross-lingual classification, translation, NER', license: 'MIT', documentation_url: 'https://huggingface.co/FacebookAI/xlm-roberta-large' },

    // Embedding Models
    { name: 'Sentence-BERT', vendor: 'UKP Lab', type: 'embedding', version: 'all-mpnet-base-v2', category: 'open_source', parameters: '110M', description: 'Sentence embeddings using siamese BERT networks for semantic similarity', use_cases: 'Semantic search, clustering, sentence similarity, paraphrase detection', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/sentence-transformers/all-mpnet-base-v2' },
    { name: 'E5 Large', vendor: 'Microsoft', type: 'embedding', version: 'e5-large-v2', category: 'open_source', parameters: '335M', description: 'Text embeddings by weakly-supervised contrastive pre-training with strong performance', use_cases: 'Semantic search, retrieval, classification, clustering', license: 'MIT', documentation_url: 'https://huggingface.co/intfloat/e5-large-v2' },
    { name: 'BGE Large', vendor: 'BAAI', type: 'embedding', version: 'bge-large-en-v1.5', category: 'open_source', parameters: '335M', description: 'Beijing Academy of AI general embedding model with SOTA retrieval performance', use_cases: 'Semantic search, information retrieval, RAG applications, clustering', license: 'MIT', documentation_url: 'https://huggingface.co/BAAI/bge-large-en-v1.5' },
    { name: 'GTE Large', vendor: 'Alibaba', type: 'embedding', version: 'gte-large', category: 'open_source', parameters: '335M', description: 'General text embeddings trained on diverse corpus for semantic understanding', use_cases: 'Semantic search, document retrieval, text similarity, clustering', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/thenlper/gte-large' },

    // Vision Models
    { name: 'CLIP ViT-L/14', vendor: 'OpenAI', type: 'multimodal', version: 'clip-vit-large-patch14', category: 'open_source', parameters: '427M', description: 'Large vision transformer CLIP model for zero-shot image classification and retrieval', use_cases: 'Zero-shot classification, image-text matching, semantic search, vision-language tasks', license: 'MIT', documentation_url: 'https://huggingface.co/openai/clip-vit-large-patch14' },
    { name: 'CLIP ViT-B/32', vendor: 'OpenAI', type: 'multimodal', version: 'clip-vit-base-patch32', category: 'open_source', parameters: '151M', description: 'Base CLIP model with vision transformer for efficient multimodal understanding', use_cases: 'Image classification, image-text retrieval, zero-shot tasks, embeddings', license: 'MIT', documentation_url: 'https://huggingface.co/openai/clip-vit-base-patch32' },
    { name: 'BLIP-2', vendor: 'Salesforce', type: 'multimodal', version: 'blip2-opt-6.7b', category: 'open_source', parameters: '7.8B', description: 'Bootstrapping language-image pre-training with frozen LLMs for vision-language tasks', use_cases: 'Image captioning, visual question answering, image-text retrieval, multimodal chat', license: 'MIT', documentation_url: 'https://huggingface.co/Salesforce/blip2-opt-6.7b' },
    { name: 'LLaVA 1.6', vendor: 'Microsoft', type: 'multimodal', version: 'llava-1.6-vicuna-13b', category: 'open_source', parameters: '13B', description: 'Large Language and Vision Assistant combining vision encoder with Vicuna LLM', use_cases: 'Visual question answering, image understanding, multimodal chat, visual reasoning', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/liuhaotian/llava-v1.6-vicuna-13b' },
    { name: 'CogVLM', vendor: 'THUDM', type: 'multimodal', version: 'cogvlm-chat-hf', category: 'open_source', parameters: '17B', description: 'Visual language model with deep fusion of vision and language for understanding', use_cases: 'Visual question answering, image captioning, visual reasoning, multimodal dialogue', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/THUDM/cogvlm-chat-hf' },
    { name: 'YOLO v8', vendor: 'Ultralytics', type: 'vision', version: 'yolov8x', category: 'open_source', parameters: '68M', description: 'State-of-the-art real-time object detection model with high accuracy and speed', use_cases: 'Object detection, instance segmentation, pose estimation, real-time inference', license: 'AGPL-3.0', documentation_url: 'https://docs.ultralytics.com/models/yolov8/' },
    { name: 'SAM (Segment Anything)', vendor: 'Meta', type: 'vision', version: 'sam-vit-huge', category: 'open_source', parameters: '641M', description: 'Promptable segmentation model for zero-shot object segmentation in images', use_cases: 'Image segmentation, object masking, annotation tools, visual editing', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/facebook/sam-vit-huge' },
    { name: 'Stable Diffusion v1.5', vendor: 'Stability AI', type: 'vision', version: 'stable-diffusion-v1-5', category: 'open_source', parameters: '860M', description: 'Latent diffusion model for high-quality text-to-image generation', use_cases: 'Image generation, art creation, image editing, inpainting', license: 'CreativeML Open RAIL-M', documentation_url: 'https://huggingface.co/runwayml/stable-diffusion-v1-5' },
    { name: 'Stable Diffusion v2.1', vendor: 'Stability AI', type: 'vision', version: 'stable-diffusion-2-1', category: 'open_source', parameters: '865M', description: 'Improved stable diffusion with better prompt understanding and image quality', use_cases: 'Advanced image generation, creative design, image synthesis, art production', license: 'CreativeML Open RAIL++-M', documentation_url: 'https://huggingface.co/stabilityai/stable-diffusion-2-1' },

    // Audio/Speech Models
    { name: 'Whisper Large V3', vendor: 'OpenAI', type: 'other', version: 'whisper-large-v3', category: 'open_source', parameters: '1.55B', description: 'Latest and most accurate Whisper model for multilingual speech recognition', use_cases: 'Speech-to-text, transcription, translation, multilingual ASR', license: 'MIT', documentation_url: 'https://huggingface.co/openai/whisper-large-v3' },
    { name: 'Whisper Medium', vendor: 'OpenAI', type: 'other', version: 'whisper-medium', category: 'open_source', parameters: '769M', description: 'Mid-sized Whisper model balancing accuracy and computational requirements', use_cases: 'Speech recognition, audio transcription, voice-to-text, subtitling', license: 'MIT', documentation_url: 'https://huggingface.co/openai/whisper-medium' },
    { name: 'Wav2Vec 2.0', vendor: 'Facebook', type: 'other', version: 'wav2vec2-large-960h', category: 'open_source', parameters: '317M', description: 'Self-supervised speech representation learning for robust ASR performance', use_cases: 'Speech recognition, audio analysis, low-resource ASR, fine-tuning', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/facebook/wav2vec2-large-960h' },

    // Code Models
    { name: 'CodeLlama 70B', vendor: 'Meta', type: 'llm', version: 'codellama-70b-instruct', category: 'open_source', parameters: '70B', description: 'Largest CodeLlama model specialized for code generation and understanding', use_cases: 'Code generation, code completion, debugging, technical documentation', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/codellama/CodeLlama-70b-Instruct-hf' },
    { name: 'CodeLlama 34B', vendor: 'Meta', type: 'llm', version: 'codellama-34b-instruct', category: 'open_source', parameters: '34B', description: 'Large CodeLlama model with strong coding capabilities and instruction following', use_cases: 'Code generation, refactoring, code explanation, programming assistance', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/codellama/CodeLlama-34b-Instruct-hf' },
    { name: 'CodeLlama 13B', vendor: 'Meta', type: 'llm', version: 'codellama-13b-instruct', category: 'open_source', parameters: '13B', description: 'Mid-sized CodeLlama for efficient code generation and understanding', use_cases: 'Code completion, code review, debugging, documentation generation', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/codellama/CodeLlama-13b-Instruct-hf' },
    { name: 'CodeLlama 7B', vendor: 'Meta', type: 'llm', version: 'codellama-7b-instruct', category: 'open_source', parameters: '7B', description: 'Compact CodeLlama model for resource-efficient code tasks', use_cases: 'Code generation, simple refactoring, code suggestions, lightweight IDE integration', license: 'Llama 2 Community License', documentation_url: 'https://huggingface.co/codellama/CodeLlama-7b-Instruct-hf' },
    { name: 'StarCoder2 15B', vendor: 'BigCode', type: 'llm', version: 'starcoder2-15b', category: 'open_source', parameters: '15B', description: 'Advanced code generation model trained on diverse programming languages', use_cases: 'Code generation, multi-language programming, code completion, technical tasks', license: 'BigCode OpenRAIL-M', documentation_url: 'https://huggingface.co/bigcode/starcoder2-15b' },
    { name: 'CodeGen 16B', vendor: 'Salesforce', type: 'llm', version: 'codegen-16b-mono', category: 'open_source', parameters: '16B', description: 'Large autoregressive model for program synthesis and code generation', use_cases: 'Code generation, program synthesis, code completion, Python programming', license: 'Apache 2.0', documentation_url: 'https://huggingface.co/Salesforce/codegen-16B-mono' },
    { name: 'DeepSeek Coder 33B', vendor: 'DeepSeek', type: 'llm', version: 'deepseek-coder-33b-instruct', category: 'open_source', parameters: '33B', description: 'Specialized coding model with strong performance on code generation benchmarks', use_cases: 'Code generation, debugging, code explanation, algorithm implementation', license: 'DeepSeek License', documentation_url: 'https://huggingface.co/deepseek-ai/deepseek-coder-33b-instruct' },

    // ML Framework Models
    { name: 'XGBoost', vendor: 'DMLC', type: 'classification', version: 'xgboost', category: 'open_source', parameters: 'Varies', description: 'Scalable gradient boosting framework for supervised learning with tree-based models', use_cases: 'Classification, regression, ranking, feature importance analysis', license: 'Apache 2.0', documentation_url: 'https://xgboost.readthedocs.io/' },
    { name: 'LightGBM', vendor: 'Microsoft', type: 'classification', version: 'lightgbm', category: 'open_source', parameters: 'Varies', description: 'Fast gradient boosting framework using histogram-based algorithms for efficiency', use_cases: 'Classification, regression, large-scale ML, feature engineering', license: 'MIT', documentation_url: 'https://lightgbm.readthedocs.io/' },
    { name: 'CatBoost', vendor: 'Yandex', type: 'classification', version: 'catboost', category: 'open_source', parameters: 'Varies', description: 'Gradient boosting library with categorical feature support and robustness', use_cases: 'Classification, regression, categorical data handling, ranking', license: 'Apache 2.0', documentation_url: 'https://catboost.ai/' },
    { name: 'Random Forest', vendor: 'Scikit-learn', type: 'classification', version: 'sklearn-rf', category: 'open_source', parameters: 'Varies', description: 'Ensemble learning method using multiple decision trees for classification and regression', use_cases: 'Classification, regression, feature selection, outlier detection', license: 'BSD-3-Clause', documentation_url: 'https://scikit-learn.org/stable/modules/ensemble.html#random-forests' },
    { name: 'Gradient Boosting', vendor: 'Scikit-learn', type: 'classification', version: 'sklearn-gb', category: 'open_source', parameters: 'Varies', description: 'Sequential ensemble method building models to correct predecessor errors', use_cases: 'Classification, regression, feature importance, predictive modeling', license: 'BSD-3-Clause', documentation_url: 'https://scikit-learn.org/stable/modules/ensemble.html#gradient-boosting' },

    // Fraud Detection / Anomaly Detection
    { name: 'Isolation Forest', vendor: 'Scikit-learn', type: 'fraud_detection', version: 'isolation-forest', category: 'open_source', parameters: 'Varies', description: 'Unsupervised anomaly detection using isolation of observations in random forests', use_cases: 'Fraud detection, anomaly detection, outlier identification, quality control', license: 'BSD-3-Clause', documentation_url: 'https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html' },
    { name: 'Autoencoder Anomaly', vendor: 'TensorFlow', type: 'fraud_detection', version: 'autoencoder-ad', category: 'open_source', parameters: 'Varies', description: 'Neural network-based anomaly detection using reconstruction error from autoencoders', use_cases: 'Fraud detection, network intrusion detection, manufacturing defects, healthcare anomalies', license: 'Apache 2.0', documentation_url: 'https://www.tensorflow.org/tutorials/generative/autoencoder' },
    { name: 'LSTM Anomaly Detection', vendor: 'PyTorch', type: 'fraud_detection', version: 'lstm-ad', category: 'open_source', parameters: 'Varies', description: 'Recurrent neural network for time-series anomaly detection using LSTM cells', use_cases: 'Time-series fraud detection, system monitoring, predictive maintenance, behavioral anomalies', license: 'BSD-3-Clause', documentation_url: 'https://pytorch.org/tutorials/beginner/lstm_word_language_model.html' },

    // Recommendation Systems
    { name: 'Neural Collaborative Filtering', vendor: 'Open Source', type: 'recommendation', version: 'ncf-v1', category: 'open_source', parameters: 'Varies', description: 'Deep learning approach to collaborative filtering using neural networks', use_cases: 'Product recommendations, content recommendations, personalization, user preference modeling', license: 'MIT', documentation_url: 'https://github.com/hexiangnan/neural_collaborative_filtering' },
    { name: 'Deep Factorization Machine', vendor: 'Open Source', type: 'recommendation', version: 'deepfm', category: 'open_source', parameters: 'Varies', description: 'Combines factorization machines with deep learning for CTR prediction and recommendations', use_cases: 'Click-through rate prediction, recommendation systems, ad targeting, e-commerce', license: 'Apache 2.0', documentation_url: 'https://github.com/ChenglongChen/tensorflow-DeepFM' },
    { name: 'Wide & Deep', vendor: 'TensorFlow', type: 'recommendation', version: 'wide-deep', category: 'open_source', parameters: 'Varies', description: 'Google recommender combining memorization and generalization for recommendations', use_cases: 'App recommendations, content recommendations, ranking systems, personalization', license: 'Apache 2.0', documentation_url: 'https://www.tensorflow.org/tutorials/structured_data/wide_and_deep' },
    { name: 'LightFM', vendor: 'Open Source', type: 'recommendation', version: 'lightfm', category: 'open_source', parameters: 'Varies', description: 'Hybrid recommendation algorithm combining collaborative and content-based filtering', use_cases: 'Cold-start recommendations, content discovery, personalization, hybrid filtering', license: 'Apache 2.0', documentation_url: 'https://github.com/lyst/lightfm' },
  ],

  // Common Vendors
  vendors: [
    { name: 'OpenAI', description: 'AI research and deployment company', industry: 'AI/ML', website: 'https://openai.com' },
    { name: 'Anthropic', description: 'AI safety and research company', industry: 'AI/ML', website: 'https://anthropic.com' },
    { name: 'Google', description: 'Google Cloud AI and Vertex AI', industry: 'Cloud/AI', website: 'https://cloud.google.com/vertex-ai' },
    { name: 'Microsoft Azure', description: 'Azure OpenAI and Cognitive Services', industry: 'Cloud/AI', website: 'https://azure.microsoft.com' },
    { name: 'Microsoft', description: 'Phi models and AI research', industry: 'AI/ML', website: 'https://www.microsoft.com/ai' },
    { name: 'AWS', description: 'Amazon Bedrock and SageMaker', industry: 'Cloud/AI', website: 'https://aws.amazon.com/bedrock' },
    { name: 'Meta', description: 'Llama models and AI research', industry: 'AI/ML', website: 'https://ai.meta.com' },
    { name: 'Mistral AI', description: 'Open and commercial LLMs', industry: 'AI/ML', website: 'https://mistral.ai' },
    { name: 'Cohere', description: 'Enterprise NLP platform', industry: 'AI/ML', website: 'https://cohere.com' },
    { name: 'Hugging Face', description: 'Open source ML platform', industry: 'AI/ML', website: 'https://huggingface.co' },
    { name: 'Perplexity AI', description: 'AI-powered search and answers', industry: 'AI/ML', website: 'https://www.perplexity.ai' },
    { name: 'AI21 Labs', description: 'Jurassic and Jamba models', industry: 'AI/ML', website: 'https://www.ai21.com' },
    { name: 'Stability AI', description: 'Stable Diffusion and generative AI', industry: 'AI/ML', website: 'https://stability.ai' },
    { name: 'Midjourney', description: 'AI image generation', industry: 'AI/ML', website: 'https://www.midjourney.com' },
    { name: 'Salesforce', description: 'Einstein AI and BLIP models', industry: 'AI/ML', website: 'https://www.salesforce.com/ai' },
    { name: 'Databricks', description: 'DBRX and MLflow', industry: 'AI/ML', website: 'https://www.databricks.com' },
    { name: 'Alibaba', description: 'Qwen models and cloud AI', industry: 'AI/ML', website: 'https://www.alibabacloud.com/solutions/ai' },
    { name: 'Scale AI', description: 'Data labeling and ML ops', industry: 'AI/ML', website: 'https://scale.com' },
    { name: 'DataRobot', description: 'Automated ML platform', industry: 'AI/ML', website: 'https://datarobot.com' },
    { name: 'H2O.ai', description: 'Open source ML platform', industry: 'AI/ML', website: 'https://h2o.ai' },
    { name: 'Replicate', description: 'Run open-source models via API', industry: 'AI/ML', website: 'https://replicate.com' },
    { name: 'Together AI', description: 'Open-source model inference', industry: 'AI/ML', website: 'https://www.together.ai' },
    { name: 'Anyscale', description: 'Ray and distributed ML', industry: 'AI/ML', website: 'https://www.anyscale.com' },
  ],

  // Common Use Cases
  useCases: [
    { name: 'Customer Service Chatbot', category: 'Customer Support', risk_level: 'medium' },
    { name: 'Document Processing & Extraction', category: 'Document AI', risk_level: 'medium' },
    { name: 'Fraud Detection', category: 'Risk Management', risk_level: 'high' },
    { name: 'Credit Risk Scoring', category: 'Lending', risk_level: 'high' },
    { name: 'KYC/Identity Verification', category: 'Compliance', risk_level: 'high' },
    { name: 'AML Transaction Monitoring', category: 'Compliance', risk_level: 'high' },
    { name: 'Content Moderation', category: 'Safety', risk_level: 'high' },
    { name: 'Sentiment Analysis', category: 'Analytics', risk_level: 'low' },
    { name: 'Product Recommendations', category: 'Personalization', risk_level: 'medium' },
    { name: 'Code Generation/Copilot', category: 'Developer Tools', risk_level: 'low' },
    { name: 'Email Classification', category: 'Productivity', risk_level: 'low' },
    { name: 'Contract Analysis', category: 'Legal Tech', risk_level: 'high' },
    { name: 'Market Research & Analysis', category: 'Analytics', risk_level: 'low' },
    { name: 'HR Resume Screening', category: 'Human Resources', risk_level: 'high' },
    { name: 'Medical Diagnosis Support', category: 'Healthcare', risk_level: 'critical' },
  ],

  // Common Data Sources
  dataSources: [
    { name: 'Internal Customer Database', sensitivity: 'high', pii: true },
    { name: 'Transaction History', sensitivity: 'high', pii: true },
    { name: 'Customer Support Tickets', sensitivity: 'medium', pii: true },
    { name: 'Public Web Data', sensitivity: 'low', pii: false },
    { name: 'Product Catalog', sensitivity: 'low', pii: false },
    { name: 'User Behavior Logs', sensitivity: 'medium', pii: true },
    { name: 'Financial Statements', sensitivity: 'high', pii: false },
    { name: 'Synthetic/Generated Data', sensitivity: 'low', pii: false },
    { name: 'Third-Party Data Feeds', sensitivity: 'medium', pii: false },
    { name: 'Social Media Data', sensitivity: 'medium', pii: true },
    { name: 'Email Communications', sensitivity: 'high', pii: true },
    { name: 'Call Center Recordings', sensitivity: 'high', pii: true },
    { name: 'Application Forms', sensitivity: 'high', pii: true },
    { name: 'Contract Documents', sensitivity: 'high', pii: true },
  ],

  // Deployment Platforms
  deploymentPlatforms: [
    { name: 'AWS SageMaker', provider: 'AWS', type: 'cloud_gpu' },
    { name: 'Google Vertex AI', provider: 'Google Cloud', type: 'cloud_gpu' },
    { name: 'Azure ML', provider: 'Microsoft Azure', type: 'cloud_gpu' },
    { name: 'Kubernetes (EKS)', provider: 'AWS', type: 'kubernetes' },
    { name: 'Kubernetes (GKE)', provider: 'Google Cloud', type: 'kubernetes' },
    { name: 'Kubernetes (AKS)', provider: 'Microsoft Azure', type: 'kubernetes' },
    { name: 'AWS Lambda', provider: 'AWS', type: 'serverless_api' },
    { name: 'Google Cloud Functions', provider: 'Google Cloud', type: 'serverless_api' },
    { name: 'Azure Functions', provider: 'Microsoft Azure', type: 'serverless_api' },
    { name: 'On-Premise GPU Cluster', provider: 'Self-Hosted', type: 'on_prem_gpu' },
    { name: 'OpenAI API', provider: 'OpenAI', type: 'vendor_hosted' },
    { name: 'Anthropic API', provider: 'Anthropic', type: 'vendor_hosted' },
    { name: 'Hugging Face Inference API', provider: 'Hugging Face', type: 'vendor_hosted' },
  ],

  // Common Safety Features
  safetyFeatures: [
    { name: 'Input Validation', description: 'Validate and sanitize all inputs', category: 'Input Security' },
    { name: 'Output Filtering', description: 'Filter harmful or inappropriate outputs', category: 'Output Security' },
    { name: 'Prompt Guardrails', description: 'Prevent prompt injection attacks', category: 'Prompt Security' },
    { name: 'Safety Classifier', description: 'Classify content for safety', category: 'Content Safety' },
    { name: 'Rate Limiting', description: 'Limit API request rates', category: 'Availability' },
    { name: 'PII Redaction', description: 'Automatically redact sensitive information', category: 'Privacy' },
    { name: 'Bias Monitoring', description: 'Monitor for biased outputs', category: 'Fairness' },
    { name: 'Audit Logging', description: 'Log all model interactions', category: 'Compliance' },
    { name: 'Human Review Queue', description: 'Queue uncertain outputs for review', category: 'Quality' },
    { name: 'Explainability Tools', description: 'Provide model decision explanations', category: 'Transparency' },
    { name: 'Model Versioning', description: 'Track model versions and rollbacks', category: 'Operations' },
    { name: 'A/B Testing', description: 'Test models before full deployment', category: 'Quality' },
  ],

  // Regulatory Frameworks
  regulatoryFrameworks: [
    { name: 'ECOA (Equal Credit Opportunity Act)', description: 'Prohibits credit discrimination', applies_to: ['credit', 'lending'] },
    { name: 'Regulation B', description: 'Implements ECOA requirements', applies_to: ['credit', 'lending'] },
    { name: 'Fair Credit Reporting Act (FCRA)', description: 'Regulates consumer credit information', applies_to: ['credit', 'background_checks'] },
    { name: 'FFIEC Guidance', description: 'Federal Financial Institutions Examination Council guidance', applies_to: ['banking', 'finance'] },
    { name: 'AML/BSA', description: 'Anti-Money Laundering and Bank Secrecy Act', applies_to: ['banking', 'finance'] },
    { name: 'KYC/CIP', description: 'Know Your Customer / Customer Identification Program', applies_to: ['banking', 'finance'] },
    { name: 'GDPR', description: 'General Data Protection Regulation (EU)', applies_to: ['data_privacy'] },
    { name: 'CCPA', description: 'California Consumer Privacy Act', applies_to: ['data_privacy'] },
    { name: 'GLBA', description: 'Gramm-Leach-Bliley Act (financial privacy)', applies_to: ['finance', 'privacy'] },
    { name: 'HIPAA', description: 'Health Insurance Portability and Accountability Act', applies_to: ['healthcare'] },
    { name: 'SR 11-7', description: 'Model Risk Management guidance', applies_to: ['banking', 'model_risk'] },
    { name: 'NIST AI Framework', description: 'National Institute of Standards and Technology AI framework', applies_to: ['all'] },
  ],
};

async function seed() {
  try {
    console.log('🌱 Seeding reference data...');

    // Drop and recreate reference tables to ensure they have the latest schema
    await pool.query('DROP TABLE IF EXISTS ref_models, ref_vendors, ref_use_cases, ref_data_sources, ref_deployment_platforms, ref_safety_features, ref_regulatory_frameworks CASCADE');

    // Create reference tables
    await pool.query(`
      CREATE TABLE ref_models (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        vendor VARCHAR(255),
        type VARCHAR(100),
        version VARCHAR(100),
        category VARCHAR(50),
        parameters VARCHAR(50),
        description TEXT,
        use_cases TEXT,
        license VARCHAR(100),
        documentation_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await pool.query(`
      CREATE TABLE ref_vendors (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        description TEXT,
        industry VARCHAR(100),
        website VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await pool.query(`
      CREATE TABLE ref_use_cases (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        category VARCHAR(100),
        risk_level VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await pool.query(`
      CREATE TABLE ref_data_sources (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        sensitivity VARCHAR(50),
        pii BOOLEAN,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await pool.query(`
      CREATE TABLE ref_deployment_platforms (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        provider VARCHAR(100),
        type VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await pool.query(`
      CREATE TABLE ref_safety_features (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        category VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await pool.query(`
      CREATE TABLE ref_regulatory_frameworks (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        applies_to JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create default user if doesn't exist (for demo/testing purposes)
    await pool.query(`
      INSERT INTO users (id, email, password_hash, full_name, role, created_at)
      VALUES (1, 'demo@example.com', 'demo-password-hash', 'Demo User', 'user', NOW())
      ON CONFLICT (id) DO NOTHING;
    `);
    console.log('✅ Default user ensured');

    // Insert models
    for (const model of seedData.commonModels) {
      await pool.query(
        'INSERT INTO ref_models (name, vendor, type, version, category, parameters, description, use_cases, license, documentation_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)',
        [model.name, model.vendor, model.type, model.version, model.category, model.parameters || null, model.description || null, model.use_cases || null, model.license || null, model.documentation_url || null]
      );
    }
    console.log(`✅ Inserted ${seedData.commonModels.length} model references`);

    // Insert vendors
    for (const vendor of seedData.vendors) {
      await pool.query(
        'INSERT INTO ref_vendors (name, description, industry, website) VALUES ($1, $2, $3, $4)',
        [vendor.name, vendor.description, vendor.industry, vendor.website]
      );
    }
    console.log(`✅ Inserted ${seedData.vendors.length} vendor references`);

    // Insert use cases
    for (const useCase of seedData.useCases) {
      await pool.query(
        'INSERT INTO ref_use_cases (name, category, risk_level) VALUES ($1, $2, $3)',
        [useCase.name, useCase.category, useCase.risk_level]
      );
    }
    console.log(`✅ Inserted ${seedData.useCases.length} use case references`);

    // Insert data sources
    for (const dataSource of seedData.dataSources) {
      await pool.query(
        'INSERT INTO ref_data_sources (name, sensitivity, pii) VALUES ($1, $2, $3)',
        [dataSource.name, dataSource.sensitivity, dataSource.pii]
      );
    }
    console.log(`✅ Inserted ${seedData.dataSources.length} data source references`);

    // Insert deployment platforms
    for (const platform of seedData.deploymentPlatforms) {
      await pool.query(
        'INSERT INTO ref_deployment_platforms (name, provider, type) VALUES ($1, $2, $3)',
        [platform.name, platform.provider, platform.type]
      );
    }
    console.log(`✅ Inserted ${seedData.deploymentPlatforms.length} deployment platform references`);

    // Insert safety features
    for (const feature of seedData.safetyFeatures) {
      await pool.query(
        'INSERT INTO ref_safety_features (name, description, category) VALUES ($1, $2, $3)',
        [feature.name, feature.description, feature.category]
      );
    }
    console.log(`✅ Inserted ${seedData.safetyFeatures.length} safety feature references`);

    // Insert regulatory frameworks
    for (const framework of seedData.regulatoryFrameworks) {
      await pool.query(
        'INSERT INTO ref_regulatory_frameworks (name, description, applies_to) VALUES ($1, $2, $3)',
        [framework.name, framework.description, JSON.stringify(framework.applies_to)]
      );
    }
    console.log(`✅ Inserted ${seedData.regulatoryFrameworks.length} regulatory framework references`);

    console.log('🎉 Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

seed();
