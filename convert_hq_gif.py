import cv2
from PIL import Image
import os

def mp4_to_hq_gif(input_path, output_path, crop_bottom_pct=0.10):
    """Convert MP4 to high quality GIF, keeping original FPS and resolution."""
    cap = cv2.VideoCapture(input_path)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    crop_h = int(h * (1 - crop_bottom_pct))
    
    print(f"  Source: {w}x{h} @ {fps}fps")
    print(f"  Output: {w}x{crop_h} (full res, watermark cropped)")
    
    # Use every other frame to keep file size reasonable (12fps)
    frame_skip = 2
    target_fps = fps / frame_skip
    duration_ms = int(1000 / target_fps)
    
    frames = []
    idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if idx % frame_skip == 0:
            cropped = frame[0:crop_h, :]
            rgb = cv2.cvtColor(cropped, cv2.COLOR_BGR2RGB)
            pil_img = Image.fromarray(rgb)
            frames.append(pil_img)
        idx += 1
    cap.release()
    
    print(f"  {len(frames)} frames @ {target_fps:.0f}fps, {duration_ms}ms/frame")
    
    # Save with high quality dithering
    frames[0].save(
        output_path,
        save_all=True,
        append_images=frames[1:],
        duration=duration_ms,
        loop=0,
        optimize=False,
    )
    
    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"  Saved: {output_path} ({size_mb:.1f} MB)")

if __name__ == "__main__":
    print("=== home.mp4 -> home_hq.gif ===")
    mp4_to_hq_gif('assets/animation/home.mp4', 'assets/animation/home_hq.gif')
    
    print("\n=== loop.mp4 -> loop_hq.gif ===")
    mp4_to_hq_gif('assets/animation/loop.mp4', 'assets/animation/loop_hq.gif')
    
    print("\nDone!")
