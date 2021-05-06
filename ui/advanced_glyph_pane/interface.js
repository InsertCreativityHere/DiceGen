
//==============================================================================
// Sketchup Callbacks
//==============================================================================

function updateValue(fieldName, value) {
    //TODO sketchup.updateValue(fieldName, value);
    console.log(`Update ${fieldName} to ${value}...`);
}

function importGlyphMapping() {
    //TODO sketchup.importGlyphMapping();
    console.log("Import Glyph Mapping...");
}

function exportGlyphMapping() {
    //TODO sketchup.exportGlyphMapping();
    console.log("Export Glyph Mapping...");
}

//==============================================================================
// Glyph Mapping Field
//==============================================================================

var isMappingCustomized = false;

function AddGlyphMapping(mappingName) {
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

    // If the user has customized the current mapping
    if (isMappingCustomized) {
        // Inform the user that switching mappings will erase their changes and prompt for confirmation.
        if (!confirm(currentLocale["ResetMappingChangesPrompt"])) {
            return;
        }
        // Remove the custom psuedo-option
        glyphMappingChooser.remove(glyphMappingChooser.selectedIndex);
    }

    // Set the new glyph mapping.
    glyphMappingChooser.value = mappingName.toUpperCase();
    currentGlyphMapping = mappingName;
}

function setCustomMapping() {
    // Create an option that says "Custom"
    const option = document.createElement("option");
    option.value = "CUSTOM_MAPPING!";
    option.innerHTML = currentLocale["Custom"];

    // Add the custom option to the glyph mapping chooser.
    const glyphMappingChooser = document.getElementById("glyph-mapping-chooser");
    glyphMappingChooser.add(option);
    glyphMappingChooser.value = "CUSTOM_MAPPING!";

    isMappingCustomized = true;
}

function updateGlyphMapping() {
    const glyphMappingChooser = document.getElementById("glyph-mapping-chooser");

    // If the user has customized the current mapping
    if (isMappingCustomized) {
        // Inform the user that switching mappings will erase their changes and prompt for confirmation.
        if (!confirm(currentLocale["ResetMappingChangesPrompt"])) {
            // If the user cancel's, reset the glyph mapping selector back to 'Custom'.
            glyphMappingChooser.value = "CUSTOM_MAPPING!";
            return;
        }
        // If the user clicked 'Ok', remove the custom psuedo-option (always the last option).
        glyphMappingChooser.remove(glyphMappingChooser.length - 1);
    }

    isMappingCustomized = false;
    updateValue("glyph-mapping", glyphMappingChooser.value);
}

//==============================================================================
// Advanced Glyph Fields
//==============================================================================

function createAdvancedGlyphFields(glyphCount) {
    const glyphTableBody = document.getElementById("advanced-glyph-table-body");
    for (let i = 1; i <= glyphCount; i++) {
        let glyphRow = glyphTableBody.insertRow(-1);

        // Create a label saying which glyph index this row's fields are for.
        let glyphIndexLabel = document.createElement("label");
        glyphIndexLabel.for = `glyph-${i}-text`;
        glyphIndexLabel.innerHTML = i;

        // Create a cell for holding the glyph index label in.
        let glyphIndexCell = glyphRow.insertCell(-1);
        glyphIndexCell.className = "glyph-index-cell";
        glyphIndexCell.appendChild(glyphIndexLabel);

        // Create a numerical input box for controlling the scale of the glyph.
        let glyphScaleField = createNumericalInputField("scale", i, 1.0, 0.1)
        glyphRow.insertCell(-1).appendChild(glyphScaleField);

        // Create a numerical input box for controlling the angular orientation of the glyph.
        let glyphAngleField = createNumericalInputField("angle", i, 0.0, 5);
        glyphRow.insertCell(-1).appendChild(glyphAngleField);

        // Create a numerical input box for controlling the x-offset of the glyph.
        let glyphXOffsetField = createNumericalInputField("x", i, 0.0, 0.5);
        glyphRow.insertCell(-1).appendChild(glyphXOffsetField);

        // Create a numerical input box for controlling the y-offset of the glyph.
        let glyphYOffsetField = createNumericalInputField("y", i, 0.0, 0.5);
        glyphRow.insertCell(-1).appendChild(glyphYOffsetField);

        // Create a numerical input box for controlling the face the glyph is placed on.
        let glyphFaceIndexField = createNumericalInputField("face-index", i, 0, 1);
        glyphFaceIndexField.min = 0;
        glyphFaceIndexField.max = glyphCount;
        // Add a callback to check for any face index conflicts.
        glyphFaceIndexField.addEventListener("input", () => checkFaceIndexValidity(glyphCount));
        glyphRow.insertCell(-1).appendChild(glyphFaceIndexField);
    }
}

function createNumericalInputField(name, index, value, step) {
    let input = document.createElement("input");
    input.type = "number";
    input.id = `glyph-${index}-${name}`;
    input.className = `glyph-${name}-field`;
    input.value = value;
    input.defaultValue = value;
    input.step = step;

    // Add a function to update the Sketchup model and glyph mapping field when the input box's value is changed.
    input.addEventListener("input", function() {
        // Remove any leading 0's from the index.
        let currentValue = input.value;
        if (currentValue.length > 1) {
            input.value = currentValue.replace(/^0+/, "");
        }

        updateValue(input.id, input.value);

        // Change the glyph mapping field to say 'Custom' if it doesn't already.
        if (document.getElementById("glyph-mapping-chooser").value != "CUSTOM_MAPPING!") {
            setCustomMapping();
        }
    });

    // Add a function to fill the input box with it's default value if the user clicks off of it while it's empty.
    input.addEventListener("focusout", function() {
        // If the input is empty, fill it with it's default value.
        if (input.value == "") {
            input.value = input.defaultValue;
            updateValue(input.id, input.value);
        }
    });

    return input;
}

function setAdvancedGlyphFields(index, scale = null, angle = null, x = null, y = null, faceIndex = null) {
    if (scale != null) {
        document.getElementById(`glyph-${index}-scale`).value = scale;
    }

    if (angle != null) {
        document.getElementById(`glyph-${index}-angle`).value = angle;
    }

    if (x != null) {
        document.getElementById(`glyph-${index}-x`).value = x;
    }

    if (y != null) {
        document.getElementById(`glyph-${index}-y`).value = y;
    }

    if (faceIndex != null) {
        document.getElementById(`glyph-${index}-face-index`).value = faceIndex;
    }
}

function clearAdvancedGlyphFields() {
    const glyphTableBody = document.getElementById("advanced-glyph-table-body");
    // Remove the all the elements (rows) from the table body.
    while (glyphTableBody.firstChild) {
        glyphTableBody.removeChild(glyphTableBody.lastChild)
    }
}

function checkFaceIndexValidity(glyphCount) {
    let errors = new Set();//TODO make this a dictionary with <i, hoverovertext> pairs.
    for (let i = 1; i <= glyphCount; i++) {
        const value = document.getElementById(`glyph-${i}-face-index`).value;

        let hasError = false;
        // Check if the index conflicts with any other faces.
        for (let j = (i+1); j <= glyphCount; j++) {
            if (document.getElementById(`glyph-${j}-face-index`).value == value) {
                errors.add(j);
                hasError = true;
            }
        }

        // If this index conflicted with another face, add it to the error list and skip the remaining checks.
        if (hasError) {
            errors.add(i);
            continue;
        }

        // Check that the face index is within bounds and an integer.
        if ((value < 1) || (value > glyphCount) || !Number.isInteger(Number(value))) {
            errors.add(i);
        }
    }

    // Iterate through the faces and update their classes to reflect their error statuses.
    for (let i = 1; i <= glyphCount; i++) {
        const faceIndexInput = document.getElementById(`glyph-${i}-face-index`);
        if (errors.has(i)) {
            faceIndexInput.className = "glyph-face-index-field-error";
        } else {
            faceIndexInput.className = "glyph-face-index-field";
        }
    }
}
