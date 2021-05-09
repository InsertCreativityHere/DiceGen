
//TODO add hover-over text explaining what each thing does.
//TODO change all my lets into consts where applicable
//TODO add validation logic to fields before accepting them.
//TODO figure out how to handle having multiple models open at once!
//TODO  Every function should have a comment on it.
//TODO also check that I'm not being dumb and making global variables anywhere either
//TODO ALSO CHECK FOR SEMICOLONS
//TODO try to track and set more of the window states (like what's open and closed or check and whatever)
//TODO go through and refactor all this code. There's definitely lots of places that could be better centralized.

// Maybe every kind of field should have a set-function which literally just performs the setting of the data.
// And an update that does other things (most importantly it'll callback into Sketchup).
// We need to stop having a single method do too much though, since it's hurting re-usability. Idk.

//==============================================================================
// Sketchup Callbacks
//==============================================================================

function selectBaseModel() {
    //TODO sketchup.selectBaseModel();
    console.log("Select Base Model...");

    // TODO remove all of this!
    clearModelVariableFields();
    clearGlyphMappings();
    clearGlyphFields();

    setButtonField("base-model", "(D10) Pentagonal Trapezohedron");

    addModelVariableField("die-width", "Die Width", 0, 10, 3, 0.1, 0.5);
    addModelVariableField("die-height", "Die Height", 0, 20, 5, 0.5, 1);
    toggleModelVariableSection(true);
    addGlyphMapping("D10");
    addGlyphMapping("D%");
    createGlyphFields(10);
    toggleGlyphFields(true);
}

function selectFont() {
    //TODO sketchup.selectFont();
    console.log("Select Font...");
}

function selectFontForGlyph(index) {
    //TODO skectup.selectFontForGlyph(index);
    console.log(`Select Font For ${index}...`);
}

function resetGlyphFields() {
    // Prompt the user to make sure they want to do this, and if they hit cancel, return and do nothing.
    if (!confirm(currentLocale["ResetGlyphFieldPrompt"])) {
        return;
    }

    const glyphCount = document.getElementById("glyph-table-body").childElementCount;

    // Iterate through each glyph's text box field and reset it to it's defaultValue.
    for (let i = 1; i <= glyphCount; i++) {
        const glyphTextField = document.getElementById(`glyph-${i}-text`);
        if (glyphTextField.value != glyphTextField.defaultValue) {
            glyphTextField.value = glyphTextField.defaultValue;
            glyphTextField.dispatchEvent(new Event("input"));
        }
    }

    //TODO skectup.resetGlyphFields();
    console.log(`Reset glyph fields.`);
}

function openAdvancedGlyphMenu() {
    //TODO sketchup.openAdvancedGlyphMenu();
    console.log("Open Advanced Glyph Menu...");
}

function updateValue(fieldName, value) {
    //TODO sketchup.updateValue(fieldName, value);
    console.log(`Update ${fieldName} to ${value}...`);
}

//==============================================================================
// Display Toggling
//==============================================================================

function toggleMenu(menuName) {
    const content = document.getElementById(`${menuName}-menu-content`);
    const dropdown = document.getElementById(`${menuName}-menu-dropdown`);

    if (content.style.display == "none") {
        content.style.display = "";
        dropdown.innerHTML = "&#x25BE;";
    } else {
        content.style.display = "none";
        dropdown.innerHTML = "&#x25B8;";
    }
}

function toggleSection(sectionName) {
    const content = document.getElementById(`${sectionName}-section`);
    const checkbox = document.getElementById(`${sectionName}-checkbox`);

    if (checkbox.checked) {
        content.style.display = "";
    } else {
        content.style.display = "none";
    }
    updateValue(sectionName, checkbox.checked);
}

function toggleGlyphFields(isVisible) {
    display = (isVisible? "" : "none");
    document.getElementById("emboss-depth-field").style.display = display;
    document.getElementById("glyph-mapping-field").style.display = display;
    document.getElementById("glyphs-section").style.display = display;
    document.getElementById("glyph-mapping-controls").style.display = display;
}

//==============================================================================
// Generic Field Setters
//==============================================================================

function setSliderField(fieldName, value) {
    document.getElementById(`${fieldName}-slider`).value = value;
    document.getElementById(`${fieldName}-input`).value = value;
}

function setCheckboxField(fieldName, value) {
    document.getElementById(`${fieldName}-checkbox`).value = value;
}

function setChooserField(fieldName, value) {
    document.getElementById(`${fieldName}-chooser`).value = value;
}

function setButtonField(fieldName, value) {
    document.getElementById(`${fieldName}-button`).innerHTML = value;
}

//==============================================================================
// Model Variable Fields
//==============================================================================

function addModelVariableField(fieldName, displayName, min, max, defaultValue, sliderStep, inputStep) {
    // Create the div that will hold everything for the field.
    const variableField = document.createElement("div");
    variableField.id = `${fieldName}-field`;
    variableField.className = "field";

    // Create the field's label.
    const sliderLabel = document.createElement("label");
    sliderLabel.htmlFor = variableField.id;
    sliderLabel.innerHTML = displayName;
    variableField.appendChild(sliderLabel);

    // Create the field's range slider.
    const rangeInput = document.createElement("input");
    rangeInput.type = "range";
    rangeInput.id = `${fieldName}-slider`;
    rangeInput.step = sliderStep;
    rangeInput.value = defaultValue;
    rangeInput.defaultValue = defaultValue;
    rangeInput.min = min;
    rangeInput.max = max;

    // Create the field's number input box.
    const numberInput = document.createElement("input");
    numberInput.type = "number";
    numberInput.id = `${fieldName}-input`;
    numberInput.step = inputStep;
    numberInput.value = defaultValue;
    numberInput.defaultValue = defaultValue;

    // Create the container for storing all the non-label portions of the field.
    // We have these in a separate div so that we can push them all to the right of the page easier.
    const sliderContainer = document.createElement("div");
    sliderContainer.className = "slider-input";
    // Add the slider bar (with it's min&max labels) and the number input box.
    sliderContainer.appendChild(document.createTextNode(min));
    sliderContainer.appendChild(rangeInput);
    sliderContainer.appendChild(document.createTextNode(max));
    sliderContainer.appendChild(numberInput);
    variableField.appendChild(sliderContainer);

    // Add the field's div container to the model variables section of the page.
    const modelVariablesSection = document.getElementById("model-variables-section");
    modelVariablesSection.appendChild(variableField);

    // Set scripts and callbacks on the elements for communicating with sketchup and syncing the slider and input box.
    configureSliderInput(fieldName);
}

function clearModelVariableFields() {
    const modelVariablesSection = document.getElementById("model-variables-section");
    // Remove the field elements from the section.
    while (modelVariablesSection.firstChild) {
        modelVariablesSection.removeChild(modelVariablesSection.lastChild);
    }
}

function toggleModelVariableSection(isVisible) {
    document.getElementById("model-variables-section").style.display = (isVisible? "" : "none");
}

//==============================================================================
// Glyph Mapping Options
//==============================================================================

function addGlyphMapping(mappingName) {
    // Create the option that will hold the mapping's name.
    const option = document.createElement("option");
    option.value = mappingName.toUpperCase();
    option.innerHTML = mappingName;

    // Add the option to the glyph mapping chooser.
    const glyphMappingChooser = document.getElementById("glyph-mapping-chooser");
    glyphMappingChooser.add(option);
}

function setGlyphMapping(mappingName) {
    const glyphMappingChooser = document.getElementById("glyph-mapping-chooser");
    glyphMappingChooser.value = mappingName.toUpperCase();
}

function clearGlyphMappings() {
    const glyphMappingChooser = document.getElementById("glyph-mapping-chooser");
    // Remove the options from the chooser.
    while (glyphMappingChooser.length > 0) {
        glyphMappingChooser.remove(0);
    }
}

//==============================================================================
// Glyph Fields
//==============================================================================

function createGlyphFields(glyphCount) {
    const glyphTable = document.getElementById("glyph-table-body");
    for (let i = 1; i <= glyphCount; i++) {
        const glyphRow = glyphTable.insertRow(-1);

        // Create a label saying which glyph index this row's fields are for.
        let glyphIndexLabel = document.createElement("label");
        glyphIndexLabel.htmlFor = `glyph-${i}-text`;
        glyphIndexLabel.innerHTML = i;

        // Create a cell for holding the glyph index label in.
        let glyphIndexCell = glyphRow.insertCell(-1);
        glyphIndexCell.className = "glyph-index-cell";
        glyphIndexCell.appendChild(glyphIndexLabel);

        // Create a text input box so users can customize the text content of the glyph.
        let glyphTextField = document.createElement("input");
        glyphTextField.type = "text";
        glyphTextField.id = glyphIndexLabel.htmlFor;
        glyphTextField.className = "glyph-text-field";
        glyphTextField.value = i;
        glyphTextField.defaultValue = i;
        glyphTextField.addEventListener("input", function() {
            const input = document.getElementById(glyphTextField.id);
            updateValue(glyphTextField.id, input.value);
        })
        glyphRow.insertCell(-1).appendChild(glyphTextField);

        // Create a font selector button for changing the individual glyph's font.
        let fontSelector = document.createElement("button");
        fontSelector.type = "button";
        fontSelector.id = `glyph-${i}-font`;
        fontSelector.className = "glyph-font-button";
        fontSelector.innerHTML = currentLocale["None"];
        fontSelector.addEventListener("click", function() {
            selectFontForGlyph(i);
        })
        glyphRow.insertCell(-1).appendChild(fontSelector);
    }
}

function setGlyphFields(index, text = null, font = null) {
    if (text != null) {
        document.getElementById(`glyph-${index}-text`).value = text;
        document.getElementById(`glyph-${index}-text`).defaultValue = text;
    }

    if (font != null) {
        document.getElementById(`glyph-${index}-font`).innerHTML = font;
    }
}

function setFontForAllGlyphs(font) {
    const glyphFontButtons = document.getElementsByClassName("glyph-font-button");
    glyphFontButtons.forEach(button => button.innerHTML = font);
}

function clearGlyphFields() {
    const glyphTableBody = document.getElementById("glyph-table-body");
    // Remove the all the elements from the glyphs section.
    while (glyphTableBody.firstChild) {
        glyphTableBody.removeChild(glyphTableBody.lastChild)
    }
}

function getCustomizedGlyphFields() {
    const glyphCount = document.getElementById("glyph-table-body").childElementCount;

    // This array stores the indexes of every glyph whose text was manually set by the user.
    let customized = [];
    for (let i = 1; i <= glyphCount; i++) {
        const glyphTextField = document.getElementById(`glyph-${i}-text`);
        // Check if the glyph's text was customized (it's value isn't the default for the current glyph mapping).
        if (glyphTextField.value != glyphTextField.defaultValue) {
            customized.push(i);
        }
    }
}

//==============================================================================
// Corner to Edge Lock Synchronization
//==============================================================================

function updateEdgeCornerTypeLock() {
    const edgeFields = {
        "edge-type-chooser": synchronizeToEdgeTypeChooser,
        "beveled-edge-depth-slider": synchronizeToBelevedEdgeDepthSlider,
        "beveled-edge-depth-input": synchronizeToBelevedEdgeDepthInput,
        "rounded-edge-depth-slider": synchronizeToRoundedEdgeDepthSlider,
        "rounded-edge-depth-input": synchronizeToRoundedEdgeDepthInput,
        "rounded-edge-curvature-slider": synchronizeToRoundedEdgeCurvatureSlider,
        "rounded-edge-curvature-input": synchronizeToRoundedEdgeCurvatureInput,
    };

    const cornerFields = [
        "corner-type-chooser",
        "truncated-corner-depth-slider",
        "truncated-corner-depth-input",
        "kleetoped-corner-depth-slider",
        "kleetoped-corner-depth-input",
        "rounded-corner-depth-slider",
        "rounded-corner-depth-input",
        "rounded-corner-curvature-slider",
        "rounded-corner-curvature-input"
    ];

    const checkbox = document.getElementById("lock-corner-edge-types-checkbox");
    if (checkbox.checked) {
        // Register event callbacks on each of the edge field elements that trigger when it's input is changed,
        // and updates the corresponding corner field to match the new value, keeping them in sync.
        for (let element in edgeFields) {
            let func = edgeFields[element];
            document.getElementById(element).addEventListener("input", func);
            // Call the sychronization function to update the fields initially.
            func();
        }
        // Disable each of the corner field elements so the user can't manually desyncronize them.
        cornerFields.forEach(element => {
            document.getElementById(element).disabled = true;
        });
    } else {
        // Un-register the synchronization event listeners.
        for (let element in edgeFields) {
            let func = edgeFields[element];
            document.getElementById(element).removeEventListener("input", func);
        }
        // Re-enable each of the corner field elements so the user can manually control them.
        cornerFields.forEach(element => {
            document.getElementById(element).disabled = false;
        });
    }
}

function synchronizeToEdgeTypeChooser() {
    const edgeChooser = document.getElementById("edge-type-chooser");
    const cornerChooser = document.getElementById("corner-type-chooser");

    if (edgeChooser.value == cornerChooser.value) {
        return;
    }

    switch (edgeChooser.value) {
        case "NORMAL":
            cornerChooser.value = "NORMAL";
            break;
        case "BEVELED":
            cornerChooser.value = "KLEETOPED";
            break;
        case "ROUNDED":
            cornerChooser.value = "ROUNDED";
            break;
        default:
            console.error(`Critical: impossible value stored in edge-type-chooser! value=${chooser.value}`);
            break;
    }
    cornerChooser.dispatchEvent(new Event("change"));
}

function synchronizeToEdgeField(edgeElementId, cornerInputId) {
    const edgeElement = document.getElementById(edgeElementId);
    const cornerInput = document.getElementById(cornerInputId);

    if (edgeElement.value == "") {
        var newValue = edgeElement.defaultValue;
    } else {
        var newValue = edgeElement.value;
    }

    if (cornerInput.value == newValue) {
        return;
    }

    cornerInput.value = newValue;
    cornerInput.dispatchEvent(new Event("input"));
}

function synchronizeToBelevedEdgeDepthSlider() {
    synchronizeToEdgeField("beveled-edge-depth-slider", "kleetoped-corner-depth-input");
}

function synchronizeToBelevedEdgeDepthInput() {
    synchronizeToEdgeField("beveled-edge-depth-input", "kleetoped-corner-depth-input");
}

function synchronizeToRoundedEdgeDepthSlider() {
    synchronizeToEdgeField("rounded-edge-depth-slider", "rounded-corner-depth-input");
}

function synchronizeToRoundedEdgeDepthInput() {
    synchronizeToEdgeField("rounded-edge-depth-input", "rounded-corner-depth-input");
}

function synchronizeToRoundedEdgeCurvatureSlider() {
    synchronizeToEdgeField("rounded-edge-curvature-slider", "rounded-corner-curvature-input");
}

function synchronizeToRoundedEdgeCurvatureInput() {
    synchronizeToEdgeField("rounded-edge-curvature-input", "rounded-corner-curvature-input");
}

//==============================================================================
// Chooser Update Functions
//==============================================================================

function updateBorderCorners() {
    const chooser = document.getElementById("face-border-corners-chooser");
    const straightCornersSection = document.getElementById("straight-border-corners-section");
    const roundedCornersSection = document.getElementById("rounded-border-corners-section");

    switch (chooser.value) {
        case "EMPTY":
            straightCornersSection.style.display = "none";
            roundedCornersSection.style.display = "none";
            break;
        case "STRAIGHT":
            straightCornersSection.style.display = "";
            roundedCornersSection.style.display = "none";
            break;
        case "ROUNDED":
            straightCornersSection.style.display = "none";
            roundedCornersSection.style.display = "";
            break;
        default:
            console.error(`Critical: impossible value stored in face-border-corners-chooser! value=${chooser.value}`);
            break;
    }
    updateValue("face-border-corners", chooser.value);
}

function updateEdgeType() {
    const chooser = document.getElementById("edge-type-chooser");
    const beveledEdgeSection = document.getElementById("beveled-edge-type-section");
    const roundedEdgeSection = document.getElementById("rounded-edge-type-section");

    switch (chooser.value) {
        case "NORMAL":
            beveledEdgeSection.style.display = "none";
            roundedEdgeSection.style.display = "none";
            break;
        case "BEVELED":
            beveledEdgeSection.style.display = "block";
            roundedEdgeSection.style.display = "none";
            break;
        case "ROUNDED":
            beveledEdgeSection.style.display = "none";
            roundedEdgeSection.style.display = "block";
            break;
        default:
            console.error(`Critical: impossible value stored in edge-type-chooser! value=${chooser.value}`);
            break;
    }
    updateValue("edge-type", chooser.value);
}

function updateCornerType() {
    const chooser = document.getElementById("corner-type-chooser");
    const truncatedCornerSection = document.getElementById("truncated-corner-type-section");
    const kleetopedCornerSection = document.getElementById("kleetoped-corner-type-section");
    const roundedCornerSection = document.getElementById("rounded-corner-type-section");

    switch (chooser.value) {
        case "NORMAL":
            truncatedCornerSection.style.display = "none";
            kleetopedCornerSection.style.display = "none";
            roundedCornerSection.style.display = "none";
            break;
        case "TRUNCATED":
            truncatedCornerSection.style.display = "block";
            kleetopedCornerSection.style.display = "none";
            roundedCornerSection.style.display = "none";
            break;
        case "KLEETOPED":
            truncatedCornerSection.style.display = "none";
            kleetopedCornerSection.style.display = "block";
            roundedCornerSection.style.display = "none";
            break;
        case "ROUNDED":
            truncatedCornerSection.style.display = "none";
            kleetopedCornerSection.style.display = "none";
            roundedCornerSection.style.display = "block";
            break;
        default:
            console.error(`Critical: impossible value stored in corner-type-chooser! value=${chooser.value}`);
            break;
    }
    updateValue("corner-type", chooser.value);
}

function updateGlyphMapping() {
    const chooser = document.getElementById("glyph-mapping-chooser");
    updateValue("glyph-mapping", chooser.value);
}
