        const resultDiv = document.getElementById("result");
        const locationStatus = document.getElementById("location-status");
        let scanLocked = false;   // prevents spamming the server while a request is in-flight
        let currentLat = null;
        let currentLng = null;

        function requestLocation() {
            if (!navigator.geolocation) {
                locationStatus.textContent = "⚠️ Your browser doesn't support location — attendance may be rejected if location is required.";
                locationStatus.className = "location-status warn";
                return;
            }
            navigator.geolocation.getCurrentPosition(
                (pos) => {
                    currentLat = pos.coords.latitude;
                    currentLng = pos.coords.longitude;
                    locationStatus.textContent = "📍 Location confirmed";
                    locationStatus.className = "location-status ok";
                },
                (err) => {
                    locationStatus.textContent = "⚠️ Location access denied — enable it in your browser settings if attendance is rejected.";
                    locationStatus.className = "location-status warn";
                },
                { enableHighAccuracy: true, timeout: 10000 }
            );
        }
        requestLocation();

        function showResult(message, isSuccess) {
            resultDiv.textContent = message;
            resultDiv.className = "result " + (isSuccess ? "success" : "error");
        }

        async function onScanSuccess(decodedText) {
            if (scanLocked) return;

            let payload;
            try {
                payload = JSON.parse(decodedText);
            } catch (e) {
                showResult("That doesn't look like a valid attendance QR code.", false);
                return;
            }

            payload.lat = currentLat;
            payload.lng = currentLng;

            scanLocked = true;
            try {
                const res = await fetch("/student/mark", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload),
                });
                const data = await res.json();
                showResult(data.message, data.status === "success");

                if (data.status === "success") {
                    // Attendance is marked - stop scanning entirely so the camera
                    // doesn't keep re-reading the same on-screen QR and overwrite
                    // this success message with a confusing "expired"/"already
                    // marked" error a moment later.
                    html5QrCode.stop().catch(() => {});
                    return;
                }
            } catch (e) {
                showResult("Network error — try again.", false);
            } finally {
                // Only re-enable scanning if we didn't already succeed above
                // (that path returns early and never reaches here).
                setTimeout(() => { scanLocked = false; }, 2000);
            }
        }

        const html5QrCode = new Html5Qrcode("reader");
        html5QrCode.start(
            { facingMode: "environment" },
            { fps: 10, qrbox: 220 },
            onScanSuccess
        ).then(() => {
            setupZoomControl();
        }).catch((err) => {
            showResult("Couldn't access camera: " + err, false);
        });

        function setupZoomControl() {
            // Not every phone/browser exposes camera zoom - only show the
            // slider if this device actually supports it.
            let trackCapabilities;
            try {
                trackCapabilities = html5QrCode.getRunningTrackCapabilities();
            } catch (e) {
                showDebug("Zoom check failed: " + e.message);
                return; // zoom not supported on this browser/device
            }

            showDebug("Camera capabilities: " + JSON.stringify(trackCapabilities));

            if (!trackCapabilities || !trackCapabilities.zoom) {
                showDebug("No 'zoom' property found on this device/browser's camera capabilities.");
                return;
            }

            const zoomControl = document.getElementById("zoom-control");
            const zoomSlider = document.getElementById("zoom-slider");
            const zoomRange = trackCapabilities.zoom;

            zoomSlider.min = zoomRange.min;
            zoomSlider.max = zoomRange.max;
            zoomSlider.step = zoomRange.step || 0.1;
            zoomSlider.value = zoomRange.min;
            zoomControl.style.display = "flex";

            zoomSlider.addEventListener("input", (e) => {
                html5QrCode.applyVideoConstraints({
                    advanced: [{ zoom: parseFloat(e.target.value) }],
                }).catch(() => {});
            });
        }

        function showDebug(text) {
            // TEMPORARY - remove once zoom support is confirmed working.
            let debugBox = document.getElementById("debug-box");
            if (!debugBox) {
                debugBox = document.createElement("div");
                debugBox.id = "debug-box";
                debugBox.style.cssText = "margin-top:1rem;padding:0.6rem;background:#eee;" +
                    "border-radius:6px;font-size:0.7rem;text-align:left;word-break:break-all;color:#333;";
                document.querySelector(".card").appendChild(debugBox);
            }
            debugBox.textContent = text;
        }
    
