import cv2
import os

def get_video_info(path):
    cap = cv2.VideoCapture(path)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    cap.release()
    return w, h, fps, count

def crop_watermark(input_path, output_path, crop_bottom_pct=0.08):
    """Crop the bottom portion of video to remove Veo watermark"""
    cap = cv2.VideoCapture(input_path)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    # New height after cropping bottom watermark
    crop_pixels = int(h * crop_bottom_pct)
    new_h = h - crop_pixels
    
    print(f"  Original: {w}x{h} @ {fps}fps")
    print(f"  Cropping bottom {crop_pixels}px -> {w}x{new_h}")
    
    # Use mp4v codec for compatibility
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (w, new_h))
    
    frame_count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        # Crop: keep everything except the bottom
        cropped = frame[0:new_h, 0:w]
        out.write(cropped)
        frame_count += 1
    
    cap.release()
    out.release()
    print(f"  Written {frame_count} frames to {output_path}")

if __name__ == "__main__":
    videos = [
        ('assets/animation/loop.mp4', 'assets/animation/loop_clean.mp4'),
        ('assets/animation/home.mp4', 'assets/animation/home_clean.mp4'),
    ]
    
    for inp, outp in videos:
        print(f"\nProcessing: {inp}")
        w, h, fps, count = get_video_info(inp)
        print(f"  Info: {w}x{h}, {fps}fps, {count} frames")
        crop_watermark(inp, outp)
        
        # Verify output
        if os.path.exists(outp):
            w2, h2, fps2, count2 = get_video_info(outp)
            print(f"  Output: {w2}x{h2}, {fps2}fps, {count2} frames, {os.path.getsize(outp)} bytes")
        else:
            print(f"  ERROR: Output file not created!")
    
    print("\nDone!")
