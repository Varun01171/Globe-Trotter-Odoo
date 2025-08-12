DROP DATABASE IF EXISTS globe_trotter1;
CREATE DATABASE IF NOT EXISTS globe_trotter1;
USE globe_trotter1;

-- screen 1: Users and related
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

-- Sample users with bcrypt hashes
INSERT INTO users (first_name, email, password_hash) VALUES
('Amit', 'amit@example.com', '$2b$12$PsaH1UOgZGgA1rP4XcZEr.2V0BzK1o2qQtp80wP4Yj4HtRk/hIN7u'), -- test123
('Priya', 'priya@example.com', '$2b$12$8fx0n/dA3L1D8l7Ezy.o7Ogj4j.q0PTLgDcvjUo1n6gI9sKckPslC'), -- welcome
('Rahul', 'rahul@example.com', '$2b$12$wF6j2jTDqOr4T5fYlEMiXeqyTuHuytKxQw07T4y9CrDplNzC4Yy3K'); -- mypass

SELECT * FROM users;

CREATE TABLE password_resets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    reset_token VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- screen 2: Regions and User-Region mapping
CREATE TABLE regions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE user_regions (
    user_id INT NOT NULL,
    region_id INT NOT NULL,
    PRIMARY KEY (user_id, region_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE CASCADE
);

-- screen 3: Cities and Trips
CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    visits INT DEFAULT 0,
    growth_percentage DECIMAL(5,2) DEFAULT 0.00
);

CREATE TABLE trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    city_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

CREATE INDEX idx_trips_user_start_end ON trips (user_id, start_date, end_date);

-- screen 4: Trip suggestions
CREATE TABLE trip_suggestions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    category VARCHAR(50)
);

-- screen 5: Itineraries and itinerary sections
CREATE TABLE itineraries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE itinerary_sections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    section_name VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE
);

-- screen 6: Planned trip requests
CREATE TABLE planned_trip_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    place VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10, 2),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- screen 7: Calendar Events
CREATE TABLE calendar_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NULL,
    itinerary_section_id INT NULL,
    title VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    event_type ENUM('trip', 'activity', 'other') DEFAULT 'trip',
    color_code VARCHAR(20),
    FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
    FOREIGN KEY (itinerary_section_id) REFERENCES itinerary_sections(id) ON DELETE CASCADE
);

-- screen 8: Activities
CREATE TABLE activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT,
    title VARCHAR(150) NOT NULL,
    image_url VARCHAR(255),
    location VARCHAR(150),
    activity_date DATE,
    slots_available INT,
    max_slots INT,
    rating DECIMAL(2,1),
    description TEXT,
    tags VARCHAR(255),
    price DECIMAL(10,2),
    price_unit VARCHAR(50) DEFAULT 'per person',
    status ENUM('open', 'limited', 'closed') DEFAULT 'open',
    duration_hours DECIMAL(4,2),
    category ENUM('adventure', 'cultural', 'dining', 'other') DEFAULT 'other',
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL
);

-- screen 9: Itinerary activities and day summary
CREATE TABLE itinerary_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    day_number INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    category ENUM('adventure', 'cultural', 'dining', 'other') DEFAULT 'other',
    duration_hours DECIMAL(4,2),
    price DECIMAL(10,2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    INDEX(itinerary_id),
    INDEX(day_number)
);

CREATE TABLE itinerary_day_summary (
    itinerary_id INT NOT NULL,
    day_number INT NOT NULL,
    activities_count INT DEFAULT 0,
    day_total_budget DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (itinerary_id, day_number),
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE
);

-- screen 10: Community posts, likes, comments
CREATE TABLE community_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category ENUM('adventure', 'cultural', 'dining', 'transport', 'accommodation', 'other') DEFAULT 'other',
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    rating DECIMAL(2,1),
    image_url VARCHAR(255),
    location VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (post_id, user_id)
);

CREATE TABLE post_comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- screen 11: User activity bookings
CREATE TABLE user_activity_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    activity_id INT NOT NULL,
    booking_date DATETIME NOT NULL,
    status ENUM('booked', 'completed', 'cancelled') DEFAULT 'booked',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
);

-- screen 12: Stats of admin
CREATE TABLE city_visits_trends (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    visits INT NOT NULL
);

CREATE TABLE city_demographics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    user_count INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

CREATE TABLE regional_distribution (
    id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    user_count INT NOT NULL,
    percentage DECIMAL(5,2) NOT NULL
);


ALTER TABLE trips 
ADD COLUMN destination VARCHAR(255) NOT NULL;
