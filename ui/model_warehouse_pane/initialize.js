// Sets functions on the filter section labels and drop-down arrows that toggle the section's visibility when clicked.
function initializeSection(sectionName) {
    document.getElementById(`${sectionName}-filters-content`).style.display = "none";
    document.getElementById(`${sectionName}-filters-label`).addEventListener("click", function() {
        toggleSection(sectionName);
    });
}

// Initialize the filter sections.
initializeSection("standard");
initializeSection("family");
initializeSection("side-count");

// Add specific callback functions to the remaining input elements.
document.getElementById("search-bar").addEventListener("input", updateSearchBar);
document.getElementById("sort-by-chooser").addEventListener("change", updateSortBy);
document.getElementById("sort-by-svg").addEventListener("click", toggleSortByDirection);
document.getElementById("clear-filters-button").addEventListener("click", clearFilters);
document.getElementById("divider").addEventListener("mousedown", startDrag)
document.addEventListener("mousemove", onDrag);
document.addEventListener("mouseup", endDrag);
// Add a window callback to update the warehouse's card display when the window is resized.
window.addEventListener("resize", updateCardDisplay);

{
    // Create a dummy card to get the style fields out of.
    let dummyCard = document.createElement("div");
    dummyCard.classList.add("model-card");
    // The card MUST be a part of the DOM in order to have computed styles.
    document.body.appendChild(dummyCard);

    let cardStyle = getComputedStyle(dummyCard);
    // Initialize variables for dynamically spacing and sizing the model cards, so we don't have to later.
    var minCardWidth = parseInt(cardStyle.minWidth, 10);
    var cardBorderWidth = dummyCard.offsetWidth - minCardWidth;
    var cardMargin = parseInt(cardStyle.marginLeft, 10) * 2; //Multiplied by 2 since margins are on left and right.

    // Remove the dummy card from the document.
    document.body.removeChild(dummyCard);
}

const EN_US = {
    "None": "None",
};

//TODO remove this
addModel("Tetrahedron", "blob", true, "Platonic Solid", 4);
addModel("Hexahedron", "blob", true, "Platonic Solid", 6);
addModel("Octahedron", "blob", true, "Platonic Solid", 8);
addModel("Dodecahedron", "blob", true, "Platonic Solid", 12);
addModel("Icosahedron", "blob", true, "Platonic Solid", 20);
addModel("Pentagonal Trapezohedron", "blob", true, "Trapezohedron", 10);
addModel("DeltoidalHexecontahedron", "blob", false, "Quadrohedron", 60);
finishedAddingModels()
// setSortBy()
// setSearchBar()
// setFilter()
computeFilteredModelArray()
