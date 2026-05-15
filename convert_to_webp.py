import cv2
from PIL import Image
import numpy as np

def mp4_to_transparent_webp(input_path, output_path, target_fps=24, crop_bottom_pct=0.10, black_threshold=30):
    """Convert MP4 to animated WebP with transparent background (black removed)."""
    cap = cv2.VideoCapture(input_path)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Crop watermark from bottom
    crop_h = int(h * (1 - crop_bottom_pct))
    
    print(f"  Source: {w}x{h} @ {fps}fps, {total} frames")
    print(f"  Output: {w}x{crop_h} @ {target_fps}fps (watermark cropped, bg removed)")
    
    # Frame skip for target fps
    frame_skip = max(1, round(fps / target_fps))
    
    frames = []
    idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if idx % frame_skip == 0:
            # Crop bottom watermark
            cropped = frame[0:crop_h, :]
            
            # Convert BGR to RGBA
            rgb = cv2.cvtColor(cropped, cv2.COLOR_BGR2RGB)
            rgba = np.zeros((crop_h, w, 4), dtype=np.uint8)
            rgba[:, :, :3] = rgb
            
            # Remove black background: make dark pixels transparent
            # Use max of RGB channels as brightness
            brightness = np.max(rgb, axis=2)
            
            # Fully transparent where brightness < threshold
            # Smooth alpha transition for anti-aliasing at edges
            alpha = np.zeros_like(brightness, dtype=np.uint8)
            mask_opaque = brightness > black_threshold + 15
            mask_transition = (brightness > black_threshold) & (~mask_opaque)
            
            alpha[mask_opaque] = 255
            # Smooth transition zone
            alpha[mask_transition] = ((brightness[mask_transition].astype(float) - black_threshold) / 15 * 255).astype(np.uint8)
            
            rgba[:, :, 3] = alpha
            
            pil_img = Image.fromarray(rgba, 'RGBA')
            frames.append(pil_img)
        idx += 1
    cap.release()
    
    if not frames:
        print("  ERROR: No frames!")
        return
    
    duration_ms = int(1000 / target_fps)
    print(f"  {len(frames)} frames, {duration_ms}ms per frame")
    
    # Save as animated WebP with transparency
    frames[0].save(
        output_path,
        save_all=True,
        append_images=frames[1:],
        duration=duration_ms,
        loop=0,
        quality=85,
        method=4,
    )
    
    import os
    size_kb = os.path.getsize(output_path) / 1024
    print(f"  Saved: {output_path} ({size_kb:.0f} KB)")

if __name__ == "__main__":
    print("=== Converting loop.mp4 -> loop.webp (transparent, high quality) ===")
    mp4_to_transparent_webp(
        'assets/animation/loop.mp4',
        'assets/animation/loop.webp',
        target_fps=20,
        crop_bottom_pct=0.10,
        black_threshold=25,
    )
    
    print("\n=== Converting home.mp4 -> home.webp (transparent, high quality) ===")
    mp4_to_transparent_webp(
        'assets/animation/home.mp4',
        'assets/animation/home.webp',
        target_fps=20,
        crop_bottom_pct=0.10,
        black_threshold=25,
    )
    
    print("\nDone!")
