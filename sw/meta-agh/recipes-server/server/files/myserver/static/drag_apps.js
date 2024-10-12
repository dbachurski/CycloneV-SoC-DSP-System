function onMouseMove(event, element) {
    let left = event.clientX - element.offsetX;
    let top = event.clientY - element.offsetY;

    left = Math.min(Math.max(left, 0), window.innerWidth - element.offsetWidth);
    top = Math.min(Math.max(top, 0), window.innerHeight - element.offsetHeight);

    element.style.position = 'absolute';
    element.style.left = `${left}px`;
    element.style.top = `${top}px`;
}

function onMousePressed(element, removeEventListeners) {
    return function(event) {
        if (event.button === 0) {
            removeEventListeners();
        }
    };
}

function makeDraggable(elements) {
    elements.forEach((element) => {
        const titleBar = element.querySelector('.title-bar');

        function startDragging(event) {
            if (event.button === 0) {
                event.preventDefault();

                const maxZIndex = Math.max(
                    ...elements
                        .filter(current_element => current_element !== element)
                        .map(current_element => parseInt(window.getComputedStyle(current_element).zIndex, 10) || 0)
                );

                element.style.zIndex = maxZIndex + 1;

                element.offsetX = event.clientX - element.getBoundingClientRect().left;
                element.offsetY = event.clientY - element.getBoundingClientRect().top;

                function removeEventListeners() {
                    document.removeEventListener('mousemove', onMouseMoveListener);
                    document.removeEventListener('mouseup', onMousePressedListener);
                }

                const onMouseMoveListener = (event) => onMouseMove(event, element);
                const onMousePressedListener = onMousePressed(element, removeEventListeners);

                document.addEventListener('mousemove', onMouseMoveListener);
                document.addEventListener('mouseup', onMousePressedListener);
            }
        }

        titleBar.addEventListener('mousedown', startDragging);
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const controlPanel = document.querySelector('.control-panel');
    const terminal = document.querySelector('.terminal');
    const dspController = document.querySelector('.dsp-controller');

    makeDraggable([controlPanel, terminal, dspController]);
});