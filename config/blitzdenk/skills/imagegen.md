---
name: imagegen
description: >
    Instruction and prompting guides for image generation. Always load when creating or editing images!
---

# Image generation

Two tools handle images:

- `lua_gen_image` creates a new image from a prompt. Args: `path` (where to save the webp), `prompt`, `size` (WxH, 256 to 1536, default 512x512).
- `lua_edit_image` edits an existing image file with an instruction prompt. Args: `path` (image to edit), `prompt`.

Both write a webp to a sandbox temp file and return a `cp` command. Run it to place the asset in the project, then report the final path.

## When to use

- New bitmap asset: concept art, product shot, hero image, sprite, texture
- New image guided by reference images for style, composition, or mood
- Edit of an existing file: background swap, object removal, style change, cutout

## When not to use

- Icons, logos, or diagrams that belong in SVG or HTML/CSS
- Edits to a native source file that already lives in the repo
- Requests where the user wants deterministic code-native output

## Workflow

1. Pick generate or edit. Assume generate unless the user asks to change an existing image.
2. Collect inputs before calling: prompt, exact text, constraints, input images.
3. Label each input image by role: edit target, style reference, or insert.
4. Shape the prompt, call the tool, check the result with `view_image`.
5. Fix problems one change per iteration. Repeat invariants each time so edits do not drift.
6. Copy the temp file into the project and report the final path and the prompt used.

For batches, issue one call per asset and keep only the finals the user asked for.

## Prompt shaping

Structure the prompt as scene -> subject -> details -> constraints.

- Name the intended use to set polish level: ad, UI mock, infographic, sprite sheet.
- Use camera and composition language for photorealism: wide shot, soft studio lighting, top-down.
- Quote exact in-image text and give typography plus placement. Spell tricky words letter by letter.
- Reference multi-image inputs by index and say what each contributes.
- For edits, state invariants explicitly: "change only the background; keep the product edges unchanged".
- If the prompt is already specific, normalize it into a clear spec without adding ideas.
- If it is generic, add only detail that materially improves the result.

## Recipe library

Starting points, not templates to copy blindly. The tools take one prompt string, so write these as prose. Add "no watermark" when the model tends to stamp one.

### Generate

Photoreal scene:

```text
Candid photo of an elderly sailor on a small fishing boat adjusting a net.
Soft coastal daylight, shallow depth of field, medium close-up at eye level.
Real skin texture, worn fabric, salt-worn wood. Natural color balance, no
retouching, no staged look.
```

Product shot:

```text
Premium product photo of a matte black shampoo bottle with a minimal label.
Clean studio gradient from light gray to white, softbox lighting, subtle
reflection. Centered, slight three-quarter angle. No logos, no watermark.
```

UI mockup:

```text
Mobile app home screen for a local farmers market with vendors and daily
specials. Realistic product UI, not concept art. Clean vertical layout,
clear hierarchy, practical spacing, legible typography. No logos.
```

Infographic:

```text
Infographic of an automatic coffee machine. Vertical poster layout,
top-to-bottom flow: bean hopper, grinder, brew group, boiler, drip tray.
Clean vector style with callouts and arrows, strong contrast. Text verbatim:
"Bean Hopper", "Grinder", "Brew Group", "Boiler", "Drip Tray".
```

Tileable texture:

```text
Seamless tileable texture of worn sandstone blocks. PBR-like material look,
neutral lighting, no obvious focal element, seamless edges.
```

Logo concept:

```text
Vector logo mark for the bakery "Field & Flour". Flat colors, minimal,
strong silhouette, centered on a plain background with generous padding.
Deep green and off-white. No gradients, no 3D, no text unless requested.
```

### Edit

Object swap:

```text
Replace only the white chairs with wooden chairs. Preserve camera angle,
lighting, floor shadows, and all surrounding objects.
```

Lighting change:

```text
Make it a winter evening with gentle snowfall. Change only lighting,
atmosphere, and weather. Keep geometry, pose, and composition unchanged.
```

Background extraction:

```text
Isolate the product on a clean transparent background. Crisp silhouette,
no halos or fringing, preserve the label text exactly, no restyling.
```

Style transfer:

```text
Apply the visual style of image 1 to a man riding a motorcycle on a plain
white backdrop. Keep its palette, texture, and brushwork. No extra elements.
```

Compositing:

```text
Place the subject from image 2 next to the person in image 1. Match
lighting, perspective, and scale. Keep the base framing unchanged.
```
