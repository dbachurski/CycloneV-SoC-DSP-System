from django.shortcuts import render
from django.http import JsonResponse, Http404, FileResponse
from .read_wav import save_wav_data_as_plot
from .generate_fir_coefficients import *
import subprocess
import os
import json

BASE_PATH = '/usr/bin/dsp'
DSP_TESTER_LOG = '/tmp/dsp-tester.log'
LED_CONTROL_LOG = '/tmp/led-control.log'
DSP_CONTROLLER_LOG = '/tmp/dsp-controller.log'
INPUT_DATA_FILE_PATH = BASE_PATH + '/data'
OUTPUT_DATA_FILE_PATH = BASE_PATH + '/output'
OUTPUT_WAV_FILE_PATH = BASE_PATH + '/output/processed_signal.wav'
DSP_CONTROLLER_SCRIPT_PATH = BASE_PATH + '/apps/dsp-controller'
DSP_TESTER_SCRIPT_PATH = BASE_PATH + '/apps/dsp-tester'
LED_CONTROL_SCRIPT_PATH = BASE_PATH + '/apps/led-control'
TEMP_PATH = os.path.join(os.getcwd(), 'temp/output')

sampling_rate = None
input_signal_path = None

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
            file_path = os.path.join(INPUT_DATA_FILE_PATH, uploaded_file.name)
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
    data_path = os.path.join(os.getcwd(), filename)
    if os.path.exists(data_path):
        return FileResponse(open(data_path, 'rb'), content_type='image/svg+xml')

    data_path = BASE_PATH + '/' + filename
    if os.path.exists(data_path):
        return FileResponse(open(data_path, 'rb'), content_type='image/svg+xml')


    raise Http404(f"File does not exist: {filename}")

def load_input_signal(request):
    global input_signal_path
    global sampling_rate

    input_signal_path = request.POST['selected_wav_file']

    if 'output/processed_signal' in input_signal_path:
        try:
            copy_result = copy_signal()

            if copy_result['status'] == 'error':
                return JsonResponse({'message': copy_result['message']}, status=500)

            sampling_rate = save_wav_data_as_plot(input_signal_path)
            return JsonResponse({'message': 'Input signal loaded successfully', 'sampling_rate': sampling_rate})

        except Exception as e:
            return JsonResponse({'message': f'Error while copying signal: {str(e)}'}, status=500)

    if not os.path.exists(input_signal_path):
        return JsonResponse({'message': 'Select or upload input signal WAV file'}, status=404)

    sampling_rate = save_wav_data_as_plot(input_signal_path)
    return JsonResponse({'message': 'Input signal loaded successfully', 'sampling_rate': sampling_rate})

def get_fir_coefficients(request):
    global sampling_rate
    if sampling_rate is None:
        return JsonResponse({'message': 'Please load an input signal to set the sampling rate.'}, status=400)

    filter_type = request.POST.get('selected_filter')
    if filter_type not in ['low-pass', 'high-pass', 'band-pass']:
        return JsonResponse({'message': 'Invalid filter type.'}, status=400)

    lower_cutoff = float(request.POST.get('lower_cutoff_frequency', 0))
    higher_cutoff = float(request.POST.get('higher_cutoff_frequency', 0))

    if lower_cutoff < 0 or higher_cutoff > (sampling_rate / 2) or (filter_type == 'band-pass' and lower_cutoff >= higher_cutoff):
        return JsonResponse({'message': 'Invalid cutoff frequencies.'}, status=400)

    if filter_type == 'low-pass':
        fir_coefficients = generate_lowpass_coefficients(lower_cutoff, sampling_rate)
    elif filter_type == 'high-pass':
        fir_coefficients = generate_highpass_coefficients(higher_cutoff, sampling_rate)
    else:
        fir_coefficients = generate_bandpass_coefficients(lower_cutoff, higher_cutoff, sampling_rate)

    if save_fir_coefficients(fir_coefficients):
        return JsonResponse({'message': 'FIR coefficients successfully generated and saved.'})
    else:
        return JsonResponse({'message': 'Error occurred while saving FIR coefficients.'}, status=500)

def start_dsp_controller(request):
    global input_signal_path
    if request.method == 'POST' and 'processing_type' in request.POST:
        processing_type = request.POST['processing_type']
        print("Processing type:", processing_type)
        coefficients_file_path = None
        if processing_type == 'fir':
            if 'selected_filter' in request.POST:
                coefficients_file_path = BASE_PATH + '/data/' + request.POST['selected_filter'] + '.txt'
            else:
                return JsonResponse({'message': 'No filter type selected.'}, status=400)

        dsp_args = [input_signal_path, processing_type]
        if coefficients_file_path:
            dsp_args.append(coefficients_file_path)

        return_code, log_content = run_subprocess(DSP_CONTROLLER_SCRIPT_PATH, dsp_args, DSP_CONTROLLER_LOG)

        if return_code != 0:
            return JsonResponse({'message': f"Error in DSP Controller. Return code: {return_code}<br>{log_content}"}, status=500)

        save_wav_data_as_plot(OUTPUT_WAV_FILE_PATH)

        return JsonResponse({'message': log_content}, status=200)

    return JsonResponse({'message': 'Processing type not provided.'}, status=400)

def get_input_files(request):
    try:
        os.makedirs(TEMP_PATH, exist_ok=True)

        dir_paths = [INPUT_DATA_FILE_PATH, TEMP_PATH]
        wav_files = []

        for path in dir_paths:
            files = os.listdir(path)
            for f in files:
                file_path = os.path.join(path, f)
                if os.path.isfile(file_path) and f.endswith('.wav'):
                    wav_files.append({
                        'filename': f,
                        'full_path': file_path
                    })

        return JsonResponse({'files': wav_files})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def copy_signal():
    global input_signal_path
    source_path = OUTPUT_WAV_FILE_PATH
    destination_dir = TEMP_PATH
    destination_path = os.path.join(destination_dir, 'processed_signal.wav')

    input_signal_path = destination_path

    try:
        if not os.path.exists(source_path):
            return {'status': 'error', 'message': f'Signal to copy "{source_path}" does not exist.'}

        os.makedirs(destination_dir, exist_ok=True)

        with open(source_path, 'rb') as source_file:
            with open(destination_path, 'wb') as destination_file:
                destination_file.write(source_file.read())

        return {'status': 'success', 'message': f'Signal "{source_path}" was copied to "{destination_path}".'}

    except Exception as e:
        return {'status': 'error', 'message': f'Error occurred: {str(e)}'}