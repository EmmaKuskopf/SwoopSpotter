# User Authentication Setup Guide

## 🎉 What's Been Added

Your SwoopSpotter app now has full user authentication! Users can:
- ✅ Sign up with email/password
- ✅ Sign in to their account
- ✅ Have their contributions tracked
- ✅ See who created each spot and report
- ✅ View their stats (coming soon!)
- ✅ Manage their profile (coming soon!)

---

## 🚀 Setup Steps

### Step 1: Run the Auth Schema SQL

1. Go to your Supabase dashboard: https://ghoipwkezxiyjkgikfyw.supabase.co
2. Click **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy the entire contents of `supabase-auth-schema.sql`
5. Paste into the query editor
6. Click **Run** (or press Cmd/Ctrl + Enter)

**Expected result:** You should see "Success. No rows returned"

This creates:
- ✅ `profiles` table (user profiles)
- ✅ User tracking columns in `spots` and `reports` tables
- ✅ Updated Row Level Security (RLS) policies
- ✅ Automatic profile creation on signup
- ✅ User statistics tracking
- ✅ Leaderboard view

---

### Step 2: Enable Email Authentication

1. In Supabase dashboard, go to **Authentication** (left sidebar)
2. Click on **Configuration** (or **Settings** if you see that)
3. Look for **Auth Providers** or **Providers** section
4. Find **Email** provider - it should already be enabled by default
5. Optional settings to configure:
   - **Confirm email**: Toggle ON (recommended - requires users to verify email)
   - **Secure email change**: Toggle ON (recommended)
   - **Secure password change**: Toggle ON (recommended)

**Note:** Email authentication is typically enabled by default in Supabase. If you can sign up users, you're all set!

---

### Step 3: Configure Email Templates (Optional but Recommended)

1. In Supabase dashboard, stay in **Authentication**
2. Look for **Email Templates** in the left menu or tabs
3. Customize the following templates:
   - **Confirmation**: Sent when users sign up
   - **Magic Link**: For passwordless login (future feature)
   - **Change Email Address**: When users change their email
   - **Reset Password**: When users forget their password

**Example Confirmation Email:**
```html
<h2>Welcome to Swoop Spotter!</h2>
<p>Click the link below to confirm your email address:</p>
<p><a href="{{ .ConfirmationURL }}">Confirm Email</a></p>
<p>Thanks for helping keep our community safe from swooping birds!</p>
```

**Note:** If you can't find Email Templates, they may be under **Authentication** → **Email Templates** in a submenu, or you can skip this step - the default templates work fine!

---

### Step 4: Test the Authentication

1. Deploy your updated `index.html` to GitHub Pages
2. Open the app in your browser
3. Click **Sign In** in the top right
4. Click the **Sign Up** tab
5. Fill in:
   - Display Name: "Test User"
   - Email: your-email@example.com
   - Password: (minimum 6 characters)
6. Click **Sign Up**
7. Check your email for the confirmation link
8. Click the confirmation link
9. You should be signed in!

---

## 🎨 New UI Features

### Header
- **Sign In button** (when signed out)
- **User button** with dropdown menu (when signed in)

### User Menu
When signed in, click your name in the top right to see:
- **Your display name and email**
- **📊 My Stats** (coming soon!)
- **⚙️ Profile** (coming soon!)
- **🚪 Sign Out**

### Auth Modal
Beautiful modal with tabs for:
- **Sign In**: For returning users
- **Sign Up**: For new users

---

## 🔒 Security Features

### Row Level Security (RLS)
The new schema includes strong security policies:

**Spots:**
- ✅ Anyone can view all spots
- ✅ Only authenticated users can create spots
- ✅ Users can only edit/delete their own spots

**Reports:**
- ✅ Anyone can view all reports
- ✅ Only authenticated users can create reports
- ✅ Users can only edit/delete their own reports

**Profiles:**
- ✅ Anyone can view public profile info
- ✅ Users can only edit their own profile

---

## 📊 User Statistics

The system automatically tracks:
- **Total spots created** by each user
- **Total reports created** by each user
- **Reputation score**: Calculated as:
  - Spots created × 10 points
  - Reports created × 5 points
- **Verification status**: Can be set by admins
- **Moderator status**: For community moderation

These stats update automatically when users create spots or reports!

---

## 🎯 How It Works

### User Flow

#### New User:
1. Click "Sign In"
2. Switch to "Sign Up" tab
3. Enter name, email, password
4. Click "Sign Up"
5. Receive confirmation email
6. Click confirmation link
7. Automatically signed in!
8. Profile created automatically

#### Returning User:
1. Click "Sign In"
2. Enter email and password
3. Click "Sign In"
4. Welcome back message appears
5. Can now create spots and reports

### Data Attribution

When a user creates a spot or report:
```javascript
{
  user_id: "uuid-of-user",
  created_by_name: "Display Name",
  // ... other data
}
```

This allows:
- Showing who created what
- User statistics tracking
- Future features like user profiles
- Moderation capabilities

---

## 🚀 What You Can Do Now

### As a User:
1. **Create an account** to track your contributions
2. **Sign in** across devices to sync your data
3. **Add spots and reports** with your name attached
4. **View your stats** (coming soon!)

### As an Admin:
1. **View all users** in Supabase → Authentication → Users
2. **See user profiles** in Table Editor → profiles
3. **Track contributions** (spots and reports tables show user_id)
4. **Set moderators**: Update `is_moderator` in profiles table
5. **Verify trusted users**: Update `is_verified` in profiles table

---

## 🧪 Testing Checklist

- [ ] Run `supabase-auth-schema.sql` in SQL Editor
- [ ] Verify `profiles` table created
- [ ] Verify `spots` and `reports` tables have new user columns
- [ ] Enable Email auth in Authentication settings
- [ ] Deploy updated code to GitHub Pages
- [ ] Sign up with a test account
- [ ] Check email for confirmation link
- [ ] Click confirmation link
- [ ] Verify you're signed in (name appears in header)
- [ ] Create a new spot
- [ ] Check Supabase → spots table → see user_id populated
- [ ] Add a report to the spot
- [ ] Check Supabase → reports table → see user_id populated
- [ ] Check profiles table → see stats updated
- [ ] Sign out
- [ ] Sign back in
- [ ] Verify data persists

---

## 🐛 Troubleshooting

### "User already registered" error
- User email already exists
- Try signing in instead of signing up
- Or use a different email

### No confirmation email received
- Check spam/junk folder
- Verify email settings in Supabase → Authentication → Email Templates
- Make sure "Enable Email Confirmations" is ON

### Email confirmation link expired or failed
**Problem:** Clicked the confirmation link but got an error like "access_denied" or "otp_expired"

**Causes:**
- Confirmation links expire after 24 hours by default
- Redirect URL may not be configured correctly

**Solutions:**

**Option 1: Manually confirm the user (Quickest)**
1. Go to Supabase Dashboard → **Authentication** → **Users**
2. Find the user account
3. Look for the user details/edit view
4. Find **"Email Confirmed At"** field or similar
5. Set the current timestamp or toggle "Email Confirmed" to ON
6. User can now sign in immediately!

**Option 2: Disable email confirmation for development (Recommended)**
1. Go to **Authentication** → **Providers** → **Email**
2. Find **"Confirm email"** toggle
3. Turn it **OFF**
4. Save changes
5. New signups will work instantly without needing email confirmation
6. Re-enable it later when ready for production

**Option 3: Configure redirect URLs properly**
1. Go to **Authentication** → **URL Configuration** (or **Settings**)
2. Set **Site URL**: `https://emmakuskopf.github.io/SwoopSpotter/`
3. Add **Redirect URLs**:
   - `https://emmakuskopf.github.io/SwoopSpotter/**`
   - `http://localhost:5500/**` (for local testing)
   - `http://127.0.0.1:5500/**` (for local testing)
4. Save changes
5. New confirmation emails will have working links

**Option 4: Extend confirmation link expiry**
1. Go to **Authentication** → **Settings** (or **Email Auth**)
2. Look for link expiration settings
3. Increase the expiration time if available
4. Save changes

**Note:** For development, Option 2 (disabling confirmation) is easiest and lets you test faster!

### "Invalid login credentials"
- Wrong email or password
- Email may not be confirmed yet (check inbox)
- If email confirmation is enabled, manually confirm user in Supabase (see above)
- Try password reset (future feature)

### User button not appearing after sign in
- Check browser console for errors
- Make sure SQL schema ran successfully
- Verify profiles table exists

### Spots not saving after adding auth
- You must be signed in to create spots now
- Check that RLS policies were created correctly
- Verify user_id is being set in saveSpotToSupabase()

### Profile display name shows email instead of actual name
**Problem:** User menu shows email address instead of display name

**Causes:**
- Profile trigger didn't capture display_name from user_metadata
- Profile created before display_name was set

**Solutions:**
1. Go to Supabase → **Table Editor** → **profiles**
2. Find the user's profile row
3. Edit the **display_name** column
4. Set it to the desired name
5. User needs to sign out and back in to see the change

**Prevention:** The JavaScript now has a fallback that automatically updates the profile if display_name is missing!

---

## 🔄 Migration Notes

### Existing Data
If you already have spots and reports in your database:

**Option 1: Keep anonymous**
- Existing data will show as "Anonymous"
- user_id will be NULL
- This is fine! Future contributions will be tracked

**Option 2: Assign to an admin account**
- Sign up as admin
- In Supabase SQL Editor, run:
```sql
UPDATE spots 
SET user_id = 'your-user-id-here',
    created_by_name = 'Admin'
WHERE user_id IS NULL;

UPDATE reports 
SET user_id = 'your-user-id-here',
    created_by_name = 'Admin'
WHERE user_id IS NULL;
```

---

## 📈 Future Enhancements

Now that you have user authentication, you can add:

### Phase 1 (Easy):
- ✅ User stats dashboard
- ✅ User profile page
- ✅ Edit own spots/reports
- ✅ Delete own spots/reports

### Phase 2 (Medium):
- 🔄 Password reset
- 🔄 Email change
- 🔄 Profile picture upload
- 🔄 Public user profiles

### Phase 3 (Advanced):
- 🔄 Social login (Google, Facebook)
- 🔄 User reputation system
- 🔄 Badges and achievements
- 🔄 Leaderboard page
- 🔄 Report verification by trusted users
- 🔄 Moderation tools
- 🔄 User blocking/reporting

---

## 📝 Code Changes Summary

### New Files:
- `supabase-auth-schema.sql` - Database schema for authentication
- `USER_AUTH_SETUP.md` - This setup guide

### Modified Files:
- `index.html`:
  - Added auth modal UI
  - Added user button and menu
  - Added authentication functions
  - Updated saveSpotToSupabase() to include user_id
  - Updated report creation to track user_id
  - Added auth state management
  - Added event listeners for auth UI

### Database Changes:
- New table: `profiles`
- Updated table: `spots` (added user_id, created_by_name)
- Updated table: `reports` (added user_id, created_by_name)
- New RLS policies (require authentication)
- New triggers (auto-create profile, update stats)
- New views (leaderboard)

---

## 🎉 Success Indicators

You'll know authentication is working when:

1. **Browser shows:**
   - "Sign In" button in header when signed out
   - User name/button in header when signed in
   - "Welcome back, [name]!" toast after sign in
   - "Account created! Check your email..." after sign up

2. **Supabase shows:**
   - New user in Authentication → Users
   - New profile in Table Editor → profiles
   - user_id populated in spots table
   - user_id populated in reports table
   - Stats updating in profiles table

3. **Multi-device test:**
   - Sign in on phone → Create spot
   - Sign in on desktop → See spot with your name

---

## 🆘 Need Help?

If you encounter issues:

1. Check browser console for errors (F12)
2. Check Supabase logs (Dashboard → Logs)
3. Verify SQL schema ran without errors
4. Ensure email auth is enabled
5. Test with a real email address you can access
6. Check that user_id is being set in database

Common issues and solutions documented in Troubleshooting section above.

Happy building! 🎉
