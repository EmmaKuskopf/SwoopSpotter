# Geolocation Permission Help

## If you're getting "GPS error: Location permission denied" on your mobile device:

### For iPhone/iPad (Safari or Chrome):
1. Open **Settings** on your device
2. Scroll down and tap **Safari** (or **Chrome**)
3. Tap **Location**
4. Select **Ask** or **Allow**
5. Alternatively, go to **Settings > Privacy & Security > Location Services**
6. Make sure Location Services is **On**
7. Scroll down to find **Safari** (or **Chrome**) and set to **While Using the App**

### For Android (Chrome):
1. Open **Chrome** browser
2. Tap the three dots menu (⋮) in the top right
3. Tap **Settings**
4. Tap **Site settings**
5. Tap **Location**
6. Make sure it's set to **Ask first** or **Allowed**
7. Find your site in the list and ensure it's set to **Allow**

### Clear Site Permissions:
If the browser has cached a "deny" response:

**Chrome (Mobile):**
1. Go to your site
2. Tap the lock icon or info icon (ⓘ) in the address bar
3. Tap **Permissions** or **Site settings**
4. Find **Location** and tap **Reset permissions** or change to **Allow**

**Safari (iPhone):**
1. Go to **Settings > Safari > Advanced > Website Data**
2. Find your site and swipe left to delete
3. Revisit the site and it will ask for permission again

### Test Your Location Access:
1. Visit your site: `https://[your-username].github.io/SwoopSpotter/`
2. Click **Use GPS** or **📍 Find Me**
3. You should see a browser prompt asking for location permission
4. Tap **Allow** or **Allow While Using**

### Troubleshooting:
- Make sure you're accessing the site via HTTPS (GitHub Pages uses HTTPS by default)
- Check that Location Services is enabled at the device level
- Try in incognito/private mode to rule out cached permissions
- Make sure you have a GPS signal (try outdoors if indoors)
- Some browsers require user interaction (button click) to request location - the code already does this

### Still Having Issues?
- Check browser console for error messages (on mobile, you may need to connect to desktop Safari/Chrome developer tools)
- Try a different browser
- Ensure your device has location/GPS enabled in system settings
