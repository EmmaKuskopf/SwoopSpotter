# Fix Profile Update Issue

## Problem
The profile update is failing because the `bio` column doesn't exist in the database.

## Solution
Run the following SQL in your Supabase SQL Editor:

### Step 1: Go to Supabase
1. Open your Supabase dashboard
2. Go to **SQL Editor**
3. Click **New Query**

### Step 2: Run This SQL
```sql
-- Add bio column to profiles table
ALTER TABLE public.profiles 
  ADD COLUMN bio TEXT;

-- Add a check constraint to limit bio length to 200 characters
ALTER TABLE public.profiles 
  ADD CONSTRAINT bio_length_check CHECK (length(bio) <= 200);
```

### Step 3: Verify
After running the SQL, go to **Table Editor** → **profiles** and you should see the new `bio` column.

### Step 4: Test
1. Refresh your app
2. Open the Chrome DevTools console (F12)
3. Click your user button → Profile
4. Try to update your bio and avatar
5. Check the console for any errors

The update should now work! ✅

---

## Alternative: Copy-Paste File
You can also copy the contents of `supabase-add-bio-column.sql` and paste it into the SQL Editor.
