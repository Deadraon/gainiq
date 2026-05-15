from PIL import Image

# Open the original icon
img = Image.open('assets/images/app_icon.png').convert("RGBA")
W, H = img.size  # 1024x1024

# ── Coordinates of the 45lb plate circle in the 1024x1024 image ──
# The plate center is approximately at (395, 540) with radius ~115px
cx, cy, r = 395, 535, 118
pad = 10  # small padding

# 1. Crop the plate region as a tight square
x0, y0 = cx - r - pad, cy - r - pad
x1, y1 = cx + r + pad, cy + r + pad
plate_crop = img.crop((x0, y0, x1, y1))

# 2. Make everything OUTSIDE the circle transparent so it spins cleanly
plate_rgba = plate_crop.copy()
pw, ph = plate_rgba.size
center_x, center_y = pw // 2, ph // 2
pixels = plate_rgba.load()
for y in range(ph):
    for x in range(pw):
        dist = ((x - center_x) ** 2 + (y - center_y) ** 2) ** 0.5
        if dist > r + pad - 4:
            pixels[x, y] = (0, 0, 0, 0)  # transparent outside circle

plate_rgba.save('assets/images/plate_only.png')
print(f"Plate saved: {plate_rgba.size}")

# 3. Erase the plate from the original logo → replace with transparency
logo_no_plate = img.copy()
pixels2 = logo_no_plate.load()
for y in range(H):
    for x in range(W):
        dist = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
        if dist <= r - 5:
            pixels2[x, y] = (0, 0, 0, 0)  # transparent hole

# remove the black background too
for y in range(H):
    for x in range(W):
        r2, g2, b2, a2 = pixels2[x, y]
        lum = max(r2, g2, b2)
        if lum <= 18:
            pixels2[x, y] = (0, 0, 0, 0)

logo_no_plate.save('assets/images/logo_no_plate.png')
print(f"Logo without plate saved: {logo_no_plate.size}")

# Also save the original transparent logo as fallback
img2 = img.copy()
px2 = img2.load()
for y in range(H):
    for x in range(W):
        r3, g3, b3, a3 = px2[x, y]
        if max(r3, g3, b3) <= 18:
            px2[x, y] = (0, 0, 0, 0)
img2.save('assets/images/app_logo_transparent.png')
print("Transparent logo updated.")
