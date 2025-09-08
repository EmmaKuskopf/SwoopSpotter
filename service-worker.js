self.addEventListener("install", event => {
  event.waitUntil(
    caches.open("geofence-cache").then(cache => {
      return cache.addAll([
        "./",
        "./index.html",
        "./manifest.json",
        "./service-worker.js",
        "https://unpkg.com/leaflet/dist/leaflet.css",
        "https://unpkg.com/leaflet/dist/leaflet.js"
      ]);
    })
  );
});

self.addEventListener("fetch", event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request);
    })
  );
});
