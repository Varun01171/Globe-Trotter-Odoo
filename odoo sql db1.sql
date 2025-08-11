CREATE DATABASE IF NOT EXISTS globe_trotter;
USE globe_trotter;

-- screen 1
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    profile_image_url VARCHAR(255),
    phone VARCHAR(20),
    bio TEXT,
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE password_resets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    reset_token VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO users (name, email, password_hash, profile_image_url) VALUES
('Rahul Sharma', 'rahul.sharma@example.com', 'pbkdf2:sha256:260000$abc123$fakehashrahul', 'https://example.com/images/rahul.jpg'),
('Priya Verma', 'priya.verma@example.com', 'pbkdf2:sha256:260000$def456$fakehashpriya', 'https://example.com/images/priya.jpg'),
('Arjun Patel', 'arjun.patel@example.com', 'pbkdf2:sha256:260000$ghi789$fakehasharjun', 'https://example.com/images/arjun.jpg');

-- screen 2
CREATE TABLE top_regional_selections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    link_url VARCHAR(255),
    image_url VARCHAR(255)
);

INSERT INTO top_regional_selections (name, link_url, image_url) VALUES
('Jaipur', 'jaipur.html', 'https://example.com/images/jaipur.jpg'),
('Shimla', NULL, 'https://example.com/images/shimla.jpg'),
('Pushkar', NULL, 'https://example.com/images/pushkar.jpg'),
('Mumbai', NULL, 'https://example.com/images/mumbai.jpg'),
('Kerala', NULL, 'https://example.com/images/kerala.jpg');

CREATE TABLE previous_trips (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO previous_trips (user_id, name, image_url) VALUES
(1, 'Amritsar', 'https://example.com/images/amritsar.jpg'),
(1, 'Puri', 'https://example.com/images/puri.jpg'),
(2, 'Vrindavan', 'https://example.com/images/vrindavan.jpg');

-- screen 3
CREATE TABLE trips (
    trip_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    start_date DATE NOT NULL,
    place VARCHAR(150) NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO trips (user_id, start_date, place, end_date) VALUES
(1, '2025-09-12', 'Delhi', '2025-09-15'),
(1, '2025-09-20', 'Manali', '2025-09-25'),
(2, '2025-10-05', 'Kerala', '2025-10-12');

-- screen 4
CREATE TABLE trip_suggestions (
    suggestion_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    category VARCHAR(50)
);

INSERT INTO trip_suggestions (title, image_url, category) VALUES
('Taj Mahal, Agra', 'images/tajmahal.jpeg', 'historical'),
('Jaipur City Palace, Rajasthan', 'images/jaipur_city_palace.jpg', 'historical'),
('Varanasi Ghats, Uttar Pradesh', 'images/varanasi.jpg', 'cultural'),
('Himalayas, Himachal Pradesh', 'images/shimla.jpg', 'nature');

-- screen 5
CREATE TABLE itineraries (
    itinerary_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE itinerary_sections (
    section_id INT PRIMARY KEY AUTO_INCREMENT,
    itinerary_id INT NOT NULL,
    section_name VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(itinerary_id) ON DELETE CASCADE
);

INSERT INTO itineraries (user_id) VALUES
(1),
(2);

INSERT INTO itinerary_sections (itinerary_id, section_name, start_date, end_date, budget) VALUES
(1, 'Hotel Stay', '2025-09-12', '2025-09-15', 5000.00),
(1, 'Travel', '2025-09-12', '2025-09-15', 3000.00),
(1, 'Food', '2025-09-12', '2025-09-15', 2000.00),
(2, 'Hotel Stay', '2025-10-05', '2025-10-07', 6000.00),
(2, 'Travel', '2025-10-05', '2025-10-07', 4000.00);

-- screen 6
CREATE OR REPLACE VIEW user_trips_status AS
SELECT
    trip_id,
    user_id,
    place,
    start_date,
    end_date,
    created_at,
    CASE
        WHEN CURDATE() BETWEEN start_date AND end_date THEN 'ongoing'
        WHEN CURDATE() < start_date THEN 'upcoming'
        ELSE 'completed'
    END AS status
FROM trips;

CREATE INDEX idx_trips_user_start_end ON trips (user_id, start_date, end_date);

CREATE TABLE planned_trip_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    place VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10, 2),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- screen 7
-- (Already included profile fields and previous_trips user_id above in screen 1 & 2)

-- screen 8
CREATE TABLE activities (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    location VARCHAR(150) NOT NULL,
    activity_date DATE NOT NULL,
    slots_available INT NOT NULL,
    max_slots INT NOT NULL,
    rating DECIMAL(2,1) DEFAULT NULL,
    description TEXT,
    tags VARCHAR(255),
    price DECIMAL(8,2) NOT NULL,
    price_unit VARCHAR(50) DEFAULT 'per person',
    status ENUM('open', 'limited', 'closed') DEFAULT 'open'
);

-- screen 9
CREATE TABLE itinerary_activities (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    day_number INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    category ENUM('adventure', 'cultural', 'dining', 'other') DEFAULT 'other',
    duration_hours DECIMAL(4,2),
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(itinerary_id) ON DELETE CASCADE,
    INDEX(itinerary_id),
    INDEX(day_number)
);

CREATE TABLE itinerary_day_summary (
    itinerary_id INT NOT NULL,
    day_number INT NOT NULL,
    activities_count INT DEFAULT 0,
    day_total_budget DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (itinerary_id, day_number),
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(itinerary_id) ON DELETE CASCADE
);

-- screen 10
CREATE TABLE community_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category ENUM('adventure', 'cultural', 'dining', 'transport', 'accommodation', 'other') DEFAULT 'other',
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    rating DECIMAL(2,1) DEFAULT NULL,
    image_url VARCHAR(255),
    location VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE post_likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES community_posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (post_id, user_id)
);

CREATE TABLE post_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES community_posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
