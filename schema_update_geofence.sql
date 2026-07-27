USE qr_attendance;

CREATE TABLE IF NOT EXISTS settings (
    setting_key VARCHAR(50) PRIMARY KEY,
    setting_value VARCHAR(100)
);

-- Defaults: geofencing OFF until admin sets real campus coordinates
INSERT INTO settings (setting_key, setting_value) VALUES
    ('campus_lat', ''),
    ('campus_lng', ''),
    ('campus_radius_meters', '200')
ON DUPLICATE KEY UPDATE setting_key = setting_key;
