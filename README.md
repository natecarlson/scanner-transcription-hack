# scanner-transcription-hack
Quick documentation of my hacky setup for trunk-recorder, openmhz, and NVidia NeMo for scanner ASR.

This is a _REALLY_ rough guide; your mileage may vary, sorry for any type-o's.

# Requirements

* Documentation is based on Ubuntu, but should (basically) work with other distributions
* You'll need a few gigabytes of space in your home directory - for the Python venv and the models that NeMo downloads.
* Python 3.7 - 3.8 might also work.. PPA https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa has 3.7 for 20.04
* Working trunk-recorder install that isn't critically important to you (you break it, you buy it!)
* Install packages: `apt-get install jq python3.7-venv virtualenv python3.7 curl sox fdkaac libsndfile1 ffmpeg`

# Installing NeMo

Do something along the following lines to install NeMo, and fire up the transcription 'webapp' for a test run..
```
virtualenv -p /usr/bin/python3.7 ~/nemo-venv
. ~/nemo-venv/bin/activate
pip install Cython
pip install nemo_toolkit[asr]==1.0.0b3
pip install flask
python /path/to/nemo-web-transcriber.py
```

You should see a message like the following:
`100% [........................................................................] 71114495 / 71114495`
..that is NeMo downloading the specified model to your home directory. Then, you should see:
```
* Serving Flask app
"nemo-web-transcriber" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 268-098-986
```

At this point, you can switch to another window, and try submitting a wav file from trunk-recorder for transcription:
```
$ curl -s -F"file=@4996-1609290226_853225000.wav" http://localhost:5000/
yeah will ever something stuck it's pressure in it out you know i it not e to come back in
```

Yay, that's working. You can then hit ctrl-c on the window with the daemon listening, and run 'deactivate' to get out of the virtualenv. You'll need to get nemo-web-transcriber running in the background; to do that, I run something like:
```
screen -S nemo
<<within the screen session>>
. ~/nemo-venv/bin/activate
python /path/to/nemo-web-transcriber.py
<<ctrl-a-d to detach>>
```
..but you can do what you'd like.  :)

Then, you need to do something useful with it. See my upload script in the repo -- it automatically runs the recording through NeMo, and then uploads it to my OpenMHz fork through curl. If you want to try it yourself, you can see the changes I've made to OpenMHz on the 'mnscanner' branch here:
[https://github.com/natecarlson/trunk-server/tree/mnscanner-branch]

