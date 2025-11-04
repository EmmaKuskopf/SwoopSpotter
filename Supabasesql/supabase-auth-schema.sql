-- Swoop Spotter User Authentication Schema
-- Run this AFTER the main schema (supabase-schema.sql)

-- ============================================
-- USER PROFILES TABLE
-- ============================================

-- Create user profiles table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  email TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT CHECK (length(bio) <= 200),
  total_spots_created INTEGER DEFAULT 0,
  total_reports_created INTEGER DEFAULT 0,
  reputation_score INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  is_moderator BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles are viewable by everyone (public info)
CREATE POLICY "Profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

-- Users can insert their own profile (for manual profile creation)
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ============================================
-- UPDATE EXISTING TABLES FOR USER TRACKING
-- ============================================

-- Add user tracking columns to spots table
ALTER TABLE spots 
  ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN created_by_name TEXT;

-- Add user tracking columns to reports table
ALTER TABLE reports 
  ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN created_by_name TEXT;

-- Create indexes for user queries
CREATE INDEX idx_spots_user_id ON spots(user_id);
CREATE INDEX idx_reports_user_id ON reports(user_id);

-- ============================================
-- UPDATE ROW LEVEL SECURITY POLICIES
-- ============================================

-- Drop old policies
DROP POLICY IF EXISTS "Anyone can create spots" ON spots;
DROP POLICY IF EXISTS "Anyone can create reports" ON reports;

-- New policy: Only authenticated users can create spots
CREATE POLICY "Authenticated users can create spots"
  ON spots FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- New policy: Only authenticated users can create reports
CREATE POLICY "Authenticated users can create reports"
  ON reports FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- New policy: Users can update their own spots
CREATE POLICY "Users can update own spots"
  ON spots FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- New policy: Users can delete their own spots
CREATE POLICY "Users can delete own spots"
  ON spots FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- New policy: Users can update their own reports
CREATE POLICY "Users can update own reports"
  ON reports FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- New policy: Users can delete their own reports
CREATE POLICY "Users can delete own reports"
  ON reports FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================
-- AUTOMATIC PROFILE CREATION
-- ============================================

-- Function to automatically create profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- REPUTATION & STATISTICS FUNCTIONS
-- ============================================

-- Function to update user statistics
CREATE OR REPLACE FUNCTION update_user_stats(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.profiles
  SET 
    total_spots_created = (SELECT COUNT(*) FROM spots WHERE user_id = user_uuid),
    total_reports_created = (SELECT COUNT(*) FROM reports WHERE user_id = user_uuid),
    reputation_score = (
      (SELECT COUNT(*) FROM spots WHERE user_id = user_uuid) * 10 +
      (SELECT COUNT(*) FROM reports WHERE user_id = user_uuid) * 5
    )
  WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update stats when spot is created
CREATE OR REPLACE FUNCTION increment_spot_count()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    PERFORM update_user_stats(NEW.user_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_spot_created
  AFTER INSERT ON spots
  FOR EACH ROW
  EXECUTE FUNCTION increment_spot_count();

-- Trigger to update stats when report is created
CREATE OR REPLACE FUNCTION increment_report_count()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    PERFORM update_user_stats(NEW.user_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_report_created
  AFTER INSERT ON reports
  FOR EACH ROW
  EXECUTE FUNCTION increment_report_count();

-- ============================================
-- LEADERBOARD VIEW
-- ============================================

CREATE VIEW public.user_leaderboard AS
SELECT 
  p.id,
  p.display_name,
  p.avatar_url,
  p.total_spots_created,
  p.total_reports_created,
  p.reputation_score,
  p.is_verified,
  p.created_at
FROM public.profiles p
ORDER BY p.reputation_score DESC, p.total_spots_created DESC
LIMIT 100;

-- Grant access to views
GRANT SELECT ON public.user_leaderboard TO anon, authenticated;

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to get user's own spots
CREATE OR REPLACE FUNCTION get_my_spots()
RETURNS TABLE(
  id TEXT,
  name TEXT,
  species TEXT,
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  risk TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id, s.name, s.species, s.lat, s.lng, s.risk, s.created_at
  FROM spots s
  WHERE s.user_id = auth.uid()
  ORDER BY s.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's own reports
CREATE OR REPLACE FUNCTION get_my_reports()
RETURNS TABLE(
  id TEXT,
  spot_id TEXT,
  alert_level TEXT,
  report_timestamp TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.id, r.spot_id, r.alert_level, r.timestamp
  FROM reports r
  WHERE r.user_id = auth.uid()
  ORDER BY r.timestamp DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- UPDATE TRIGGERS
-- ============================================

-- Trigger to auto-update updated_at on profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;
