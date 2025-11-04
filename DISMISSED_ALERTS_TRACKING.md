# Dismissed Alerts Tracking

## Problem
When a user was inside a swooping zone and clicked "Clear Alert", the alert would reappear every ~3 seconds as the location tracking continued to detect them inside the zone. This created a frustrating user experience where users couldn't dismiss alerts they'd already acknowledged.

## Solution
Implemented a dismissed alerts tracking system that remembers which spot alerts a user has manually cleared during their current journey through that zone.

## Implementation

### New State Variable
Added `dismissedAlerts` Set to track spot IDs that the user has manually dismissed:

```javascript
let dismissedAlerts = new Set(); // Track alerts user manually dismissed (cleared while still in zone)
```

### Alert Filtering
Updated the `checkLocation()` function to filter out dismissed alerts:

```javascript
const activeThreats = insideSpots.filter(s => 
  s.risk !== 'Calm - All clear' && 
  !recentlyReportedSpots.has(s.id) &&
  !dismissedAlerts.has(s.id)  // NEW: Don't re-alert dismissed spots
);
```

### Clear Alert Button Behavior
When user clicks "Clear Alert", the spot IDs are added to the dismissed set:

```javascript
document.getElementById('clearAlertBtn').onclick = () => {
  // Add all current alert spots to dismissed list
  currentAlertSpots.forEach(spot => dismissedAlerts.add(spot.id));
  console.log('🔕 User dismissed alert for:', currentAlertSpots.map(s => s.name).join(', '));
  currentAlertSpots = [];
  hideCenteredAlert();
};
```

### Reset on Exit
The dismissed alerts are cleared when the user exits ALL zones, allowing fresh alerts on the next journey:

```javascript
// Clear visited spots for next journey
visitedSpots.clear();
alreadyReportedThisJourney.clear();
dismissedAlerts.clear(); // Clear dismissed alerts when exiting all zones
hasShownCalmFeedback = false;
```

## User Experience

### Before
1. User enters swoop zone → Alert appears ✅
2. User clicks "Clear Alert" → Alert disappears ✅
3. 3 seconds later (location update) → **Alert reappears** ❌
4. User clicks "Clear Alert" again → Alert disappears ✅
5. 3 seconds later → **Alert reappears again** ❌
6. (Frustrating cycle continues...)

### After
1. User enters swoop zone → Alert appears ✅
2. User clicks "Clear Alert" → Alert disappears ✅
3. 3 seconds later (location update) → **No alert** ✅
4. User continues through zone → **No repeated alerts** ✅
5. User exits zone and later re-enters → Fresh alert appears ✅

## Journey Lifecycle

A "journey" is defined as the period from entering a zone until exiting ALL zones. The dismissed alerts tracking follows this lifecycle:

### Journey Start
- User enters one or more swoop zones
- Alerts are shown for all active threats

### During Journey
- User can dismiss individual alerts
- Dismissed alerts won't reappear while user is in ANY zone
- User can still:
  - Click markers on the map to see spot details
  - View spots in the nearby alerts list
  - Add reports to dismissed spots

### Journey End
- User exits ALL swoop zones
- Exit feedback prompt appears (if applicable)
- ALL tracking is reset:
  - `visitedSpots.clear()`
  - `alreadyReportedThisJourney.clear()`
  - `dismissedAlerts.clear()` ← Dismissed alerts reset here
  - `hasShownCalmFeedback = false`

### Next Journey
- Clean slate - all previous dismissals forgotten
- Fresh alerts will appear when re-entering zones

## Related Tracking Systems

The dismissed alerts system works alongside other tracking mechanisms:

### 1. `recentlyReportedSpots` (10-second suppression)
- **Purpose**: Prevent immediate re-alerting after user adds a report
- **Duration**: 10 seconds
- **Cleared**: Automatically after timeout

### 2. `visitedSpots` (journey tracking)
- **Purpose**: Track which spots to include in exit feedback prompt
- **Duration**: Current journey
- **Cleared**: When user exits all zones

### 3. `alreadyReportedThisJourney` (feedback prevention)
- **Purpose**: Don't ask for feedback on spots user just reported
- **Duration**: Current journey
- **Cleared**: When user exits all zones

### 4. `dismissedAlerts` (manual dismissal)
- **Purpose**: Don't re-show alerts user manually cleared
- **Duration**: Current journey (until exit all zones)
- **Cleared**: When user exits all zones

## Edge Cases Handled

### Multiple Zones
- User in overlapping zones can dismiss individual alerts
- Each dismissed spot is tracked separately
- Only non-dismissed spots will show alerts

### Re-entering After Exit
- If user exits ALL zones and re-enters, fresh alerts appear
- Previous dismissals are forgotten (clean slate)

### Reporting While Dismissed
- User can still add reports to dismissed spots via:
  - Map markers (click to open details)
  - Nearby alerts list
- Adding a report doesn't re-show the alert (user already acknowledged it)

### Location Updates
- Continuous tracking (~3 second updates) won't re-trigger dismissed alerts
- User location marker remains visible at all times
- Dismissed spots still visible on map as markers

## Console Logging
For debugging, dismissal events are logged:
```
🔕 User dismissed alert for: Maggie the Magpie, Swoopy the Crow
```

## Code Locations
- **State declaration**: ~line 4910
- **Filter logic**: ~line 4932
- **Dismiss handler (single)**: ~line 5719
- **Dismiss handler (multiple)**: ~line 5805
- **Reset logic**: ~line 4976

## Testing Recommendations

### Manual Testing
1. **Basic Dismissal**
   - Enter a swoop zone
   - Verify alert appears
   - Click "Clear Alert"
   - Wait 5+ seconds
   - Verify alert does NOT reappear

2. **Multiple Zones**
   - Position near overlapping zones
   - Dismiss one alert
   - Verify only non-dismissed alerts show

3. **Exit and Re-enter**
   - Enter zone and dismiss alert
   - Exit the zone completely
   - Re-enter the zone
   - Verify alert appears again (fresh journey)

4. **Report After Dismiss**
   - Dismiss an alert
   - Click the spot marker on map
   - Add a report
   - Verify no alert re-appears

5. **User Marker Visibility**
   - Dismiss an alert
   - Verify user location marker stays on map
   - Verify tracking continues (marker updates position)

## Future Enhancements

Potential improvements:
- **Persistent Dismissals**: Store in localStorage to survive page refresh
- **Time-based Reset**: Auto-reset dismissals after X hours
- **Per-session Tracking**: Reset on app close/reopen
- **Dismissal History**: Track how often users dismiss certain spots

## Related Documentation
- `CONTINUOUS_LOCATION_TRACKING.md` - Location tracking implementation
- `MODAL_NAVIGATION_IMPROVEMENTS.md` - Alert modal patterns
- `.github/copilot-instructions.md` - Location tracking patterns

## Date Implemented
November 4, 2024
