function initializeMenu(menuName) {
    document.getElementById(`${menuName}-menu-content`).style.display = "none";
    document.getElementById(`${menuName}-menu-dropdown`).addEventListener("click", function() {
        toggleMenu(menuName);
    });
    document.getElementById(`${menuName}-menu-label`).addEventListener("click", function() {
        toggleMenu(menuName);
    });
}

initializeMenu("model");
initializeMenu("faces");
initializeMenu("edges");
initializeMenu("corners");
initializeMenu("glyphs");

function hideElement(elementId) {
    document.getElementById(elementId).style.display = "none";
}

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

function configureSliderInput(fieldName) {
    document.getElementById(`${fieldName}-slider`).addEventListener("input", function() {
        synchronizeToSlider(fieldName);
    });
    document.getElementById(`${fieldName}-input`).addEventListener("input", function() {
        synchronizeToInput(fieldName);
    });
    document.getElementById(`${fieldName}-input`).addEventListener("focusout", function() {
        fillEmptyInput(fieldName);
    });
    // TODO send a thing to sketchup.
}

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

document.getElementById("base-model-button").addEventListener("click", selectBaseModel);
document.getElementById("recess-faces-checkbox").addEventListener("change", updateRecessFacesCheckbox);
document.getElementById("face-border-corners-chooser").addEventListener("change", updateBorderCorners);
document.getElementById("round-faces-checkbox").addEventListener("change", updateRoundFacesCheckbox);
document.getElementById("edge-type-chooser").addEventListener("change", updateEdgeType);
document.getElementById("corner-type-chooser").addEventListener("change", updateCornerType);
document.getElementById("lock-corner-edge-types-checkbox").addEventListener("change", updateEdgeCornerTypeLock)
