// Uses SESSION_ID and QR_VALID_SECONDS, which are set as globals
// in a small inline script in session_live.html (Flask/Jinja passes them in).

let remaining = QR_VALID_SECONDS;

function updateCountdown() {
    document.getElementById("countdown").textContent = remaining;
    remaining -= 1;
    if (remaining < 0) {
        refreshQR();
    }
}

async function refreshQR() {
    remaining = QR_VALID_SECONDS;
    try {
        const res = await fetch(`/teacher/session/${SESSION_ID}/refresh`, { method: "POST" });
        if (!res.ok) return; // session may have been ended
        const img = document.getElementById("qr-img");
        img.src = `/teacher/session/${SESSION_ID}/qr.png?t=${Date.now()}`;
    } catch (e) {
        console.error("Refresh failed", e);
    }
}

setInterval(updateCountdown, 1000);
