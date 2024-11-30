const DOUBLE_CLICK_DELAY = 800;
let clickTimer = null;

function openApp(app) {
    if (app === 'terminal')
        $('.terminal').show();
    else if (app === 'controlPanel')
        $('.control-panel').show();
    else if (app === 'dspController')
        runDspController();
    else if (app === 'dspTester')
        runDspTester();
}

function handleIconClick(event) {
    const icon = event.currentTarget;

    if (clickTimer) {
        clearTimeout(clickTimer);

        if (icon.classList.contains('terminal-icon'))
            openApp('terminal');
        else if (icon.classList.contains('control-panel-icon'))
            openApp('controlPanel');
        else if (icon.classList.contains('dsp-controller-icon'))
            openApp('dspController');
        else if (icon.classList.contains('dsp-tester-icon'))
            openApp('dspTester');

        clickTimer = null;
    } else {
        clickTimer = setTimeout(() => {
            clickTimer = null;
        }, DOUBLE_CLICK_DELAY);
    }
}

document.addEventListener("DOMContentLoaded", () => {
    const terminalIcon = document.querySelector('.terminal-icon');
    const controlPanelIcon = document.querySelector('.control-panel-icon');
    const dspControllerIcon = document.querySelector('.dsp-controller-icon');
    const dspTesterIcon = document.querySelector('.dsp-tester-icon');

    terminalIcon.addEventListener('click', handleIconClick);
    controlPanelIcon.addEventListener('click', handleIconClick);
    dspControllerIcon.addEventListener('click', handleIconClick);
    dspTesterIcon.addEventListener('click', handleIconClick);
});