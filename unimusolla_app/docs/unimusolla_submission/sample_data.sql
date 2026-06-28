PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
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
INSERT INTO users VALUES(2,'admin@unimusolla.com','$2y$10$P9Qs5cCnhj.bc4Edaba4ceohI0u4CBZrobUXOt.litkiFCNNaVv1G','6a40f227eb0c17.59485771.jpg','admin','2026-06-26 10:52:13','2026-06-28 10:06:28','Super Admin');
INSERT INTO users VALUES(9,'kuazim04@gmail.com','$2y$10$e3CKueThQqsn0NW9oekhCu/LARlhISPFRKWV0/DN2lkfbADd8LFR6','6a4107777c0678.99247202.jpg','user','2026-06-28 11:36:18','2026-06-28 11:37:23','Luqman');
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
INSERT INTO musollas VALUES(23,'Masjid Kachi','SME Bank','Near Kachi Mart',37.421998000000002,-122.084000000000003,'available',1,1,0,1,1,2,'2026-06-28 11:53:05','2026-06-28 11:53:05');
INSERT INTO musollas VALUES(24,'Surau SOC','Dkg 4','Level 1',6.43943200000000004,100.530124,'available',1,1,0,1,1,9,'2026-06-28 12:00:24','2026-06-28 12:00:24');
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
INSERT INTO musolla_images VALUES(26,23,'6a410b0c9dccd4.83634993.jpg',2,1,'2026-06-28 11:53:06');
INSERT INTO musolla_images VALUES(27,24,'6a410cae5c8755.48562523.jpg',9,1,'2026-06-28 12:00:25');
INSERT INTO musolla_images VALUES(28,24,'6a410cae9eff27.24695425.jpg',9,1,'2026-06-28 12:00:25');
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
INSERT INTO admin_logs VALUES(2,2,'approved_report','report',1,'2026-06-26 11:50:58');
INSERT INTO admin_logs VALUES(3,2,'approved_report','report',3,'2026-06-26 12:26:11');
INSERT INTO admin_logs VALUES(4,2,'approved_report','report',4,'2026-06-26 15:24:26');
INSERT INTO admin_logs VALUES(5,2,'approved_report','report',5,'2026-06-27 05:50:50');
INSERT INTO admin_logs VALUES(6,2,'rejected_report','report',6,'2026-06-27 05:56:56');
INSERT INTO admin_logs VALUES(7,2,'rejected_report','report',9,'2026-06-27 07:12:57');
INSERT INTO admin_logs VALUES(8,2,'approved_report','report',11,'2026-06-27 07:40:58');
INSERT INTO admin_logs VALUES(9,2,'approved_report','report',12,'2026-06-27 07:54:18');
INSERT INTO admin_logs VALUES(10,2,'approved_report','report',8,'2026-06-27 07:54:26');
INSERT INTO admin_logs VALUES(11,2,'approved_report','report',13,'2026-06-27 07:58:16');
INSERT INTO admin_logs VALUES(12,2,'approved_report','report',14,'2026-06-27 08:07:34');
INSERT INTO admin_logs VALUES(13,2,'approved_report','report',17,'2026-06-27 13:23:31');
INSERT INTO admin_logs VALUES(14,2,'approved_report','report',16,'2026-06-27 13:23:37');
INSERT INTO admin_logs VALUES(15,2,'approved_report','report',18,'2026-06-27 14:45:31');
INSERT INTO admin_logs VALUES(16,2,'approved_report','report',30,'2026-06-27 19:16:06');
INSERT INTO admin_logs VALUES(17,2,'approved_report','report',31,'2026-06-27 19:44:05');
INSERT INTO admin_logs VALUES(18,2,'rejected_report','report',29,'2026-06-27 19:44:10');
INSERT INTO admin_logs VALUES(19,2,'rejected_report','report',28,'2026-06-27 19:44:13');
INSERT INTO admin_logs VALUES(20,2,'rejected_report','report',27,'2026-06-27 19:44:16');
INSERT INTO admin_logs VALUES(21,2,'rejected_report','report',26,'2026-06-27 19:44:20');
INSERT INTO admin_logs VALUES(22,2,'approved_report','report',32,'2026-06-27 19:56:02');
INSERT INTO admin_logs VALUES(23,2,'approved_report','report',35,'2026-06-27 20:36:17');
INSERT INTO admin_logs VALUES(24,2,'approved_report','report',36,'2026-06-27 22:00:55');
INSERT INTO admin_logs VALUES(25,2,'approved_report','report',37,'2026-06-27 22:00:59');
INSERT INTO admin_logs VALUES(26,2,'rejected_report','report',34,'2026-06-28 07:57:51');
INSERT INTO admin_logs VALUES(27,2,'approved_report','report',33,'2026-06-28 08:10:45');
INSERT INTO admin_logs VALUES(28,2,'rejected_report','report',25,'2026-06-28 08:22:42');
INSERT INTO admin_logs VALUES(29,2,'rejected_report','report',23,'2026-06-28 08:22:59');
INSERT INTO admin_logs VALUES(30,2,'approved_report','report',38,'2026-06-28 09:09:40');
INSERT INTO admin_logs VALUES(31,2,'approved_report','report',39,'2026-06-28 09:13:06');
INSERT INTO admin_logs VALUES(32,2,'approved_report','report',40,'2026-06-28 09:21:12');
INSERT INTO admin_logs VALUES(33,2,'rejected_report','report',19,'2026-06-28 10:37:53');
INSERT INTO admin_logs VALUES(34,2,'rejected_report','report',15,'2026-06-28 10:46:59');
INSERT INTO admin_logs VALUES(35,2,'approved_report','report',41,'2026-06-28 11:05:25');
INSERT INTO admin_logs VALUES(36,2,'rejected_report','report',2,'2026-06-28 11:15:32');
INSERT INTO admin_logs VALUES(37,2,'approved_report','report',42,'2026-06-28 11:40:45');
INSERT INTO admin_logs VALUES(38,2,'approved_report','report',43,'2026-06-28 11:43:04');
INSERT INTO admin_logs VALUES(39,2,'approved_report','report',44,'2026-06-28 11:53:06');
INSERT INTO admin_logs VALUES(40,2,'approved_report','report',45,'2026-06-28 12:00:25');
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
INSERT INTO reports VALUES(1,2,NULL,'Musolla DKG 7','DKG 7','Ground Floor',2.31499999999999994,102.325000000000002,'available',1,1,1,1,1,'approved',2,'2026-06-26 11:50:07','2026-06-26 11:50:58');
INSERT INTO reports VALUES(2,2,NULL,'FINAL TEST','DKG FINAL','Level 10',2.29999999999999982,102.299999999999997,'available',1,1,1,1,1,'rejected',2,'2026-06-26 12:16:17','2026-06-28 11:15:30');
INSERT INTO reports VALUES(4,2,NULL,'DELETE MUSOLLA','TEST','TEST',0.0,0.0,'available',1,1,1,1,1,'approved',2,'2026-06-26 12:26:02','2026-06-26 15:24:26');
INSERT INTO reports VALUES(5,2,NULL,'Backend Final Test','DKG 99','Level 9',2.29999999999999982,102.299999999999997,'available',1,1,1,1,1,'approved',2,'2026-06-27 05:42:08','2026-06-27 05:50:50');
INSERT INTO reports VALUES(6,2,NULL,'REJECT TEST','DKG TEST',NULL,NULL,NULL,'available',0,0,0,0,0,'rejected',2,'2026-06-27 05:55:33','2026-06-27 05:56:56');
INSERT INTO reports VALUES(10,2,NULL,'NEW TEST MUSOLLA','DKG TEST','Level 1',2.29999999999999982,102.299999999999997,'available',1,1,1,1,1,'pending',NULL,'2026-06-27 07:37:49',NULL);
INSERT INTO reports VALUES(41,2,NULL,'Surau Kachi','DKG 6','Near IBS',37.421998000000002,-122.084000000000003,'available',1,0,0,1,0,'approved',2,'2026-06-28 11:04:50','2026-06-28 11:05:25');
INSERT INTO reports VALUES(43,9,NULL,'Surau Kachi','Sme Bank','Ground Level',6.43942800000000037,100.530120999999994,'available',1,1,1,1,1,'approved',2,'2026-06-28 11:42:25','2026-06-28 11:43:04');
INSERT INTO reports VALUES(44,2,NULL,'Masjid Kachi','SME Bank','Near Kachi Mart',37.421998000000002,-122.084000000000003,'available',1,1,0,1,1,'approved',2,'2026-06-28 11:52:39','2026-06-28 11:53:06');
INSERT INTO reports VALUES(45,9,NULL,'Surau SOC','Dkg 4','Level 1',6.43943200000000004,100.530124,'available',1,1,0,1,1,'approved',2,'2026-06-28 11:59:39','2026-06-28 12:00:25');
CREATE TABLE report_images (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    report_id INTEGER NOT NULL,

    image_path TEXT NOT NULL,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(report_id)
        REFERENCES reports(id)
        ON DELETE CASCADE
);
INSERT INTO report_images VALUES(1,2,'6a3e6dc7e760f0.40848859.','2026-06-26 12:17:11');
INSERT INTO report_images VALUES(2,2,'6a3e6dc84ac2b3.52250442.','2026-06-26 12:17:12');
INSERT INTO report_images VALUES(27,41,'6a40ffd87bd370.81380258.jpg','2026-06-28 11:04:56');
INSERT INTO report_images VALUES(28,44,'6a410b0c9dccd4.83634993.jpg','2026-06-28 11:52:44');
INSERT INTO report_images VALUES(29,45,'6a410cae5c8755.48562523.jpg','2026-06-28 11:59:42');
INSERT INTO report_images VALUES(30,45,'6a410cae9eff27.24695425.jpg','2026-06-28 11:59:42');
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('users',9);
INSERT INTO sqlite_sequence VALUES('musollas',24);
INSERT INTO sqlite_sequence VALUES('pending_musollas',4);
INSERT INTO sqlite_sequence VALUES('admin_logs',40);
INSERT INTO sqlite_sequence VALUES('reports',45);
INSERT INTO sqlite_sequence VALUES('report_images',30);
INSERT INTO sqlite_sequence VALUES('musolla_images',28);
CREATE INDEX idx_users_email
ON users(email);
CREATE INDEX idx_musollas_name
ON musollas(name);
CREATE INDEX idx_musollas_location
ON musollas(location);
COMMIT;
