from flask import make_response
import json

def _error(status=500, message=None):
    error = {}
    error['code'] = status
    error['message'] = message
    resp = make_response(json.dumps(error), status)
    resp.headers['Content-Type'] = 'application/json'
    return resp
