-- Create database
CREATE DATABASE IF NOT EXISTS airline_reservation_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE airline_reservation_system;

-- -----------------------------
-- 1. SCHEMA DEFINITION
-- -----------------------------

-- Create user roles system (optional metadata for staff)
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

-- Airport management
CREATE TABLE airports (
    airport_code CHAR(3) PRIMARY KEY, -- IATA code
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6)
);

-- Aircraft types and models
CREATE TABLE aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    year_of_manufacture YEAR,
    active_status BOOLEAN DEFAULT TRUE
);

-- Seat configurations based on aircraft
CREATE TABLE seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL, -- e.g., '12A'
    seat_class ENUM(
        'ECONOMY',
        'PREMIUM_ECONOMY',
        'BUSINESS',
        'FIRST'
    ) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (aircraft_id) REFERENCES aircraft (aircraft_id),
    UNIQUE KEY (aircraft_id, seat_number) -- Prevent duplicate seats per aircraft
);

-- Flight Routes
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_airport CHAR(3) NOT NULL,
    destination_airport CHAR(3) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    distance_km INT,
    FOREIGN KEY (origin_airport) REFERENCES airports (airport_code),
    FOREIGN KEY (destination_airport) REFERENCES airports (airport_code),
    UNIQUE KEY (
        origin_airport,
        destination_airport
    )
);

-- Flight schedules
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
    FOREIGN KEY (aircraft_id) REFERENCES aircraft (aircraft_id),
    CHECK (arrival_time > departure_time)
);

-- Passenger details (can be distinct from users/booking agents)
CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(50) UNIQUE,
    nationality VARCHAR(50)
);

-- Flight class pricing details for specific flights (multiplier on base price)
CREATE TABLE flight_pricing (
    pricing_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_class ENUM(
        'ECONOMY',
        'PREMIUM_ECONOMY',
        'BUSINESS',
        'FIRST'
    ) NOT NULL,
    price_multiplier DECIMAL(4, 2) NOT NULL DEFAULT 1.00,
    FOREIGN KEY (flight_id) REFERENCES flights (flight_id),
    UNIQUE KEY (flight_id, seat_class)
);

-- Bookings
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference CHAR(6) NOT NULL UNIQUE, -- Alphanumeric PNR
    user_id INT NOT NULL, -- Who made the booking
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM(
        'PENDING',
        'CONFIRMED',
        'CANCELLED'
    ) DEFAULT 'PENDING',
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- Booking Items (Specific seats booked for specific passengers)
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

-- Payment processing
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM(
        'CREDIT_CARD',
        'DEBIT_CARD',
        'PAYPAL',
        'BANK_TRANSFER'
    ) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE,
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
-- 2. INDEXES FOR SEARCH OPTIMIZATION
-- -----------------------------
CREATE INDEX idx_flights_departure ON flights (departure_time);

CREATE INDEX idx_flights_route ON flights (route_id, status);

CREATE INDEX idx_booking_items_flight_seat ON booking_items (flight_id, seat_id, status);

CREATE INDEX idx_bookings_user ON bookings (user_id, status);

-- -----------------------------
-- 3. TRIGGERS
-- -----------------------------
DELIMITER / /

-- Trigger: Prevent Double Booking
CREATE TRIGGER before_booking_item_insert
BEFORE INSERT ON booking_items
FOR EACH ROW
BEGIN
    DECLARE seat_booked INT;
    DECLARE matching_aircraft INT;

    -- 1. Check if the seat is already actively booked for this flight
    SELECT COUNT(*) INTO seat_booked
    FROM booking_items
    WHERE flight_id = NEW.flight_id 
      AND seat_id = NEW.seat_id 
      AND status = 'ACTIVE';
      
    IF seat_booked > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This seat is already booked for this flight.';
    END IF;

    -- 2. Validate that the seat actually belongs to the aircraft assigned to the flight
    SELECT COUNT(*) INTO matching_aircraft
    FROM seats s
    JOIN flights f ON s.aircraft_id = f.aircraft_id
    WHERE s.seat_id = NEW.seat_id AND f.flight_id = NEW.flight_id;
    
    IF matching_aircraft = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat does not belong to the assigned aircraft for this flight.';
    END IF;
END //

CREATE TRIGGER before_booking_item_update
BEFORE UPDATE ON booking_items
FOR EACH ROW
BEGIN
    DECLARE seat_booked INT;
    IF NEW.status = 'ACTIVE' AND (NEW.seat_id != OLD.seat_id OR OLD.status = 'CANCELLED') THEN
        SELECT COUNT(*) INTO seat_booked
        FROM booking_items
        WHERE flight_id = NEW.flight_id 
          AND seat_id = NEW.seat_id 
          AND status = 'ACTIVE'
          AND booking_item_id != NEW.booking_item_id;
          
        IF seat_booked > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This seat is already booked for this flight.';
        END IF;
    END IF;
END //

DELIMITER;

-- -----------------------------
-- 4. STORED PROCEDURES
-- -----------------------------
DELIMITER / /

-- Stored Procedure: Make a Booking with Transactions
CREATE PROCEDURE SP_BookFlight(
    IN p_user_id INT,
    IN p_flight_id INT,
    IN p_passenger_id INT,
    IN p_seat_id INT,
    IN p_payment_method VARCHAR(50),
    IN p_transaction_id VARCHAR(100),
    OUT p_message VARCHAR(100),
    OUT p_booking_id INT
)
BEGIN
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_multiplier DECIMAL(4,2);
    DECLARE v_final_price DECIMAL(10,2);
    DECLARE v_route_id INT;
    DECLARE v_seat_class VARCHAR(50);
    DECLARE v_booking_ref CHAR(6);
    
    DECLARE exit handler for sqlexception
    BEGIN
        ROLLBACK;
        SET p_message = 'Booking failed due to an error. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Generate a random Reference (PNR)
    SET v_booking_ref = SUBSTRING(MD5(RAND()), 1, 6);

    -- Get Base Price and Seat Class Multiplier
    SELECT f.route_id INTO v_route_id FROM flights f WHERE f.flight_id = p_flight_id FOR SHARE;
    SELECT base_price INTO v_base_price FROM routes WHERE route_id = v_route_id;
    SELECT seat_class INTO v_seat_class FROM seats WHERE seat_id = p_seat_id;
    
    SELECT COALESCE(price_multiplier, 1.0) INTO v_multiplier 
    FROM flight_pricing 
    WHERE flight_id = p_flight_id AND seat_class = v_seat_class;

    SET v_final_price = v_base_price * v_multiplier;

    -- Create Booking record
    INSERT INTO bookings (booking_reference, user_id, total_amount, status)
    VALUES (UPPER(v_booking_ref), p_user_id, v_final_price, 'CONFIRMED');
    
    SET p_booking_id = LAST_INSERT_ID();

    -- Create Booking Item (Trigger will catch double booking here)
    INSERT INTO booking_items (booking_id, flight_id, passenger_id, seat_id, item_price, status)
    VALUES (p_booking_id, p_flight_id, p_passenger_id, p_seat_id, v_final_price, 'ACTIVE');

    -- Record Payment
    INSERT INTO payments (booking_id, amount, payment_method, transaction_id, payment_status)
    VALUES (p_booking_id, v_final_price, p_payment_method, p_transaction_id, 'SUCCESS');

    COMMIT;
    SET p_message = 'Booking confirmed successfully.';
END //

-- Stored Procedure: Cancel Booking
CREATE PROCEDURE SP_CancelBooking(
    IN p_booking_id INT,
    OUT p_message VARCHAR(100)
)
BEGIN
    DECLARE exit handler for sqlexception
    BEGIN
        ROLLBACK;
        SET p_message = 'Cancellation failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Update booking status
    UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = p_booking_id;
    
    -- Release seats
    UPDATE booking_items SET status = 'CANCELLED' WHERE booking_id = p_booking_id;
    
    -- Refund payment (simulated)
    UPDATE payments SET payment_status = 'REFUNDED' WHERE booking_id = p_booking_id AND payment_status = 'SUCCESS';

    COMMIT;
    SET p_message = 'Booking cancelled successfully.';
END //

DELIMITER;

-- -----------------------------
-- 5. VIEWS FOR ANALYTICS AND REPORTS
-- -----------------------------

-- View: Detailed Booking Report
CREATE VIEW vw_booking_details AS
SELECT
    b.booking_reference,
    b.booking_date,
    b.status AS booking_status,
    f.flight_number,
    r.origin_airport,
    r.destination_airport,
    f.departure_time,
    p.first_name,
    p.last_name,
    s.seat_number,
    s.seat_class,
    bi.item_price,
    pay.payment_status
FROM
    bookings b
    JOIN booking_items bi ON b.booking_id = bi.booking_id
    JOIN flights f ON bi.flight_id = f.flight_id
    JOIN routes r ON f.route_id = r.route_id
    JOIN passengers p ON bi.passenger_id = p.passenger_id
    JOIN seats s ON bi.seat_id = s.seat_id
    JOIN payments pay ON b.booking_id = pay.booking_id;

-- View: Revenue by Flight
CREATE VIEW vw_flight_revenue AS
SELECT
    f.flight_id,
    f.flight_number,
    r.origin_airport,
    r.destination_airport,
    f.departure_time,
    COUNT(bi.booking_item_id) AS seats_sold,
    SUM(bi.item_price) AS total_revenue
FROM
    flights f
    JOIN routes r ON f.route_id = r.route_id
    LEFT JOIN booking_items bi ON f.flight_id = bi.flight_id
    AND bi.status = 'ACTIVE'
GROUP BY
    f.flight_id,
    f.flight_number,
    r.origin_airport,
    r.destination_airport,
    f.departure_time;

-- -----------------------------
-- 6. ADVANCED ANALYTICS QUERIES (Examples using window functions)
-- -----------------------------

-- Note: These are example queries that analysts would run.

/* 
-- Rank popular flight routes based on total passengers (Window Function Example)
SELECT 
r.origin_airport, 
r.destination_airport,
COUNT(bi.booking_item_id) as total_passengers,
RANK() OVER (ORDER BY COUNT(bi.booking_item_id) DESC) as popularity_rank,
DENSE_RANK() OVER (ORDER BY COUNT(bi.booking_item_id) DESC) as popularity_dense_rank
FROM routes r
JOIN flights f ON r.route_id = f.route_id
LEFT JOIN booking_items bi ON f.flight_id = bi.flight_id AND bi.status = 'ACTIVE'
GROUP BY r.route_id, r.origin_airport, r.destination_airport;

-- Cumulative Revenue over time (Window Function Example)
SELECT 
DATE(payment_date) as date,
SUM(amount) as daily_revenue,
SUM(SUM(amount)) OVER (ORDER BY DATE(payment_date) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cumulative_revenue
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY DATE(payment_date);

-- Identify empty seats on a specific flight
SELECT s.seat_number, s.seat_class
FROM seats s
WHERE s.aircraft_id = (SELECT aircraft_id FROM flights WHERE flight_id = 1)
AND s.seat_id NOT IN (
SELECT seat_id FROM booking_items WHERE flight_id = 1 AND status = 'ACTIVE'
);
*/