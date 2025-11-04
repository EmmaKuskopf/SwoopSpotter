-- Add bio column to profiles table
-- Run this in Supabase SQL Editor

ALTER TABLE public.profiles 
  ADD COLUMN bio TEXT;

-- Optional: Add a check constraint to limit bio length
ALTER TABLE public.profiles 
  ADD CONSTRAINT bio_length_check CHECK (length(bio) <= 200);
