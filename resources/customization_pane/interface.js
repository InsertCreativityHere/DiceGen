function toggleMenu(menuName) {
    let content = document.getElementById(`${menuName}-menu-content`);
    let dropdown = document.getElementById(`${menuName}-menu-dropdown`);

    if (content.style.display == "none") {
        content.style.display = "block";
        dropdown.innerHTML = "&#x25BE;";
    } else {
        content.style.display = "none";
        dropdown.innerHTML = "&#x25B8;";
    }
}

function toggleSection(sectionName) {
    let content = document.getElementById(`${sectionName}-section`);
    let checkbox = document.getElementById(`${sectionName}-checkbox`);

    if (checkbox.checked) {
        content.style.display = "block";
    } else {
        content.style.display = "none";
    }
}

function synchronizeToInput(inputName) {
    let input = document.getElementById(`${inputName}-input`);
    let slider = document.getElementById(`${inputName}-slider`);

    // Set the sliders's value to match the input, unless it's empty, then use the slider's default value.
    if (input.value == "") {
        slider.value = slider.defaultValue;
    } else {
        slider.value = input.value;
    }
}

function synchronizeToSlider(sliderName) {
    let input = document.getElementById(`${sliderName}-input`);
    let slider = document.getElementById(`${sliderName}-slider`);

    // Set the input's value to match the slider.
    input.value = slider.value;
}

function fillEmptyInput(inputName) {
    let input = document.getElementById(`${inputName}-input`);

    // If the input is empty, fill it with it's default value.
    if (input.value == "") {
        input.value = input.defaultValue;
    }
}

function updateRecessFacesCheckbox() {
    toggleSection("recess-faces");
}

function updateFaceDepthSlider() {
    synchronizeToSlider("face-depth");
}

function updateFaceDepthInput() {
    synchronizeToInput("face-depth");
}

function updateBorderWidthSlider() {
    synchronizeToSlider("face-border-width");
}

function updateBorderWidthInput() {
    synchronizeToInput("face-border-width");
}

function updateBorderCornersChooser() {
    let chooser = document.getElementById("face-border-corners-chooser");
    let straightCornersSection = document.getElementById("straight-border-corners-section");
    let roundedCornersSection = document.getElementById("rounded-border-corners-section");

    switch (chooser.value) {
        case "EMPTY":
            straightCornersSection.style.display = "none";
            roundedCornersSection.style.display = "none";
            break;
        case "STRAIGHT":
            straightCornersSection.style.display = "block";
            roundedCornersSection.style.display = "none";
            break;
        case "ROUNDED":
            straightCornersSection.style.display = "none";
            roundedCornersSection.style.display = "block";
            break;
        default:
            console.error(`Critical: impossible value stored in face-border-corners-chooser! value=${chooser.value}`);
            break;
    }
}

function updateStraightBorderCornersProtrusionSlider() {
    synchronizeToSlider("straight-border-corners-protrusion");
}

function updateStraightBorderCornersProtrusionInput() {
    synchronizeToInput("straight-border-corners-protrusion");
}

function updateRoundedBorderCornersProtrusionSlider() {
    synchronizeToSlider("rounded-border-corners-protrusion");
}

function updateRoundedBorderCornersProtrusionInput() {
    synchronizeToInput("rounded-border-corners-protrusion");
}

function updateRoundedBorderCornersCurvatureSlider() {
    synchronizeToSlider("rounded-border-corners-curvature");
}

function updateRoundedBorderCornersCurvatureInput() {
    synchronizeToInput("rounded-border-corners-curvature");
}

function updateRoundFacesCheckbox() {
    toggleSection("round-faces");
}

function updateFaceCurvatureSlider() {
    synchronizeToSlider("face-curvature");
}

function updateFaceCurvatureInput() {
    synchronizeToInput("face-curvature");
}

function updateFaceSubdivisionsSlider() {
    synchronizeToSlider("face-subdivisions");
}

function updateFaceSubdivisionsInput() {
    synchronizeToInput("face-subdivisions");
}
