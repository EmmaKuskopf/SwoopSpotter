-- Add safe passage tracking columns to spots table
-- Run this in your Supabase SQL Editor

ALTER TABLE spots 
ADD COLUMN IF NOT EXISTS safe_passage_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_safe_passage TIMESTAMPTZ;

-- Add helpful comment
COMMENT ON COLUMN spots.safe_passage_count IS 'Number of times users have reported passing through this spot safely';
COMMENT ON COLUMN spots.last_safe_passage IS 'Timestamp of the most recent safe passage report';

-- Optional: Update existing spots to have 0 safe passages
UPDATE spots 
SET safe_passage_count = 0 
WHERE safe_passage_count IS NULL;
