document.addEventListener("DOMContentLoaded", () => {
    const closeButtons = document.querySelectorAll('.btn-red');

    closeButtons.forEach(button => {
        button.addEventListener('click', (event) => {
            const appContainer = event.target.closest('.terminal, .control-panel, .dsp-controller, .settings, .dsp-controller-file-selection');

            if (appContainer) {
                if (appContainer.classList.contains('terminal')) {
                    const terminalContent = document.getElementById('terminal-content');
                    appContainer.style.display = 'none';
                    terminalContent.textContent = null;
                } else if (appContainer.classList.contains('settings') ||
                    appContainer.classList.contains('dsp-controller-file-selection')) {
                    appContainer.style.display = 'none';
                    $('.overlay').hide();
                } else {
                    appContainer.style.display = 'none';
                }
            }
        });
    });
});
