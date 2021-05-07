
//TODO Add localization somehow.

//==============================================================================
// Sketchup Callbacks
//==============================================================================

function setModel(modelName) {
    //TODO sketchup.setModel(modelName);
    console.log(`Set Model to ${modelName}...`);
}

function setSortBy(sortType) {
    //TODO sketchup.setSortBy(sortType);
    console.log(`Set SortType to ${sortType}...`);
}

function toggleFilter(filterName, isChecked) {
    //TODO sketchup.toggleFilter(filterName, isChecked);
    console.log(`Toggling the ${filterName} filter to ${isChecked}...`);
}

//==============================================================================
// Model Management
//==============================================================================

class ModelCard {
    static modelCardArray = [];

    static modelFamilies = Set();
    static modelSideCounts = Set();

    constructor(modelName, imageURL, family, sideCount, isStandard) {
        // Store the provided data.
        this.name = modelName;
        this.imageURL = imageURL;
        this.family = family;
        this.sideCount = sideCount;
        this.isStandard = isStandard;

        // Add entries to the 'families' and 'sidecounts' arrays if this model has new entries.
        if (!modelFamilies.has(family)) {
            modelFamilies.add(family);
        }
        if (!modelSideCounts.has(sideCount)) {
            modelSideCounts.add(sideCount);
        }

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

//==============================================================================
// Sorting and Filtering
//==============================================================================









//==============================================================================
// Model Management
//==============================================================================

// List of all the models currently in the warehouse, unsorted (or sorted in the order they were added).
// Models are stored as the 'div's representing their cards.
let modelCardArray = [];
// This array stores the order to display models in according to the current 'sort-by' criteria.
// Models are referenced by index (corresponding to their index in 'modelArray'), and the array contains all models.
// Even those that have been filtered out.
let sortedModelArray = [];
// This array stores whether each model should be displayed or whether it's been filtered out. True means it should be
// displayed, and false means it's been filtered out and shouldn't be. It shares indexes with 'modelArray'.
let enabledModelList = [];

// Dictionary that sorts all the models by polyhedral family. Keys are the names of a family, and the corresponding
// values are arrays that store each of the models in that family by index (their index in modelCardArray).
let modelFamilies = {};

// Dictionary that sorts all the models by side count. Keys are an integer representing the number of sides, and the
// corresponding values are arrays that store every model with that many sides by index (their index in modelCardArray).
let modelSideCounts = {};

// Dictionary that sorts all the models by whether they're standard. There are 2 keys: "standard" and "nonstandard" each
// of which has an array value that stores all the models corresponding to the key (by their index in modelCardArray).
let modelStandardness = { "standard" : [], "nonstandard": [] };

function addModel(modelName, imageURL, sideCount, family, isStandard) {

}

//==============================================================================
// Sorting and Filtering
//==============================================================================

function setSortBy(sortType) {

}

function setFilterState(filterName, isChecked) {

}

function sortModels() {

}

function filterModels() {

}



        // Add the model's card's index to the correct categories.
        if (!(family in modelFamilies)) {
          modelFamilies[family] = [];
      }
      modelFamilies[family].push(index);

      if (!(sideCount in modelSideCounts)) {
          modelSideCounts[sideCount] = [];
      }
      modelSideCounts[sideCount].push(index);

      modelStandardness[(isStandard? "standard" : "nonstandard")].push(index);


  


It should be an AND operation. So if any filter is unchecked that applies to a model, then the model is totally disabled.

So we need the dictionaries, that's for sure. One for standardness, family, and sideCount. We'll definitely keep those.
For the sorting... We don't actually need to sort them. We can just iterate through the dictionaries... And that's good
enough actually. So for sorting, we don't even need a separate list, we can just clear the div, then append children in
the order of the dictionary.

And then for filtering things... We will need to store the filters somehow...
Okay, side note, we'll use a Map instead of a 'dictionary' object object. But anyways, for filters... I guess while iterating
over one of the maps we'll need to check every single element, which is meh. So we'll keep... 

Okay, so the simple iterating idea doesn't actually work. It won't work for alphabetical, nor for side counts.
So, maybe we'll want presorted lists?

No, we'll make presorted arrays, one for each option. There's no reason not too, the models wont change very often.
So, yeah presorted arrays are okay, and then for filtering.class


modelCardArray = [];
  class modelCard {
    cardElement
    name
    family
    isStandard
    sideCount
  }

familyFilters = Set()
sideCountFilters = Set()
standardFilters = Set()

families = [];
sideCounts = [];

// Presorted array for each card.
NameSortedCard = [];
...

// Iterare in order through presorted array checking filters while going.