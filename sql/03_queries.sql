-- Queries the clinic can now answer reliably.
-- Each query is preceded by a "-- name:" line used by run.py to label results.

-- name: Visit log (patient, doctor, time, medicine)
-- Inner joins for Patient and Doctor: an appointment cannot exist without either.
-- Left joins for Prescription and Medicine: visits without a drug must still appear.
SELECT p.PatientName,
       d.DoctorName,
       a.AppointmentDateTime,
       COALESCE(m.MedicineName, '(none)') AS MedicineName
FROM        Appointment  a
JOIN        Patient      p  ON a.PatientID     = p.PatientID
JOIN        Doctor       d  ON a.DoctorID      = d.DoctorID
LEFT JOIN   Prescription pr ON a.AppointmentID = pr.AppointmentID
LEFT JOIN   Medicine     m  ON pr.MedicineID   = m.MedicineID
ORDER BY    a.AppointmentDateTime;

-- name: Pending cases worklist
-- Visits still waiting for a diagnosis, oldest first.
SELECT a.AppointmentID,
       p.PatientName,
       d.DoctorName,
       a.AppointmentDateTime,
       CAST(julianday('2026-10-27') - julianday(a.AppointmentDateTime) AS INTEGER) AS DaysOpen
FROM   Appointment a
JOIN   Patient p ON a.PatientID = p.PatientID
JOIN   Doctor  d ON a.DoctorID  = d.DoctorID
WHERE  a.DiagnosisID IS NULL
ORDER BY a.AppointmentDateTime;

-- name: Doctor workload and documentation rate
SELECT d.DoctorName,
       d.Specialty,
       COUNT(a.AppointmentID)                                          AS Visits,
       SUM(a.DiagnosisID IS NOT NULL)                                  AS Diagnosed,
       CAST(ROUND(100.0 * SUM(a.DiagnosisID IS NOT NULL) / COUNT(a.AppointmentID)) AS INTEGER) AS DiagnosedPct,
       COUNT(pr.PrescriptionID)                                        AS Prescriptions
FROM   Doctor d
LEFT JOIN Appointment  a  ON a.DoctorID      = d.DoctorID
LEFT JOIN Prescription pr ON pr.AppointmentID = a.AppointmentID
GROUP BY d.DoctorID
ORDER BY Visits DESC, d.DoctorName;

-- name: Most common diagnoses
SELECT dx.DiagnosisName,
       dx.DiagnosisCode,
       dx.Category,
       COUNT(a.AppointmentID) AS Visits
FROM   Diagnosis dx
LEFT JOIN Appointment a ON a.DiagnosisID = dx.DiagnosisID
GROUP BY dx.DiagnosisID
ORDER BY Visits DESC, dx.DiagnosisName;

-- name: Medicines by prescription count, including never prescribed
SELECT m.MedicineName,
       m.Form,
       m.StandardDosage,
       COUNT(pr.PrescriptionID) AS TimesPrescribed
FROM   Medicine m
LEFT JOIN Prescription pr ON pr.MedicineID = m.MedicineID
GROUP BY m.MedicineID
ORDER BY TimesPrescribed DESC, m.MedicineName;

-- name: Returning patients
SELECT p.PatientName,
       COUNT(*)                              AS Visits,
       MIN(date(a.AppointmentDateTime))      AS FirstVisit,
       MAX(date(a.AppointmentDateTime))      AS LastVisit,
       COUNT(DISTINCT a.DoctorID)            AS DoctorsSeen
FROM   Appointment a
JOIN   Patient p ON a.PatientID = p.PatientID
GROUP BY p.PatientID
HAVING COUNT(*) > 1
ORDER BY Visits DESC, p.PatientName;

-- name: Registered patients with no visit yet
SELECT p.PatientID, p.PatientName, p.PatientPhone
FROM   Patient p
LEFT JOIN Appointment a ON a.PatientID = p.PatientID
WHERE  a.AppointmentID IS NULL;
