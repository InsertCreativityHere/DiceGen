
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

function toggleSection(sectionName) {
    content = document.getElementById(`${sectionName}-section`);
    checkbox = document.getElementById(`${sectionName}-checkbox`);

    if (checkbox.checked) {
        content.style.display = "block";
    } else {
        content.style.display = "none";
    }
}

function synchronizeSlider(inputName) {
    input = document.getElementById(`${inputName}-input`);
    slider = document.getElementById(`${inputName}-slider`);

    // Set the sliders's value to match the input, unless it's empty, then use the slider's default value.
    if (input.value == "") {
        slider.value = slider.defaultValue;
    } else {
        slider.value = input.value;
    }
}

function synchronizeInput(sliderName) {
    input = document.getElementById(`${sliderName}-input`);
    slider = document.getElementById(`${sliderName}-slider`);

    // Set the input's value to match the slider.
    input.value = slider.value;
}

function updateRecessFacesCheckbox() {
    toggleSection("recess-faces");
}

function updateFaceDepthSlider() {
    synchronizeInput("face-depth");
}

function updateFaceDepthInput() {
    synchronizeSlider("face-depth");
}

function updateBorderWidthSlider() {
    synchronizeInput("face-border-width");
}

function updateBorderWidthInput() {
    synchronizeSlider("face-border-width");
}

function updateBorderCornersChooser() {
    chooser = document.getElementById("face-border-corners-chooser");
    straightCornersSection = document.getElementById("straight-border-corners-section");
    roundedCornersSection = document.getElementById("rounded-border-corners-section");

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
    }
}

function updateStraightBorderCornersProtrusionSlider() {
    synchronizeInput("straight-border-corners-protrusion");
}

function updateStraightBorderCornersProtrusionInput() {
    synchronizeSlider("straight-border-corners-protrusion");
}

function updateRoundedBorderCornersProtrusionSlider() {
    synchronizeInput("rounded-border-corners-protrusion");
}

function updateRoundedBorderCornersProtrusionInput() {
    synchronizeSlider("rounded-border-corners-protrusion");
}

function updateRoundedBorderCornersCurvatureSlider() {
    synchronizeInput("rounded-border-corners-curvature");
}

function updateRoundedBorderCornersCurvatureInput() {
    synchronizeSlider("rounded-border-corners-curvature");
}

function updateRoundFacesCheckbox() {
    toggleSection("round-faces");
}

function updateFaceCurvatureSlider() {
    synchronizeInput("face-curvature");
}

function updateFaceCurvatureInput() {
    synchronizeSlider("face-curvature");
}

function updateFaceSubdivisionsSlider() {
    synchronizeInput("face-subdivisions");
}

function updateFaceSubdivisionsInput() {
    synchronizeSlider("face-subdivisions");
}
