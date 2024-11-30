function getLedColor(led) {
    if (led.classList.contains('led-red')) return 'rgb(255, 0, 0)';
    if (led.classList.contains('led-blue')) return 'rgb(0, 0, 255)';
    if (led.classList.contains('led-green')) return 'rgb(0, 255, 0)';
    if (led.classList.contains('led-yellow')) return 'rgb(255, 255, 0)';
}

function toggleLed(led) {
    if (led.dataset.ledEnable === 'true') {
        led.style.fill = led.dataset.originalColor;
        led.dataset.ledEnable = 'false';
    } else {
        const newColor = getLedColor(led);
        led.style.fill = newColor;
        led.dataset.ledEnable = 'true';
    }
}

function sendLedState(ledId, ledState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    return fetch('/led_toggle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken
        },
        body: JSON.stringify({ led_id: ledId, led_state: ledState })
    })
    .then(response => response.json());
}

function handleServerResponse(data) {
    if (data.message) {
        const terminalContent = document.getElementById('terminal-content');
        $('.terminal').show();
        terminalContent.textContent += data.message;
    } else {
        console.error('Error updating LED state:', data.message);
    }
}

function handleLedClick(event) {
    const led = event.currentTarget;
    const ledId = led.id;

    toggleLed(led);

    sendLedState(ledId, led.dataset.ledEnable)
    .then(handleServerResponse)
    .catch(error => console.error('Fetch error:', error));
}

document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll('.led').forEach(led => {
        led.dataset.originalColor = window.getComputedStyle(led).fill;
        led.addEventListener('click', handleLedClick);
    });
});