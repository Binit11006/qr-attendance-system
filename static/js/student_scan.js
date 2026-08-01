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
        ).catch((err) => {
            showResult("Couldn't access camera: " + err, false);
        });
    
