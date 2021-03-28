
function initializeMenu(menuName) {
    document.getElementById(`${menuName}-menu-content`).style.display = "none";
    document.getElementById(`${menuName}-menu-header`).onclick = function() { toggleMenu(menuName); };
}

initializeMenu("model");
initializeMenu("faces");
initializeMenu("edges");
initializeMenu("corners");
initializeMenu("glyphs");

function hideSection(sectionId) {
    document.getElementById(sectionId).style.display = "none";
}

hideSection("recess-faces-section");
hideSection("straight-border-corners-section");
hideSection("rounded-border-corners-section");
hideSection("round-faces-section");

document.getElementById("recess-faces-checkbox").oninput = updateRecessFacesCheckbox
document.getElementById("face-depth-slider").oninput = updateFaceDepthSlider
document.getElementById("face-depth-input").oninput = updateFaceDepthInput
document.getElementById("face-depth-input").onfocusout = updateFaceDepthInput
document.getElementById("face-border-width-slider").oninput = updateBorderWidthSlider
document.getElementById("face-border-width-input").oninput = updateBorderWidthInput
document.getElementById("face-border-corners-chooser").onchange = updateBorderCornersChooser
document.getElementById("straight-border-corners-protrusion-slider").oninput = updateStraightBorderCornersProtrusionSlider
document.getElementById("straight-border-corners-protrusion-input").oninput = updateStraightBorderCornersProtrusionInput
document.getElementById("rounded-border-corners-protrusion-slider").oninput = updateRoundedBorderProtrusionSlider
document.getElementById("rounded-border-corners-protrusion-input").oninput = updateRoundedBorderProtrusionInput
document.getElementById("rounded-border-corners-curvature-slider").oninput = updateRoundedBorderCurvatureSlider
document.getElementById("rounded-border-corners-curvature-input").oninput = updateRoundedBorderCurvatureInput
document.getElementById("round-faces-checkbox").oninput = updateRoundFacesCheckbox
document.getElementById("face-curvature-slider").oninput = updateFaceCurvatureSlider
document.getElementById("face-curvature-input").oninput = updateFaceCurvatureInput
document.getElementById("face-subdivisions-slider").oninput = updateFaceSubdivisionsSlider
document.getElementById("face-subdivisions-input").oninput = updateFaceSubdivisionsInput
