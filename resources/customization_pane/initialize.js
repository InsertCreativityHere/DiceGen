// Sets functions on the main menu names (and drop-down arrows) for toggling the menu's visibility when clicked.
function initializeMenu(menuName) {
    document.getElementById(`${menuName}-menu-content`).style.display = "none";
    document.getElementById(`${menuName}-menu-dropdown`).addEventListener("click", function() {
        toggleMenu(menuName);
    });
    document.getElementById(`${menuName}-menu-label`).addEventListener("click", function() {
        toggleMenu(menuName);
    });
}

// Initialize the following menus.
initializeMenu("model");
initializeMenu("faces");
initializeMenu("edges");
initializeMenu("corners");
initializeMenu("glyphs");

// Hides an element when the page loads. Usually their visibility will be toggled by Javascript later.
function hideElement(elementId) {
    document.getElementById(elementId).style.display = "none";
}

// Hide the following elements.
hideElement("model-variables-section");
hideElement("recess-faces-section");
hideElement("straight-border-corners-section");
hideElement("rounded-border-corners-section");
hideElement("round-faces-section");
hideElement("beveled-edge-type-section");
hideElement("rounded-edge-type-section");
hideElement("truncated-corner-type-section");
hideElement("kleetoped-corner-type-section");
hideElement("rounded-corner-type-section");
hideElement("glyph-mapping-field");
hideElement("glyphs-section");

// Sets a series of event listeners on fields that have a range slider and an input box in them.
// These listeners keep the slider and input box in sync when their values change, and ensure that input boxes can never
// be left empty.
function configureSliderInput(fieldName) {
    // Add a function to update the input box's value to match the slider's when the slider is changed.
    document.getElementById(`${fieldName}-slider`).addEventListener("input", function() {
        const input = document.getElementById(`${sliderName}-input`);
        const slider = document.getElementById(`${sliderName}-slider`);
        input.value = slider.value;
    });

    // Add a function to update the slider's value to match the input's when the input box is changed.
    document.getElementById(`${fieldName}-input`).addEventListener("input", function() {
        const input = document.getElementById(`${inputName}-input`);
        const slider = document.getElementById(`${inputName}-slider`);

        // If the input box is empty, then use the slider's default value.
        if (input.value == "") {
            slider.value = slider.defaultValue;
        } else {
            slider.value = input.value;
        }
    });

    // Add a function to fill the input box with it's default value if the user clicks out of it while it's empty.
    document.getElementById(`${fieldName}-input`).addEventListener("focusout", function() {
        const input = document.getElementById(`${inputName}-input`);

        // If the input is empty, fill it with it's default value.
        if (input.value == "") {
            input.value = input.defaultValue;
        }
    });

    // TODO send a thing to sketchup.
}

// Configure the following field's sliders and input boxes.
configureSliderInput("face-depth");
configureSliderInput("face-border-width");
configureSliderInput("straight-border-corners-protrusion");
configureSliderInput("rounded-border-corners-protrusion");
configureSliderInput("rounded-border-corners-curvature");
configureSliderInput("face-curvature");
configureSliderInput("face-subdivisions");
configureSliderInput("beveled-edge-depth");
configureSliderInput("rounded-edge-depth");
configureSliderInput("rounded-edge-curvature");
configureSliderInput("truncated-corner-depth");
configureSliderInput("kleetoped-corner-depth");
configureSliderInput("kleetoped-corner-protrusion");
configureSliderInput("rounded-corner-depth");
configureSliderInput("rounded-corner-curvature");

// Add specific callback functions to the remaining input elements.
document.getElementById("base-model-button").addEventListener("click", selectBaseModel);
document.getElementById("recess-faces-checkbox").addEventListener("change", updateRecessFacesCheckbox);
document.getElementById("face-border-corners-chooser").addEventListener("change", updateBorderCorners);
document.getElementById("round-faces-checkbox").addEventListener("change", updateRoundFacesCheckbox);
document.getElementById("edge-type-chooser").addEventListener("change", updateEdgeType);
document.getElementById("corner-type-chooser").addEventListener("change", updateCornerType);
document.getElementById("lock-corner-edge-types-checkbox").addEventListener("change", updateEdgeCornerTypeLock)
