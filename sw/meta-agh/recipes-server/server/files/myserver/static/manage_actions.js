let selectedFile = null;
let selectedFilter = null;
let cutoffFrequency = null;
let inputSignalLoaded = false;

function getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content');
}

function selectFilter(filter) {
    if (filter === 'low_pass') {
        const maxZIndex = Math.max(
            ...$('.dsp-controller, .terminal, .control-panel, .low-pass-settings')
                .map(function() {
                    return parseInt($(this).css('z-index')) || 0;
                })
                .get()
        );

        $('#overlay').css('z-index', maxZIndex + 1).show();

        $('.low-pass-settings').css('z-index', maxZIndex + 2).show();
    } else {
        selectedFilter = filter;
        appendToTerminal('Selected filter: ' + selectedFilter);
    }
}

function appendToTerminal(message) {
    $('.terminal').show();
    $('#terminal-content').append(message + '\n');
}

function runDspController() {
    $('.dsp-controller').show();
    loadSVG('inputSignalGraph', 'data/empty_plot.svg');
    loadSVG('filteredSignalGraph', 'data/empty_plot.svg');
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

$(document).ready(function() {
    $('#runTesterBtn').on('click', function() {
        runDspTester();
    });

    $('#runDspControllerBtn').on('click', function() {
        runDspController();
    });

    $('#saveLowPassSettingsBtn').on('click', function() {
        cutoffFrequency = $('#cutoffFrequency').val();

        $('.overlay').hide();
        $('.low-pass-settings').hide();

        selectedFilter = 'low_pass';
        appendToTerminal('Selected filter: ' + selectedFilter);
        appendToTerminal('Cutoff Frequency: ' + cutoffFrequency);

        const formData = new FormData();
        formData.append('selected_filter', selectedFilter);
        formData.append('cutoff_frequency', cutoffFrequency);

        $.ajax({
            type: 'POST',
            url: '/get_fir_coefficients',
            data: formData,
            headers: {
                'X-CSRFToken': getCsrfToken()
            },
            processData: false,
            contentType: false,
            success: function(response) {
                appendToTerminal(response.message);
            },
            error: function(xhr) {
                console.log(xhr.responseText);
                appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
            }
        });
    });

    $('#uploadDataBtn').on('click', function() {
        const formData = new FormData();
        const selectedFile = $('#fileInput')[0].files[0];

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

    $('#loadSignalBtn').on('click', function() {
        $.ajax({
            type: 'POST',
            url: '/load_input_signal',
            headers: {
                'X-CSRFToken': getCsrfToken()
            },
            success: function(response) {
                appendToTerminal(response.message);
                loadSVG('inputSignalGraph', 'data/input_signal.svg');
            },
            error: function(xhr) {
                appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
            }
        });
        inputSignalLoaded = true;
    });

    $('#startProcessingBtn').on('click', function() {
        if (inputSignalLoaded) {
            const formData = new FormData();

            if (selectedFilter) {
                formData.append('selected_filter', selectedFilter);
            } else {
                appendToTerminal('No filter type selected');
                return;
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
                    loadSVG('filteredSignalGraph', 'output/filtered_signal.svg');
                },
                error: function(xhr) {
                    appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
                }
            });
        } else {
            alert('Load input signal');
        }
    });
});