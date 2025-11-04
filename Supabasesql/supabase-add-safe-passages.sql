-- ============================================
-- Add Safe Passages tracking to user profiles
-- ============================================
-- 
-- INSTRUCTIONS:
-- 1. Go to your Supabase project dashboard
-- 2. Navigate to SQL Editor (left sidebar)
-- 3. Click "New Query"
-- 4. Copy and paste this entire file
-- 5. Click "Run" or press Ctrl/Cmd + Enter
-- 
-- This will:
-- - Add total_safe_passages column to profiles table
-- - Create increment functions for safe passages, spots, and reports
-- - Grant proper permissions to authenticated users
-- - Backfill existing users with 0 safe passages
-- 
-- After running this, the app will be able to track:
-- - Safe passages (when users report "No bird here")
-- - Spots created
-- - Reports added
-- ============================================

-- Add total_safe_passages column to profiles table
ALTER TABLE public.profiles 
  ADD COLUMN IF NOT EXISTS total_safe_passages INTEGER DEFAULT 0;

-- Function to increment safe passages counter
CREATE OR REPLACE FUNCTION public.increment_safe_passages(user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.profiles
  SET total_safe_passages = COALESCE(total_safe_passages, 0) + 1
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment spots created counter
CREATE OR REPLACE FUNCTION public.increment_spots_created(user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.profiles
  SET total_spots_created = COALESCE(total_spots_created, 0) + 1
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment reports created counter
CREATE OR REPLACE FUNCTION public.increment_reports_created(user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.profiles
  SET total_reports_created = COALESCE(total_reports_created, 0) + 1
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.increment_safe_passages(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.increment_spots_created(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.increment_reports_created(UUID) TO authenticated;

-- Optional: Backfill existing users with 0 safe passages if column was added later
UPDATE public.profiles 
SET total_safe_passages = 0 
WHERE total_safe_passages IS NULL;
