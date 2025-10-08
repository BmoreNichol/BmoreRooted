-- Fixed Supabase schema for Business Intelligence Reports
-- Removes immutable function issues

CREATE TABLE IF NOT EXISTS reports (
  id BIGSERIAL PRIMARY KEY,
  report_id TEXT UNIQUE NOT NULL,
  domain TEXT NOT NULL,
  company_data JSONB NOT NULL,
  industry_data JSONB NOT NULL,
  competitive_analysis JSONB NOT NULL,
  strategic_recommendations JSONB NOT NULL,
  created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Performance indexes (removed problematic partial index)
CREATE INDEX IF NOT EXISTS idx_reports_domain ON reports(domain);
CREATE INDEX IF NOT EXISTS idx_reports_report_id ON reports(report_id);
CREATE INDEX IF NOT EXISTS idx_reports_created_timestamp ON reports(created_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_reports_domain_recent ON reports(domain, created_timestamp DESC);

-- GIN indexes for JSON search capabilities
CREATE INDEX IF NOT EXISTS idx_reports_company_data_gin ON reports USING GIN (company_data);
CREATE INDEX IF NOT EXISTS idx_reports_competitive_gin ON reports USING GIN (competitive_analysis);

-- Enable Row Level Security
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Allow authenticated users to insert reports" ON reports
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to read reports" ON reports
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Allow service role full access" ON reports
  FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

-- Auto-update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for auto-updating timestamps
CREATE TRIGGER update_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Usage analytics view (fixed to avoid NOW() issues)
CREATE OR REPLACE VIEW usage_analytics AS
SELECT
  DATE(created_timestamp) as report_date,
  COUNT(*) as total_reports,
  COUNT(DISTINCT domain) as unique_domains,
  AVG(CASE
    WHEN company_data->>'processing_time_ms' IS NOT NULL
    THEN (company_data->>'processing_time_ms')::INTEGER
    ELSE NULL
  END) as avg_processing_time_ms,
  SUM(CASE
    WHEN company_data->'metadata'->>'estimated_cost_usd' IS NOT NULL
    THEN (company_data->'metadata'->>'estimated_cost_usd')::DECIMAL
    ELSE 0.70
  END) as estimated_daily_cost,
  COUNT(CASE
    WHEN company_data->'metadata'->>'cache_hit' = 'true'
    THEN 1
    ELSE NULL
  END) as cache_hits
FROM reports
WHERE created_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_timestamp)
ORDER BY report_date DESC;

-- Cache efficiency view
CREATE OR REPLACE VIEW cache_efficiency AS
SELECT
  domain,
  COUNT(*) as total_requests,
  COUNT(CASE
    WHEN created_timestamp = (
      SELECT MIN(created_timestamp)
      FROM reports r2
      WHERE r2.domain = reports.domain
    ) THEN 1
    ELSE NULL
  END) as cache_misses,
  COUNT(*) - COUNT(CASE
    WHEN created_timestamp = (
      SELECT MIN(created_timestamp)
      FROM reports r2
      WHERE r2.domain = reports.domain
    ) THEN 1
    ELSE NULL
  END) as cache_hits,
  ROUND(
    (COUNT(*) - COUNT(CASE
      WHEN created_timestamp = (
        SELECT MIN(created_timestamp)
        FROM reports r2
        WHERE r2.domain = reports.domain
      ) THEN 1
      ELSE NULL
    END)) * 100.0 / COUNT(*), 2
  ) as cache_hit_rate_percent,
  MAX(created_timestamp) as last_request
FROM reports
WHERE created_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY domain
ORDER BY total_requests DESC;

-- Monthly cost summary view
CREATE OR REPLACE VIEW monthly_cost_summary AS
SELECT
  DATE_TRUNC('month', created_timestamp) as month,
  COUNT(*) as total_executions,
  COUNT(CASE
    WHEN company_data->'metadata'->>'cache_hit' = 'true'
    THEN 1
    ELSE NULL
  END) as cached_responses,
  COUNT(*) - COUNT(CASE
    WHEN company_data->'metadata'->>'cache_hit' = 'true'
    THEN 1
    ELSE NULL
  END) as api_calls_made,
  (COUNT(*) - COUNT(CASE
    WHEN company_data->'metadata'->>'cache_hit' = 'true'
    THEN 1
    ELSE NULL
  END)) * 0.70 as estimated_api_cost,
  20.00 as n8n_starter_cost,
  (COUNT(*) - COUNT(CASE
    WHEN company_data->'metadata'->>'cache_hit' = 'true'
    THEN 1
    ELSE NULL
  END)) * 0.70 + 20.00 as total_estimated_cost
FROM reports
WHERE created_timestamp >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months')
GROUP BY DATE_TRUNC('month', created_timestamp)
ORDER BY month DESC;

-- Function to check cache before processing (fixed for immutability)
CREATE OR REPLACE FUNCTION check_domain_cache(input_domain TEXT, days_back INTEGER DEFAULT 7)
RETURNS TABLE (
  found BOOLEAN,
  report_data JSONB,
  age_hours INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    CASE WHEN r.report_id IS NOT NULL THEN TRUE ELSE FALSE END as found,
    CASE
      WHEN r.report_id IS NOT NULL THEN
        jsonb_build_object(
          'report_id', r.report_id,
          'domain', r.domain,
          'company_data', r.company_data,
          'industry_data', r.industry_data,
          'competitive_analysis', r.competitive_analysis,
          'strategic_recommendations', r.strategic_recommendations,
          'created_timestamp', r.created_timestamp,
          'cache_hit', true
        )
      ELSE NULL
    END as report_data,
    CASE
      WHEN r.report_id IS NOT NULL THEN
        EXTRACT(EPOCH FROM (NOW() - r.created_timestamp)) / 3600
      ELSE NULL
    END::INTEGER as age_hours
  FROM (
    SELECT * FROM reports
    WHERE domain = input_domain
      AND created_timestamp > NOW() - (days_back || ' days')::INTERVAL
    ORDER BY created_timestamp DESC
    LIMIT 1
  ) r;
END;
$$ LANGUAGE plpgsql STABLE;

-- Cleanup function for old reports (optional - run monthly)
CREATE OR REPLACE FUNCTION cleanup_old_reports(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM reports
  WHERE created_timestamp < NOW() - (days_to_keep || ' days')::INTERVAL;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;
GRANT USAGE, SELECT ON SEQUENCE reports_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE reports_id_seq TO service_role;

-- Grant view permissions
GRANT SELECT ON usage_analytics TO authenticated;
GRANT SELECT ON cache_efficiency TO authenticated;
GRANT SELECT ON monthly_cost_summary TO authenticated;

-- Grant function permissions
GRANT EXECUTE ON FUNCTION check_domain_cache(TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION check_domain_cache(TEXT, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION cleanup_old_reports(INTEGER) TO service_role;