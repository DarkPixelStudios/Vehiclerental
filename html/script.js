var vehicles        = [];
var selectedVehicle = null;
var duration        = 30;
var minDuration     = 10;
var maxDuration     = 120;
var rentStep        = 10;

window.addEventListener('message', function (e) {
    var data = e.data;
    if (!data || !data.action) return;

    if (data.action === 'openRental') {
        vehicles    = data.vehicles    || [];
        minDuration = data.minDuration || 10;
        maxDuration = data.maxDuration || 120;
        rentStep    = data.step        || 10;
        duration    = minDuration;

        var shopTitle = document.getElementById('shop-title');
        if (data.shopName && shopTitle) shopTitle.textContent = data.shopName;

        setupSlider();
        renderVehicleList();
        document.getElementById('slider-panel').classList.add('hidden');
        selectedVehicle = null;
        document.getElementById('overlay').classList.remove('hidden');
    }

    if (data.action === 'closeRental') {
        document.getElementById('overlay').classList.add('hidden');
        vehicles = [];
        selectedVehicle = null;
    }
});

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeUI();
});

function setupSlider() {
    var slider = document.getElementById('durationSlider');
    slider.min   = minDuration;
    slider.max   = maxDuration;
    slider.step  = rentStep;
    slider.value = minDuration;
    duration     = minDuration;
    document.getElementById('sliderMin').textContent = minDuration + ' min';
    document.getElementById('sliderMax').textContent = maxDuration + ' min';
    updateSlider();
}

document.getElementById('durationSlider').addEventListener('input', function () {
    duration = parseInt(this.value, 10);
    updateSlider();
    updateTotalPrice();
});

function updateSlider() {
    document.getElementById('durationBadge').textContent = duration + ' min';
    var pct = ((duration - minDuration) / (maxDuration - minDuration)) * 100;
    document.getElementById('durationSlider').style.background =
        'linear-gradient(to right, #27ae60 ' + pct + '%, #333 ' + pct + '%)';
}

function updateTotalPrice() {
    if (!selectedVehicle) return;
    document.getElementById('totalPrice').textContent =
        (selectedVehicle.priceperminute * duration).toLocaleString('de-DE') + ' \u20AC';
}

function renderVehicleList() {
    var list = document.getElementById('vehicle-list');
    list.innerHTML = '';
    for (var i = 0; i < vehicles.length; i++) {
        (function(v) {
            var card = document.createElement('div');
            card.className = 'vehicle-card';
            var imgHtml = '';
            if (v.image && v.image !== '') {
                imgHtml = '<img class="vc-image" src="' + v.image + '" alt="" onerror="this.style.display=\'none\'">';
            }
            card.innerHTML =
                imgHtml +
                '<div class="vc-info">' +
                '<div class="vc-label">' + v.label + '</div>' +
                '<div class="vc-price">' + v.priceperminute + ' \u20AC/min</div>' +
                '</div>' +
                '<button class="vc-btn">Mieten</button>';
            card.querySelector('.vc-btn').addEventListener('click', function () {
                selectVehicle(v);
            });
            list.appendChild(card);
        })(vehicles[i]);
    }
}

function selectVehicle(vehicle) {
    selectedVehicle = vehicle;
    document.getElementById('slider-panel').classList.remove('hidden');
    updateTotalPrice();
}

document.getElementById('confirmRentBtn').addEventListener('click', function () {
    if (!selectedVehicle) return;
    fetch('https://' + GetParentResourceName() + '/rentVehicle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model: selectedVehicle.model, duration: duration }),
    });
    document.getElementById('overlay').classList.add('hidden');
    vehicles = [];
    selectedVehicle = null;
});

function closeUI() {
    fetch('https://' + GetParentResourceName() + '/closeUI', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
    });
    document.getElementById('overlay').classList.add('hidden');
    vehicles = [];
    selectedVehicle = null;
}
