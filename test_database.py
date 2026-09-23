import sqlite3
import unittest
from pathlib import Path
ROOT=Path(__file__).parent
class RentalTests(unittest.TestCase):
    def setUp(self):
        self.db=sqlite3.connect(':memory:')
        self.addCleanup(self.db.close)
        self.db.executescript((ROOT/'schema.sql').read_text())
        self.db.executescript((ROOT/'seed.sql').read_text())
    def test_seed_and_join(self):
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM rentals').fetchone()[0],3)
        self.assertEqual(self.db.execute('SELECT SUM((julianday(end_date)-julianday(start_date))*daily_rate) FROM rentals WHERE status != "cancelled"').fetchone()[0],1450000)
    def test_foreign_key_and_dates(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO rentals(customer_id,vehicle_id,start_date,end_date,daily_rate,status) VALUES(999,1,'2026-10-01','2026-10-02',200000,'booked')")
        for start,end in [('2026-10-03','2026-10-02'),('2026-02-30','2026-03-02')]:
            with self.assertRaises(sqlite3.IntegrityError):
                self.db.execute("INSERT INTO rentals(customer_id,vehicle_id,start_date,end_date,daily_rate,status) VALUES(1,1,?,?,200000,'booked')",(start,end))
    def test_overlap_rejected_but_adjacent_allowed(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO rentals(customer_id,vehicle_id,start_date,end_date,daily_rate,status) VALUES(1,1,'2026-09-21','2026-09-23',250000,'booked')")
        self.db.execute("INSERT INTO rentals(customer_id,vehicle_id,start_date,end_date,daily_rate,status) VALUES(1,1,'2026-09-22','2026-09-23',250000,'booked')")
    def test_update_overlap_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE rentals SET status='booked' WHERE id=3")

if __name__ == '__main__': unittest.main()
