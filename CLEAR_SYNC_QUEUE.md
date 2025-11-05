# Clear Sync Queue - User Guide

## Problem
Spots created **before** the sync queue fixes may have issues syncing because they're missing the new `user_id` and `created_by_name` fields in the queue items.

## Solution

### Option 1: Clear Unsynced Button (Recommended)
**Easy, no technical knowledge needed**

1. **Open the app** and sign in
2. **Open the hamburger menu** (three lines icon in top left)
3. If you have unsynced spots, you'll see:
   - **"Sync Now"** button with a badge showing the count
   - **"Clear Unsynced"** button (new!)
4. **Click "Clear Unsynced"**
5. Confirm when prompted
6. All unsynced spots will be removed from the queue

**What happens:**
- ✅ Spots stay visible on your map (they're still in localStorage)
- ✅ They won't try to sync anymore (no more errors)
- ❌ They won't be uploaded to the database
- ❌ Other users won't see them

**When to use this:**
- You have old test spots you don't care about
- You keep seeing sync errors
- You want a fresh start with syncing

### Option 2: Browser Console Command (Advanced)
**For developers or if the button doesn't work**

1. **Open browser console**
   - Chrome/Edge: `Cmd+Option+J` (Mac) or `Ctrl+Shift+J` (Windows)
   - Safari: `Cmd+Option+C` (Mac) - Enable Developer menu first
   - Firefox: `Cmd+Option+K` (Mac) or `Ctrl+Shift+K` (Windows)

2. **Paste this command:**
   ```javascript
   localStorage.removeItem('swoop_sync_queue_v1');
   location.reload();
   ```

3. **Press Enter**

4. The page will reload with an empty sync queue

### Option 3: Clear All Local Data (Nuclear Option)
**Only if you want to start completely fresh**

1. **Open browser console** (see Option 2)
2. **Paste this command:**
   ```javascript
   localStorage.clear();
   location.reload();
   ```
3. **Press Enter**

**Warning:** This clears:
- ❌ All locally created spots (not synced to database)
- ❌ All settings (dark mode, etc.)
- ❌ Test date settings
- ❌ Sync queue

Spots already in the database will reload when you sign in.

## How to Avoid This in the Future

### After Clearing, Create New Spots Properly:
1. **Sign in first** before creating spots
2. Create spots while **online** (not in airplane mode)
3. Spots will sync immediately and get proper `user_id` tracking

### If You Must Create Spots While Offline:
1. Create the spot
2. You'll see "X unsynced" indicator
3. **Sign in** (if not already)
4. **Go online**
5. Click **"Sync Now"** in the hamburger menu
6. Spots will sync with your user ID

## Technical Details

### What Changed in the Fix
**Before:**
```javascript
syncQueue.push({
  spotId: spot.id,
  action: 'create',
  timestamp: Date.now(),
  retryCount: 0
  // Missing user_id and created_by_name!
});
```

**After:**
```javascript
syncQueue.push({
  spotId: spot.id,
  action: 'create',
  timestamp: Date.now(),
  retryCount: 0,
  user_id: currentUser?.id,           // NEW: Track ownership
  created_by_name: userProfile?.display_name  // NEW: For logging
});
```

### Why Old Spots Won't Sync
1. Old queue items don't have `user_id` field
2. New code tries to sync spots to database with `currentUser.id`
3. If queue item has no `user_id`, it's backward compatible
4. BUT if you weren't signed in when creating the spot, `currentUser` was null
5. So the spot has no user association and can't be saved to database

### The Fix Handles This
The new `processSyncQueue()` function:
- ✅ Checks if `user_id` exists in queue item
- ✅ If missing, assumes it belongs to current user (backward compatible)
- ✅ If different user, skips it (prevents permission errors)
- ✅ If user not signed in, waits until they sign in

### But Old Spots Created While Signed Out
If you created spots before the fix while **not signed in**:
- ❌ No `currentUser` at creation time
- ❌ Spot saved to localStorage only
- ❌ Queue item created with action 'create'
- ❌ When you sign in later, it tries to sync
- ❌ But `spot.user_id` is undefined or null
- ❌ Database requires `user_id` for new spots
- ❌ Sync fails repeatedly

**Solution:** Clear those old queue items and create new spots while signed in!

## Checking Sync Queue Status

### In Browser Console:
```javascript
// View sync queue
const queue = JSON.parse(localStorage.getItem('swoop_sync_queue_v1'));
console.log('Sync Queue:', queue);

// Check each item
queue.forEach(item => {
  console.log(`Spot ${item.spotId}:`, {
    hasUserId: !!item.user_id,
    createdBy: item.created_by_name,
    retries: item.retryCount,
    lastError: item.lastError
  });
});
```

### Look for:
- Items with `user_id: undefined` or missing `user_id` field
- Items with high `retryCount` (3+)
- Items with `lastError` containing "user_id" or "null"

These are candidates for clearing!

## FAQ

**Q: Will clearing the queue delete my spots from the map?**
A: No! Spots stay in localStorage and remain visible. They just won't try to sync anymore.

**Q: What if I want to keep some spots but not others?**
A: Currently, it's all-or-nothing. You'd need to use the browser console to selectively remove items from the queue.

**Q: Can I recreate the spots after clearing?**
A: Yes! While signed in and online, create new spots. They'll sync properly with your user ID.

**Q: What if I have spots that DID sync but are still in the queue?**
A: That shouldn't happen, but if it does, clearing the queue is safe. Already-synced spots are in the database and will reload.

## Support

If clearing doesn't work or you need help:
1. Check browser console for errors
2. Note the sync queue contents (see "Checking Sync Queue Status")
3. Try the nuclear option (clear all localStorage)
4. Contact support with console logs
