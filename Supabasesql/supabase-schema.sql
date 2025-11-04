-- Swoop Spotter Database Schema
-- Run this in your Supabase SQL Editor

-- Enable PostGIS extension for location-based queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table: spots
CREATE TABLE spots (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  lat DECIMAL(10, 8) NOT NULL,
  lng DECIMAL(11, 8) NOT NULL,
  risk TEXT NOT NULL CHECK (risk IN ('Low risk', 'Take caution', 'Danger - Avoid')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: reports
CREATE TABLE reports (
  id TEXT PRIMARY KEY,
  spot_id TEXT NOT NULL REFERENCES spots(id) ON DELETE CASCADE,
  alert_level TEXT NOT NULL CHECK (alert_level IN ('Low risk', 'Take caution', 'Danger - Avoid')),
  bird_behaviour JSONB DEFAULT '[]'::jsonb,
  human_behaviour JSONB DEFAULT '[]'::jsonb,
  precautions JSONB DEFAULT '[]'::jsonb,
  extra_details TEXT,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_spots_location ON spots(lat, lng);
CREATE INDEX idx_reports_spot_id ON reports(spot_id);
CREATE INDEX idx_reports_timestamp ON reports(timestamp DESC);
CREATE INDEX idx_spots_created_at ON spots(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE spots ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Public read access (anyone can view spots and reports)
CREATE POLICY "Public spots are viewable by everyone" 
  ON spots FOR SELECT 
  USING (true);

CREATE POLICY "Public reports are viewable by everyone" 
  ON reports FOR SELECT 
  USING (true);

-- Public write access (anyone can create spots and reports for now)
-- We'll restrict this to authenticated users later
CREATE POLICY "Anyone can create spots" 
  ON spots FOR INSERT 
  WITH CHECK (true);

CREATE POLICY "Anyone can create reports" 
  ON reports FOR INSERT 
  WITH CHECK (true);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on spots
CREATE TRIGGER update_spots_updated_at 
  BEFORE UPDATE ON spots
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Create a view for spots with their reports (makes querying easier)
CREATE VIEW spots_with_reports AS
SELECT 
  s.id,
  s.name,
  s.species,
  s.lat,
  s.lng,
  s.risk,
  s.created_at,
  s.updated_at,
  COALESCE(
    json_agg(
      json_build_object(
        'id', r.id,
        'alertLevel', r.alert_level,
        'birdBehaviour', r.bird_behaviour,
        'humanBehaviour', r.human_behaviour,
        'precautions', r.precautions,
        'extraDetails', r.extra_details,
        'timestamp', r.timestamp
      ) ORDER BY r.timestamp DESC
    ) FILTER (WHERE r.id IS NOT NULL),
    '[]'::json
  ) AS reports
FROM spots s
LEFT JOIN reports r ON s.id = r.spot_id
GROUP BY s.id, s.name, s.species, s.lat, s.lng, s.risk, s.created_at, s.updated_at;

-- Grant access to the view
GRANT SELECT ON spots_with_reports TO anon, authenticated;
