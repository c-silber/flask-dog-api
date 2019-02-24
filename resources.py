from keras.applications.resnet50 import preprocess_input, decode_predictions
from keras.preprocessing import image
from tqdm import tqdm
import numpy as np
from extract_bottleneck_features import *
from keras.layers import Conv2D, MaxPooling2D, GlobalAveragePooling2D
from keras.layers import Dropout, Flatten, Dense
from keras.models import Sequential
import ssl
import cv2
from glob import glob
from urllib import request
from keras.applications.resnet50 import ResNet50

def run(object):
    global ResNet50_model
    global face_cascade
    global model
    global dog_names

    ssl._create_default_https_context = ssl._create_unverified_context
    ResNet50_model = ResNet50(weights='imagenet')
    face_cascade = cv2.CascadeClassifier('haarcascades/haarcascade_frontalface_alt2.xml')
    dog_names = [item[20:-1] for item in sorted(glob("dogImages/train/*/"))]

    bottleneck_features = np.load('bottleneck_features/DogInceptionV3Data.npz')
    train_V3 = bottleneck_features['train']
    valid_V3 = bottleneck_features['valid']
    test_V3 = bottleneck_features['test']

    model = Sequential()
    model.add(GlobalAveragePooling2D(input_shape=train_V3.shape[1:]))
    model.add(Dense(133, activation='softmax'))
    model.load_weights('models/weights.best.V3.hdf5')
    return getDogBreed(object)

def InceptionV3Prediction(img_path):
    # extract bottleneck features
    bottleneck_feature = extract_InceptionV3(path_to_tensor(img_path))
    # obtain predicted vector
    predicted_vector = model.predict(bottleneck_feature)
    # return dog breed that is predicted by the model
    return dog_names[np.argmax(predicted_vector)]

def path_to_tensor(img_path):
    # loads RGB image as PIL.Image.Image type
    img = image.load_img(img_path, target_size=(224, 224))
    # convert PIL.Image.Image type to 3D tensor with shape (224, 224, 3)
    x = image.img_to_array(img)
    # convert 3D tensor to 4D tensor with shape (1, 224, 224, 3) and return 4D tensor
    return np.expand_dims(x, axis=0)

def paths_to_tensor(img_paths):
    list_of_tensors = [path_to_tensor(img_path) for img_path in tqdm(img_paths)]
    return np.vstack(list_of_tensors)

def ResNet50_predict_labels(img_path):
    # returns prediction vector for image located at img_path
    img = preprocess_input(path_to_tensor(img_path))
    return np.argmax(ResNet50_model.predict(img))

def dog_detector(img_path):
    prediction = ResNet50_predict_labels(img_path)
    return ((prediction <= 268) & (prediction >= 151))

def face_detector(img_path):
    img = cv2.imread(img_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray)
    return len(faces) > 0

def getDogBreed(imgPath):
    if dog_detector(imgPath) == 1:
        return { 'type' : 'dog', 'breed' : InceptionV3Prediction(imgPath) }
    elif face_detector(imgPath) == 1:
        return { 'type' : 'human', 'breed' : InceptionV3Prediction(imgPath) }
    else:
        return { 'type' : None, 'breed' : None }
