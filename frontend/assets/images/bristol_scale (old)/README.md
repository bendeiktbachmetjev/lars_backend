# Bristol Scale Images

This directory contains images for the Bristol Stool Scale (1-7).

## Required Images

You need to add the following PNG images:
- `bristol_1.png` - Type 1: Separate hard lumps
- `bristol_2.png` - Type 2: Sausage-like but lumpy
- `bristol_3.png` - Type 3: Sausage-like with cracks
- `bristol_4.png` - Type 4: Sausage-like, smooth and soft
- `bristol_5.png` - Type 5: Soft blobs with clear-cut edges
- `bristol_6.png` - Type 6: Mushy consistency with ragged edges
- `bristol_7.png` - Type 7: Entirely liquid

## Image Specifications

- **Format**: PNG (transparent background recommended)
- **Size**: 120x80 pixels (for optimal display)
- **Aspect Ratio**: 3:2 (width:height)
- **Background**: Transparent or white
- **Style**: Medical/clinical illustrations

## How to Add Images

1. Generate images using ChatGPT or any image generation tool
2. Save them as PNG files with the naming convention above
3. Place them in this directory
4. Run `flutter pub get` to update assets
5. Test the app to ensure images display correctly

## Fallback

If images are not found, the app will display placeholder icons instead. 