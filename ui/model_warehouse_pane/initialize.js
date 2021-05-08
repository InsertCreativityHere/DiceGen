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
document.getElementById("divider").addEventListener("mousedown", startDrag)
document.addEventListener("mousemove", onDrag);
document.addEventListener("mouseup", endDrag);

const EN_US = {
    "None": "None",
};

//TODO remove this
//addModel()...
//displayFilters();
//setFilterState()...
//setSortBy("STANDARD");
