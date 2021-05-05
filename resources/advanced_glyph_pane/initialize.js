
// Add specific callback functions for some of the input elements.
document.getElementById("glyph-mapping-chooser").addEventListener("change", updateGlyphMapping);

AddGlyphMapping("D10");
AddGlyphMapping("D%");
createAdvancedGlyphFields(14);

const EN_US = {
    "Custom": "Custom",
    "ResetMappingChangesPrompt": "Changing glyph mappings will erase any custom modifications you've made. Are you sure you're okay with that?",
};
