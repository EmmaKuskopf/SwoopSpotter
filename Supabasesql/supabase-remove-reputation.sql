-- Remove Reputation System from Swoop Spotter
-- This is OPTIONAL - only run if you want to completely remove reputation tracking
-- 
-- NOTE: This will preserve the basic stats (total_spots_created, total_reports_created)
--       and only remove the gamification elements

-- ============================================
-- OPTION 1: Keep Database Columns (Recommended)
-- ============================================
-- Don't run anything! Just remove from UI (already done)
-- Keeps data for potential future use
-- No data loss

-- ============================================
-- OPTION 2: Remove Reputation Calculation Only
-- ============================================
-- Keeps the columns but stops calculating reputation
-- You can run this if you want to stop the auto-calculation:

-- Drop the triggers that calculate reputation
DROP TRIGGER IF EXISTS on_spot_created ON spots;
DROP TRIGGER IF EXISTS on_report_created ON reports;

-- Drop the functions
DROP FUNCTION IF EXISTS increment_spot_count();
DROP FUNCTION IF EXISTS increment_report_count();
DROP FUNCTION IF EXISTS update_user_stats(UUID);

-- ============================================
-- OPTION 3: Remove Columns Completely (Not Recommended)
-- ============================================
-- WARNING: This will delete data permanently!
-- Only run if you're SURE you never want reputation system

-- Remove reputation-related columns
ALTER TABLE public.profiles 
  DROP COLUMN IF EXISTS reputation_score,
  DROP COLUMN IF EXISTS is_verified,
  DROP COLUMN IF EXISTS is_moderator;

-- NOTE: We're keeping total_spots_created and total_reports_created
-- because those are useful stats!

-- ============================================
-- RECOMMENDATION
-- ============================================
-- Don't run any of this SQL!
-- The UI changes are enough - reputation is hidden from users
-- Database still tracks the numbers in case you want them later
-- No harm in keeping the data
