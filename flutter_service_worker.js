'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"assets/FontManifest.json": "37e52af31cf8fb7a597d7bf46113fb13",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "17ee8e30dde24e349e70ffcdc0073fb0",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "f3307f62ddff94d2cd8b103daf8d1b0f",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "04f83c01dded195a11d21c2edf643455",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/images/mandel_logo.png": "dcae55f0748daf1392fef9bbf2c11dd2",
"assets/assets/images/mandel_my_order.png": "91fab902d2cee32f97f375cfacb8d095",
"assets/assets/images/mandel_device_not_found.png": "325855f15e538d7ae72e4c64b00564dd",
"assets/assets/images/mandel_category.png": "478bfeddc0f9eab636651b4617a27140",
"assets/assets/images/mandel_animate_barcode.gif": "f3300b1ad8320c61263cbd37e1072a7c",
"assets/assets/images/mandel_return.png": "91c0d528bc106cc7bb67ddbedc44e19a",
"assets/assets/images/mandel_deals.png": "7bcaeb364c6a9ae8f1c341ef7d912d2e",
"assets/assets/images/mandel_login.png": "acb89e32a752bdbafaf8050b47f29a06",
"assets/assets/images/mandel_close_icon.png": "ae37388ae2537a5e11ae0f49d8c663c9",
"assets/assets/images/mandel_new_order.png": "3a2896b0f40b6bd995e5f81968e9a0ff",
"assets/assets/images/mandel_profile.png": "26ff0097abfc9518e5b689ef80c90c28",
"assets/assets/images/mandel_angle_left.png": "4ca4f63985785c999741f680fd4fd42a",
"assets/assets/images/mandel_new_items.png": "7c3d37d62ff6f3ebb69ca10ae01086d5",
"assets/assets/images/mandel_notification.png": "59a0f279b4e1a0e252e140351cca6377",
"assets/assets/images/mandel_more.png": "1d533139513ab5c1c315ef481fc9d699",
"assets/assets/images/mandel_settings.png": "21461c16e44fbb5295b3aa09687b9ba2",
"assets/assets/images/mandel_scan_item.png": "4906ebb9ea293a98aac69075196b72b6",
"assets/assets/images/mandel_empty_state.png": "7829a28ab0fd1b2788e076623a36faf4",
"assets/assets/images/mandel_otp.png": "5e0bc78982ffed534da28cf00219ca47",
"assets/assets/images/mandel_brand.png": "9e4bb4f7506a56a2dc42596dc4bc4016",
"assets/assets/images/mandel_no_image.jpg": "57da1720c8ec3c5b7c19d6c99a227605",
"assets/assets/fonts/Nunito-Bold.ttf": "91019ffb3b1df640e444b34e5a73dfc3",
"assets/assets/fonts/Nunito-Regular.ttf": "0c890be2af0d241a2387ad2c4c16af2c",
"assets/assets/fonts/Nunito-Italic.ttf": "ce460427f5742744a5a062cce0fdf93e",
"assets/assets/json/amplify_config.json": "193a3a5a9998bbf0362f93d9fb68e6da",
"assets/assets/logo/mandel_logo_wide.png": "35e47f83d372eb37ce296161ab3723cd",
"assets/assets/logo/mandel_logo.jpeg": "2129ebce709d877b2219808573b3d928",
"assets/AssetManifest.bin.json": "a4a030bd03bff8381dca87ced40f7a31",
"assets/fonts/MaterialIcons-Regular.otf": "d19618f24e76b6e324b7bf9fcc080c95",
"assets/AssetManifest.bin": "e2b1de62bfb3da51e86fd9424bc02df1",
"assets/NOTICES": "3aaa8e50eba8b1bf69a6fa0ecd75daf3",
"assets/AssetManifest.json": "ec3b7986fe4c9ecf991d5b0155d736ef",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"index.html": "1bd531e17436eced2bc61a6743af71da",
"/": "1bd531e17436eced2bc61a6743af71da",
"main.dart.js": "2558ab9c68be9a64db20b84f22d0f1cc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"manifest.json": "b93c4f06b5c7b0ec8d133eabc0f5a037",
"version.json": "73fd786d929ee86167c1c9b28dc50c55"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
