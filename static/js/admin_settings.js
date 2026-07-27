        function useMyLocation() {
            const status = document.getElementById("locate-status");
            if (!navigator.geolocation) {
                status.textContent = "Your browser doesn't support location.";
                return;
            }
            status.textContent = "Getting location…";
            navigator.geolocation.getCurrentPosition(
                (pos) => {
                    document.getElementById("campus_lat").value = pos.coords.latitude;
                    document.getElementById("campus_lng").value = pos.coords.longitude;
                    status.textContent = "Location captured — review and click Save.";
                },
                (err) => {
                    status.textContent = "Couldn't get location: " + err.message;
                }
            );
        }
    
