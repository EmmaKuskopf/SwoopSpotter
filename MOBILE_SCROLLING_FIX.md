# Mobile Modal Scrolling Fix

## Issue
On mobile devices, users were unable to scroll within modals (create spot form, details modal, etc.) to complete forms when the content was taller than the viewport.

## Solution Implemented

### 1. **Modal Container Improvements**
- Added `overflow-y: auto` to modal overlay for vertical scrolling
- Added `-webkit-overflow-scrolling: touch` for smooth iOS scrolling
- Changed modal containers from `w-11/12` to `w-full` for better mobile width
- Added `max-h-[95vh]` to prevent modals from exceeding viewport height
- Added `overflow-y-auto` to modal content divs for internal scrolling
- Added `my-auto` to center modals vertically
- Added padding (`p-4`) to modal overlays for breathing room

### 2. **Body Scroll Prevention**
Added CSS class to prevent background scrolling when modals are open:
```css
body.modal-open {
  overflow: hidden;
  position: fixed;
  width: 100%;
  height: 100%;
}
```

### 3. **JavaScript Body Class Management**
Added `document.body.classList.add('modal-open')` when opening modals and `document.body.classList.remove('modal-open')` when closing modals for:
- Spot creation modal (`spotModal`)
- Details modal (`detailsModal`)
- Success modal (`successModal`)
- Safe passage modal
- Exit prompt modal (`exitPromptModal`)

### 4. **Mobile-Specific Adjustments**
```css
@media (max-width: 768px) {
  .modal-overlay {
    align-items: flex-start !important;
    padding-top: 1rem;
    padding-bottom: 1rem;
  }
}
```

## Updated Modals
✅ Spot Creation Modal (`#spotModal`)
✅ Details/Report Modal (`#detailsModal`)
✅ Success Modal (`#successModal`)
✅ Exit Prompt Modal (`#exitPromptModal`)
✅ Confirm Discard Modal (`#confirmModal`)
✅ Dynamically created details modal content

## Testing Recommendations
1. Test on iPhone Safari (most restrictive)
2. Test on Android Chrome
3. Test in landscape and portrait orientations
4. Test creating a spot with all form fields
5. Test adding reports to existing spots
6. Test on smaller devices (iPhone SE, etc.)

## Key Changes
- Modal containers now scroll internally instead of trying to expand beyond viewport
- Background page is locked when modals are open (prevents confusion)
- Modals are properly centered with breathing room on all sides
- Touch scrolling is smooth on iOS devices
- All modals consistently handle overflow content
