
function toggleMenu(menuName) {
    const content = document.getElementById(`${menuName}-menu-content`);
    const dropdown = document.getElementById(`${menuName}-menu-dropdown`);

    if (content.style.display == "none") {
        content.style.display = "block";
        dropdown.innerHTML = "&#x25BE;";
    } else {
        content.style.display = "none";
        dropdown.innerHTML = "&#x25B8;";
    }
}

function toggleSection(sectionName) {
    const content = document.getElementById(`${sectionName}-section`);
    const checkbox = document.getElementById(`${sectionName}-checkbox`);

    if (checkbox.checked) {
        content.style.display = "block";
    } else {
        content.style.display = "none";
    }
}



// TODO selectBaseModel goes here



function addModelVariableField(fieldName, displayName, min, max, defaultValue, sliderStep, inputStep) {
    // Create the div that will hold everything for the field.
    const variableField = document.createElement("div");
    variableField.id = `${fieldName}-field`;
    variableField.className = "field";

    // Create the field's label.
    const sliderLabel = document.createElement("label");
    sliderLabel.for = variableField.id;
    sliderLabel.innerHTML = displayName;
    variableField.appendChild(sliderLabel);

    // Create the field's range slider.
    const rangeInput = document.createElement("input");
    rangeInput.type = "range";
    rangeInput.id = `${fieldName}-slider`;
    rangeInput.step = sliderStep;
    rangeInput.value = defaultValue;
    rangeInput.defaultValue = defaultValue;
    rangeInput.min = min;
    rangeInput.max = max;

    // Create the field's number input box.
    const numberInput = document.createElement("input");
    numberInput.type = "number";
    numberInput.id = `${fieldName}-input`;
    numberInput.step = inputStep;
    numberInput.value = defaultValue;
    numberInput.defaultValue = defaultValue;

    // Create the container for storing all the non-label portions of the field.
    // We have these in a separate div so that we can push them all to the right of the page easier.
    const sliderContainer = document.createElement("div");
    sliderContainer.className = "slider-input";
    // Add the slider bar (with it's min&max labels) and the number input box.
    sliderContainer.appendChild(document.createTextNode(min));
    sliderContainer.appendChild(rangeInput);
    sliderContainer.appendChild(document.createTextNode(max));
    sliderContainer.appendChild(numberInput);
    variableField.appendChild(sliderContainer);

    // Add the field's div container to the model variables section of the page.
    const modelVariablesSection = document.getElementById("model-variables-section");
    modelVariablesSection.appendChild(variableField);

    // Set scripts and callbacks on the elements for communicating with sketchup and syncing the slider and input box.
    configureSliderInput(fieldName);
}

function showModelVariableFields() {
    document.getElementById("model-variables-section").style.display = "block";
}

function resetModelVariableFields() {
    const modelVariablesSection = document.getElementById("model-variables-section");
    
    // First, hide the model variables section.
    modelVariablesSection.style.display = "none";
    // Remove the field elements from the section.
    while (modelVariablesSection.firstChild) {
        modelVariablesSection.removeChild(modelVariablesSection.lastChild)
    }
}



function updateRecessFacesCheckbox() {
    toggleSection("recess-faces");
    // TODO send a thing to sketchup
}

function updateBorderCorners() {
    const chooser = document.getElementById("face-border-corners-chooser");
    const straightCornersSection = document.getElementById("straight-border-corners-section");
    const roundedCornersSection = document.getElementById("rounded-border-corners-section");

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

    // TODO send a thing to sketchup
}

function updateRoundFacesCheckbox() {
    toggleSection("round-faces");
    // TODO send a thing to sketchup
}

function updateEdgeType() {
    const chooser = document.getElementById("edge-type-chooser");
    const beveledEdgeSection = document.getElementById("beveled-edge-type-section");
    const roundedEdgeSection = document.getElementById("rounded-edge-type-section");

    switch (chooser.value) {
        case "NORMAL":
            beveledEdgeSection.style.display = "none";
            roundedEdgeSection.style.display = "none";
            break;
        case "BEVELED":
            beveledEdgeSection.style.display = "block";
            roundedEdgeSection.style.display = "none";
            break;
        case "ROUNDED":
            beveledEdgeSection.style.display = "none";
            roundedEdgeSection.style.display = "block";
            break;
        default:
            console.error(`Critical: impossible value stored in edge-type-chooser! value=${chooser.value}`);
            break;
    }

    // TODO send a thing to sketchup
}

function updateCornerType() {
    const chooser = document.getElementById("corner-type-chooser");
    const truncatedCornerSection = document.getElementById("truncated-corner-type-section");
    const kleetopedCornerSection = document.getElementById("kleetoped-corner-type-section");
    const roundedCornerSection = document.getElementById("rounded-corner-type-section");

    switch (chooser.value) {
        case "NORMAL":
            truncatedCornerSection.style.display = "none";
            kleetopedCornerSection.style.display = "none";
            roundedCornerSection.style.display = "none";
            break;
        case "TRUNCATED":
            truncatedCornerSection.style.display = "block";
            kleetopedCornerSection.style.display = "none";
            roundedCornerSection.style.display = "none";
            break;
        case "KLEETOPED":
            truncatedCornerSection.style.display = "none";
            kleetopedCornerSection.style.display = "block";
            roundedCornerSection.style.display = "none";
            break;
        case "ROUNDED":
            truncatedCornerSection.style.display = "none";
            kleetopedCornerSection.style.display = "none";
            roundedCornerSection.style.display = "block";
            break;
        default:
            console.error(`Critical: impossible value stored in corner-type-chooser! value=${chooser.value}`);
            break;
    }

    // TODO send a thing to sketchup
}



function updateEdgeCornerTypeLock() {
    const checkbox = document.getElementById("lock-corner-edge-types-checkbox");
    if (checkbox.checked) {
        synchronizeToEdgeTypeChooser();
        synchronizeToEdgeTypeChooser();
        synchronizeToBelevedEdgeDepthSlider();
        synchronizeToBelevedEdgeDepthInput();
        synchronizeToRoundedEdgeDepthSlider();
        synchronizeToRoundedEdgeDepthInput();
        synchronizeToRoundedEdgeCurvatureSlider();
        synchronizeToRoundedEdgeCurvatureInput();

        document.getElementById("edge-type-chooser").addEventListener("change", synchronizeToEdgeTypeChooser);
        document.getElementById("beveled-edge-depth-slider").addEventListener("input", synchronizeToBelevedEdgeDepthSlider);
        document.getElementById("beveled-edge-depth-input").addEventListener("input", synchronizeToBelevedEdgeDepthInput);
        document.getElementById("rounded-edge-depth-slider").addEventListener("input", synchronizeToRoundedEdgeDepthSlider);
        document.getElementById("rounded-edge-depth-input").addEventListener("input", synchronizeToRoundedEdgeDepthInput);
        document.getElementById("rounded-edge-curvature-slider").addEventListener("input", synchronizeToRoundedEdgeCurvatureSlider);
        document.getElementById("rounded-edge-curvature-input").addEventListener("input", synchronizeToRoundedEdgeCurvatureInput);
        document.getElementById("corner-type-chooser").disabled = true;
        document.getElementById("kleetoped-corner-depth-input").disabled = true;
        document.getElementById("kleetoped-corner-depth-slider").disabled = true;
        document.getElementById("kleetoped-corner-depth-input").disabled = true;
        document.getElementById("kleetoped-corner-depth-slider").disabled = true;
        document.getElementById("rounded-corner-depth-input").disabled = true;
        document.getElementById("rounded-corner-depth-slider").disabled = true;
        document.getElementById("rounded-corner-depth-input").disabled = true;
        document.getElementById("rounded-corner-depth-slider").disabled = true;
        document.getElementById("rounded-corner-curvature-input").disabled = true;
        document.getElementById("rounded-corner-curvature-slider").disabled = true;
        document.getElementById("rounded-corner-curvature-input").disabled = true;
        document.getElementById("rounded-corner-curvature-slider").disabled = true;
    } else {
        document.getElementById("edge-type-chooser").removeEventListener("change", synchronizeToEdgeTypeChooser);
        document.getElementById("beveled-edge-depth-slider").removeEventListener("input", synchronizeToBelevedEdgeDepthSlider);
        document.getElementById("beveled-edge-depth-input").removeEventListener("input", synchronizeToBelevedEdgeDepthInput);
        document.getElementById("rounded-edge-depth-slider").removeEventListener("input", synchronizeToRoundedEdgeDepthSlider);
        document.getElementById("rounded-edge-depth-input").removeEventListener("input", synchronizeToRoundedEdgeDepthInput);
        document.getElementById("rounded-edge-curvature-slider").removeEventListener("input", synchronizeToRoundedEdgeCurvatureSlider);
        document.getElementById("rounded-edge-curvature-input").removeEventListener("input", synchronizeToRoundedEdgeCurvatureInput);
        document.getElementById("corner-type-chooser").disabled = false;
        document.getElementById("kleetoped-corner-depth-input").disabled = false;
        document.getElementById("kleetoped-corner-depth-slider").disabled = false;
        document.getElementById("kleetoped-corner-depth-input").disabled = false;
        document.getElementById("kleetoped-corner-depth-slider").disabled = false;
        document.getElementById("rounded-corner-depth-input").disabled = false;
        document.getElementById("rounded-corner-depth-slider").disabled = false;
        document.getElementById("rounded-corner-depth-input").disabled = false;
        document.getElementById("rounded-corner-depth-slider").disabled = false;
        document.getElementById("rounded-corner-curvature-input").disabled = false;
        document.getElementById("rounded-corner-curvature-slider").disabled = false;
        document.getElementById("rounded-corner-curvature-input").disabled = false;
        document.getElementById("rounded-corner-curvature-slider").disabled = false;
    }
}

function synchronizeToEdgeSlider(edgeSliderName, cornerInputName) {
    const edgeSlider = document.getElementById(edgeSliderName);
    const cornerInput = document.getElementById(cornerInputName);

    cornerInput.value = edgeSlider.value;
    cornerInput.dispatchEvent(new Event("input"));
}

function synchronizeToEdgeInput(edgeInputName, cornerInputName) {
    const edgeInput = document.getElementById(edgeInputName);
    const cornerInput = document.getElementById(cornerInputName);

    if (edgeInput.value == "") {
        cornerInput.value = edgeInput.defaultValue;
    } else {
        cornerInput.value = edgeInput.value;
    }
    cornerInput.dispatchEvent(new Event("input"));
}

function synchronizeToEdgeTypeChooser() {
    const edgeChooser = document.getElementById("edge-type-chooser");
    const cornerChooser = document.getElementById("corner-type-chooser");

    switch (edgeChooser.value) {
        case "NORMAL":
            cornerChooser.value = "NORMAL";
            break;
        case "BEVELED":
            cornerChooser.value = "KLEETOPED";
            break;
        case "ROUNDED":
            cornerChooser.value = "ROUNDED";
            break;
        default:
            console.error(`Critical: impossible value stored in edge-type-chooser! value=${chooser.value}`);
            break;
    }
    cornerChooser.dispatchEvent(new Event("change"));
}

function synchronizeToBelevedEdgeDepthSlider() {
    synchronizeToEdgeSlider("beveled-edge-depth-slider", "kleetoped-corner-depth-input");
}

function synchronizeToBelevedEdgeDepthInput() {
    synchronizeToEdgeInput("beveled-edge-depth-input", "kleetoped-corner-depth-input");
}

function synchronizeToRoundedEdgeDepthSlider() {
    synchronizeToEdgeSlider("rounded-edge-depth-slider", "rounded-corner-depth-input");
}

function synchronizeToRoundedEdgeDepthInput() {
    synchronizeToEdgeInput("rounded-edge-depth-input", "rounded-corner-depth-input");
}

function synchronizeToRoundedEdgeCurvatureSlider() {
    synchronizeToEdgeSlider("rounded-edge-curvature-slider", "rounded-corner-curvature-input");
}

function synchronizeToRoundedEdgeCurvatureInput() {
    synchronizeToEdgeInput("rounded-edge-curvature-input", "rounded-corner-curvature-input");
}
















function selectBaseModel() {
    // TODO

    resetModelVariableFields();
    resetGlyphMappings();

    document.getElementById("base-model-button").innerHTML = ("(D10) Pentagonal Trapezohedron");

    // setModelSideCount(10);
    addModelVariableField("die-width", "Die Width", 0, 10, 3, 0.1, 0.5);
    addModelVariableField("die-height", "Die Height", 0, 20, 5, 0.5, 1);
    showModelVariableFields();
}

function addGlyphMapping(mappingName /*MORE FIELDS*/) {
    // TODO
}

function resetGlyphMappings() {
    // TODO
}
