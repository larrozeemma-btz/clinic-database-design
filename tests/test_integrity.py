"""Checks that the schema enforces the business rules and removes the paper record's anomalies.

Run with:  python -m unittest discover tests
"""
import sqlite3
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from run import build  # noqa: E402


class ClinicSchemaTests(unittest.TestCase):
    def setUp(self):
        self.db = build(":memory:")

    def tearDown(self):
        self.db.close()

    def count(self, sql, *args):
        return self.db.execute(sql, args).fetchone()[0]

    # Rule 3: an appointment cannot exist without a patient and a doctor
    def test_appointment_requires_existing_patient(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO Appointment VALUES ('A700', 'P999', 'D07', '2026-11-02 09:00:00', NULL)")

    def test_appointment_requires_existing_doctor(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO Appointment VALUES ('A701', 'P101', 'D99', '2026-11-02 09:00:00', NULL)")

    # Rule 4: at most one prescription per visit
    def test_only_one_prescription_per_appointment(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO Prescription VALUES ('RX2000', 'A501', 'M03', '2026-09-03')")

    # Insertion anomaly removed: register a patient or a medicine on its own
    def test_patient_can_be_registered_before_any_visit(self):
        self.db.execute("INSERT INTO Patient VALUES ('P600', 'Walk-in Student', '555-0100', NULL)")
        self.assertEqual(self.count("SELECT COUNT(*) FROM Appointment WHERE PatientID = 'P600'"), 0)

    def test_medicine_can_exist_without_prescription(self):
        self.assertEqual(self.count("SELECT COUNT(*) FROM Prescription WHERE MedicineID = 'M07'"), 0)

    # Deletion anomaly removed: cancelling a visit keeps the patient and reference data
    def test_deleting_only_visit_keeps_patient_and_diagnosis(self):
        self.db.execute("DELETE FROM Appointment WHERE AppointmentID = 'A630'")
        self.db.execute("DELETE FROM Appointment WHERE AppointmentID = 'A566'")
        self.assertEqual(self.count("SELECT COUNT(*) FROM Patient WHERE PatientID = 'P204'"), 1)
        self.assertEqual(self.count("SELECT COUNT(*) FROM Diagnosis WHERE DiagnosisName = 'Migraine'"), 1)
        self.assertEqual(self.count("SELECT COUNT(*) FROM Prescription WHERE AppointmentID = 'A566'"), 0)

    def test_patient_with_visits_cannot_be_deleted(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("DELETE FROM Patient WHERE PatientID = 'P101'")

    # Update anomaly removed: one edit fixes every visit
    def test_phone_is_stored_once(self):
        self.db.execute("UPDATE Patient SET PatientPhone = '555-0111' WHERE PatientID = 'P101'")
        phones = self.db.execute(
            "SELECT DISTINCT p.PatientPhone FROM Appointment a JOIN Patient p USING (PatientID) WHERE a.PatientID = 'P101'"
        ).fetchall()
        self.assertEqual(phones, [("555-0111",)])

    # Pending diagnoses are recorded as NULL, not loose text
    def test_pending_case_has_null_diagnosis(self):
        self.assertIsNone(self.db.execute("SELECT DiagnosisID FROM Appointment WHERE AppointmentID = 'A590'").fetchone()[0])

    # Identifier formats are validated
    def test_malformed_patient_id_is_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO Patient VALUES ('X12', 'Bad Id', '555-0000', NULL)")

    def test_malformed_datetime_is_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO Appointment VALUES ('A702', 'P101', 'D07', 'Sep 3, 9:00', NULL)")

    # The workshop query keeps visits without a prescription
    def test_visit_log_includes_visits_without_medicine(self):
        total = self.count("SELECT COUNT(*) FROM Appointment")
        logged = self.count("""
            SELECT COUNT(*) FROM Appointment a
            JOIN Patient p ON a.PatientID = p.PatientID
            JOIN Doctor d ON a.DoctorID = d.DoctorID
            LEFT JOIN Prescription pr ON a.AppointmentID = pr.AppointmentID
            LEFT JOIN Medicine m ON pr.MedicineID = m.MedicineID""")
        self.assertEqual(total, logged)


if __name__ == "__main__":
    unittest.main()
