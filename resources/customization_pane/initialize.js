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

function hideSection(sectionId) {
    document.getElementById(sectionId).style.display = "none";
}

hideSection("model-variables-section");
hideSection("recess-faces-section");
hideSection("straight-border-corners-section");
hideSection("rounded-border-corners-section");
hideSection("round-faces-section");

document.getElementById("recess-faces-checkbox").addEventListener("change", updateRecessFacesCheckbox);

document.getElementById("face-depth-slider").addEventListener("input", updateFaceDepthSlider);
document.getElementById("face-depth-input").addEventListener("input", updateFaceDepthInput);
document.getElementById("face-depth-input").addEventListener("focusout", function() {
    fillEmptyInput("face-depth");
});

document.getElementById("face-border-width-slider").addEventListener("input", updateBorderWidthSlider);
document.getElementById("face-border-width-input").addEventListener("input", updateBorderWidthInput);
document.getElementById("face-border-width-input").addEventListener("focusout", function() {
    fillEmptyInput("face-border-width");
});

document.getElementById("face-border-corners-chooser").addEventListener("change", updateBorderCornersChooser);

document.getElementById("straight-border-corners-protrusion-slider").addEventListener("input", updateStraightBorderCornersProtrusionSlider);
document.getElementById("straight-border-corners-protrusion-input").addEventListener("input", updateStraightBorderCornersProtrusionInput);
document.getElementById("straight-border-corners-protrusion-input").addEventListener("focusout", function() {
    fillEmptyInput("straight-border-corners-protrusion");
});

document.getElementById("rounded-border-corners-protrusion-slider").addEventListener("input", updateRoundedBorderCornersProtrusionSlider);
document.getElementById("rounded-border-corners-protrusion-input").addEventListener("input", updateRoundedBorderCornersProtrusionInput);
document.getElementById("rounded-border-corners-protrusion-input").addEventListener("focusout", function() {
    fillEmptyInput("rounded-border-corners-protrusion");
});

document.getElementById("rounded-border-corners-curvature-slider").addEventListener("input", updateRoundedBorderCornersCurvatureSlider);
document.getElementById("rounded-border-corners-curvature-input").addEventListener("input", updateRoundedBorderCornersCurvatureInput);
document.getElementById("rounded-border-corners-curvature-input").addEventListener("focusout", function() {
    fillEmptyInput("rounded-border-corners-curvature");
});

document.getElementById("round-faces-checkbox").addEventListener("change", updateRoundFacesCheckbox);

document.getElementById("face-curvature-slider").addEventListener("input", updateFaceCurvatureSlider);
document.getElementById("face-curvature-input").addEventListener("input", updateFaceCurvatureInput);
document.getElementById("face-curvature-input").addEventListener("focusout", function() {
    fillEmptyInput("face-curvature");
});

document.getElementById("face-subdivisions-slider").addEventListener("input", updateFaceSubdivisionsSlider);
document.getElementById("face-subdivisions-input").addEventListener("input", updateFaceSubdivisionsInput);
document.getElementById("face-subdivisions-input").addEventListener("focusout", function() {
    fillEmptyInput("face-subdivisions");
});
