import cv2
from PIL import Image
import numpy as np
import os

def mp4_to_transparent_gif(input_path, output_path, crop_bottom_pct=0.10, black_threshold=30):
    """Convert MP4 to GIF with transparent background (black removed)."""
    cap = cv2.VideoCapture(input_path)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    crop_h = int(h * (1 - crop_bottom_pct))
    frame_skip = 2  # 12fps
    
    print(f"  Source: {w}x{h} @ {fps}fps")
    print(f"  Output: {w}x{crop_h} @ 12fps, transparent bg")
    
    frames = []
    idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if idx % frame_skip == 0:
            cropped = frame[0:crop_h, :]
            rgb = cv2.cvtColor(cropped, cv2.COLOR_BGR2RGB)
            
            # Create RGBA with transparency where black
            rgba = np.zeros((crop_h, w, 4), dtype=np.uint8)
            rgba[:, :, :3] = rgb
            
            brightness = np.max(rgb, axis=2)
            # Make dark pixels transparent
            rgba[:, :, 3] = np.where(brightness > black_threshold, 255, 0).astype(np.uint8)
            
            pil_img = Image.fromarray(rgba, 'RGBA')
            frames.append(pil_img)
        idx += 1
    cap.release()
    
    duration_ms = int(1000 / 12)
    print(f"  {len(frames)} frames, {duration_ms}ms/frame")
    
    # For GIF transparency, need to convert RGBA to P mode with transparency
    processed = []
    for f in frames:
        # Convert to palette mode with transparency
        alpha = f.getchannel('A')
        p_img = f.convert('RGB').convert('P', palette=Image.ADAPTIVE, colors=255)
        # Set transparent color index
        mask = Image.eval(alpha, lambda a: 255 if a <= 128 else 0)
        p_img.paste(255, mask)  # index 255 = transparent
        processed.append(p_img)
    
    processed[0].save(
        output_path,
        save_all=True,
        append_images=processed[1:],
        duration=duration_ms,
        loop=0,
        transparency=255,
        disposal=2,  # Clear frame before drawing next (important for transparency)
    )
    
    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"  Saved: {output_path} ({size_mb:.1f} MB)")

if __name__ == "__main__":
    print("=== home.mp4 -> home_transparent.gif ===")
    mp4_to_transparent_gif('assets/animation/home.mp4', 'assets/animation/home_transparent.gif')
    
    print("\n=== loop.mp4 -> loop_transparent.gif ===")
    mp4_to_transparent_gif('assets/animation/loop.mp4', 'assets/animation/loop_transparent.gif')
    
    print("\nDone!")
