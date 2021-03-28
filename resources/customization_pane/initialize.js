
function initializeMenu(menuName) {
    document.getElementById(`${menuName}-menu-content`).style.display = "none";
    document.getElementById(`${menuName}-menu-header`).addEventListener("click", function() {
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

hideSection("recess-faces-section");
hideSection("straight-border-corners-section");
hideSection("rounded-border-corners-section");
hideSection("round-faces-section");

document.getElementById("recess-faces-checkbox").addEventListener("input", updateRecessFacesCheckbox);

document.getElementById("face-depth-slider").addEventListener("input", updateFaceDepthSlider);
document.getElementById("face-depth-input").addEventListener("input", updateFaceDepthInput);
document.getElementById("face-depth-input").addEventListener("focusout", updateFaceDepthSlider);

document.getElementById("face-border-width-slider").addEventListener("input", updateBorderWidthSlider);
document.getElementById("face-border-width-input").addEventListener("input", updateBorderWidthInput);
document.getElementById("face-border-width-input").addEventListener("focusout", updateBorderWidthSlider);

document.getElementById("face-border-corners-chooser").addEventListener("change", updateBorderCornersChooser);

document.getElementById("straight-border-corners-protrusion-slider").addEventListener("input", updateStraightBorderCornersProtrusionSlider);
document.getElementById("straight-border-corners-protrusion-input").addEventListener("input", updateStraightBorderCornersProtrusionInput);
document.getElementById("straight-border-corners-protrusion-input").addEventListener("focusout", updateStraightBorderCornersProtrusionSlider);

document.getElementById("rounded-border-corners-protrusion-slider").addEventListener("input", updateRoundedBorderCornersProtrusionSlider);
document.getElementById("rounded-border-corners-protrusion-input").addEventListener("input", updateRoundedBorderCornersProtrusionInput);
document.getElementById("rounded-border-corners-protrusion-input").addEventListener("focusout", updateRoundedBorderCornersProtrusionSlider);

document.getElementById("rounded-border-corners-curvature-slider").addEventListener("input", updateRoundedBorderCornersCurvatureSlider);
document.getElementById("rounded-border-corners-curvature-input").addEventListener("input", updateRoundedBorderCornersCurvatureInput);
document.getElementById("rounded-border-corners-curvature-input").addEventListener("focusout", updateRoundedBorderCornersCurvatureSlider);

document.getElementById("round-faces-checkbox").addEventListener("input", updateRoundFacesCheckbox);

document.getElementById("face-curvature-slider").addEventListener("input", updateFaceCurvatureSlider);
document.getElementById("face-curvature-input").addEventListener("input", updateFaceCurvatureInput);
document.getElementById("face-curvature-input").addEventListener("focusout", updateFaceCurvatureSlider);

document.getElementById("face-subdivisions-slider").addEventListener("input", updateFaceSubdivisionsSlider);
document.getElementById("face-subdivisions-input").addEventListener("input", updateFaceSubdivisionsInput);
document.getElementById("face-subdivisions-input").addEventListener("focusout", updateFaceSubdivisionsSlider);
