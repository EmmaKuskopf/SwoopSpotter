# Location Tracking Feature

## Overview
Continuous location tracking has been added to help users stay informed about swoop zones in real-time as they walk, cycle, or move through areas.

## How It Works

### Tracking Button
- **Location**: Top right of the header, labeled "Start Tracking"
- **State Toggle**: 
  - **Not tracking**: Dark brown (#422d1e), shows "Start Tracking"
  - **Tracking**: Red (#ef4444), shows "Stop Tracking"

### Tracking Behavior
The app uses the browser's `watchPosition()` API which:
- **Continuously monitors** your location (not just once)
- **Updates approximately every 3 seconds** when you're moving
- **More battery efficient** than repeatedly calling `getCurrentPosition()`
- **Automatically adjusts** based on device capabilities

### Location Check Interval
- **Target: ~3 seconds** between location updates when moving
- **Why 3 seconds?**
  - ✅ Fast enough to alert users before entering swoop zones
  - ✅ Responsive for walking speed (~5 km/h = ~4 meters per second)
  - ✅ Perfect for cycling speed (~15 km/h = ~12 meters per second)
  - ✅ Balanced battery consumption
  - ✅ Prevents alert spam/fatigue

### What Happens During Tracking
1. **Initial location**: Map centers on your position
2. **Continuous monitoring**: Your blue user marker updates as you move
3. **Alert checking**: Every update checks if you're near any swoop spots
4. **Zone entry alerts**: 
   - Centered alert box appears
   - Audio notification plays (if available)
   - Device vibrates on mobile
5. **Zone exit detection**: Tracks when you leave swoop areas
6. **Exit prompt**: After leaving all zones, you can report safe passage or add details

## User Interactions

### Starting Tracking
1. Click "Start Tracking" button in header
2. Browser requests location permission (first time only)
3. Grant permission
4. Button turns red and shows "Stop Tracking"
5. Toast notification: "Location tracking active"

### Stopping Tracking
1. Click "Stop Tracking" button
2. Button returns to dark brown and shows "Start Tracking"
3. Toast notification: "Location tracking stopped"
4. User marker remains at last known position

### Find Me Button (One-Time Location)
- Still available for quick location checks
- Gets your current location once
- Centers map on your position
- Does not start continuous tracking

## Mobile Optimization

### Battery Considerations
- `enableHighAccuracy: true` - Uses GPS for precision
- `maximumAge: 3000` - Accepts cached positions up to 3 seconds old
- `timeout: 10000` - 10-second timeout prevents hanging

### Adaptive Behavior
- The browser/OS handles the actual timing
- May check more frequently when moving
- May reduce checks when stationary (device-dependent)

### Mobile Detection
The app detects mobile devices via:
```javascript
function isMobileDevice() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) 
         || window.innerWidth <= 768;
}
```

### Auto-Start Option (Currently Disabled)
Code is included but commented out to auto-start tracking on mobile devices:
- Uncomment lines in the code if you want tracking to start automatically
- Will prompt user with a confirmation dialog
- Respects user preference

## Error Handling

### Permission Denied
- Stops tracking automatically
- Shows error message with instructions
- User can try again after enabling permissions

### Position Unavailable
- Shows error message
- Continues trying to get location
- Helpful for temporary GPS signal loss

### Timeout
- Shows "retrying" message
- Continues tracking attempts
- Good for areas with poor GPS reception

## Technical Details

### API Used
```javascript
navigator.geolocation.watchPosition(
  successCallback,
  errorCallback,
  {
    enableHighAccuracy: true,
    timeout: 10000,
    maximumAge: 3000
  }
)
```

### State Management
- `locationWatchId`: Stores the watch ID for cleanup
- `isTracking`: Boolean flag for current tracking state
- Proper cleanup with `clearWatch()` when stopping

### Benefits Over setInterval
- ✅ Native browser API optimized for location tracking
- ✅ Respects device power-saving features
- ✅ Automatically adapts to movement patterns
- ✅ More accurate timing based on actual GPS updates
- ✅ Better battery life than polling

## Recommended Usage

### For Walking/Running
- Start tracking before your walk/run
- Get real-time alerts as you approach swoop zones
- Stop tracking when you finish

### For Cycling
- Essential for cyclists moving faster
- 3-second intervals provide advance warning
- Enough time to take alternate routes

### For Static Location Checks
- Use "Find Me" button instead
- No need for continuous tracking
- One-time location check

## Future Enhancements (Potential)

### Could Add:
- [ ] Visual tracking indicator on map (breadcrumb trail)
- [ ] Distance/time tracking during sessions
- [ ] Background tracking (requires service workers)
- [ ] Geofencing alerts (push notifications)
- [ ] Speed-based adaptive intervals (faster checks when cycling)
- [ ] Battery level monitoring
- [ ] Location accuracy indicator

### Performance Monitoring:
- [ ] Log actual update frequency
- [ ] Track battery usage
- [ ] User feedback on timing
- [ ] A/B test different intervals (2s vs 3s vs 5s)

## Testing Recommendations

### On Mobile:
1. Start tracking while stationary - verify it starts
2. Walk around a swoop spot - verify alerts trigger
3. Walk through multiple zones - verify all alerts
4. Exit all zones - verify exit prompt appears
5. Stop and restart tracking - verify state persists correctly
6. Test with low battery - verify tracking continues
7. Test with poor GPS signal - verify error messages

### Battery Testing:
- Monitor battery drain over 30-minute walk
- Compare tracking vs. non-tracking battery usage
- Test in areas with varying GPS signal quality

## Privacy & Permissions

### Location Data
- ✅ Never stored on servers
- ✅ Never transmitted externally  
- ✅ Only used for local alert checks
- ✅ Clears when tracking stops

### Permissions Required
- Location access (GPS/network)
- User must explicitly grant permission
- Can be revoked anytime in browser settings
