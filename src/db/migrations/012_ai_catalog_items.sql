-- AI Catalog Items - Dynamic catalog that can be managed via admin UI
-- Stores models, tools, OSS, datasets, and use cases

CREATE TABLE IF NOT EXISTS ai_catalog_items (
  id SERIAL PRIMARY KEY,
  catalog_id VARCHAR(255) NOT NULL UNIQUE, -- e.g., "anthropic:claude-3.5-sonnet"
  name VARCHAR(255) NOT NULL,
  provider VARCHAR(255),
  category VARCHAR(50) NOT NULL CHECK (category IN ('model', 'tool', 'oss', 'dataset', 'use_case')),
  description TEXT,
  tags TEXT[] DEFAULT ARRAY[]::TEXT[],

  -- Additional metadata
  version VARCHAR(100), -- For models/oss: "3.5", "v2.1", etc.
  license VARCHAR(100), -- For OSS: "MIT", "Apache-2.0", "GPL-3.0", etc.
  homepage_url TEXT,
  documentation_url TEXT,

  -- Status
  is_active BOOLEAN DEFAULT true,
  is_deprecated BOOLEAN DEFAULT false,
  deprecation_note TEXT,

  -- Audit
  created_by INTEGER REFERENCES users(id),
  updated_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_ai_catalog_items_catalog_id ON ai_catalog_items(catalog_id);
CREATE INDEX idx_ai_catalog_items_category ON ai_catalog_items(category);
CREATE INDEX idx_ai_catalog_items_provider ON ai_catalog_items(provider);
CREATE INDEX idx_ai_catalog_items_active ON ai_catalog_items(is_active);
CREATE INDEX idx_ai_catalog_items_tags ON ai_catalog_items USING GIN(tags);

-- Full text search index
CREATE INDEX idx_ai_catalog_items_search ON ai_catalog_items USING GIN(
  to_tsvector('english',
    COALESCE(name, '') || ' ' ||
    COALESCE(provider, '') || ' ' ||
    COALESCE(description, '') || ' ' ||
    COALESCE(array_to_string(tags, ' '), '')
  )
);

COMMENT ON TABLE ai_catalog_items IS 'Dynamic AI catalog that can be managed through admin UI';
COMMENT ON COLUMN ai_catalog_items.catalog_id IS 'Unique identifier like "openai:gpt-4.1" or "fraud-detection"';
COMMENT ON COLUMN ai_catalog_items.category IS 'Type: model, tool, oss, dataset, or use_case';
