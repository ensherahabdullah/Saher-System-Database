create database saher;
USE saher;

CREATE TABLE owners (
    owner_id INT PRIMARY KEY ,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) ,
    address VARCHAR(250)
);

CREATE TABLE vehicles (
    plate_number VARCHAR(16) PRIMARY KEY,
    owner_id INT,
    type VARCHAR(50),
    model VARCHAR(50),
    color VARCHAR(30),
    FOREIGN KEY (owner_id) REFERENCES owners(owner_id)
);

CREATE TABLE cameras (
    camera_id INT PRIMARY KEY,
    location VARCHAR(255) NOT NULL,
    type VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE violations (
    violation_id INT PRIMARY key,
    type VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL check(price>0)
);

CREATE TABLE records (
    plate_number VARCHAR(16),
    camera_id INT,
    primary key (plate_number,camera_id),
    FOREIGN KEY (plate_number) REFERENCES vehicles(plate_number),
    FOREIGN KEY (camera_id) REFERENCES cameras(camera_id)
);

CREATE TABLE committedby (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    plate_number VARCHAR(16),
    violation_id INT,
	date DATE,
    FOREIGN KEY (plate_number) REFERENCES vehicles(plate_number),
    FOREIGN KEY (violation_id) REFERENCES violations(violation_id)
 );

INSERT INTO owners (owner_id, name, phone_number, address) VALUES
(1, 'Ahmed Ali', '0501111111', 'Riyadh'),
(2, 'Sara Mohammed', '0502222222', 'Jeddah'),
(3, 'Fahad Saleh', '0503333333', 'Dammam'),
(4, 'Noura Abdullah', '0504444444', 'Riyadh'),
(5, 'Khalid Omar', '0505555555', 'Makkah');

INSERT INTO vehicles (plate_number, owner_id, type, model, color) VALUES
('ABC123', 1, 'Sedan', 'Corolla', 'White'),
('XYZ555', 2, 'SUV', 'Sportage', 'Black'),
('JED777', 3, 'Truck', 'Isuzu', 'Blue'),
('KSA999', 4, 'Sedan', 'Altima', 'Silver'),
('MKK111', 5, 'Taxi', 'Accent', 'Yellow');

INSERT INTO cameras (camera_id, location, type, status) VALUES
(1, 'King Fahd Road', 'Speed', 'Active'),
(2, 'Highway 40', 'ANPR', 'Active'),
(3, 'Dammam Bridge', 'Speed', 'Maintenance'),
(4, 'Jeddah Corniche', 'ANPR', 'Inactive'),
(5, 'Riyadh Exit 15', 'Speed', 'Active');

INSERT INTO violations (violation_id, type, price) VALUES
(1, 'Speeding', 500.00),
(2, 'Red Light', 700.00),
(3, 'No Seatbelt', 150.00),
(4, 'Illegal Parking', 200.00),
(5, 'Wrong Lane', 300.00);

INSERT INTO records (plate_number, camera_id) VALUES
('ABC123', 1),
('XYZ555', 2),
('JED777', 3),
('KSA999', 1),
('MKK111', 5);

INSERT INTO committedby (plate_number, violation_id, date) VALUES
('ABC123', 1, '2023-10-10'),
('ABC123', 3, '2023-10-10'),
('XYZ555', 2, '2023-10-11'),
('JED777', 5, '2023-10-12'),
('MKK111', 4, '2023-10-13');

/* Retrieve violation records after October 10, 2023 */
SELECT plate_number, violation_id, date
FROM committedby
WHERE date > '2023-10-10';

/* Retrieve violations with a price greater than 300 */
SELECT violation_id, type, price
FROM violations
WHERE price > 300;

/* Count the number of violations for each vehicle */
SELECT plate_number, COUNT(violation_id) AS total_violations
FROM committedby
GROUP BY plate_number;

/* Calculate the average violation price for each owner, including owners with no violations */
SELECT 
    o.owner_id,
    o.name,
    COALESCE(AVG(v.price), 0) AS average_violation_price
FROM owners o
LEFT JOIN vehicles ve ON o.owner_id = ve.owner_id
LEFT JOIN committedby c ON ve.plate_number = c.plate_number
LEFT JOIN violations v ON c.violation_id = v.violation_id
GROUP BY o.owner_id, o.name;

/* Display the plate number, owner name, vehicle model, violation type, and date */
SELECT cb.plate_number,
       o.name AS owner_name,
       v.model AS vehicle_model,
       viola.type AS violation_type,
       cb.date
FROM committedby cb
JOIN vehicles v ON cb.plate_number = v.plate_number
JOIN owners o ON v.owner_id = o.owner_id
JOIN violations viola ON cb.violation_id = viola.violation_id;

/* Find vehicles with more than one recorded violation */
SELECT plate_number
FROM vehicles
WHERE plate_number IN (
    SELECT plate_number
    FROM committedby
    GROUP BY plate_number
    HAVING COUNT(violation_id) > 1
);

/* Create a view summarizing recorded violations and their owners */
CREATE VIEW violation_report AS
SELECT 
    v.plate_number,
    o.name AS owner_name,
    viola.type AS violation_type,
    viola.price,
    cb.date AS violation_date
FROM committedby cb
JOIN vehicles v ON cb.plate_number = v.plate_number
JOIN owners o ON v.owner_id = o.owner_id
JOIN violations viola ON cb.violation_id = viola.violation_id;

/* Display the violation report view */
SELECT * FROM violation_report;
