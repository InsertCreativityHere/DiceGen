
//TODO Add localization somehow.


// For skecthup to call (in order):
// addModel...
// finishedAddingModels
// setSortBy
// setSearchBar
// setFilter...
// computeFilteredModelArray

// sketchup callbacks:
// chooseModel
// updateSearchBar
// updateSortBy
// updateFilter



//==============================================================================
// Sketchup Callbacks
//==============================================================================

function chooseModel(modelName) {
    //TODO change the background of the currently selected model!

    //TODO sketchup.chooseModel(modelName);
    console.log(`Set Model to ${modelName}...`);
}

function updateSearchBar() {
    // Filter the models according to the new search criteria and display the remaining cards in order.
    computeFilteredModelArray();

    const search = document.getElementById("search-bar").value;
    //TODO sketchup.updateSearchBar(search);
    console.log(`Set Search to ${search}...`);
}

function updateSortBy() {
    // Change the sorting criteria and display the re-filtered cards in order.
    computeFilteredModelArray();

    const sortType = document.getElementById("sort-by-chooser").value;
    //TODO sketchup.updateSortBy(sortType);
    console.log(`Set SortType to ${sortType}...`);
}

function updateFilter(category, filter) {
    // Update the filtering criteria.
    const isChecked = document.getElementById(`${filterName}-checkbox`).checked;
    if (isChecked) {
        filterCategories[category].add(filter);
    } else {
        filterCategories[category].delete(filter);
    }
    // Filter the models according to the new filter criteria and display the remaining cards in order.
    computeFilteredModelArray();

    //TODO sketchup.updateFilter(filterName, isChecked);
    console.log(`Toggling the ${filterName} filter to ${isChecked}...`);
}

//==============================================================================
// Sidebar
//==============================================================================

function toggleSection(sectionName) {
    const content = document.getElementById(`${sectionName}-filters-content`);
    const dropdown = document.getElementById(`${sectionName}-filters-dropdown`);

    if (content.style.display == "none") {
        content.style.display = "";
        dropdown.innerHTML = "&#x25BE;";
    } else {
        content.style.display = "none";
        dropdown.innerHTML = "&#x25B8;";
    }
}

//==============================================================================
// Model Management
//==============================================================================

// Array containing all the instances of ModelCard.
let modelCardArray = [];

// Class for storing all the information about a model, and that generates a UI card element to display the model with.
class ModelCard {
    // Create a new model card.
    constructor(modelName, imageURL, isStandard, family, sideCount) {
        // Store the provided data.
        this.name = modelName;
        this.imageURL = imageURL;
        this.isStandard = isStandard;
        this.family = family;
        this.sideCount = sideCount;

        // Create the UI card element that will display this model to the user. Starting with the card's div.
        const modelCard = document.createElement("div");
        modelCard.className = "model-card";

        // Create the div that will hold the model's image (This is to be able to set a background color).
        const imageHolder = document.createElement("div");
        imageHolder.className = "model-image-holder";
        modelCard.appendChild(imageHolder);

        // Create the model's image and add it to the image holder.
        const modelImage = document.createElement("img");
        modelImage.src = imageURL;
        modelImage.alt = modelName;
        modelImage.className = "model-image";
        imageHolder.appendChild(modelImage);

        // Create the model's name label.
        const modelLabel = document.createElement("label");
        modelLabel.class = "model-name-label";
        modelLabel.innerText = modelName;
        modelCard.appendChild(modelLabel);

        // Create a div for holding the model's details (side count and polyhedral family).
        const modelDetails = document.createElement("div");
        modelDetails.className = "model-details";
        modelCard.appendChild(modelDetails);

        // Create a label describing the die's normal name, side count, and whether or not it's standard.
        const leftLabel = document.createElement("label");
        leftLabel.innerText = (isStandard? "Standard" : "Nonstandard") + ` D${sideCount}`;
        modelDetails.appendChild(leftLabel);

        // Create a label describing what polyhedral family the die belongs to.
        const rightLabel = document.createElement("label");
        rightLabel.innerText = family;
        modelDetails.appendChild(rightLabel);

        // Store a reference to the card div.
        this.cardElement = modelCard;
    }
}

function addModel(modelName, imageURL, isStandard, family, sideCount) {
    // Construct a new model card and add it to the model card array.
    modelCardArray.push(new ModelCard(modelName, imageURL, isStandard, family, sideCount));
}

function finishedAddingModels() {
    // Array containing the polyhedral families of all the models that have been added to the warehouse.
    let families = [];
    // Array containing the side counts for all the models that have been added to the warehouse.
    let sideCounts = [];

    for (modelCard in modelCardArray) {
        // If this model's family hasn't been seen yet, add it to the family array.
        if (!families.has(modelCard.family)) {
            families.push(modelCard.family);
        }
        // If this model's side count hasn't been seen yet, add it the side count array.
        if (!sideCounts.has(modelCard.sideCount)) {
            sideCounts.push(modelCard.sideCount);
        }
    }

    // Create filters for each of the families and side counts.
    createFilters(families, sideCounts);
    // Compute and cache sorted arrays of the models, one for each possible sorting.
    computeSortedModelArrays(families);
    // Filter the models and display the remaining cards in order.
    computeFilteredModelArray();
}

//==============================================================================
// Sorting
//==============================================================================

// Array of all the model cards sorted by whether they're standard (Standard comes first, followed by nonstandard).
let sortedByStandard = [];
// Array of all the model cards sorted by their polyhedral family (Families are sorted in the order of 'modelFamilies').
let sortedByFamily = [];
// Array of all the model cards sorted by the number of sides they have (Sorted from least to greatest).
let sortedBySideCount = [];
// Array of all the model cards sorted alphabetically (A to Z).
let sortedByName = [];

function computeSortedModelArrays(families) {
    sortedByStandard = sortArray(modelCardArray, function(a, b) {
        // Don't move the models if they're both of the same standardness.
        if (a.isStandard == b.isStandard) return 0;
        // If 'a' is standard, move it to the left, otherwise move it to the right (since it's nonstandard).
        // This works because we know that 'b' must be the opposite standardness to 'a' by this point.
        return (a.isStandard? -1 : 1);
    });

    sortedByFamily = sortArray(modelCardArray, function(a, b) {
        // Return the difference in family indexes. If they're in the same family, they won't be moved, otherwise they
        // be moved to match the order of families in 'families'.
        return (families.indexOf(a.family) - families.indexOf(b.family));
    });

    sortedBySideCount = sortArray(modelCardArray, function(a, b) {
        // Return the difference in side counts. If 'a' has less sides than 'b', it'll be moved to the left, if it has
        // more sides, it'll be moved to the right, and if they have the same number, they won't be moved.
        return (a.sideCount - b.sideCount);
    });

    sortedByName = sortArray(modelCardArray, function(a, b) {
        // Don't move the models if they both have the same name.
        if (a.name == b.name) return 0;
        // Use the standard alphabetical comparator to sort them otherwise.
        return ((a.name < b.name)? -1 : 1);
    });
}

function sortArray(array, comparator) {
    // A stabilized sorting algorithm which preserves the order of elements that equal under the provided comparator.
    let stableCompare = function(a, b) {
        // Attempt to compare them normally, and if the element's aren't equal under the comparison, return the result.
        let compareResult = comparator(a[0], b[0]);
        if (compareResult != 0) return compareResult;
        // If the elements were equal, return the difference in their indexes, to ensure they still in the same order.
        return (a[1] - b[1]);
    };

    // Create a new array where each element is replaced with a sub-array of the element and it's index.
    elementIndexArray = array.map((el, index) => [el, index]);
    // Sort this array with the stablized sorting algorithm.
    elementIndexArray.sort(stableCompare);

    // Extract the elements back out of the derived array and return it.
    elementIndexArray.forEach(function(element, index, arr) {
        arr[index] = element[0];
    });
    return elementIndexArray;
}

function setSortBy(sortByOption) {
    document.getElementById("sort-by-chooser").value = sortByOption;
}

//==============================================================================
// Filtering
//==============================================================================

// Set of all the currently enabled standard filters.
// These are stored as booleans ('true' for standard and 'false' for nonstandard).
let standardFilters;
// Set of all the currently enabled family filters.
let familyFilters;
// Set of all the currently enabled side count filters.
let sideCountFilters;
// Dictionary mapping category names to their corresponding filter arrays.
let filterCategories;

// Array containing only the filtered model cards that should be displayed to the user, in sorted order.
let filteredModelArray;

function createFilters(families, sideCounts) {
    // First create arrays for storing all the filter's states.
    standardFilters = new Set([true, false]);
    familyFilters = new Set(families);
    sideCountFilters = new Set(sideCounts);
    // Store all the filter arrays in the filterCategories dictionary.
    filterCategories = { "standard": standardFilters, "family": familyFilters, "side-count": sideCountFilters};

    // Create UI fields for each of the standard filters.
    createFilterField("standard", "Standard Dice");
    createFilterField("standard", "Nonstandard Dice");

    // Create UI fields for each of the family filters.
    for (familyFilter in familyFilters) {
        createFilterField("family", familyFilter);
    }

    // Create UI fields for each of the side count filters.
    for (sideCountFilter in sideCountFilters) {
        createFilterField("sideCount", sideCountFilter);
    }
}

function createFilterField(category, filter) {
    // Lowercase the filter name and replace spaces with dashes.
    sanitizedFilter = filter.replace(' ', '-').toLowerCase();

    // Create a div for placing the field's elements into.
    const filterField =  document.createElement("div");
    filterField.id = `${sanitizedFilter}-filter`;
    filterField.className = "filter-field";

    // Create a checkbox for toggling the filter.
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.id = `${sanitizedFilter}-checkbox`;
    checkbox.checked = true;
    filterField.appendChild(checkbox);

    // Create a label saying what the filter is for.
    const label = document.createElement("label");
    label.for = checkbox.id;
    label.innerText = filter;
    filterField.appendChild(label);

    // Add an action listener to toggle the filter when clicked.
    checkbox.addEventListener("change", () => updateFilter(category, sanitizedFilter));

    // Add the div to the filter category's container.
    document.getElementById(`${category}-filters`).appendChild(filterField);
}

function setSearchBar(value) {
    document.getElementById("search-bar").value = value;
}

function setFilter(category, filter, isEnabled) {
    if (isEnabled) {
        filterCategories[category].add(filter);
    } else {
        filterCategories[category].delete(filter);
    }
}

function computeFilteredModelArray() {
    // Determine which sorted list should be used based on the current value of the sort by chooser.
    const chooser = document.getElementById("sort-by-chooser");
    let sortedModelArray;
    switch (chooser.value) {
        case "STANDARD":
            sortedModelArray = sortedByStandard;
            break;
        case "FAMILY":
            sortedModelArray = sortedByFamily;
            break;
        case "SIDES":
            sortedModelArray = sortedBySideCount;
            break;
        case "NAME":
            sortedModelArray = sortedByName;
            break;
        default:
            console.error(`Critical: impossible value stored in sort-by-chooser! value=${chooser.value}`);
    }

    // Get the current value of the search bar and lowercase it for comparisons.
    const searchValue = document.getElementById("search-bar").value.toLowerCase();

    // Filter the array down and store the result.
    filteredModelArray = sortedList.filter(function(model) {
        return (standardFilters.has(model.isStandard) &&
                familyFilters.has(model.family) &&
                sideCountFilters.has(model.sideCount) &&
                model.name.toLowerCase().includes(searchValue));
    });

    // Update the model card display.
    updateCardDisplay();
}

//==============================================================================
// Warehouse Display
//==============================================================================

let startX = -1;
let sidebarWidth = -1;

function startDrag(event) {
    // Start the divider dragging by storing the initial sidebar width, and the x coordinate of the user's click.
    startX = event.clientX;
    sidebarWidth = document.getElementById("sidebar").offsetWidth;
    // Set the page's cursor to 'ew-resize' to match the divider's hover-over cursor. This prevents the cursor from
    // flickering back and forth while the divider is catching up the mouse location.
    document.body.style.cursor = "ew-resize";
}

function endDrag() {
    if (sidebarWidth > -1) {
        // Clear all the properties set during the divider drag.
        startX = -1;
        sidebarWidth = -1;
        document.body.style.cursor = "";
    }
}

function onDrag(event) {
    if (sidebarWidth > -1) {
        let newWidth = Math.max((sidebarWidth + (event.clientX - startX)), 144);
        document.getElementById("sidebar").style.width = `${newWidth}px`;
    }
}

function updateCardDisplay() {

}
