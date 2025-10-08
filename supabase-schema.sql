-- Supabase schema for Business Intelligence Reports
-- Run this in your Supabase SQL editor

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

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reports_domain ON reports(domain);
CREATE INDEX IF NOT EXISTS idx_reports_report_id ON reports(report_id);
CREATE INDEX IF NOT EXISTS idx_reports_created_timestamp ON reports(created_timestamp);

-- Enable Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users to insert and read
CREATE POLICY "Allow authenticated users to insert reports" ON reports
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to read reports" ON reports
  FOR SELECT TO authenticated
  USING (true);

-- Create policy for service role to have full access
CREATE POLICY "Allow service role full access" ON reports
  FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

-- Optional: Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;
GRANT USAGE, SELECT ON SEQUENCE reports_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE reports_id_seq TO service_role;