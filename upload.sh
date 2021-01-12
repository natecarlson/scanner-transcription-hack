#!/bin/bash

# Hack script to run through transcription and upload to my branch of trunk-server/openmhz

basename="${2%.*}"
tg="$( echo $basename | awk -F'/' '{ print $NF }' | awk -F'-' '{ print $1 }' )"

# Run the call through the transcribe service
export transcripttext=`curl -s -F"file=@${basename}.wav" http://localhost:5000/`

# Add the transcription to the call json, called 'audiotranscript'
mv ${basename}.json ${basename}.json.orig
jq '. += {"audiotranscript": env.transcripttext}' ${basename}.json.orig > ${basename}.json

# Create a m4a, using the same command that trunk-recorder's built in uploader uses
sox ${basename}.wav -t wav - --norm=-3 | fdkaac --silent --ignorelength -b 8000 -o ${basename}.m4a -

# HACK HACK to upload manually to OpenMHz-compatible, including the transcript.
read freq start_time stop_time length talkgroup emergency srclist freqlisttmp audiotranscript < <(echo $(jq -c -r '.freq, .start_time, .stop_time, .stop_time - .start_time, .talkgroup, .emergency, .srcList, .freqList, .audiotranscript' ${basename}.json))

# _sigh_, need to rename error_count -> errors, spike_count -> spikes for openmhz to be happy.
freqlist=`echo ${freqlisttmp} | sed -e s/error_count/errors/g | sed -e s/spike_count/spikes/g`

# Transcription list for use with my openmhz hack branch
transcriptionlist="[{\"text\":\"${audiotranscript}\",\"time\":${start_time},\"pos\":0}]"

# Send to mnscanner branch
#curl -s https://api.mnscanner.com/<systemname>/upload \
#     -F "api_key=<key>" \
#     -F "call=@${basename}.m4a;type=application/octet-stream;filename=`basename ${basename}.m4a`" \
#     -F "freq=${freq}" \
#     -F "start_time=${start_time}" \
#     -F "stop_time=${stop_time}" \
#     -F "call_length=${length}" \
#     -F "talkgroup_num=${talkgroup}" \
#     -F "emergency=${emergency}" \
#     -F "source_list=${srclist}" \
#     -F "transcription_list=${transcriptionlist}" \
#     -F "freq_list=${freqlist}"


# If you want to upload to OpenMHz but replace srclist with the transcription..
transcriptionsrclist="[{\"src\":\"${audiotranscript}\",\"time\":${start_time},\"pos\":0,\"emergency\":0,\"signal_system\":\"p25\",\"tag\":\"\"}]"

# OpenMHz
#curl -s https://api.openmhz.com/<systemname>/upload \
#     -F "api_key=<key>" \
#     -F "call=@${basename}.m4a;type=application/octet-stream;filename=`basename ${basename}.m4a`" \
#     -F "freq=${freq}" \
#     -F "start_time=${start_time}" \
#     -F "stop_time=${stop_time}" \
#     -F "call_length=${length}" \
#     -F "talkgroup_num=${talkgroup}" \
#     -F "emergency=${emergency}" \
#     -F "source_list=${transcriptionsrclist}" \
#     -F "freq_list=${freqlist}"

# Kill the local copies of the files, if desired.
#rm -f ${basename}.*
