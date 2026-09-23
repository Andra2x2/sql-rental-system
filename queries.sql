-- Rental details, agreed rate and number of billable days (end date excluded).
SELECT r.id, c.name AS customer, v.brand, r.start_date, r.end_date,
 CAST(julianday(r.end_date)-julianday(r.start_date) AS INTEGER) AS days,
 r.daily_rate, CAST((julianday(r.end_date)-julianday(r.start_date))*r.daily_rate AS INTEGER) AS total,
 r.status
FROM rentals r JOIN customers c ON c.id=r.customer_id
JOIN vehicles v ON v.id=r.vehicle_id ORDER BY r.id;

-- Include customers with no non-cancelled bookings using LEFT JOIN.
SELECT c.name, COUNT(r.id) AS bookings FROM customers c
LEFT JOIN rentals r ON r.customer_id=c.id AND r.status != 'cancelled'
GROUP BY c.id,c.name ORDER BY c.id;

-- Vehicles available for [2026-09-20, 2026-09-22).
SELECT v.plate,v.brand,v.daily_rate FROM vehicles v WHERE NOT EXISTS (
 SELECT 1 FROM rentals r WHERE r.vehicle_id=v.id AND r.status != 'cancelled'
 AND r.start_date < '2026-09-22' AND r.end_date > '2026-09-20'
);

-- Booking value is not the same as received payment.
SELECT SUM(CAST((julianday(end_date)-julianday(start_date))*daily_rate AS INTEGER)) AS booking_value
FROM rentals WHERE status != 'cancelled';
