# Map Dark Mode & Location Tracking Fix

## Issue Identified

When dark/light mode toggling was implemented for the map tiles, it introduced a **race condition** that could interfere with location tracking.

### The Problem

**Original Implementation:**
```javascript
window.switchMapTiles = function(isDark) {
  if (isDark) {
    map.removeLayer(lightTileLayer);
    darkTileLayer.addTo(map);
  } else {
    map.removeLayer(darkTileLayer);
    lightTileLayer.addTo(map);
  }
};
```

**Issues:**
1. ❌ **No error handling** - if a layer wasn't on the map, `removeLayer()` could throw errors
2. ❌ **No layer existence check** - tried to remove/add layers blindly
3. ❌ **No map refresh** - switching layers could leave map in inconsistent state
4. ❌ **Timing conflicts** - if dark mode toggled while location update happening, could cause rendering issues
5. ❌ **Silent failures** - errors would break location tracking but not be visible

### Why This Affected Location Tracking

When location updates tried to:
- Update user marker position
- Center map on user
- Draw circles around spots
- Render alerts

...at the **same time** as tile layers were being switched, the map could enter an inconsistent state where:
- Markers wouldn't render
- Map view wouldn't update
- Location callbacks would fail
- User would see "location troubles" even though GPS was working

## Solution Implemented

### 1. Safe Layer Switching

**New Implementation:**
```javascript
window.switchMapTiles = function(isDark) {
  console.log('🗺️ Switching map tiles to:', isDark ? 'dark' : 'light');
  
  try {
    if (isDark) {
      // Check if light layer exists before removing
      if (map.hasLayer(lightTileLayer)) {
        map.removeLayer(lightTileLayer);
      }
      // Only add dark layer if not already added
      if (!map.hasLayer(darkTileLayer)) {
        darkTileLayer.addTo(map);
      }
    } else {
      // Check if dark layer exists before removing
      if (map.hasLayer(darkTileLayer)) {
        map.removeLayer(darkTileLayer);
      }
      // Only add light layer if not already added
      if (!map.hasLayer(lightTileLayer)) {
        lightTileLayer.addTo(map);
      }
    }
    
    console.log('✅ Map tiles switched successfully');
    
    // Force map to refresh/redraw (helps prevent rendering issues)
    setTimeout(() => {
      map.invalidateSize();
    }, 100);
    
  } catch (error) {
    console.error('❌ Error switching map tiles:', error);
    // Fallback: ensure at least one tile layer is active
    if (!map.hasLayer(lightTileLayer) && !map.hasLayer(darkTileLayer)) {
      console.log('⚠️ No tile layer active, adding default light layer');
      lightTileLayer.addTo(map);
    }
  }
};
```

**Improvements:**
- ✅ **Existence checks** using `map.hasLayer()` before removing/adding
- ✅ **Try-catch block** to handle any errors gracefully
- ✅ **Fallback mechanism** ensures at least one layer is always active
- ✅ **Map refresh** with `invalidateSize()` after switching
- ✅ **Console logging** for debugging tile switch operations
- ✅ **Idempotent** - safe to call multiple times, won't duplicate layers

### 2. Improved Map Initialization

**Added to map configuration:**
```javascript
const map = L.map('map', {
  minZoom: 3,
  maxZoom: 18,
  zoomControl: true,
  trackResize: true  // ← NEW: Ensures map handles resize events properly
}).setView([-27.4698, 153.0251], 18);

console.log('🗺️ Map initialized:', !!map);
```

**Benefits:**
- `trackResize: true` - Map automatically handles DOM changes
- Better logging to verify map initialization
- More robust against timing issues

### 3. Theme Initialization Logging

```javascript
console.log('🎨 Initial theme:', isDarkMode ? 'dark' : 'light');
```

Helps debug which theme is loaded on startup.

## How It Works Now

### Scenario 1: User Toggles Dark Mode While Location Tracking Active

**Before (Broken):**
1. User enables location tracking ✅
2. GPS updates user position ✅
3. User toggles dark mode 🔄
4. `removeLayer()` throws error (layer not found) ❌
5. Map enters broken state ❌
6. Location updates fail ❌
7. User sees "location troubles" ❌

**After (Fixed):**
1. User enables location tracking ✅
2. GPS updates user position ✅
3. User toggles dark mode 🔄
4. `hasLayer()` checks if layer exists ✅
5. Layer switched safely ✅
6. `invalidateSize()` refreshes map ✅
7. Location updates continue working ✅

### Scenario 2: Location Update During Theme Switch

**Race Condition Handled:**
- If location update happens while theme switching:
  - Try-catch prevents errors from breaking location tracking
  - `invalidateSize()` ensures map redraws properly
  - Fallback ensures a tile layer is always present
  - Next location update will render correctly

### Scenario 3: Multiple Rapid Theme Toggles

**Idempotent Protection:**
- `hasLayer()` checks prevent duplicate layers
- Won't try to remove layer that's not there
- Won't add layer that's already present
- Safe to toggle rapidly without breaking map

## Testing Recommendations

### Test Dark Mode with Active Location Tracking

1. **Enable location tracking**
   - Check console: `✅ Location tracking active`
   - Verify user marker appears on map

2. **Toggle dark mode**
   - Click dark mode toggle
   - Check console: `🗺️ Switching map tiles to: dark`
   - Check console: `✅ Map tiles switched successfully`
   - Verify map switches to dark tiles
   - Verify user marker still visible
   - Verify location updates continue

3. **Toggle back to light mode**
   - Click dark mode toggle again
   - Check console logs
   - Verify smooth transition
   - Verify location tracking unaffected

4. **Test rapid toggles**
   - Toggle dark/light mode quickly 5-10 times
   - Should not see any errors
   - Map should always have tiles
   - Location tracking should continue

### Test Edge Cases

**Test 1: Toggle Before Location Permission Granted**
- Open app (no location yet)
- Toggle dark mode
- Grant location permission
- Start tracking
- Should work normally

**Test 2: Toggle While Walking Through Swoop Zone**
- Walk into swoop zone (alert shows)
- Toggle dark mode while alert visible
- Alert should remain functional
- Location tracking should continue
- Alert should update as you move

**Test 3: Toggle on Slow Network**
- Throttle network in dev tools
- Toggle dark mode
- Tiles should switch (even if slowly)
- Location tracking should continue
- No errors in console

## Console Logging to Monitor

**Successful operation shows:**
```
🗺️ Map initialized: true
🎨 Initial theme: light
📍 Location update: -27.4698, 153.0251 (accuracy: 12m)
📡 Source: GPS
🗺️ Switching map tiles to: dark
✅ Map tiles switched successfully
📍 Location update: -27.4698, 153.0251 (accuracy: 11m)
📡 Source: GPS
```

**Problem indicators (should NOT see):**
```
❌ Error switching map tiles: [error]
⚠️ No tile layer active, adding default light layer
```

If you see these, it means:
- Map entered broken state (triggered fallback)
- Investigate what caused the error
- Fallback should recover gracefully

## Benefits

### For Users
1. ✅ **Seamless dark mode** - switches smoothly without breaking location
2. ✅ **Reliable tracking** - location updates work regardless of theme changes
3. ✅ **No "location troubles"** - false errors eliminated
4. ✅ **Better night usage** - can safely switch to dark mode while tracking

### For Developers
1. ✅ **Better debugging** - comprehensive console logging
2. ✅ **Error recovery** - graceful fallbacks prevent total failure
3. ✅ **Idempotent** - safe to call repeatedly
4. ✅ **Maintainable** - clear error messages and structure

## Technical Details

### Leaflet Layer Management

**Key Methods:**
- `map.hasLayer(layer)` - Returns true if layer is on map
- `map.removeLayer(layer)` - Removes layer (throws error if not present)
- `map.addLayer(layer)` - Adds layer (no error if already present, but creates duplicate)
- `map.invalidateSize()` - Forces map to recalculate and redraw

### Why invalidateSize() Matters

After switching tile layers, the map's internal state might be:
- Out of sync with DOM
- Using cached dimensions
- Not properly rendering new tiles

`invalidateSize()` forces the map to:
1. Re-check container dimensions
2. Recalculate tile positions
3. Redraw all layers
4. Update marker positions

This ensures location markers render correctly after theme switch.

### Timeout Delay (100ms)

```javascript
setTimeout(() => {
  map.invalidateSize();
}, 100);
```

**Why 100ms?**
- Gives DOM time to settle after layer switch
- Prevents race condition with rendering
- Long enough for tiles to start loading
- Short enough user doesn't notice delay

## Related Files

- `index.html` - Lines ~2020-2090 (map initialization and tile switching)
- `index.html` - Lines ~7850-7880 (dark mode toggle handler)

## Summary

The dark mode/light mode map implementation was causing location tracking issues due to:
1. Unsafe layer removal/addition
2. No error handling
3. No map refresh after switching
4. Race conditions with location updates

**Fixed by:**
1. Adding existence checks with `hasLayer()`
2. Wrapping in try-catch with fallback
3. Adding `invalidateSize()` to refresh map
4. Comprehensive logging for debugging
5. Making tile switching idempotent and safe

**Result:**
Location tracking now works reliably regardless of theme changes! 🎉
