BEGIN;
INSERT INTO customers VALUES (1,'Andi','Banjarmasin'),(2,'Citra','Banjarbaru'),(3,'Budi','Martapura');
INSERT INTO customer_phones VALUES (1,'080000000001'),(1,'080000000002'),(2,'080000000003');
INSERT INTO categories VALUES (1,'City car'),(2,'MPV'),(3,'SUV');
INSERT INTO vehicles VALUES
 (1,'DEMO-01','Toyota Agya',2023,250000,1),
 (2,'DEMO-02','Toyota Avanza',2022,350000,2),
 (3,'DEMO-03','Daihatsu Terios',2024,450000,3);
INSERT INTO rentals VALUES
 (1,1,1,'2026-09-20','2026-09-22',250000,'booked'),
 (2,2,3,'2026-09-20','2026-09-22',475000,'active'),
 (3,3,1,'2026-09-21','2026-09-23',250000,'cancelled');
COMMIT;
