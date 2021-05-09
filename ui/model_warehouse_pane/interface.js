
//TODO Add localization somehow.
//TODO make the search bar fancier so it can also search for D% and stuff. Maybe?...

//==============================================================================
// Sketchup Callbacks
//==============================================================================

function chooseModel(modelName) {
    //TODO No, make the text of the model card turn blue for the selected model.

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

function toggleSortByDirection() {
    // By default (with no transform) is points down and sorts descendingly. If there is a transform, it's ascending.
    const sortDirection = document.getElementById("sort-by-direction-arrow").hasAttribute("transform");
    setSortByDirection(!sortDirection);

    // Change the sorting criteria and display the re-filtered cards in order.
    computeFilteredModelArray();

    //TODO sketchup.updateSortByDirection(!sortDirection);
    console.log(`Set SortDirection to ${!sortDirection}...`);
}

function updateFilter(category, filter) {
    // Update the filtering criteria.
    const isChecked = document.getElementById(`${filter}-checkbox`).checked;
    if (isChecked) {
        currentFilters[category].add(filter);
    } else {
        currentFilters[category].delete(filter);
    }
    // Filter the models according to the new filter criteria and display the remaining cards in order.
    computeFilteredModelArray();

    //TODO sketchup.updateFilter(filter, isChecked);
    console.log(`Toggling the ${filter} filter to ${isChecked}...`);
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
        this.sanitizedFamily = family.replace(' ', '-').toLowerCase();
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
        modelLabel.className = "model-name-label";
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

        // Store a reference to the model's card.
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
    // Array of all the family names but lowercased and with spaces sanitized into dashes.
    let sanitizedFamilies = [];
    // Array containing the side counts for all the models that have been added to the warehouse.
    let sideCounts = [];

    for (let i = 0, modelCard; modelCard = modelCardArray[i]; i++) {
        // If this model's family hasn't been seen yet, add it to the family array.
        if (!families.includes(modelCard.family)) {
            families.push(modelCard.family);
            sanitizedFamilies.push(modelCard.sanitizedFamily);
        }
        // If this model's side count hasn't been seen yet, add it the side count array.
        if (!sideCounts.includes(modelCard.sideCount)) {
            sideCounts.push(modelCard.sideCount);
        }
    }
    sideCounts.sort((a, b) => a-b);

    // Create filters for each of the families and side counts.
    createFilters(families, sanitizedFamilies, sideCounts);
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

function setSortByDirection(direction) {
    const arrow = document.getElementById("sort-by-direction-arrow");
    // True means sort ascending, false means sort descending.
    if (direction) {
        arrow.setAttribute("transform", "rotate(180, 3, 8)");
    } else {
        arrow.removeAttribute("transform");
    }
}

//==============================================================================
// Filtering
//==============================================================================

// Set of all the possible standard filters.
let standardFilters;
// Set of all the possible family filters.
let familyFilters;
// Set of all the possible side count filters.
let sideCountFilters;
// Dictionary that contains all the currently enabled filters.
// They are grouped into categories and stored as sets keyed by the name of the category.
let currentFilters;

// Array containing only the filtered model cards that should be displayed to the user, in sorted order.
let filteredModelArray;

function createFilters(families, sanitizedFamilies, sideCounts) {
    // Create arrays for storing all the filter's states.
    standardFilters = new Set(["standard", "nonstandard"]);
    familyFilters = new Set(sanitizedFamilies);
    sideCountFilters = new Set(sideCounts);
    // Store all the filter arrays in the currentFilters dictionary.
    currentFilters = { "standard": new Set(standardFilters),
                       "family": new Set(familyFilters),
                       "side-count": new Set(sideCountFilters)};

    // Create UI fields for each of the standard filters.
    createFilterField("standard", "standard", "Standard Dice");
    createFilterField("standard", "nonstandard", "Nonstandard Dice");

    // Create UI fields for each of the family filters.
    for (let i = 0; i < families.length; i++) {
        createFilterField("family", sanitizedFamilies[i], families[i]);
    }

    // Create UI fields for each of the side count filters.
    for (let sideCount of sideCounts) {
        createFilterField("side-count", sideCount, sideCount.toString());
    }
}

function createFilterField(category, filterValue, filterLabel) {
    // Create a div for placing the field's elements into.
    const filterField =  document.createElement("div");
    filterField.id = `${filterValue}-filter`;
    filterField.className = "filter-field";

    // Create a checkbox for toggling the filter.
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.id = `${filterValue}-checkbox`;
    checkbox.checked = true;
    filterField.appendChild(checkbox);

    // Create a label saying what the filter is for.
    const label = document.createElement("label");
    label.htmlFor = checkbox.id;
    label.innerText = filterLabel;
    filterField.appendChild(label);

    // Add an action listener to toggle the filter when clicked.
    // We need to create a temporary set of the parameters for 'updateFilter' AND need them to be in a seperate scope,
    // so they're dropped after the scope exits. Otherwise, the action listener's closure will capture pointers to this
    // function's parameters, which will change every time 'createFilterField' is called.
    {
        let categoryCopy = category;
        let filterValueCopy = filterValue;
        checkbox.addEventListener("change", () => updateFilter(categoryCopy, filterValueCopy));
    }

    // Add the div to the filter category's container.
    document.getElementById(`${category}-filters-content`).appendChild(filterField);
}

function setSearchBar(value) {
    document.getElementById("search-bar").value = value;
}

function setFilter(category, filter, isEnabled) {
    document.getElementById(`${filter}-checkbox`).checked = isEnabled;
    if (isEnabled) {
        currentFilters[category].add(filter);
    } else {
        currentFilters[category].delete(filter);
    }
}

function clearFilters() {
    // Enable all the filters by resetting the filter categories dictionary.
    currentFilters = { "standard": new Set(standardFilters),
                       "family": new Set(familyFilters),
                       "side-count": new Set(sideCountFilters)};

    // Update all the UI elements and call the appropiate sketchup callbacks.
    for (let filter of standardFilters) {
        document.getElementById(`${filter}-checkbox`).checked = true;
        //TODO sketchup.updateFilter(filter, true);
        console.log(`Toggling the ${filter} filter to true...`);
    }
    for (let filter of familyFilters) {
        document.getElementById(`${filter}-checkbox`).checked = true;
        //TODO sketchup.updateFilter(filter, true);
        console.log(`Toggling the ${filter} filter to true...`);
    }
    for (let filter of sideCountFilters) {
        document.getElementById(`${filter}-checkbox`).checked = true;
        //TODO sketchup.updateFilter(filter, true);
        console.log(`Toggling the ${filter} filter to true...`);
    }

    // Recompute the model array now that all the filters have been enabled.
    computeFilteredModelArray();
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
    filteredModelArray = sortedModelArray.filter(function(model) {
        return (currentFilters["standard"].has(model.isStandard? "standard" : "nonstandard") &&
                currentFilters["family"].has(model.sanitizedFamily) &&
                currentFilters["side-count"].has(model.sideCount) &&
                model.name.toLowerCase().includes(searchValue));
    });

    // Check if the array should be sorted descendingly (default) or ascendingly. With no transform, the sorting
    // direction arrows points down for descending. If it is transformed, it's pointing up for ascending.
    if (document.getElementById("sort-by-direction-arrow").hasAttribute("transform")) {
        filteredModelArray.reverse();
    }

    // Update the model card display.
    updateWarehouseListings();
}

//==============================================================================
// Warehouse Display
//==============================================================================

// The number of cards currently being shown per row in the warehouse. This is stored globally so the
// 'updateCardDisplay' function can compare against it effeciently, instead of needing to compute it every time.
let currentCardsPerRow = -1;

function updateWarehouseListings() {
    const warehouse = document.getElementById("warehouse");
    // Compute how much space is usable in the warehouse by subtracting the left margin.
    const warehousePaneWidth = warehouse.clientWidth - cardMargin;

    const columnCount = Math.max(Math.floor(warehousePaneWidth / (minCardWidth + cardBorderWidth + cardMargin)), 1);
    const rowCount = Math.ceil(filteredModelArray.length / columnCount);
    const cardWidth = (warehousePaneWidth / columnCount) - (cardBorderWidth + cardMargin);

    // Remove all the cards from the table.
    for (let i = 0, row; row = warehouse.children[i]; i++) {
        while (row.firstChild) {
            row.removeChild(row.lastChild);
        }
    }

    // Add or remove divs to reach the correct number of rows in the warehouse.
    const rowDelta = rowCount - warehouse.childElementCount;
    if (rowDelta > 0) {
        for (let i = 0; i < rowDelta; i++) {
            warehouse.appendChild(document.createElement("div"));
        }
    } else
    if (rowDelta < 0) {
        for (let i = 0; i < rowDelta; i++) {
            warehouse.removeChild(warehouse.lastChild);
        }
    }

    // Iterate through the rows and add the cards back into the table in the new order.
    for (let i = 0; i < filteredModelArray.length; i++) {
        let card = filteredModelArray[i].cardElement;
        // First resize the card to fit the page though.
        card.style.width = `${cardWidth}px`;
        let testing = Math.floor(i / columnCount);
        warehouse.children[testing].appendChild(card);
    }

    // Set how many cards there are per row.
    currentCardsPerRow = columnCount;
}

// The x coord that the user clicked when the dragging began. -1 means the user isn't currently dragging the divider.
let startX = -1;
// The width of the sidebar when the dragging began. -1 means the user isn't currently dragging the divider.
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
        // Set the sidebar's new width.
        let newWidth = Math.max((sidebarWidth + (event.clientX - startX)), 150);
        document.getElementById("sidebar").style.width = `${newWidth}px`;
        // Update the card display so they neatly fit within the warehouse window.
        updateCardDisplay();
        // Stop the event from propogating and doing anything weird (like trying to 'drag' the divider element, or
        // highlighting text in the window while the divider is being moved).
        event.preventDefault();
        event.stopPropagation();
    }
}

function updateCardDisplay() {
    const warehouse = document.getElementById("warehouse");
    // Compute how much space is usable in the warehouse by subtracting the left margin.
    const warehousePaneWidth = warehouse.clientWidth - cardMargin;
    const columnCount = Math.max(Math.floor(warehousePaneWidth / (minCardWidth + cardBorderWidth + cardMargin)), 1);

    // If the number of cards that fit in a margin has changed, relayout the entire grid.
    if (currentCardsPerRow != columnCount) {
        return updateWarehouseListings();
    }

    // Change the width of each of the table's cells.
    const cardWidth = (warehousePaneWidth / columnCount) - (cardBorderWidth + cardMargin);
    for (let i = 0; i < filteredModelArray.length; i++) {
        let card = filteredModelArray[i].cardElement;
        card.style.width = `${cardWidth}px`;
    }
}
