-- ==========================================
-- AIRLINE RESERVATION SYSTEM (FULL SETUP)
-- ==========================================
-- This script creates the schema, inserts data, and outputs reports.

DROP DATABASE IF EXISTS airline_reservation_system;

CREATE DATABASE airline_reservation_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE airline_reservation_system;

-- -----------------------------
-- 1. SCHEMA DEFINITION
-- -----------------------------
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles (role_id)
);

CREATE TABLE airports (
    airport_code CHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    year_of_manufacture YEAR,
    active_status BOOLEAN DEFAULT TRUE
);

CREATE TABLE seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    seat_class ENUM(
        'ECONOMY',
        'PREMIUM_ECONOMY',
        'BUSINESS',
        'FIRST'
    ) NOT NULL,
    FOREIGN KEY (aircraft_id) REFERENCES aircraft (aircraft_id)
);

CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_airport CHAR(3) NOT NULL,
    destination_airport CHAR(3) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    distance_km INT,
    FOREIGN KEY (origin_airport) REFERENCES airports (airport_code),
    FOREIGN KEY (destination_airport) REFERENCES airports (airport_code)
);

CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    route_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    status ENUM(
        'SCHEDULED',
        'DELAYED',
        'DEPARTED',
        'ARRIVED',
        'CANCELLED'
    ) DEFAULT 'SCHEDULED',
    FOREIGN KEY (route_id) REFERENCES routes (route_id),
    FOREIGN KEY (aircraft_id) REFERENCES aircraft (aircraft_id)
);

CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(50) UNIQUE,
    nationality VARCHAR(50)
);

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference CHAR(6) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM(
        'PENDING',
        'CONFIRMED',
        'CANCELLED'
    ) DEFAULT 'PENDING',
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE TABLE booking_items (
    booking_item_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_id INT NOT NULL,
    item_price DECIMAL(10, 2) NOT NULL,
    status ENUM('ACTIVE', 'CANCELLED') DEFAULT 'ACTIVE',
    FOREIGN KEY (booking_id) REFERENCES bookings (booking_id),
    FOREIGN KEY (flight_id) REFERENCES flights (flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id),
    FOREIGN KEY (seat_id) REFERENCES seats (seat_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status ENUM(
        'PENDING',
        'SUCCESS',
        'FAILED',
        'REFUNDED'
    ) DEFAULT 'PENDING',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings (booking_id)
);

-- -----------------------------
-- 2. INSERT SAMPLE DATA
-- -----------------------------
INSERT INTO roles (role_name) VALUES ('ADMIN'), ('CUSTOMER');

INSERT INTO
    users (
        email,
        password_hash,
        first_name,
        last_name,
        role_id
    )
VALUES (
        'john.doe@example.com',
        'hash',
        'John',
        'Doe',
        2
    ),
    (
        'jane.smith@example.com',
        'hash',
        'Jane',
        'Smith',
        2
    );

INSERT INTO
    airports (
        airport_code,
        name,
        city,
        country
    )
VALUES (
        'JFK',
        'John F. Kennedy',
        'New York',
        'USA'
    ),
    (
        'LHR',
        'Heathrow',
        'London',
        'UK'
    ),
    (
        'DXB',
        'Dubai International',
        'Dubai',
        'UAE'
    );

INSERT INTO
    aircraft (
        model,
        manufacturer,
        year_of_manufacture
    )
VALUES ('Boeing 777', 'Boeing', 2015),
    ('Airbus A380', 'Airbus', 2018);

INSERT INTO
    seats (
        aircraft_id,
        seat_number,
        seat_class
    )
VALUES (1, '1A', 'FIRST'),
    (1, '1B', 'FIRST'),
    (1, '12A', 'ECONOMY'),
    (1, '12B', 'ECONOMY'),
    (2, '1A', 'FIRST'),
    (2, '1B', 'FIRST'),
    (2, '35C', 'ECONOMY');

INSERT INTO
    routes (
        origin_airport,
        destination_airport,
        base_price,
        distance_km
    )
VALUES ('JFK', 'LHR', 500.00, 5540),
    ('LHR', 'DXB', 600.00, 5470),
    ('DXB', 'JFK', 800.00, 11000);

-- Insert Flights
INSERT INTO
    flights (
        flight_number,
        route_id,
        aircraft_id,
        departure_time,
        arrival_time,
        status
    )
VALUES (
        'AA100',
        1,
        1,
        '2026-04-01 10:00:00',
        '2026-04-01 22:00:00',
        'SCHEDULED'
    ),
    (
        'BA200',
        2,
        2,
        '2026-04-02 11:30:00',
        '2026-04-02 21:30:00',
        'SCHEDULED'
    ),
    (
        'EK300',
        3,
        1,
        '2026-04-03 08:00:00',
        '2026-04-03 23:00:00',
        'SCHEDULED'
    );

-- Insert Passengers
INSERT INTO
    passengers (
        first_name,
        last_name,
        passport_number,
        nationality
    )
VALUES (
        'Alice',
        'Johnson',
        'P123456',
        'USA'
    ),
    (
        'Bob',
        'Williams',
        'P654321',
        'UK'
    ),
    (
        'Charlie',
        'Brown',
        'P112233',
        'Canada'
    );

-- Insert Bookings
INSERT INTO
    bookings (
        booking_reference,
        user_id,
        total_amount,
        status
    )
VALUES (
        'REF001',
        1,
        1000.00,
        'CONFIRMED'
    ),
    (
        'REF002',
        2,
        800.00,
        'CONFIRMED'
    ),
    (
        'REF003',
        1,
        3600.00,
        'CONFIRMED'
    );

-- Booking Items
INSERT INTO
    booking_items (
        booking_id,
        flight_id,
        passenger_id,
        seat_id,
        item_price,
        status
    )
VALUES (1, 1, 1, 1, 500.00, 'ACTIVE'), -- Alice on AA100
    (1, 1, 2, 2, 500.00, 'ACTIVE'), -- Bob on AA100
    (2, 2, 3, 5, 800.00, 'ACTIVE'), -- Charlie on BA200
    (3, 3, 1, 3, 1200.00, 'ACTIVE'), -- Alice on EK300
    (3, 3, 2, 4, 1200.00, 'ACTIVE'), -- Bob on EK300
    (3, 3, 3, 7, 1200.00, 'ACTIVE');
-- Charlie on EK300

-- Payments
INSERT INTO
    payments (
        booking_id,
        amount,
        payment_status
    )
VALUES (1, 1000.00, 'SUCCESS'),
    (2, 800.00, 'SUCCESS'),
    (3, 3600.00, 'SUCCESS');

-- -----------------------------
-- 3. GENERATE TERMINAL OUTPUT (REPORTS)
-- -----------------------------

SELECT '--- Upcoming Flights Report ---' AS Report_Title;

SELECT f.flight_number, r.origin_airport AS `from`, r.destination_airport AS `to`, f.departure_time, f.status
FROM flights f
    JOIN routes r ON f.route_id = r.route_id;

SELECT '--- Passenger Bookings Report ---' AS Report_Title;

SELECT b.booking_reference, p.first_name, p.last_name, f.flight_number, s.seat_number, bi.item_price
FROM
    booking_items bi
    JOIN bookings b ON bi.booking_id = b.booking_id
    JOIN passengers p ON bi.passenger_id = p.passenger_id
    JOIN flights f ON bi.flight_id = f.flight_id
    JOIN seats s ON bi.seat_id = s.seat_id
WHERE
    bi.status = 'ACTIVE';

SELECT '--- Cumulative Revenue Report ---' AS Report_Title;

SELECT
    DATE(payment_date) as `Date`,
    SUM(amount) as daily_revenue,
    SUM(SUM(amount)) OVER (
        ORDER BY DATE(payment_date) ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) as cumulative_revenue
FROM payments
WHERE
    payment_status = 'SUCCESS'
GROUP BY
    DATE(payment_date);