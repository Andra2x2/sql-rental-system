-- SQLite 3.38+. Run on a new database; this script never drops existing data.
PRAGMA foreign_keys = ON;
BEGIN;
CREATE TABLE customers (
 id INTEGER PRIMARY KEY, name TEXT NOT NULL CHECK(length(trim(name)) > 0),
 address TEXT NOT NULL
);
CREATE TABLE customer_phones (
 customer_id INTEGER NOT NULL REFERENCES customers(id), phone TEXT NOT NULL,
 PRIMARY KEY(customer_id,phone), CHECK(length(trim(phone)) > 0)
);
CREATE TABLE categories (
 id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE
);
CREATE TABLE vehicles (
 id INTEGER PRIMARY KEY, plate TEXT NOT NULL UNIQUE, brand TEXT NOT NULL,
 year INTEGER NOT NULL CHECK(year BETWEEN 1900 AND 2100),
 daily_rate INTEGER NOT NULL CHECK(daily_rate > 0),
 category_id INTEGER NOT NULL REFERENCES categories(id)
);
CREATE TABLE rentals (
 id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL REFERENCES customers(id),
 vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
 start_date TEXT NOT NULL, end_date TEXT NOT NULL,
 -- Store the rate agreed at booking, so later vehicle price changes do not alter it.
 daily_rate INTEGER NOT NULL CHECK(daily_rate > 0),
 status TEXT NOT NULL CHECK(status IN ('booked','active','completed','cancelled')),
 CHECK(length(start_date)=10 AND start_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
       AND date(start_date,'+0 days') IS NOT NULL AND date(start_date,'+0 days')=start_date),
 CHECK(length(end_date)=10 AND end_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
       AND date(end_date,'+0 days') IS NOT NULL AND date(end_date,'+0 days')=end_date),
 CHECK(end_date > start_date)
);
CREATE INDEX rental_vehicle_dates ON rentals(vehicle_id,start_date,end_date);
-- Half-open intervals [start, end): return and next pickup may share a date.
CREATE TRIGGER prevent_overlap_insert BEFORE INSERT ON rentals
WHEN NEW.status != 'cancelled' AND EXISTS (
 SELECT 1 FROM rentals WHERE vehicle_id=NEW.vehicle_id AND status != 'cancelled'
 AND start_date < NEW.end_date AND end_date > NEW.start_date
)
BEGIN SELECT RAISE(ABORT,'Vehicle already booked for these dates'); END;
CREATE TRIGGER prevent_overlap_update BEFORE UPDATE ON rentals
WHEN NEW.status != 'cancelled' AND EXISTS (
 SELECT 1 FROM rentals WHERE vehicle_id=NEW.vehicle_id AND id != OLD.id AND status != 'cancelled'
 AND start_date < NEW.end_date AND end_date > NEW.start_date
)
BEGIN SELECT RAISE(ABORT,'Vehicle already booked for these dates'); END;
COMMIT;
