# GitHub Copilot Instructions for SwoopSpotter

## Project Overview
SwoopSpotter is a community-driven web application for reporting and tracking aggressive swooping birds in Australia. Users can create spots, add reports, and receive real-time alerts as they move through areas with swooping birds.

## Code Style & Standards

### Emoji Usage
- ✅ **ALLOWED**: Emojis in console logs for debugging purposes only
  - Example: `console.log('🎯 Starting location tracking...');`
  - Purpose: Makes debugging easier by visually distinguishing different log types
- ❌ **NOT ALLOWED**: Emojis in user-facing UI elements
  - No emojis in buttons, labels, headings, or any visible text
  - Keep the UI professional and clean
  - Exception: Icon images are fine (e.g., SVG icons for birds, users, etc.)

### Console Logging Standards
**MANDATORY**: All functions must include console logging for debugging, especially on mobile where developers cannot easily access the console.

Use descriptive emoji prefixes for different log types:
- 🎯 Function start/initialization
- ✅ Success/completion
- ⚠️ Warnings
- ❌ Errors
- 📍 Location updates
- 📊 Data operations
- 🔄 Sync/real-time updates
- 🌍 Geolocation
- 🛑 Stop/cleanup
- 💾 Save operations
- 📂 Load operations
- 📌 UI state changes (minimize, show, hide)
- 🔔 Alerts and notifications
- 🐦 Bird/spot related operations

#### Logging Best Practices

1. **Log at function entry with context:**
   ```javascript
   function myFunction(param1, param2) {
     console.log('🎯 myFunction called:', { param1, param2 });
     // ... function body
   }
   ```

2. **Log state changes before and after:**
   ```javascript
   console.log('📌 Before state change:', element.className);
   element.classList.add('new-class');
   console.log('📌 After state change:', element.className);
   ```

3. **Log critical paths and decision points:**
   ```javascript
   if (condition) {
     console.log('✅ Condition met - executing branch A');
     // ... 
   } else {
     console.log('⚠️ Condition not met - executing branch B');
     // ...
   }
   ```

4. **Log computed/calculated values:**
   ```javascript
   const computed = window.getComputedStyle(element);
   console.log('📊 Computed styles:', {
     display: computed.display,
     width: computed.width,
     opacity: computed.opacity
   });
   ```

5. **Always log errors with context:**
   ```javascript
   try {
     // operation
   } catch (error) {
     console.error('❌ Operation failed:', error);
     console.error('❌ Context:', { relevantData });
     toast('User-friendly error message', 3000);
   }
   ```

6. **Log async operations:**
   ```javascript
   console.log('🔄 Starting async operation...');
   const result = await asyncFunction();
   console.log('✅ Async operation complete:', result);
   ```

#### When to Add Extra Logging

Add extra diagnostic logging when:
- Working with UI state changes (show/hide/minimize)
- Handling user interactions (clicks, gestures)
- Processing location data
- Managing real-time updates
- Debugging mobile-specific issues
- Event handler attachment/removal
- CSS class manipulation
- DOM manipulation

#### Mobile Debugging Support

Since mobile users cannot easily access the console:
- Include `toast()` messages for critical user-facing state changes during development
- Log computed styles when debugging layout issues
- Log event handler attachment to verify they're connected
- Use timeouts to log delayed state for async operations

### JavaScript Style
- Use ES6+ features (arrow functions, destructuring, async/await)
- Prefer `const` over `let`, never use `var`
- Use meaningful variable names (no single letters except in loops)
- Comment complex logic and business rules
- Use IIFE pattern for app initialization to avoid global namespace pollution

### HTML/CSS Style
- Use semantic HTML5 elements
- Inline styles only when necessary for dynamic behavior
- Use Tailwind-like utility classes where appropriate
- Maintain mobile-first responsive design
- All modals should use consistent structure and styling

### Accessibility
- All buttons must have descriptive labels or aria-labels
- Images must have alt text
- Modals should trap focus when open
- Keyboard navigation should work everywhere
- Color contrast must meet WCAG AA standards

## Architecture Patterns

### Data Flow
1. **Supabase (Primary)**: Real-time database for spots and reports
2. **localStorage (Fallback)**: Offline support and backup
3. **Real-time Sync**: Subscribe to database changes for multi-user updates

### State Management
- `currentUser` - Authenticated user object
- `userProfile` - User profile data from database
- `spots` - Array of all swoop spots with reports
- `isTracking` - Boolean for location tracking state
- `locationWatchId` - ID for continuous location tracking

### Modal Pattern
All modals follow this structure:
```javascript
// Open modal
function openModal() {
  modal.classList.remove('hidden');
  document.body.classList.add('modal-open');
}

// Close modal
function closeModal() {
  modal.classList.add('hidden');
  document.body.classList.remove('modal-open');
  scrollToHome(); // Reset navigation state
}
```

### Location Tracking
- Use `watchPosition()` for continuous tracking (not polling)
- Update frequency: ~3 seconds (`maximumAge: 3000`)
- High accuracy mode for GPS precision
- Show/hide "Enable Location" button based on permission state

## Key Features

### Authentication
- Supabase Auth for user management
- Profile system with avatars and display names
- Dynamic UI updates based on auth state
- Sign In/Sign Out (not "Login"/"Logout")

### Bird Swooping Data
- Season-based risk calculation
- Auto-calm after 10 days without reports
- Pre-season warnings 30 days before season starts
- Preventative tips for building rapport with birds
- Safety tips per species

### Real-time Alerts
- Continuous location tracking when permission granted
- Alert when entering swoop zone (50-100m radius)
- Multi-bird alerts when multiple zones overlap
- Exit prompts for feedback after leaving zones
- Safe passage tracking

### Stats & Gamification
- Track user contributions (spots, reports, safe passages)
- Activity feed showing recent contributions
- Community stats (today/week/season)

## API & External Services

### Supabase
- URL: `https://ghoipwkezxiyjkgikfyw.supabase.co`
- Tables: `spots`, `reports`, `profiles`
- Real-time subscriptions enabled
- Row-level security policies in place

### Geocoding
- Service: `geocode.maps.co` (free, CORS-friendly)
- Use for address lookups and reverse geocoding
- No API key required

### Map
- Library: Leaflet.js
- Tiles: CartoDB (light and dark themes)
- Custom bird and user icons
- Radius circles based on risk level

## Testing & Debugging

### Test Date Feature
- Located in Testing modal
- Allows simulating different dates to test seasonal logic
- Use `getCurrentDate()` instead of `new Date()` everywhere

### Walk Simulator
- Simulates user movement between two addresses
- Useful for testing location tracking and alerts
- Located in Testing modal

### Vibration Testing
- Test device vibration patterns
- Useful for mobile alert testing
- Located in Testing modal

## Common Patterns

### Toast Notifications
```javascript
toast('Message here', duration); // duration in ms, default 1600
```

### Error Handling
```javascript
try {
  // Operation
  console.log('✅ Success');
} catch (error) {
  console.error('❌ Error:', error);
  toast('User-friendly error message', 3000);
}
```

### Supabase Queries
```javascript
const { data, error } = await supabase
  .from('table_name')
  .select('*')
  .eq('column', value);

if (error) throw error;
```

### Modal State
```javascript
// Always close all modals before opening a new one
closeAllModals();
modalElement.classList.remove('hidden');
document.body.classList.add('modal-open');
```

## Performance Considerations

### Location Tracking
- Battery impact: Use GPS but limit update frequency
- Don't center map on every update (only first one)
- Clear watch when tracking stops

### Real-time Subscriptions
- Only subscribe once on app init
- Ignore real-time updates for our own saves
- Reload silently to avoid notification spam

### Map Performance
- Remove markers/circles before recreating
- Use try-catch when removing layers (may not exist)
- Batch marker updates when possible

## Security & Privacy

### User Data
- Never store passwords in localStorage
- Use Supabase Auth for all authentication
- Don't expose user emails publicly
- Row-level security on all tables

### Location Data
- Request permission before tracking
- Clear explanation of why location is needed
- Easy way to disable/re-enable tracking
- Don't track when app is in background

## Browser Compatibility

### Target Support
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile Safari (iOS 14+)
- Chrome Mobile (Android 90+)

### Feature Detection
Always check for API availability:
```javascript
if (navigator.geolocation) {
  // Use geolocation
} else {
  // Fallback or error message
}
```

## Deployment Notes

### GitHub Pages
- Deployed from `main` branch
- URL: https://emmakuskopf.github.io/SwoopSpotter/
- Static hosting (no server-side code)
- All API calls are client-side

### Environment
- No build process required
- Direct HTML/CSS/JS (no bundler)
- CDN dependencies (Leaflet, Supabase, Tailwind)

## File Structure

```
SwoopSpotter/
├── index.html              # Main app (single-page application)
├── service-worker.js       # PWA service worker
├── manifest.json          # PWA manifest
├── Assets/
│   ├── Icons/             # Bird status icons
│   ├── Logo/              # Branding
│   ├── Menu Icons/        # Navigation icons
│   └── Users Icons/       # Avatar options
└── *.md                   # Documentation files
```

## Documentation Files

- `CONTINUOUS_LOCATION_TRACKING.md` - Location tracking implementation
- `MODAL_NAVIGATION_IMPROVEMENTS.md` - Modal and navigation patterns
- `DARK_MODE_MAP_IMPLEMENTATION.md` - Dark mode theming
- `SUPABASE_SETUP.md` - Database configuration
- `SAFETY_TIPS_SOURCES.md` - Sources for bird safety information

## When Making Changes

1. **Always test on mobile** - Primary use case is walking/cycling
2. **Check dark mode** - Both light and dark themes must work
3. **Test offline** - localStorage fallback should work
4. **Verify auth states** - Test logged in, logged out, and transitions
5. **Check real-time sync** - Open in two browsers to test
6. **Test location permission** - Denied, granted, and revoked states
7. **Mobile scroll lock** - Modals should prevent body scroll on mobile

## Bird Species Supported

- Magpie (August - November)
- Magpie-Lark (Peewee) (August - November)
- Masked Lapwing (June - December)
- Butcherbird (August - November)
- Crow (August - October)
- Noisy Miner (July - November)
- Noisy Friarbird (September - December)

## Risk Levels

1. **Danger - Avoid** (Red) - Contact made, close swoops
2. **Take caution** (Amber) - Active swooping
3. **Low risk** (Green) - Noisy, observed but no swooping
4. **Calm - All clear** (Blue) - Pre-season or auto-calmed

---

**Remember**: This is a community safety tool. User experience and clarity are paramount. When in doubt, prioritize safety, accessibility, and clear communication over fancy features.
