# This script resizes an image to a new width while maintaining the aspect ratio
# and saves the resized image to a new file.

from PIL import Image
import os

# Open the original image
img = Image.open('assets/images/app_image.png')
print(f'Original size: {img.size}')

# Calculate new size maintaining aspect ratio
original_width, original_height = img.size
target_width = 1920
target_height = int((target_width * original_height) / original_width)

print(f'New size: {target_width}x{target_height}')

# Resize the image
resized_img = img.resize((target_width, target_height), Image.Resampling.LANCZOS)

# Save the resized image
resized_img.save('assets/images/app_image_resized.png', 'PNG', optimize=True)

# Check file sizes
original_size = os.path.getsize('assets/images/app_image.png')
new_size = os.path.getsize('assets/images/app_image_resized.png')

print(f'Original file size: {original_size / (1024*1024):.1f} MB')
print(f'New file size: {new_size / (1024*1024):.1f} MB')
print(f'Size reduction: {((original_size - new_size) / original_size) * 100:.1f}%') 
