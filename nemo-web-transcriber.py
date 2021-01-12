#!/usr/bin/env python

# Complete hack script to run transcriptions through NVidia NeMo
# via a simple web API
#
# This will listen on port 5000 by default; to send an audio file:
# curl -s -F"file=@/path/to/file.wav" http://localhost:5000/
#
# The text will be returned without any formatting/container/etc.
#
# If you need to listen on something other than localhost, change
# the host entry (currently 127.0.0.1) to something else in app.run
# at the bottom of the file.

from nemo.utils import logging
from flask import Flask, flash, request, redirect, url_for
from werkzeug.utils import secure_filename
import os

logging.setLevel("ERROR")
logging.add_file_handler("/dev/null")

import nemo
import nemo.collections.asr as nemo_asr
import sys

quartznetnr = nemo_asr.models.EncDecCTCModel.from_pretrained(model_name="QuartzNet15x5NR-En")

app = Flask(__name__)

@app.route('/', methods=['GET','POST'])
def index():
    if request.method == 'POST':
        if 'file' not in request.files:
            flash('No file part')
            return "Need to upload a wav file as 'file'"
        file = request.files['file']
        if file.filename == '':
            flash('No selected file')
            return "Need to specify a filename."
        filename = secure_filename(file.filename)
        file.save(os.path.join('/var/tmp/', filename))
        files=[(os.path.join('/var/tmp/', filename))]
       
        for fname, transcription in zip(files, quartznetnr.transcribe(paths2audio_files=files)):
            if os.path.exists(os.path.join('/var/tmp/', filename)):
                os.remove(os.path.join('/var/tmp/', filename))
            return(transcription)


    return '''
    You gotta give us a filename.
    '''

if __name__ == '__main__':
    app.secret_key = 'some secret key'
    app.run(debug=True,host='127.0.0.1')
