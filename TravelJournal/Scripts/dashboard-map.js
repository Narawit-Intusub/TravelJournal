// Dashboard Map Script for Travel Journal
// Leaflet + OpenStreetMap

var map, tempMarker = null, markers = [];

function initMap() {
    // Initialize map centered on Thailand
    map = L.map('map', {
        worldCopyJump: true,  // กระโดดกลับไปที่แผนที่หลักเมื่อเลื่อนข้ามขอบ
        maxBounds: [[-90, -180], [90, 180]],  // จำกัดขอบเขตการแสดงผล
        maxBoundsViscosity: 1.0,  // ไม่ให้เลื่อนออกนอกขอบเขต
        minZoom: 2,  // จำกัดการ zoom ออกสุด
        maxZoom: 19  // จำกัดการ zoom เข้าสุด
    }).setView([13.7563, 100.5018], 6);

    // Add OpenStreetMap tiles with better styling
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        noWrap: true  // ไม่ให้แผนที่ซ้ำตัวเอง
    }).addTo(map);

    // Click to fill coordinates
    map.on('click', function (e) {
        var lat = e.latlng.lat.toFixed(6);
        var lng = e.latlng.lng.toFixed(6);

        // Get textbox elements by ID (will be set via data attributes)
        var latInput = document.getElementById(window.latitudeClientId);
        var lngInput = document.getElementById(window.longitudeClientId);

        if (latInput && lngInput) {
            latInput.value = lat;
            lngInput.value = lng;
        }

        // Remove previous temporary marker
        if (tempMarker) {
            map.removeLayer(tempMarker);
        }

        // Add new temporary marker
        tempMarker = L.marker([lat, lng], {
            icon: L.icon({
                iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png',
                shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                iconSize: [25, 41],
                iconAnchor: [12, 41],
                popupAnchor: [1, -34],
                shadowSize: [41, 41]
            })
        }).addTo(map);

        tempMarker.bindPopup('<strong>พิกัดที่เลือก</strong><br>' + lat + ', ' + lng).openPopup();
    });

    // Load existing markers
    loadExistingLocations();
}

function loadExistingLocations() {
    // Get map data from hidden field (set via data attribute)
    var mapDataElement = document.getElementById(window.mapDataClientId);
    if (!mapDataElement) return;

    var mapDataJson = mapDataElement.value;
    if (!mapDataJson || mapDataJson.trim() === '') return;

    try {
        var locations = JSON.parse(mapDataJson);
        var bounds = [];

        locations.forEach(function (location) {
            var lat = parseFloat(location.Latitude);
            var lng = parseFloat(location.Longitude);
            if (isNaN(lat) || isNaN(lng)) return;

            var iconUrl = getMarkerColor(location.Rating);
            var marker = L.marker([lat, lng], {
                icon: L.icon({
                    iconUrl: iconUrl,
                    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                    iconSize: [25, 41],
                    iconAnchor: [12, 41],
                    popupAnchor: [1, -34],
                    shadowSize: [41, 41]
                })
            }).addTo(map);

            var html = '<div style="min-width:220px; font-family: Segoe UI, sans-serif;">' +
                '<strong style="font-size:16px; color:#667eea;">' + (location.LocationName || '') + '</strong><br>' +
                '<span style="color:#666; font-size:13px;">📍 ' + (location.City || '') + ', ' + (location.Country || '') + '</span><br>' +
                '<span style="color:#f39c12; font-size:14px; font-weight:600;">⭐ ' + (location.Rating || 0) + '/5</span><br>' +
                '<span style="color:#888; font-size:12px;">📅 ' + (location.TravelDate || '') + '</span>' +
                '</div>';

            marker.bindPopup(html);
            markers.push(marker);
            bounds.push([lat, lng]);
        });

        // Fit map to show all markers
        if (bounds.length > 0) {
            map.fitBounds(bounds, { padding: [50, 50] });
        }
    } catch (e) {
        console.error('Error parsing map data:', e);
    }
}

// Get marker color based on rating
// Using github.com/pointhi/leaflet-color-markers
function getMarkerColor(rating) {
    var colors = {
        5: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
        4: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
        3: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-yellow.png',
        2: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-orange.png',
        1: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png'
    };
    return colors[rating] || colors[3];
}

// Initialize map on page load
window.onload = initMap;