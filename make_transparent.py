from PIL import Image

def make_transparent(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # Use max RGB channel as lightness indicator
            lum = max(r, g, b)
            
            # Threshold to avoid making dark parts of the actual logo transparent
            # The background is around 13 (0x0D)
            if lum <= 18:
                pixels[x, y] = (0, 0, 0, 0)
            else:
                # Smooth alpha blending to avoid black fringing
                # Map [18, 255] to [0, 255]
                alpha = int(min(255, max(0, (lum - 18) * 255 / (255 - 18))))
                
                if alpha > 0 and alpha < 255:
                    # Un-multiply the background darkness from the edges to keep them bright
                    factor = 255.0 / alpha
                    new_r = int(min(255, r * factor))
                    new_g = int(min(255, g * factor))
                    new_b = int(min(255, b * factor))
                    pixels[x, y] = (new_r, new_g, new_b, alpha)
                else:
                    pixels[x, y] = (r, g, b, alpha)

    img.save(output_path, "PNG")

if __name__ == "__main__":
    make_transparent('assets/images/app_icon.png', 'assets/images/app_logo_transparent.png')
