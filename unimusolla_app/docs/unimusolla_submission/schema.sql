CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,

    profile_image TEXT,

    role TEXT NOT NULL DEFAULT 'user'
        CHECK(role IN ('user','admin')),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
, username TEXT);
CREATE TABLE sqlite_sequence(name,seq);
CREATE INDEX idx_users_email
ON users(email);
CREATE TABLE musollas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    name TEXT NOT NULL,

    location TEXT NOT NULL,

    exact_location TEXT,

    latitude REAL,
    longitude REAL,

    status TEXT NOT NULL DEFAULT 'available'
        CHECK(status IN ('available','unavailable')),

    has_wudhu INTEGER DEFAULT 0,
    has_toilet INTEGER DEFAULT 0,
    has_aircond INTEGER DEFAULT 0,
    has_mats INTEGER DEFAULT 0,
    has_telekung INTEGER DEFAULT 0,

    created_by INTEGER,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(created_by)
        REFERENCES users(id)
);
CREATE INDEX idx_musollas_name
ON musollas(name);
CREATE INDEX idx_musollas_location
ON musollas(location);
CREATE TABLE musolla_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    musolla_id INTEGER NOT NULL,

    image_path TEXT NOT NULL,

    uploaded_by INTEGER,

    is_active INTEGER DEFAULT 1,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(musolla_id)
        REFERENCES musollas(id)
        ON DELETE CASCADE,

    FOREIGN KEY(uploaded_by)
        REFERENCES users(id)
);
CREATE TABLE pending_musollas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    user_id INTEGER NOT NULL,

    musolla_id INTEGER,

    name TEXT NOT NULL,

    location TEXT NOT NULL,

    exact_location TEXT,

    latitude REAL,
    longitude REAL,

    status TEXT DEFAULT 'available'
        CHECK(status IN ('available','unavailable')),

    has_wudhu INTEGER DEFAULT 0,
    has_toilet INTEGER DEFAULT 0,
    has_aircond INTEGER DEFAULT 0,
    has_mats INTEGER DEFAULT 0,
    has_telekung INTEGER DEFAULT 0,

    approval_status TEXT DEFAULT 'pending'
        CHECK(
            approval_status IN (
                'pending',
                'approved',
                'rejected'
            )
        ),

    reviewed_by INTEGER,

    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    reviewed_at DATETIME,

    FOREIGN KEY(user_id)
        REFERENCES users(id),

    FOREIGN KEY(reviewed_by)
        REFERENCES users(id),

    FOREIGN KEY(musolla_id)
        REFERENCES musollas(id)
);
CREATE TABLE pending_musolla_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    pending_musolla_id INTEGER NOT NULL,

    image_path TEXT NOT NULL,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(pending_musolla_id)
        REFERENCES pending_musollas(id)
        ON DELETE CASCADE
);
CREATE TABLE admin_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    admin_id INTEGER NOT NULL,

    action TEXT NOT NULL,

    target_type TEXT NOT NULL,

    target_id INTEGER,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(admin_id)
        REFERENCES users(id)
);
CREATE TABLE reports (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    user_id INTEGER NOT NULL,

    musolla_id INTEGER,

    name TEXT NOT NULL,

    location TEXT NOT NULL,

    exact_location TEXT,

    latitude REAL,
    longitude REAL,

    status TEXT NOT NULL DEFAULT 'available'
        CHECK(status IN ('available','unavailable')),

    has_wudhu INTEGER DEFAULT 0,
    has_toilet INTEGER DEFAULT 0,
    has_aircond INTEGER DEFAULT 0,
    has_mats INTEGER DEFAULT 0,
    has_telekung INTEGER DEFAULT 0,

    approval_status TEXT NOT NULL DEFAULT 'pending'
        CHECK(
            approval_status IN (
                'pending',
                'approved',
                'rejected'
            )
        ),

    reviewed_by INTEGER,

    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    reviewed_at DATETIME,

    FOREIGN KEY(user_id)
        REFERENCES users(id),

    FOREIGN KEY(musolla_id)
        REFERENCES musollas(id),

    FOREIGN KEY(reviewed_by)
        REFERENCES users(id)
);
CREATE TABLE report_images (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    report_id INTEGER NOT NULL,

    image_path TEXT NOT NULL,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(report_id)
        REFERENCES reports(id)
        ON DELETE CASCADE
);
