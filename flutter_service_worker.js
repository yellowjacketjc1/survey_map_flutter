'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "888483df48293866f9f41d3d9274a779",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "a4f3280222678775d72e51366601e1ca",
"index.html": "b0f4197f1b4c35b15eb17422a4288380",
"/": "b0f4197f1b4c35b15eb17422a4288380",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "9db5ff97cfc70631a70dc293a5659f9c",
"assets/assets/Postings/Slide99.svg": "f983b05d768f0370cabc589fc6f87ab1",
"assets/assets/Postings/Slide7.svg": "192d5c92dbab44c19ce5ae9b7b8918d3",
"assets/assets/Postings/Slide64.svg": "b2075d68e865204c2031963a9623217f",
"assets/assets/Postings/Slide55.svg": "da1de20e4e7c2bbc76d652f8c5494d32",
"assets/assets/Postings/Slide10.svg": "e0e4700c49e578f4f61cc7ed1f178ac4",
"assets/assets/Postings/Slide95.svg": "0c8009c5ea226170d893c56a23c20b25",
"assets/assets/Postings/Slide4.svg": "e78b318ba54c5f2ee9458541e0fb1c02",
"assets/assets/Postings/Slide110.svg": "c6ff00bedc9f1bdfb6a87e76abd529ce",
"assets/assets/Postings/Slide69.svg": "487c6e491d2e9c3413c832d1aa052a67",
"assets/assets/Postings/Slide84.svg": "d9a6451c8358e930732ee6ab3d6160e6",
"assets/assets/Postings/Slide86.svg": "2259e09789d3a3af1584f4e3214befa4",
"assets/assets/Postings/Slide20.svg": "ef89dc2282ab41af665f6dfd7cbdad63",
"assets/assets/Postings/Slide41.svg": "408133efe3a049044c480f18c7fb8710",
"assets/assets/Postings/Slide126.svg": "7b151372d47727a69c83d7e26e9e9cdb",
"assets/assets/Postings/Slide47.svg": "22af2ac7c78ebea9d6d1f0ebb419b610",
"assets/assets/Postings/Slide40.svg": "cccef653a545cd691a632399be546ab2",
"assets/assets/Postings/Slide81.svg": "a66791123c21c0eeae912f9cb2a6e51e",
"assets/assets/Postings/Slide15.svg": "4eca374ec81e7c0eb6122df9085a32a0",
"assets/assets/Postings/Slide11.svg": "5b9c9e04cd0842ab05be7f02473fb0e0",
"assets/assets/Postings/Slide128.svg": "fa2a8c918eb79fcbff8f8b431124fe95",
"assets/assets/Postings/Slide38.svg": "f5dbb4df7034fa004639d7b803a686f6",
"assets/assets/Postings/Slide53.svg": "20f31205173fcadca456e87cf7d1b064",
"assets/assets/Postings/Slide19.svg": "146dd26102c934216c096dbed160f4ae",
"assets/assets/Postings/Slide6.svg": "8480d2ba6bcfd6a3ef480a014a04f8e8",
"assets/assets/Postings/Slide88.svg": "7ab59c4b5db7e536f5d2c1a7b02095b1",
"assets/assets/Postings/Slide58.svg": "b64fcf8d2b994816ead4841be229fd7c",
"assets/assets/Postings/Slide115.svg": "8cb67ddabd4c854b3277d07ba5bb3ef5",
"assets/assets/Postings/Slide65.svg": "6b93d089b8ea1d2a1775ee21e319a7ed",
"assets/assets/Postings/Slide80.svg": "48c5a95299436b50cf2b5381ad2e8110",
"assets/assets/Postings/Slide23.svg": "e6f29b13aa30c75d293030d8632ae578",
"assets/assets/Postings/Slide45.svg": "7ffbbe95fe230467a5d58518d1826da8",
"assets/assets/Postings/Slide89.svg": "2f7861b883c7b9ff4eb43c0f537d0017",
"assets/assets/Postings/Slide8.svg": "289b21429e9bee35f99ddf6278362d37",
"assets/assets/Postings/Slide122.svg": "15310e9cd891f3a3c95c308697f047ba",
"assets/assets/Postings/Slide26.svg": "3afd521327f60d939820ca2e4c651afe",
"assets/assets/Postings/Slide117.svg": "650f364656e6580904153593041589d3",
"assets/assets/Postings/Slide48.svg": "d3bae6628bd7d79ad3c9772b33e6efd7",
"assets/assets/Postings/Slide52.svg": "19f4eb44c690e06fd7ba25fe4b7059c9",
"assets/assets/Postings/Slide85.svg": "28d054daf25b25d14c299b5f7a36bb3e",
"assets/assets/Postings/Slide121.svg": "747dd00e6461a9540826831cbc0cd778",
"assets/assets/Postings/Slide54.svg": "cdcb2e15ec756444fc51975ce475aeb9",
"assets/assets/Postings/Slide73.svg": "f565a1d8b25ab86370410e246b4bf7a3",
"assets/assets/Postings/Slide124.svg": "219213330c9ed3d1904e2a19609de82b",
"assets/assets/Postings/Slide91.svg": "742272dfed7ba65e4a9d71968dcb8db7",
"assets/assets/Postings/Slide14.svg": "a8dfb4cbfb61a8f322ace84c7347e5ef",
"assets/assets/Postings/Slide3.svg": "4a1cf56f7376d6d01b98ed0d4ad691a7",
"assets/assets/Postings/Slide18.svg": "56dfe5aaa08720b593c2fcd923e8173e",
"assets/assets/Postings/Slide78.svg": "8c36d6e3e1bcb73d47aefafd69b774d3",
"assets/assets/Postings/Slide116.svg": "7a114d42d85d7abf4da428e289c5216e",
"assets/assets/Postings/Slide43.svg": "3d8d92a4ed783079037f13f001715eba",
"assets/assets/Postings/Slide100.svg": "edc152b2ae9822bb6b9a68a1599bd10d",
"assets/assets/Postings/Slide60.svg": "ecb2b6d91951a33532a61d7a0a2d8b5b",
"assets/assets/Postings/Slide75.svg": "bd55a5e313bf9394e22e965d40abae9e",
"assets/assets/Postings/Slide63.svg": "c793f4d07ea010dfe3c1c6be5563c818",
"assets/assets/Postings/Slide22.svg": "f6aaba27131d1360891d8b4171335af7",
"assets/assets/Postings/Slide66.svg": "2d62a6201ae45d050c3c2c03d4a54def",
"assets/assets/Postings/Slide109.svg": "712fe72cdc7d4d8fab12c7cfa72b1c22",
"assets/assets/Postings/Slide49.svg": "660ff2ffe47936c028b6552e2143a4a5",
"assets/assets/Postings/Slide34.svg": "ebe5778b3a9ecf852ed81419fc104872",
"assets/assets/Postings/Slide92.svg": "ffb6d3b47a1367ba8a865f5e24d93da8",
"assets/assets/Postings/Slide1.svg": "7b745fab79e29ac640b77a13a2ea7da9",
"assets/assets/Postings/Slide67.svg": "1f30d0a5e45e07b678c8904fc4ac7978",
"assets/assets/Postings/Slide57.svg": "f8214b193b45b8ba865d9a67765a4e60",
"assets/assets/Postings/Slide108.svg": "d2dc5669d4d60744db436211fd9f2688",
"assets/assets/Postings/Slide68.svg": "b781b2d5b01c11166fb1f83ee2b848cd",
"assets/assets/Postings/Slide29.svg": "d08152590d0eb03d0e7f6570c30fae7f",
"assets/assets/Postings/Slide28.svg": "23b8b020a35cf5075e1fa2a7496ea8bf",
"assets/assets/Postings/Slide107.svg": "a53eaa80414363086668e82264eb142a",
"assets/assets/Postings/Slide36.svg": "cc604476cdf46c65249f33fdb9aba6c9",
"assets/assets/Postings/Slide98.svg": "820338cf84c5d26531891f1eb6f16799",
"assets/assets/Postings/Slide105.svg": "2bf6de2b9f8c1dff047673b392beb400",
"assets/assets/Postings/Slide70.svg": "cd6b07870d1f3e85ab61ff70f19ba109",
"assets/assets/Postings/Slide93.svg": "68b4537e6228aa84be70e0bafcd11db7",
"assets/assets/Postings/Slide24.svg": "5c6ebc8c6bd3dcc271975acba281002b",
"assets/assets/Postings/Slide106.svg": "eafa5a925734eda95579de4362ae90d7",
"assets/assets/Postings/Slide21.svg": "a0dfe60ed9dd219884468ebf2885fbb3",
"assets/assets/Postings/Slide119.svg": "3d03a81a4f8263be0d39cdffd5f2062b",
"assets/assets/Postings/Slide59.svg": "dd065f8c67652314fabfab1b2ea8a5f3",
"assets/assets/Postings/Slide51.svg": "80528a4f0610f073c190f9a26a42b94a",
"assets/assets/Postings/Slide71.svg": "b4b3edfd29f9062fec16f11d7adc4a26",
"assets/assets/Postings/Slide31.svg": "2f5ce986fea98788a479cfbeb906911b",
"assets/assets/Postings/Slide50.svg": "2b0bd43dfdc7416c9505c587c3493e47",
"assets/assets/Postings/Slide25.svg": "10a7b67bc4f0f1c1e1b0efe54209b12d",
"assets/assets/Postings/Slide114.svg": "a3bedc5d6028d4418c2b4e2872c80bb6",
"assets/assets/Postings/Slide125.svg": "22a60f5effd824d36444e82e7f1a1349",
"assets/assets/Postings/Slide33.svg": "92732685594a236a7b7eb29346c7871b",
"assets/assets/Postings/Slide90.svg": "15a65eb384da6b5c9e864e6ae118ac18",
"assets/assets/Postings/Slide102.svg": "cade41aef1357807af0b4058b0d00018",
"assets/assets/Postings/Slide32.svg": "7f2102e30334cb30c9e336cb3f4d8137",
"assets/assets/Postings/Slide44.svg": "f7b58262799413f3e68b03b753c7c0c8",
"assets/assets/Postings/Slide42.svg": "093d27386fcd6ba32e03c4fd67545bb6",
"assets/assets/Postings/Slide76.svg": "9486be6732e3c7ff62bb823f2f1f9523",
"assets/assets/Postings/Slide97.svg": "d9bd7c056b704859351d5f46f1a91ef6",
"assets/assets/Postings/Slide35.svg": "694114941c5d87612ba04b67d1459967",
"assets/assets/Postings/Slide83.svg": "55445afe263b5448c3d2001a43bc967c",
"assets/assets/Postings/Slide120.svg": "4a6c6893d705a8fdac0b6f714bff1862",
"assets/assets/Postings/Slide79.svg": "055df11fc7d2575216d2ea3afcd5a828",
"assets/assets/Postings/Slide17.svg": "7b1b6c6989cc8507a60c953fbe5770e3",
"assets/assets/Postings/Slide82.svg": "2afd0a15be6f760144e8455b54e28ed1",
"assets/assets/Postings/Slide112.svg": "80428828449ae34e04ec4b9281fa82bc",
"assets/assets/Postings/Slide118.svg": "deba2ec322987c9f42fc5559ee3fc9bc",
"assets/assets/Postings/Slide94.svg": "1faeae83f32398d5a003273b492abbb0",
"assets/assets/Postings/Slide77.svg": "a1a246cc4f66d3202728c67316620738",
"assets/assets/Postings/Slide9.svg": "bedf2c3b00831098fbe6b8d376ea8b80",
"assets/assets/Postings/Slide111.svg": "2012cfa5d88f72c1be1419c0bbcff95a",
"assets/assets/Postings/Slide37.svg": "9b8ec433c7b5ad8fa320dfda64ece187",
"assets/assets/Postings/Slide39.svg": "a20260ad70eb77745c3c58ba939d5857",
"assets/assets/Postings/Slide62.svg": "dce8f83c238a835a323c93842f28c060",
"assets/assets/Postings/Slide104.svg": "60a1edda6ea574fa835111593486ad07",
"assets/assets/Postings/Slide123.svg": "870865f866bd6c0f76997e754ba192f1",
"assets/assets/Postings/Slide30.svg": "7260ca458bbba70d83b0cdbd540fd12a",
"assets/assets/Postings/Slide101.svg": "9fd8ebe87ba688b3eba4a19e4e4d3bf3",
"assets/assets/Postings/Slide72.svg": "cfc22fcb25e49e7a45e206e96d804a45",
"assets/assets/Postings/Slide96.svg": "b5a6a2322bda5efc3cdd46d153dd9d63",
"assets/assets/Postings/Slide61.svg": "b1a286ae0ba2c54d92baaf0d09cc8f79",
"assets/assets/Postings/Slide5.svg": "68d1757f88702a76faa81e454c0fe9e0",
"assets/assets/Postings/Slide2.svg": "43a5563051dadd9a34e7db3360271fee",
"assets/assets/Postings/Slide74.svg": "d879bfd258a22d9448b9eb9b40c1a6e9",
"assets/assets/Postings/Slide13.svg": "30d4f13a9147a5d1e32daccc66289682",
"assets/assets/Postings/Slide12.svg": "b7944bfd86b91ba538b09f273b3f7da1",
"assets/assets/Postings/Slide127.svg": "50ab1396db4c953068386bd784a0c2f5",
"assets/assets/Postings/Slide87.svg": "dc1da5641644796f79154ea90e0c41c3",
"assets/assets/Postings/Slide46.svg": "b1bcaab28f6ce8b2ce0b55cb12b318d5",
"assets/assets/Postings/Slide56.svg": "2fd0ee1f619d254826c67c0e094cd05b",
"assets/assets/Postings/Slide27.svg": "f933a1e89c5bed153a1eac2be83fc694",
"assets/assets/Postings/Slide103.svg": "107c0f6dc28fe89b722a4afd56a64f01",
"assets/assets/Postings/Slide113.svg": "7e6fd5247ac212b978b4befc7fc830e7",
"assets/assets/Postings/Slide16.svg": "2d79212808a25b3eb814daf5f68f2b24",
"assets/assets/postings.json": "7d92ed9115c9cc2fe2d780b3168cc6d5",
"assets/assets/building_maps.json": "81cd288c4fdea32be1cefb750bfc3ce9",
"assets/fonts/MaterialIcons-Regular.otf": "ee38a73a17cb0055c22eabdd3f2dd49a",
"assets/NOTICES": "865f8f40db70fd03342faec7f2ae609b",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin": "ea81a355bfa4d84542aee29ae15a760b",
"assets/AssetManifest.json": "0ad0ce98bb66b5aa540f1ed781c69877",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "0968c97261aaa14deb162d1024898a38",
"version.json": "8eb73f816122db1a67f4b0e6469af4ba",
"main.dart.js": "1abe2de087aca2b0ab722742b68ed46b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
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
