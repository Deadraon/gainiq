import cv2
from PIL import Image
import os

def mp4_to_gif(input_path, output_path, target_fps=12, scale=0.5, crop_bottom_pct=0.10):
    """Convert MP4 to GIF, cropping watermark and optimizing size."""
    cap = cv2.VideoCapture(input_path)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Crop watermark from bottom
    crop_h = int(h * (1 - crop_bottom_pct))
    
    # Scale down
    new_w = int(w * scale)
    new_h = int(crop_h * scale)
    
    print(f"  Source: {w}x{h} @ {fps}fps, {total} frames")
    print(f"  Output: {new_w}x{new_h} @ {target_fps}fps (cropped + scaled)")
    
    # Calculate frame skip to match target fps
    frame_skip = max(1, int(fps / target_fps))
    
    frames = []
    idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if idx % frame_skip == 0:
            # Crop bottom
            cropped = frame[0:crop_h, :]
            # Scale
            resized = cv2.resize(cropped, (new_w, new_h))
            # Convert BGR to RGB
            rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
            pil_img = Image.fromarray(rgb)
            frames.append(pil_img)
        idx += 1
    cap.release()
    
    if not frames:
        print("  ERROR: No frames extracted!")
        return
    
    # Calculate duration per frame in ms
    duration_ms = int(1000 / target_fps)
    
    print(f"  Extracted {len(frames)} frames, duration per frame: {duration_ms}ms")
    
    # Save as GIF
    frames[0].save(
        output_path,
        save_all=True,
        append_images=frames[1:],
        duration=duration_ms,
        loop=0,  # 0 = infinite loop
        optimize=True,
    )
    
    size_kb = os.path.getsize(output_path) / 1024
    print(f"  Saved: {output_path} ({size_kb:.0f} KB)")

if __name__ == "__main__":
    print("Converting loop.mp4 -> loop.gif")
    mp4_to_gif(
        'assets/animation/loop.mp4',
        'assets/animation/loop.gif',
        target_fps=15,
        scale=0.5,
    )
    
    print("\nConverting home.mp4 -> home.gif")
    mp4_to_gif(
        'assets/animation/home.mp4',
        'assets/animation/home.gif',
        target_fps=15,
        scale=0.6,  # slightly higher quality for splash
    )
    
    print("\nDone!")
