from django.shortcuts import render
from django.http import JsonResponse, Http404, FileResponse
from .read_wav import save_wav_data_as_plot
from .generate_fir_coefficients import save_fir_coefficients, generate_lowpass_coefficients
import subprocess
import os
import json
import logging

BASE_PATH = '/usr/bin/dsp'
DSP_TESTER_LOG = '/tmp/dsp-tester.log'
LED_CONTROL_LOG = '/tmp/led-control.log'
DSP_CONTROLLER_LOG = '/tmp/dsp-controller.log'
INPUT_WAV_FILE_PATH = BASE_PATH + '/data/input_signal.wav'
OUTPUT_WAV_FILE_PATH = BASE_PATH + '/output/filtered_signal.wav'
DSP_CONTROLLER_SCRIPT_PATH = BASE_PATH + '/apps/dsp-controller'
DSP_TESTER_SCRIPT_PATH = BASE_PATH + '/apps/dsp-tester'
LED_CONTROL_SCRIPT_PATH = BASE_PATH + '/apps/led-control'

sampling_rate = None

def run_subprocess(script_path, args, log_path):
    with open(log_path, 'w') as log_file:
        process = subprocess.Popen(
            ['python3', script_path] + args,
            stdout=log_file,
            stderr=log_file,
            text=True,
            env={**os.environ, 'PYTHONUNBUFFERED': '1'}
        )
        return_code = process.wait()

    with open(log_path, 'r') as log_file:
        log_content = log_file.read()

    return return_code, log_content

def home(request):
    return render(request, 'home.html')

def start_dsp_tester(request):
    return_code, log_content = run_subprocess(DSP_TESTER_SCRIPT_PATH, [], DSP_TESTER_LOG)
    return JsonResponse({'message': log_content}, status=500 if return_code != 0 else 200)

def upload_data(request):
    if request.method == 'POST' and 'file' in request.FILES:
        uploaded_file = request.FILES['file']
        if not uploaded_file.name.endswith('.wav'):
            return JsonResponse({'message': 'Invalid file type. Only .wav files are allowed.'}, status=400)

        try:
            file_path = BASE_PATH + '/data/input_signal.wav'
            with open(file_path, 'wb+') as destination:
                for chunk in uploaded_file.chunks():
                    destination.write(chunk)
            return JsonResponse({'file_path': file_path, 'message': 'File uploaded and saved successfully!'})
        except Exception as e:
            return JsonResponse({'message': f'Error occurred while saving the file: {str(e)}'}, status=500)

    return JsonResponse({'message': 'No file uploaded or invalid request.'}, status=400)

def led_toggle(request):
    try:
        data = json.loads(request.body)
        led_id, led_state = data.get('led_id'), data.get('led_state')
    except json.JSONDecodeError:
        return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)

    return_code, log_content = run_subprocess(LED_CONTROL_SCRIPT_PATH, [led_id, led_state], LED_CONTROL_LOG)
    return JsonResponse({'message': log_content}, status=500 if return_code != 0 else 200)

def get_svg(request, filename):
    dsp_path = BASE_PATH + '/' + filename
    if os.path.exists(dsp_path):
        return FileResponse(open(dsp_path, 'rb'), content_type='image/svg+xml')

    current_directory_path = os.path.join(os.getcwd(), filename)
    if os.path.exists(current_directory_path):
        return FileResponse(open(current_directory_path, 'rb'), content_type='image/svg+xml')

    raise Http404(f"File does not exist: {filename}")

def load_input_signal(request):
    global sampling_rate
    if not os.path.exists(INPUT_WAV_FILE_PATH):
        return JsonResponse({'message': 'WAV file does not exist, upload input signal'}, status=404)

    sampling_rate = save_wav_data_as_plot(INPUT_WAV_FILE_PATH)
    return JsonResponse({'message': 'Input signal loaded successfully'})

def get_fir_coefficients(request):
    global sampling_rate
    if sampling_rate is None:
        return JsonResponse({'message': 'Please load an input signal to set the sampling rate.'}, status=400)

    cutoff_frequency = float(request.POST.get('cutoff_frequency'));

    if cutoff_frequency < 0 or cutoff_frequency > (sampling_rate / 2):
        return JsonResponse({'message': 'Cutoff frequency must be in the range [0, Nyquist Frequency].'}, status=400)

    fir_coefficients = generate_lowpass_coefficients(cutoff_frequency, sampling_rate)

    if save_fir_coefficients(fir_coefficients):
        return JsonResponse({'message': 'FIR coefficients successfully generated and saved.'})
    else:
        return JsonResponse({'message': 'Error occurred while saving FIR coefficients.'}, status=500)


def start_dsp_controller(request):
    if request.method == 'POST' and 'selected_filter' in request.POST:
        coefficients_file_path = BASE_PATH + '/data/' + request.POST['selected_filter'] + '.txt'
        if not os.path.exists(INPUT_WAV_FILE_PATH):
            return JsonResponse({'message': 'Input signal file not found.'}, status=404)

        return_code, log_content = run_subprocess(DSP_CONTROLLER_SCRIPT_PATH, [INPUT_WAV_FILE_PATH, coefficients_file_path], DSP_CONTROLLER_LOG)

        if return_code != 0:
            return JsonResponse({'message': f"Error in DSP Controller. Return code: {return_code}<br>{log_content}"}, status=500)

        save_wav_data_as_plot(OUTPUT_WAV_FILE_PATH)
        return JsonResponse({'message': log_content}, status=200)

    return JsonResponse({'message': 'No filter type selected.'}, status=400)
