from flask import Flask, request, jsonify
from PIL import Image
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import img_to_array
import numpy as np
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

model = load_model('skin_disease_model.h5')

with open('class_indices.json', 'r') as f:
    class_indices = json.load(f)
idx_to_label = {v: k for k, v in class_indices.items()}

with open('disease_info.json', 'r') as f:
    disease_info = json.load(f)

@app.route('/predict', methods=['POST'])
def predict():
    print("Predict API called")  # ✅ Add this
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400

    try:
        # Preprocess image
        image = Image.open(file.stream).convert("RGB").resize((224, 224))
        image = img_to_array(image) / 255.0
        image = np.expand_dims(image, axis=0)

        # Prediction
        print("Starting prediction...")
        preds = model.predict(image)[0]
        print("Prediction done")
        predicted_idx = np.argmax(preds)
        confidence = float(preds[predicted_idx])
        predicted_label = idx_to_label[predicted_idx]

        # Default fallback
        
        formatted_info = "No detailed information available for this disease."
        info = {}


        # Get disease info if available
        if predicted_idx < len(disease_info):
            info = disease_info[predicted_idx]
            formatted_info = (
                f"🩺 Disease Name: {info.get('name', 'N/A')}\n\n"
                f"📝 Description:\n{info.get('description', 'N/A')}\n\n"
                f"⚠️ Precautions:\n{info.get('precautions', 'N/A')}\n\n"
                f"💊 Recommended Medicines:\n{info.get('medicines', 'N/A')}"
            )

        return jsonify({
            'prediction': predicted_label,
            'confidence': round(confidence, 4),
            'disease_info': formatted_info,
            'raw_info': info  
        })
    


    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
