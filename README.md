# flask-dog-api

Simple flask API for dog breed classification. Given an image url, will return the dog breed.

## Installation

Clone the repository:
```bash
git clone https://github.com/c-silber/flask-dog-api.git
cd ~/flask-dog-api/src/
```

Install pip:

```bash
sudo apt-get install -y python3-pip
```

Install virtualenv:
```bash
pip3 install virtualenv
```

Create and activate virtualenv:
```bash
virtualenv venv
source ./venv/bin/activate
```

Install requirements:
```bash
pip install -r requirements.txt
```

Download the dogImages samples:
```bash
wget https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/dogImages.zip
unzip dogImages.zip
```

Download bottleneck_features:
```bash
mkdir bottleneck_features
cd bottleneck_features/
wget https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/DogInceptionV3Data.npz
cd ../
```

Setup env variables:
```bash
EXPORT S3_BUCKET = <your-s3-bucket-name>
EXPORT S3_KEY= <your-s3-key>
EXPORT S3_SECRET_ACCESS_KEY=<your-s3-access-key>
```
[Where do I get these?](https://supsystic.com/documentation/id-secret-access-key-amazon-s3/)

## Usage

```python
python wsgi.py
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
