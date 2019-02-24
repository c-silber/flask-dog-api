from flask import Flask, request
from flask_restplus import Resource, Api, fields, reqparse
import resources
import s3
from error import _error

app = Flask(__name__)
api = Api(app, version='1.0', title='Dog Breed API')

dogSchema = api.model('dogSchema', {
    'imagePath': fields.Url('image_path')
})

@api.route('/getDogBreed', methods=['POST'])
class Crowd(Resource):
    @api.expect(dogSchema)
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument('imagePath', required=True, help="URL cannot be blank")
        args = parser.parse_args()

        inputrequest = args['imagePath']
        if (len(inputrequest)) != 0:
            filename = inputrequest.split("/")[-1]

            saveFile = s3.getImage(filename)
            if (saveFile == 200):
                print("file: " + filename)
                check = resources.run("s3_images/" + filename)
                return check
            elif(saveFile == 404):
                return _error(404, 'The object does not exist')
            else:
                return _error(500, 'Error downloading image')
        else:
            return _error(500, 'URL cannot be null')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
