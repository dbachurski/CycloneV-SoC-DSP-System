let selectedFile = null;
let selectedFilter = null;
let cutoffFrequency = null;
let selectedWavFile = null;
let svgFilePath = null;
let inputSignalLoaded = false;
let processedSignalLoaded = false
let dftInputGraphLoaded = false;
let dftOutputGraphLoaded = false;
let svgProcessedSignalFilePath = 'output/processed_signal.svg'
let svgProcessedSignalFilePathDft = 'output/processed_signal_dft.svg'
let svgTempProcessedSignalFilePath = 'temp/output/processed_signal.svg'
let svgTempProcessedSignalFilePathDft = 'temp/output/processed_signal_dft.svg'

function getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content');
}

function selectFilter(filter) {
    const filterType = filter.split('-')[0];

    if (filterType === 'low' || filterType === 'high' || filterType === 'band') {
        showOverlay(`.${filter}-settings`);
        selectedFilter = 'filter';
    } else {
        selectedFilter = filter;
        appendToTerminal('Selected filter: ' + selectedFilter);
    }
}

function showOverlay(element) {
    const maxZIndex = Math.max(
        ...$('.dsp-controller, .terminal, .control-panel, .low-pass-settings, .dsp-controller-file-selection')
            .map(function() {
                return parseInt($(this).css('z-index')) || 0;
            })
            .get()
    );

    $('#overlay').css('z-index', maxZIndex + 1).show();
    $(element).css('z-index', maxZIndex + 2).show();
}

function appendToTerminal(message) {
    $('.terminal').show();
    $('#terminal-content').append(message + '\n');
}

function runDspController() {
    $('.dsp-controller').show();
    loadSVG('inputSignalGraph', 'data/empty_plot.svg');
    loadSVG('processedSignalGraph', 'data/empty_plot.svg');
}

function loadSVG(containerId, filename) {
    $.get('/svg/' + filename, function(data) {
        const container = document.getElementById(containerId);
        try {
            container.innerHTML = '';

            if (data instanceof XMLDocument) {
                const serializer = new XMLSerializer();
                data = serializer.serializeToString(data);
            }

            const svg = new DOMParser().parseFromString(data, 'image/svg+xml').documentElement;
            svg.setAttribute('viewBox', '0 0 864 432');
            container.appendChild(svg);

            const figureElement = svg.querySelector('#figure_1');
            const scaleFactor = 0.85;
            const bbox = figureElement.getBBox();

            const translateX = (864 - bbox.width * scaleFactor) / 2 - bbox.x * scaleFactor;
            const translateY = (432 - bbox.height * scaleFactor) / 2 - bbox.y * scaleFactor;

            figureElement.setAttribute('transform', `translate(${translateX}, ${translateY}) scale(${scaleFactor})`);
        } catch (error) {
            appendToTerminal('Error inserting SVG: ' + error);
        }
    }).fail(function() {
        appendToTerminal('Error loading SVG: ' + filename);
    });
}

function saveFilterSettings(filterType, lowerCutoff = null, higherCutoff = null) {
    $('.overlay').hide();
    $(`.${filterType}-settings`).hide();

    appendToTerminal('Selected filter: ' + filterType);

    const formData = new FormData();
    formData.append('selected_filter', filterType);

    if (filterType === 'low-pass') {
        appendToTerminal('Cutoff Frequency: ' + lowerCutoff);
        formData.append('lower_cutoff_frequency', lowerCutoff);
    } else if (filterType === 'high-pass') {
        appendToTerminal('Cutoff Frequency: ' + higherCutoff);
        formData.append('higher_cutoff_frequency', higherCutoff);
    } else if (filterType === 'band-pass') {
        appendToTerminal('Lower Cutoff Frequency: ' + lowerCutoff);
        appendToTerminal('Higher Cutoff Frequency: ' + higherCutoff);
        formData.append('lower_cutoff_frequency', lowerCutoff);
        formData.append('higher_cutoff_frequency', higherCutoff);
    }

    $.ajax({
        type: 'POST',
        url: '/get_fir_coefficients',
        data: formData,
        headers: {
            'X-CSRFToken': getCsrfToken()
        },
        processData: false,
        contentType: false,
        success: function (response) {
            appendToTerminal(response.message);
        },
        error: function (xhr) {
            console.log(xhr.responseText);
            appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
        }
    });
}

function runDspTester() {
    $.ajax({
        type: 'POST',
        url: '/start_dsp_tester',
        headers: {
            'X-CSRFToken': getCsrfToken()
        },
        success: function(response) {
            appendToTerminal(response.message);
        },
        error: function(xhr) {
            appendToTerminal('Error occurred: ' + xhr.responseText);
        }
    });
}

function startDspProcessing(processingType) {
    if (inputSignalLoaded) {
        const formData = new FormData();

        formData.append('processing_type', processingType);

        if (processingType === 'fir') {
            if (selectedFilter) {
                formData.append('selected_filter', selectedFilter);
            } else {
                appendToTerminal('No filter type selected');
                return;
            }
        }

        $.ajax({
            type: 'POST',
            url: '/start_dsp_controller',
            data: formData,
            headers: {
                'X-CSRFToken': getCsrfToken()
            },
            processData: false,
            contentType: false,
            success: function(response) {
                appendToTerminal(response.message);
                loadSVG('processedSignalGraph', svgProcessedSignalFilePath);
                processedSignalLoaded = true
            },
            error: function(xhr) {
                appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
            }
        });
    } else {
        alert('Load input signal');
    }
}

$(document).ready(function() {
    $('#runTesterBtn').on('click', function() {
        runDspTester();
    });

    $('#runDspControllerBtn').on('click', function() {
        runDspController();
    });

    $('#saveLowPassSettingsBtn').on('click', function () {
        const lowerCutoffFrequency = $('#cutoffFrequency').val();
        saveFilterSettings('low-pass', lowerCutoffFrequency);
    });

    $('#saveHighPassSettingsBtn').on('click', function () {
        const higherCutoffFrequency = $('#highPassCutoffFrequency').val();
        saveFilterSettings('high-pass', null, higherCutoffFrequency);
    });

    $('#saveBandPassSettingsBtn').on('click', function () {
        const lowerCutoffFrequency = $('#bandPassLowerCutoffFrequency').val();
        const higherCutoffFrequency = $('#bandPassUpperCutoffFrequency').val();
        saveFilterSettings('band-pass', lowerCutoffFrequency, higherCutoffFrequency);
    });

    $('#fileInput').on('change', function() {
        const formData = new FormData();
        const selectedFile = this.files[0];

        if (selectedFile) {
            formData.append('file', selectedFile);

            $.ajax({
                type: 'POST',
                url: '/upload_data',
                data: formData,
                headers: {
                    'X-CSRFToken': getCsrfToken()
                },
                processData: false,
                contentType: false,
                success: function(response) {
                    alert(response.message);
                },
                error: function(xhr) {
                    alert('Error: ' + xhr.responseJSON.message);
                }
            });
        } else {
            alert('No file selected.');
        }
    });

    $('#selectSignalBtn').on('click', function() {
        $.ajax({
            type: 'GET',
            url: '/get_input_files',
            success: function(response) {
                $('#fileList').empty();
                response.files.forEach(function(file) {
                    $('#fileList').append('<li class="file-item" data-file="' + file.full_path + '">' + file.filename + '</li>');
                });
                showOverlay('.dsp-controller-file-selection');
            },
            error: function(xhr) {
                appendToTerminal('Error loading file list: ' + xhr.responseJSON.error);
            }
        });
    });

    $('#reload').on('click', function() {
        const formData = new FormData();
        formData.append('selected_wav_file', selectedWavFile);

        $.ajax({
            type: 'POST',
            url: '/load_input_signal',
            data: formData,
            headers: {
                'X-CSRFToken': getCsrfToken()
            },
            processData: false,
            contentType: false,
            success: function(response) {
                appendToTerminal(response.message);
                loadSVG('inputSignalGraph', svgFilePath);
            },
            error: function(xhr) {
                appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
            }
        });
    });

    $(document).on('click', '.file-item', function() {
        const clickedItem = $(this);

        selectedWavFile = clickedItem.data('file');
        appendToTerminal('Selected file: ' + selectedWavFile);

        $('.overlay').hide();
        $('.dsp-controller-file-selection').hide();

        svgFilePath = selectedWavFile.replace('.wav', '.svg');

        const formData = new FormData();
        formData.append('selected_wav_file', selectedWavFile);

        $.ajax({
            type: 'POST',
            url: '/load_input_signal',
            data: formData,
            headers: {
                'X-CSRFToken': getCsrfToken()
            },
            processData: false,
            contentType: false,
            success: function(response) {
                appendToTerminal('Sampling frequency: ' + response.sampling_rate + 'Hz');
                appendToTerminal(response.message);
                loadSVG('inputSignalGraph', svgFilePath);
            },
            error: function(xhr) {
                appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
            }
        });
        inputSignalLoaded = true;
    });

    $('#startFirProcessingBtn').on('click', function() {
        startDspProcessing('fir');
    });

    $('#startEncryptionBtn').on('click', function() {
        startDspProcessing('encrypt');
    });

    $('#startDecryptionBtn').on('click', function() {
        startDspProcessing('decrypt');
    });

    $('#inputSignalGraph').on('click', function() {
        if (dftInputGraphLoaded) {
            loadSVG('inputSignalGraph', svgFilePath);
            dftInputGraphLoaded = false
        } else {
            if (inputSignalLoaded) {
                svgDftFilePath = svgFilePath.replace('.svg', '_dft.svg')
                loadSVG('inputSignalGraph', svgDftFilePath);
                dftInputGraphLoaded = true
            }
        }
    });

    $('#processedSignalGraph').on('click', function() {
        if (dftOutputGraphLoaded) {
            loadSVG('processedSignalGraph', svgProcessedSignalFilePath);
            dftOutputGraphLoaded = false
        } else {
            if (processedSignalLoaded) {
                loadSVG('processedSignalGraph', svgProcessedSignalFilePathDft);
                dftOutputGraphLoaded = true
            }
        }
    });

    $('#outputToInputBtn').on('click', function() {
        if (processedSignalLoaded) {
            const formData = new FormData();
            formData.append('selected_wav_file', 'output/processed_signal.wav');

            svgFilePath = svgTempProcessedSignalFilePath

            $.ajax({
                type: 'POST',
                url: '/load_input_signal',
                data: formData,
                headers: {
                    'X-CSRFToken': getCsrfToken()
                },
                processData: false,
                contentType: false,
                success: function(response) {
                    appendToTerminal(response.message);
                    loadSVG('inputSignalGraph', svgTempProcessedSignalFilePath);
                },
                error: function(xhr) {
                    appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
                }
            });
        }
    });
});