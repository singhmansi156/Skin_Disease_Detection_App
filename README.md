# Skin_Disease_Detection_App

1. Project Description 
The Skin Disease Detection App is a mobile application that uses deep learning to identify various skin diseases from images. The app allows users to    upload an image of an affected skin area, predicts the disease type using a pre-trained MobileNetV2 model, and displays detailed information including symptoms and recommended precautions. The app leverages a Flask backend to serve predictions via a REST API.

2. Features 
   - Real-time skin disease classification  
   - Upload image functionality  
   - Displays disease name, symptoms, and precautions  
   - Integrated MobileNetV2 TensorFlow model  
   - REST API backend for image processing and prediction  
   - Lightweight and responsive UI using Flutter

3. Hardware Requirements 
   - Smartphone or computer  
   - Internet connection (for real-time API calls)  
   - Server or local machine to run the Flask backend

4. Software Requirements 
   - Operating System: Windows / Linux / macOS  
   - Frontend Framework: Flutter  
   - Backend Framework: Flask (Python)  
   - Machine Learning: TensorFlow  
   - Programming Languages: Dart, Python  
   - Libraries:  
     - Flutter: `http`, `image_picker`
     - Python: `Flask`, `TensorFlow`, `Pillow`, `Flask-CORS`  
   - IDE: VS Code 

5. Installation & Setup Instructions

   Frontend (Flutter):
   1. Clone the repo and navigate to the `lib` folder.
   2. Run: `flutter pub get`
   3. Launch app: `flutter run -d chrome` or `flutter run` (for mobile)

   Backend (Flask):
   1. Navigate to the `backend` directory.
   2. Run: `pip install -r requirements.txt`
   3. Launch server: `python app.py`

   Model:
   1. Ensure `model.h5` is in the correct path in your backend.
   2. Flask will load this model for prediction on image upload.

6. License 
This app is made only for learning and project work. It is not meant to give medical advice or treatment. Please talk to a doctor for any skin problems.








