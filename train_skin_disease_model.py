import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras import Model
from PIL import Image, UnidentifiedImageError, ImageFile
import os
import json

# Allow PIL to load truncated/corrupt images without crashing
ImageFile.LOAD_TRUNCATED_IMAGES = True

# Change this path to your actual dataset structure
TRAIN_DIR = r"D:\Mansi\skin_detection_app\skin_detection_dataset\Diseases\Train"
VALID_DIR = r"D:\Mansi\skin_detection_app\skin_detection_dataset\Diseases\Validation"

# Step 1: Remove corrupted images (run once)
def remove_corrupted_images(folder):
    for root, _, files in os.walk(folder):
        for fname in files:
            fpath = os.path.join(root, fname)
            try:
                img = Image.open(fpath)
                img.verify()
            except (IOError, SyntaxError, UnidentifiedImageError, OSError):
                print(f"Removed corrupted image: {fpath}")
                os.remove(fpath)

print("Checking for corrupted images...")
remove_corrupted_images(TRAIN_DIR)
remove_corrupted_images(VALID_DIR)
print("Done cleaning.")

# Step 2: Data Generators
train_datagen = ImageDataGenerator(
    rescale=1./255,
    horizontal_flip=True,
    zoom_range=0.2,
    rotation_range=20
)

valid_datagen = ImageDataGenerator(rescale=1./255)

train_generator = train_datagen.flow_from_directory(
    TRAIN_DIR,
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical'
)

validation_generator = valid_datagen.flow_from_directory(
    VALID_DIR,
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical'
)

# Step 3: MobileNetV2 Model
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
base_model.trainable = False  # Freeze base model

x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
predictions = Dense(train_generator.num_classes, activation='softmax')(x)

model = Model(inputs=base_model.input, outputs=predictions)

# Step 4: Compile
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Step 5: Train
model.fit(
    train_generator,
    validation_data=validation_generator,
    epochs=10
)

# Step 6: Save the model
model.save("skin_disease_model.h5")

# Step 7: Save class indices
with open('class_indices.json', 'w') as f:
    json.dump(train_generator.class_indices, f)

print("class_indices.json saved!")
