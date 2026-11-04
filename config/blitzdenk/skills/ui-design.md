---
name: ui-design
description: >
    Rules for good UI design: hierarchy, layout, type, color, motion, control
    flow, information structure, states, and accessibility. Load when building
    or reviewing a user interface, styling a page or app, or choosing spacing,
    color, animation, form, or interaction patterns.
---

# UI design

Design in grayscale first. Add color last. If the layout fails in gray, color will not save it.

Every element must earn its place. Remove decoration, duplicate labels, and non-essential borders before adding structure.

## Layout

- One primary action per view. Demote every other action to secondary or tertiary. Two filled buttons compete.
- Build hierarchy with size, weight, contrast, and space. Use three levels at most: primary, secondary, muted.
- Use a 4 px spacing scale: 4, 8, 12, 16, 24, 32, 48, 64. No arbitrary values.
- Put less space inside a group than between groups. Use about twice the gap between groups.
- Align to one grid. Left-align text. Right-align numbers.
- Limit body text to 45-75 characters per line. Target 66.
- Start with too much whitespace, then remove. Dense is not the same as efficient.
- Use one content column. Use multiple columns only for independent content.
- One idea per card. No nested cards. Prefer space and alignment over borders.
- Use two elevation levels at most. Prefer a 1 px border or a surface shift over a shadow.
- Pick two corner radii. Nested radius = outer radius - gap.
- Page padding: 16 px on mobile, 24-32 px on desktop. Dense tables: 8-12 px.
- Touch targets: 44x44 minimum, 48x48 preferred. The WCAG 2.2 minimum is 24x24 with spacing.
- Forms: one column, labels above fields, one or two optional fields maximum. Mark optional fields, not required ones. Never use a placeholder as a label.
- Check 320, 360, 768, 1024, and 1440 px. No horizontal scroll at 320.
- Keep labels next to their controls. Keep controls near the result they affect (Fitts).
- Center only short headings, empty states, and single actions.

## Typography

- Body: 16 px minimum, line-height 1.5. Headings: line-height 1.1-1.25.
- Use 4-5 sizes. Ratio 1.2 on mobile, 1.25-1.333 on desktop.
- Use two families and three weights at most.
- Change weight or color before size when you need less emphasis.
- Use sentence case. All caps only for short labels, with 0.05em tracking.
- Left-align body text. Avoid justified text on the web.
- Use tabular numerals for tables, prices, timers, and aligned data.
- Set font sizes in rem and line-height without units.

## Color

- Spend most of the surface on neutrals. Accent is for action, selection, and state only. Aim for 60-30-10 or stricter.
- Use one accent hue. Add a second only for semantic meaning: danger, success, warning.
- Build palettes in OKLCH: hold hue and chroma, step lightness. Perceived brightness stays even.
- Tint neutrals with a little of the accent hue (chroma ~0.01-0.03). Pure gray looks dead next to color.
- Name colors by role: `bg`, `surface`, `border`, `text`, `text-muted`, `accent`, `danger`. Never put raw hex values in components.
- Contrast: 4.5:1 for body text, 3:1 for large text, icons, borders, and focus rings. Check every pairing.
- Never use color as the only signal. Add an icon, label, pattern, or weight change.
- Dark mode is a separate design, not an inversion. Use #121212, not #000. Lighten surfaces with elevation. Desaturate accents. Use off-white text, not #FFF.
- Reserve red for destructive actions and errors.
- Keep disabled controls readable and explain why they are disabled.
- Test both themes with real content. Support `prefers-color-scheme`.

## Motion

- Motion must do one of three jobs: explain a change, confirm feedback, or direct attention. If it does none, delete it.
- Enter with ease-out: `cubic-bezier(0, 0, 0, 1)`. Exit with ease-in: `cubic-bezier(0.3, 0, 1, 1)`. Move on screen with standard: `cubic-bezier(0.2, 0, 0, 1)`.
- For expressive entrances, use Material emphasized decelerate: `cubic-bezier(0.05, 0.7, 0.1, 1)`.
- For gestures and interruptible motion, use a spring at critical damping (ratio ~1). Add bounce only for rare, playful moments.
- Duration follows distance and frequency: 100-150 ms for micro feedback, 150-250 ms for small elements, 250-350 ms for medium surfaces, 300-500 ms for large or full-screen changes. Frequent actions get shorter motion. Exit at about 70% of enter.
- Animate movement with `transform` and `opacity` only. Avoid width, height, top, left, and filters.
- Expand menus and popovers from their trigger. Set the transform origin.
- Choreograph one lead element. Stagger children by 20-50 ms. Keep the total under 400 ms.
- Never block input. Let the user interrupt or reverse the animation.
- Do not animate the 100th repeat of a frequent action.
- Honor `prefers-reduced-motion`: replace movement with a short cross-fade. Remove parallax, autoplay, and scroll-jacking.
- Motion must never carry the only meaning. Pair it with a visible state change.

## Control flow

- Respond within 100 ms. Keep feedback under 400 ms to preserve flow (Doherty).
- 100 ms-1 s: show a busy state without a spinner. 1-10 s: spinner or skeleton. Over 10 s: progress, estimate, and cancel.
- Delay loading indicators 200-300 ms to avoid flashes. Keep them visible for at least 300 ms. Reserve the final layout to prevent shift.
- Prefer undo over confirmation; keep the undo option available for 5-10 s. Confirm only irreversible, high-cost actions. Name the outcome: "Delete 3 files", not "Are you sure?".
- Use optimistic updates for low-risk actions. Reconcile or roll back visibly on failure.
- Prevent errors before reporting them: constrain input, add defaults, use the right input type, accept common formats.
- Validate on blur, not on every keystroke. Use live validation only for positive hints. Keep all entered data after an error. Put the message next to the field and say what to do. Add a summary for long forms.
- Show the state of every control: default, hover, focus, active, selected, disabled, loading, empty, error, success.
- Empty, zero, no-results, and error are different states. Each needs its own message and action. No-results must offer a way to clear filters.
- Every empty state answers: what is this, why is it empty, and what is the one next action.
- Progressive disclosure: show the core task first, hide advanced options behind "More options". Never hide the primary action.
- Fewer choices, one recommended default. Split long tasks into steps with progress and a way back.
- Keep context visible. Show current filters, scope, and selection. Restore it on back navigation.
- Every screen needs an exit: back, cancel, close, or undo. No dead ends.
- Keyboard: tab order matches visual order. Focus is always visible. Esc closes, Enter submits, shortcuts are discoverable.
- Follow platform conventions (Jakob's law) unless you have a strong reason.
- Save automatically and show "Saved". Warn before leaving with unsaved changes.
- Disable submit while a request is in flight. Make retries safe.
- Use inline messages for errors. Toasts are for non-critical confirmation only. Never make a toast the only error channel.
- Confirm success with the result, not just "Success".

## Information and content

- Organize by the user's task, not the system's structure. Label each group.
- Write from the user's goal. Use verb + object: "Save changes", "Invite member". Avoid "Submit" and "OK".
- Front-load the keyword. Use the user's vocabulary, not internal jargon.
- One concept gets one label everywhere.
- Show units, formats, and time zones. Localize numbers and dates.
- Prefer showing over asking. Suggest defaults, recent values, and smart options.
- Remove duplicate information. Say it once, where the decision is made.
- Tables: left-align text, right-align numbers, use tabular figures, show sort direction, keep the header visible. Let tables scroll on small screens; do not crush columns.
- Error copy: what happened, why, and the fix. No blame, no humor, no error codes alone.

## Accessibility

- Make focus visible: at least 2 px, offset, 3:1 against adjacent colors. Never remove the outline without a replacement.
- Everything works with a keyboard. Use semantic elements and native controls first.
- Tie every label to its input. Keep labels visible. Add autocomplete and correct input types.
- Give every image alt text. Mark decorative images as decorative.
- Support 200% text zoom and 320 px reflow without loss of content or function.
- Do not disable paste.
- Announce status and errors with `aria-live`. Connect errors to fields with `aria-describedby`.
- Provide captions and transcripts for media.

## Review pass

Run these checks on every screen:

1. Squint: one element dominates, related items group.
2. Grayscale: hierarchy still reads.
3. Count primary actions: exactly one.
4. Tab through: focus visible, order sane, main task completes.
5. 320 px and 200% zoom: no horizontal scroll, no clipped controls.
6. Slow network: loading states appear, layout does not shift.
7. Error path: data survives, the fix is obvious.
8. 100th use: motion is still short and quiet.
9. Empty and first-run states: a clear next action exists.
10. Contrast: every text and UI pairing passes.
