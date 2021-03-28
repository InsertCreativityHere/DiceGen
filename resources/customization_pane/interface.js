
function toggleMenu(menuName) {
    content = document.getElementById(`${menuName}-menu-content`);
    dropdown = document.getElementById(`${menuName}-menu-dropdown`);

    if (content.style.display == "none") {
        content.style.display = "block";
        dropdown.innerHTML = "&#x25BE;";
    } else {
        content.style.display = "none";
        dropdown.innerHTML = "&#x25B8;";
    }
}

function synchronizeSlider(inputName) {
    input = document.getElementById(`${inputName}-input`);
    slider = document.getElementById(`${inputName}-slider`);

    // Set the sliders's value to match the input.
    slider.value = input.value;
}

function synchronizeInput(sliderName) {
    input = document.getElementById(`${sliderName}-input`);
    slider = document.getElementById(`${sliderName}-slider`);

    // Set the input's value to match the slider.
    input.value = slider.value;
}

function updateRecessFacesCheckbox() {
    content = document.getElementById("recess-faces-section");
    checkbox = document.getElementById("recess-faces-checkbox");

    if (checkbox.checked) {
        content.style.display = "block";
        // TODO
    } else {
        content.style.display = "none";
        // TODO
    }
}

function updateFaceDepthSlider() {
    synchronizeInput("face-depth");
}

function updateFaceDepthInput() {
    synchronizeSlider("face-depth");
}

function updateBorderWidthSlider() {

}

function updateBorderWidthInput() {

}

function updateBorderCornersChooser() {

}

function updateStraightBorderCornersProtrusionSlider() {

}

function updateStraightBorderCornersProtrusionInput() {

}

function updateRoundedBorderProtrusionSlider() {

}

function updateRoundedBorderProtrusionInput() {

}

function updateRoundedBorderCurvatureSlider() {

}

function updateRoundedBorderCurvatureInput() {

}

function updateRoundFacesCheckbox() {

}

function updateFaceCurvatureSlider() {
    
}

function updateFaceCurvatureInput() {

}

function updateFaceSubdivisionsSlider() {

}

function updateFaceSubdivisionsInput() {

}
