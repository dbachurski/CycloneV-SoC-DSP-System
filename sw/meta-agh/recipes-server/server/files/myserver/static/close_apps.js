let terminal, controlPanel, dspController;

function closeApp(event) {
    const clickedButton = event.currentTarget;

    if (clickedButton.closest('.terminal')) {
        if (terminal) {
            const terminalContent = document.getElementById('terminal-content');
            terminal.style.display = 'none';
            terminalContent.textContent = null;
        }
    } else if (clickedButton.closest('.control-panel')) {
        if (controlPanel) {
            controlPanel.style.display = 'none';
        }
    } else if (clickedButton.closest('.dsp-controller')) {
        if (dspController) {
            dspController.style.display = 'none';
        }
    }
}

document.addEventListener("DOMContentLoaded", () => {
    terminal = document.querySelector('.terminal');
    controlPanel = document.querySelector('.control-panel');
    dspController = document.querySelector('.dsp-controller');

    const btnCloseTerminal = terminal.querySelector('.btn-red');
    const btnCloseControlPanel = controlPanel.querySelector('.btn-red');
    const btnCloseDspController = dspController.querySelector('.btn-red');

    btnCloseTerminal.addEventListener('click', closeApp);
    btnCloseControlPanel.addEventListener('click', closeApp);
    btnCloseDspController.addEventListener('click', closeApp);
});
