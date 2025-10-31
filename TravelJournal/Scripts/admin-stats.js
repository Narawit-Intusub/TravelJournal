// Admin Statistics Script for Travel Journal
// Leaflet + Chart.js

var map, markers = [];

function initMap() {
    // Create Leaflet map centered on Thailand
    map = L.map('map', {
        worldCopyJump: true,  // กระโดดกลับไปที่แผนที่หลักเมื่อเลื่อนข้ามขอบ
        maxBounds: [[-90, -180], [90, 180]],  // จำกัดขอบเขตการแสดงผล
        maxBoundsViscosity: 1.0,  // ไม่ให้เลื่อนออกนอกขอบเขต
        minZoom: 2,  // จำกัดการ zoom ออกสุด
        maxZoom: 19  // จำกัดการ zoom เข้าสุด
    }).setView([13.7563, 100.5018], 6);

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19,
        noWrap: true  // ไม่ให้แผนที่ซ้ำตัวเอง
    }).addTo(map);

    // Load location data
    loadLocationData();

    // Initialize charts
    initCharts();
}

function loadLocationData() {
    // Get map data from hidden field
    var mapDataElement = document.getElementById(window.mapDataClientId);
    if (!mapDataElement) return;

    var mapDataJson = mapDataElement.value;
    if (!mapDataJson || mapDataJson.trim() === '') return;

    try {
        var locations = JSON.parse(mapDataJson);

        locations.forEach(function (location) {
            var lat = parseFloat(location.Latitude);
            var lng = parseFloat(location.Longitude);
            if (isNaN(lat) || isNaN(lng)) return;

            var markerColor = getMarkerColor(location.PopularityScale);
            // ปรับขนาด
            var markerSize = 6 + (location.PopularityScale * 2);

            // Create circle marker
            var marker = L.circleMarker([lat, lng], {
                radius: markerSize,
                fillColor: markerColor,
                color: '#ffffff',
                weight: 1.5,  // ความหนาของขอบ
                opacity: 1,
                fillOpacity: 0.7  // ความทึบ
            }).addTo(map);

            // Create popup
            var popularityLevel = getPopularityLevel(location.PopularityScale);
            var popupContent = '<div style="min-width:200px;">' +
                '<h3 style="margin:0 0 10px 0; color:' + markerColor + ';">' + location.LocationName + '</h3>' +
                '<p style="margin:5px 0;"><strong>Location:</strong> ' + location.City + ', ' + location.Country + '</p>' +
                '<p style="margin:5px 0;"><strong>Category:</strong> ' + location.Category + '</p>' +
                '<p style="margin:5px 0;"><strong>Visit Count:</strong> ' + location.VisitCount + '</p>' +
                '<p style="margin:5px 0;"><strong>Average Rating:</strong> ' + location.AverageRating + ' / 5</p>' +
                '<p style="margin:5px 0;"><strong>Popularity:</strong> ' +
                '<span style="color:' + markerColor + '; font-weight:bold;">' +
                location.PopularityScale + ' / 5 (' + popularityLevel + ')</span></p>' +
                '</div>';

            marker.bindPopup(popupContent);
            markers.push(marker);
        });

        // Fit bounds
        if (markers.length > 0) {
            var group = new L.featureGroup(markers);
            map.fitBounds(group.getBounds().pad(0.1));
        }
    } catch (e) {
        console.error('Error parsing map data:', e);
    }
}

function getMarkerColor(scale) {
    var colors = {
        5: '#0066ff',
        4: '#00cc00',
        3: '#ff9900',
        2: '#ff6600',
        1: '#ff0000'
    };
    return colors[scale] || '#999999';
}

function getPopularityLevel(scale) {
    var levels = {
        5: 'Very Popular',
        4: 'Popular',
        3: 'Moderate',
        2: 'Low',
        1: 'Very Low'
    };
    return levels[scale] || 'Unknown';
}

function initCharts() {
    // Get chart data from hidden field
    var chartDataElement = document.getElementById(window.chartDataClientId);
    if (!chartDataElement) return;

    var chartDataJson = chartDataElement.value;
    if (!chartDataJson || chartDataJson.trim() === '') return;

    try {
        var data = JSON.parse(chartDataJson);

        // 1. Popularity Scale Distribution
        createPopularityChart(data.popularityDistribution);

        // 2. Top Locations
        createTopLocationsChart(data.topLocations);

        // 3. Category Distribution
        createCategoryChart(data.categoryDistribution);

        // 4. Rating by Category
        createRatingChart(data.ratingByCategory);

    } catch (e) {
        console.error('Error creating charts:', e);
    }
}

function createPopularityChart(data) {
    var ctx = document.getElementById('popularityChart');
    if (!ctx) return;

    new Chart(ctx.getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['Scale 1', 'Scale 2', 'Scale 3', 'Scale 4', 'Scale 5'],
            datasets: [{
                data: [data.scale1, data.scale2, data.scale3, data.scale4, data.scale5],
                backgroundColor: ['#ff0000', '#ff6600', '#ff9900', '#00cc00', '#0066ff']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

function createTopLocationsChart(data) {
    var ctx = document.getElementById('topLocationsChart');
    if (!ctx) return;

    new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Visits',
                data: data.values,
                backgroundColor: '#667eea'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            indexAxis: 'y',
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                x: {
                    beginAtZero: true
                }
            }
        }
    });
}

function createCategoryChart(data) {
    var ctx = document.getElementById('categoryChart');
    if (!ctx) return;

    new Chart(ctx.getContext('2d'), {
        type: 'pie',
        data: {
            labels: data.labels,
            datasets: [{
                data: data.values,
                backgroundColor: [
                    '#667eea', '#764ba2', '#f093fb', '#4facfe',
                    '#00f2fe', '#43e97b', '#38f9d7', '#fa709a'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

function createRatingChart(data) {
    var ctx = document.getElementById('ratingChart');
    if (!ctx) return;

    new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Average Rating',
                data: data.values,
                backgroundColor: '#f093fb'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    max: 5,
                    ticks: {
                        stepSize: 1
                    }
                }
            }
        }
    });
}

// Initialize on page load
window.onload = initMap;