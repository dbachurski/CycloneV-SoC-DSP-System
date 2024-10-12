const DOUBLE_CLICK_DELAY = 800;
let clickTimer = null;

function openApp(app) {
    if (app === 'terminal')
        $('.terminal').show();
    else if (app = 'controlPanel')
        $('.control-panel').show();
}

function handleIconClick(event) {
    const icon = event.currentTarget;

    if (clickTimer) {
        clearTimeout(clickTimer);

        if (icon.classList.contains('terminal-icon'))
            openApp('terminal');
        else if (icon.classList.contains('control-panel-icon'))
            openApp('controlPanel');

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

    terminalIcon.addEventListener('click', handleIconClick);
    controlPanelIcon.addEventListener('click', handleIconClick);
});