let selectedFile = null;
let selectedFilter = null;
let inputSignalLoaded = false;

function selectFilter(filter) {
    selectedFilter = filter;
    appendToTerminal('Selected filter: ' + selectedFilter);
}

function appendToTerminal(message) {
    $('.terminal').show();
    $('#terminal-content').append(message + '\n');
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

$('#runTesterForm').on('submit', function(event) {
    event.preventDefault();
    $.ajax({
        type: 'POST',
        url: '/start_dsp_tester',
        data: $(this).serialize(),
        success: function(response) {
            appendToTerminal(response.message);
        },
        error: function(xhr) {
            appendToTerminal('Error occurred: ' + xhr.responseText);
        }
    });
});

$('#runDspControllerForm').on('submit', function(event) {
    event.preventDefault();
    $('.dsp-controller').show();

    loadSVG('inputSignalGraph', 'data/empty_plot.svg');
    loadSVG('filteredSignalGraph', 'data/empty_plot.svg');

    $(this).trigger('reset');
});

$('#fileInput').on('change', function() {
    selectedFile = $(this)[0].files[0];
    appendToTerminal('Selected file: ' + selectedFile.name);
});

$('#uploadForm').on('submit', function(event) {
    event.preventDefault();

    const formData = new FormData(this);

    if (selectedFile) {
        formData.append('file', selectedFile);
    }

    $.ajax({
        type: 'POST',
        url: '/upload_data',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            alert(response.message);
        },
        error: function(xhr) {
            alert('Error: ' + xhr.responseJSON.message);
        }
    });
});

$('#loadSignalForm').on('submit', function(event) {
    event.preventDefault();

    $.ajax({
        type: 'POST',
        url: '/load_input_signal',
        data: $(this).serialize(),
        success: function(response) {
            appendToTerminal(response.message);
            loadSVG('inputSignalGraph', 'data/input_signal.svg');
        },
        error: function(xhr) {
            appendToTerminal('Error occurred: ' + xhr.responseJSON.message);
        }
    });
    inputSignalLoaded = true;

    $(this).trigger('reset');
});

$('#startProcessingForm').on('submit', function(event) {
    event.preventDefault();

    if (inputSignalLoaded) {
        const formData = new FormData(this);

        if (selectedFilter) {
            formData.append('selected_filter', selectedFilter);
        } else {
            appendToTerminal('No filter type selected');
        }

        $.ajax({
            type: 'POST',
            url: '/start_dsp_controller',
            data: formData,
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

    $(this).trigger('reset');
});
