
    // TODO HAVE TO ADD FILLEMPTYFIELD TO THE OTHER ADVANCED MENU STILL!!!

    // So if the user has messed with the advanced stuff, we'll issue a warning everytime and unset the CUSTOM mapping.
    // If the user has changed the text... Hmmm, I say tough titties. I can't think of when it would really be use...
    // No. No, that's wrong. Like if someone is switchinig between Rybonator and Chessex numbering, we should keep the text.
    // So. If the user has changed the text, we'll let sketchup launch a 




function updateValue(fieldName, value) {
    //TODO sketchup.updateValue(fieldName, value);
    console.log(`Update ${fieldName} to ${value}...`);
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
        // Add a callback to check for any face index conflicts.
        glyphFaceIndexField.addEventListener("input", () => checkFaceIndexValidity(glyphFaceIndexField.id, glyphCount));
        glyphRow.insertCell(-1).appendChild(glyphFaceIndexField);
    }
}

function createNumericalInputField(name, index, value, step) {
    let field = document.createElement("input");
    field.type = "number";
    field.id = `glyph-${index}-${name}`;
    field.className = `glyph-${name}-field`;
    field.value = value;
    field.defaultValue = value;
    field.step = step;
    field.addEventListener("input", function() {
        const input = document.getElementById(field.id);
        updateValue(field.id, input.value);

        // Change the glyph mapping field to say 'Custom' if it doesn't already.
        if (document.getElementById("glyph-mapping-chooser").value != "CUSTOM_MAPPING!") {
            setCustomMapping();
        }
    });
    return field;
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

function checkFaceIndexValidity(fieldId, glyphCount) {
    const faceIndexInput = document.getElementById(fieldId);
    const value = faceIndexInput.value;
    let hasError = false;

    // Check that the face index is within bounds and an integer.
    if ((value < 1) || (value > glyphCount) || (false/*INTEGER CHECK*/)) {
        hasError = true;
        //TODO set the hover-over text!
    }

    // Check if the face index is used by any other glyphs.
    const faceIndexFields = document.getElementsByClassName("glyph-face-index");
    // TODO DO THAT!

    if (hasError) {
        // Change the class so it has a red border or something.
        // OH and add a hover-over explaining the error.
    }
}
