// WasteLink Client-side JavaScript Helpers

// Auto-detect browser location and set inputs
function initGeolocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            var latInput = document.getElementById('latitude');
            var lonInput = document.getElementById('longitude');
            if (latInput) {
                latInput.value = position.coords.latitude.toFixed(6);
            }
            if (lonInput) {
                lonInput.value = position.coords.longitude.toFixed(6);
            }
            console.log("WasteLink Geolocation auto-fill success:", position.coords.latitude, position.coords.longitude);
        }, function(error) {
            console.warn("Geolocation detection failed or blocked. Using default coordinate fallbacks (Bengaluru).", error);
        });
    } else {
        console.warn("Browser does not support Geolocation API.");
    }
}

// Client side validation helper
document.addEventListener("DOMContentLoaded", function() {
    // Check if we need to auto-load coordinates
    var autoLocateElements = document.getElementsByClassName("auto-locate");
    if (autoLocateElements.length > 0) {
        initGeolocation();
    }
});
