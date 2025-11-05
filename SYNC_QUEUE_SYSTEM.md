# Sync Queue System Documentation

## Overview

The Sync Queue System ensures that all user-created spots are eventually synced to the Supabase database, even when:
- The user is offline
- Database connection fails
- User creates spots before signing in
- Network is unstable

## How It Works

### 1. Queue Management

**Storage**: Queue is persisted in localStorage under `swoop_sync_queue_v1`

**Queue Items Structure**:
```javascript
{
  spotId: string,        // Unique spot identifier
  action: string,        // 'create' or 'update'
  timestamp: number,     // When item was added to queue
  retryCount: number,    // Number of sync attempts
  lastError: string,     // Last error message (optional)
  lastAttempt: number    // Timestamp of last attempt (optional)
}
```

### 2. When Spots Are Added to Queue

A spot is added to the sync queue when:

1. **User not authenticated**: Spot is created but user isn't signed in
2. **Network failure**: Supabase save fails due to connection issues
3. **Database error**: Any error during database save operation

### 3. When Queue is Processed

The sync queue is automatically processed when:

1. **User signs in**: All pending spots are synced immediately
2. **Page loads**: If user is signed in, queue is processed after 2-3 seconds
3. **Connection restored**: `online` event triggers immediate sync
4. **Manual trigger**: User clicks "Sync Now" in menu
5. **Automatic retry**: Failed items are retried with exponential backoff

### 4. Retry Strategy

**Exponential Backoff**:
- Retry 0: 30 seconds
- Retry 1: 1 minute
- Retry 2: 2 minutes
- Retry 3: 5 minutes
- Retry 4+: 10 minutes

**Maximum Retries**: Unlimited (will keep trying until successful)

**User Notification**: After 5 failed attempts, shows "Sync issue: [spot name] - will keep trying"

### 5. User Indicators

**Floating Indicator** (top right):
- Shows when queue has items: "X unsynced"
- Orange background, white text
- Positioned at `top: 140px, right: 20px`

**Menu Badge**:
- "Sync Now" button appears in hamburger menu when queue has items
- Badge shows number of unsynced items
- Only visible to signed-in users

### 6. Core Functions

#### `loadSyncQueue()`
Loads queue from localStorage on app startup

#### `saveSyncQueue()`
Persists queue to localStorage after modifications

#### `addToSyncQueue(spotId, action)`
Adds or updates item in queue
- Prevents duplicates (updates existing entry)
- Saves to localStorage
- Updates UI indicators

#### `removeFromSyncQueue(spotId)`
Removes item from queue after successful sync
- Updates localStorage
- Updates UI indicators

#### `processSyncQueue()`
Main sync processor
- Iterates through all queue items
- Attempts to sync each spot using `saveSpotToSupabaseInternal()`
- Removes successful syncs from queue
- Increments retry count for failures
- Adds 500ms delay between syncs to avoid overwhelming server
- Schedules next retry if items remain

#### `saveSpotToSupabaseInternal(spot)`
Internal save function used by both:
- Direct saves (when user creates spot while online)
- Queue processor (retry mechanism)

Handles:
- Spot data preparation
- Database upsert
- Report saves
- Real-time update deduplication

#### `updateSyncIndicator()`
Updates all UI elements:
- Floating indicator visibility and count
- Menu sync button visibility
- Menu badge count

#### `scheduleNextSync()`
Sets up automatic retry timer with exponential backoff

### 7. Integration Points

#### Authentication
```javascript
// When user signs in
handleAuthStateChange(user) {
  loadSyncQueue();
  updateSyncIndicator();
  if (syncQueue.length > 0) {
    processSyncQueue();
  }
}
```

#### Data Loading
```javascript
// After loading from Supabase
loadAllFromSupabase() {
  // ... load data ...
  if (currentUser && syncQueue.length > 0) {
    processSyncQueue();
  }
}

// After loading from localStorage
loadAll() {
  // ... load data ...
  loadSyncQueue();
  updateSyncIndicator();
  if (currentUser && syncQueue.length > 0) {
    processSyncQueue();
  }
}
```

#### Spot Creation
```javascript
// When saving spot
saveSpotToSupabase(spot) {
  if (!currentUser) {
    addToSyncQueue(spot.id, 'create');
    return;
  }
  
  try {
    await saveSpotToSupabaseInternal(spot);
    removeFromSyncQueue(spot.id); // Success
  } catch (error) {
    addToSyncQueue(spot.id, 'update'); // Failed, queue it
    scheduleNextSync();
  }
}
```

#### Network Events
```javascript
window.addEventListener('online', () => {
  if (currentUser && syncQueue.length > 0) {
    processSyncQueue();
  }
});

window.addEventListener('offline', () => {
  toast('Offline - changes will sync later', 2000);
});
```

## User Experience

### Scenario 1: User Creates Spot While Offline

1. User clicks map to create spot
2. Spot appears on map immediately (saved to localStorage)
3. Sync fails → added to queue
4. Toast: "Saved locally - will sync when online"
5. Floating indicator appears: "1 unsynced"
6. Menu shows "Sync Now" button with badge
7. When connection restored → auto-syncs
8. Toast: "Synced: [spot name]"
9. Indicator disappears

### Scenario 2: User Creates Spot Before Signing In

1. Anonymous user creates spot
2. Spot saved to localStorage only
3. Added to sync queue (user_id is null)
4. User signs in later
5. Queue automatically processes
6. Spot synced with user's credentials
7. Other users can now see it

### Scenario 3: Database Temporarily Down

1. User creates spot
2. Database returns error
3. Spot added to queue
4. Retry 1: 30 seconds later → still down
5. Retry 2: 1 minute later → still down
6. Retry 3: 2 minutes later → success!
7. Spot synced, removed from queue

### Scenario 4: Manual Sync

1. User opens hamburger menu
2. Sees "Sync Now (3)" button
3. Clicks button
4. Toast: "Syncing 3 items..."
5. All items processed
6. Toast: "Sync complete!" or "[X] items still pending"

## Data Integrity

### Preventing Data Loss

1. **Dual Storage**: All spots saved to both localStorage AND queue
2. **Persistent Queue**: Queue survives page refreshes
3. **Merge Strategy**: Database data + queue data on load
4. **No Overwrites**: Queue items not removed until confirmed saved

### Handling Duplicates

- Queue uses `spotId` as unique identifier
- If spot already in queue, updates timestamp and retry count
- Real-time updates ignored for recently saved spots (3-second window)

### User ID Handling

- Spots created while signed out: `user_id: null` in queue
- When synced after sign-in: Uses current user's ID
- Attribution: `created_by_name` set at sync time

## Monitoring & Debugging

### Console Logs

- `📋 Loaded X items from sync queue` - Queue loaded
- `➕ Adding to sync queue: spotId (action)` - Item added
- `✅ Removed spotId from sync queue` - Item synced
- `🔄 Processing sync queue: X items` - Processing started
- `⏰ Scheduling next sync in Xs` - Retry scheduled
- `🌐 Connection restored - processing sync queue` - Online event

### localStorage Inspection

```javascript
// View queue in browser console
JSON.parse(localStorage.getItem('swoop_sync_queue_v1'))

// Clear queue (debug only)
localStorage.removeItem('swoop_sync_queue_v1')
```

## Limitations & Considerations

1. **localStorage Limits**: ~5-10MB total (should handle hundreds of queued spots)
2. **No Conflict Resolution**: Last write wins (Supabase upsert)
3. **Requires Sign-In**: Sync only works for authenticated users
4. **No Partial Sync**: If report save fails, entire spot fails
5. **Network Detection**: May not detect all offline scenarios

## Future Enhancements

- Conflict resolution for spots edited by multiple users
- Differential sync (only changed fields)
- Priority queue (recent spots synced first)
- Sync status per spot in UI
- Batch sync API endpoint
- Progressive Web App offline capabilities
- Service Worker integration
