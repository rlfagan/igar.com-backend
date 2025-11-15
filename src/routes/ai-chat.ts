import express from 'express';
import Anthropic from '@anthropic-ai/sdk';

const router = express.Router();

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

interface ChatContext {
  page?: string;
  warnings?: string[];
  riskScores?: Record<string, number>;
  complianceIssues?: string[];
}

router.post('/ai-chat', async (req, res) => {
  try {
    const { message, context, conversationHistory } = req.body as {
      message: string;
      context: ChatContext;
      conversationHistory: ChatMessage[];
    };

    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Message is required',
      });
    }

    if (!process.env.ANTHROPIC_API_KEY) {
      return res.status(500).json({
        success: false,
        error: 'Anthropic API key not configured',
      });
    }

    // Build context-aware system prompt
    let systemPrompt = `You are an expert AI governance assistant for the IGAR (Intelligent Governance, Assurance & Risk) platform. Your role is to help users understand:

1. **Risk Scores and Warnings**: Explain what various risk scores mean, why certain items are flagged, and how to address them.

2. **Compliance Requirements**: Provide clear explanations of regulatory requirements including:
   - ECOA (Equal Credit Opportunity Act)
   - FFIEC (Federal Financial Institutions Examination Council)
   - AML/BSA (Anti-Money Laundering / Bank Secrecy Act)
   - KYC/CIP (Know Your Customer / Customer Identification Program)
   - GDPR and data privacy regulations

3. **AI Model Evaluation**: Help users understand:
   - Model performance metrics
   - Bias and fairness considerations
   - Training data requirements
   - Model documentation best practices

4. **Remediation Steps**: Provide actionable advice on how to fix issues and improve compliance scores.

Keep your responses:
- **Concise**: 2-3 paragraphs maximum
- **Actionable**: Include specific next steps when relevant
- **Professional**: Use clear, business-appropriate language
- **Accurate**: Base answers on established AI governance frameworks (ISO/IEC 42001, EU AI Act, NIST AI RMF)

`;

    // Add context-specific information
    if (context) {
      if (context.page) {
        systemPrompt += `\n\nCurrent Page: ${context.page}`;
      }

      if (context.warnings && context.warnings.length > 0) {
        systemPrompt += `\n\nActive Warnings:\n${context.warnings.map((w, i) => `${i + 1}. ${w}`).join('\n')}`;
      }

      if (context.riskScores && Object.keys(context.riskScores).length > 0) {
        systemPrompt += `\n\nRisk Scores:\n${Object.entries(context.riskScores).map(([key, value]) => `- ${key}: ${value}/100`).join('\n')}`;
      }

      if (context.complianceIssues && context.complianceIssues.length > 0) {
        systemPrompt += `\n\nCompliance Issues:\n${context.complianceIssues.map((issue, i) => `${i + 1}. ${issue}`).join('\n')}`;
      }
    }

    // Build conversation history for Claude API
    const messages: Array<{ role: 'user' | 'assistant'; content: string }> = [];

    // Add previous conversation (limit to last 10 messages to avoid token limits)
    const recentHistory = conversationHistory.slice(-10);
    recentHistory.forEach((msg) => {
      messages.push({
        role: msg.role,
        content: msg.content,
      });
    });

    // Add current message
    messages.push({
      role: 'user',
      content: message,
    });

    // Call Claude API
    const response = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 1024,
      system: systemPrompt,
      messages: messages,
    });

    // Extract response text
    const responseText = response.content
      .filter((block) => block.type === 'text')
      .map((block) => (block as any).text)
      .join('\n');

    return res.json({
      success: true,
      response: responseText,
    });

  } catch (error: any) {
    console.error('AI chat error:', error);
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to process chat message',
    });
  }
});

export default router;
