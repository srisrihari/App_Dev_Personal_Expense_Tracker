from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np

def create_gradient_background(width, height):
    # Create a gradient background
    base = Image.new('RGB', (width, height), (106, 90, 224))  # Base color
    top_color = (167, 139, 250)  # Lighter purple
    
    for y in range(height):
        # Interpolate between base and top color
        r = int(base.getpixel((0, 0))[0] + (top_color[0] - base.getpixel((0, 0))[0]) * y / height)
        g = int(base.getpixel((0, 0))[1] + (top_color[1] - base.getpixel((0, 0))[1]) * y / height)
        b = int(base.getpixel((0, 0))[2] + (top_color[2] - base.getpixel((0, 0))[2]) * y / height)
        
        for x in range(width):
            base.putpixel((x, y), (r, g, b))
    
    return base

def create_logo(width=500, height=500):
    # Create gradient background
    logo = create_gradient_background(width, height)
    draw = ImageDraw.Draw(logo)
    
    # Add shadow effect
    shadow = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    
    # Try to use a system font, fallback to default
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 250)
    except IOError:
        font = ImageFont.load_default()
    
    # Draw text shadow
    shadow_draw.text((width//2, height//2), "CB", font=font, fill=(0,0,0,100), anchor="mm")
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    
    # Combine shadow with main image
    logo = Image.alpha_composite(logo.convert("RGBA"), shadow)
    draw = ImageDraw.Draw(logo)
    
    # Draw text
    draw.text((width//2, height//2), "CB", font=font, fill=(255,255,255,255), anchor="mm")
    
    # Save the logo
    logo.convert("RGB").save("/home/srihari/Documents/Projects/App Dev/chillbills/assets/logo.png")
    print("Logo generated successfully!")

if __name__ == "__main__":
    create_logo()
