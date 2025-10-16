// SwoopSpotter main application code
(() => {
  // ----------------------------
  // Setup map + icons + DOM refs
  // ----------------------------
  const map = L.map('map').setView([-27.4698,153.0251], 14);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution:'© OpenStreetMap contributors' }).addTo(map);

  // Rest of the existing JavaScript code...
})();
