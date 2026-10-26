-- University Wellness Clinic: normalized schema (Third Normal Form)
--
-- Business rules this schema enforces:
--   1. One patient may have zero or many appointments; each appointment belongs to exactly one patient.
--   2. One doctor may conduct many appointments; each appointment is assigned to exactly one doctor.
--   3. A patient may be registered before booking anything; an appointment cannot exist
--      without both a patient and a doctor.
--   4. After a visit, an appointment has zero or one diagnosis and zero or one prescription.
--      One medicine may appear on many prescriptions; each prescription names exactly one medicine.

-- Date checks use IS rather than =: date() returns NULL for malformed text, and a CHECK
-- that evaluates to NULL would otherwise let the bad value through.

PRAGMA foreign_keys = ON;

CREATE TABLE Patient (
    PatientID     TEXT PRIMARY KEY CHECK (PatientID GLOB 'P[0-9][0-9][0-9]'),
    PatientName   TEXT NOT NULL,
    PatientPhone  TEXT NOT NULL,
    DateOfBirth   TEXT CHECK (DateOfBirth IS NULL OR date(DateOfBirth) IS DateOfBirth)
);

CREATE TABLE Doctor (
    DoctorID      TEXT PRIMARY KEY CHECK (DoctorID GLOB 'D[0-9][0-9]'),
    DoctorName    TEXT NOT NULL,
    Specialty     TEXT NOT NULL,
    Extension     TEXT
);

-- Reference list, so a condition is spelled and coded the same way on every visit.
CREATE TABLE Diagnosis (
    DiagnosisID   TEXT PRIMARY KEY,
    DiagnosisName TEXT NOT NULL UNIQUE,
    DiagnosisCode TEXT NOT NULL UNIQUE,   -- ICD-10-CM
    Category      TEXT NOT NULL
);

-- Formulary: a medicine exists whether or not it has ever been prescribed.
CREATE TABLE Medicine (
    MedicineID      TEXT PRIMARY KEY,
    MedicineName    TEXT NOT NULL UNIQUE,
    Form            TEXT NOT NULL,
    StandardDosage  TEXT NOT NULL
);

-- Existence-dependent on Patient and Doctor. A surrogate key is used because the
-- same patient and doctor can meet more than once.
-- DiagnosisID stays NULL while a case is pending.
CREATE TABLE Appointment (
    AppointmentID        TEXT PRIMARY KEY CHECK (AppointmentID GLOB 'A[0-9][0-9][0-9]'),
    PatientID            TEXT NOT NULL REFERENCES Patient(PatientID) ON DELETE RESTRICT,
    DoctorID             TEXT NOT NULL REFERENCES Doctor(DoctorID)   ON DELETE RESTRICT,
    AppointmentDateTime  TEXT NOT NULL CHECK (datetime(AppointmentDateTime) IS AppointmentDateTime),
    DiagnosisID          TEXT REFERENCES Diagnosis(DiagnosisID)
);

-- Associative table resolving the many-to-many relationship between Appointment and Medicine.
-- UNIQUE on AppointmentID enforces "at most one prescription per visit". If the clinic
-- later allows several drugs per visit, dropping this constraint is the only change needed.
CREATE TABLE Prescription (
    PrescriptionID  TEXT PRIMARY KEY,
    AppointmentID   TEXT NOT NULL UNIQUE REFERENCES Appointment(AppointmentID) ON DELETE CASCADE,
    MedicineID      TEXT NOT NULL REFERENCES Medicine(MedicineID) ON DELETE RESTRICT,
    DateIssued      TEXT NOT NULL CHECK (date(DateIssued) IS DateIssued)
);

CREATE INDEX idx_appointment_patient   ON Appointment(PatientID);
CREATE INDEX idx_appointment_doctor    ON Appointment(DoctorID);
CREATE INDEX idx_appointment_diagnosis ON Appointment(DiagnosisID);
CREATE INDEX idx_prescription_medicine ON Prescription(MedicineID);
