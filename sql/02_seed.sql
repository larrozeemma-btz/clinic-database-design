-- Seed data
--
-- Section 1 normalizes the four rows of the clinic's original paper record.
-- Section 2 adds illustrative sample records (fictional people and visits) so the
-- queries in 03_queries.sql have enough data to be meaningful.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Section 1: the original paper record, normalized
-- ---------------------------------------------------------------------------
-- The paper record listed Maya Chen with two phone numbers (555-0101 on A501,
-- 555-0199 on A548): an update anomaly. We keep the number from her most recent
-- visit as current, and it is now stored exactly once.

INSERT INTO Doctor VALUES
  ('D07', 'Dr. Ortiz', 'General Practice', '2107'),
  ('D12', 'Dr. Singh', 'Family Medicine',  '2112');

INSERT INTO Patient VALUES
  ('P101', 'Maya Chen', '555-0199', NULL),
  ('P204', 'Omar Ali',  '555-0144', NULL),
  ('P330', 'Lina Park', '555-0170', NULL);

INSERT INTO Diagnosis VALUES
  ('DX01', 'Migraine',          'G43.909', 'Neurological'),
  ('DX02', 'Allergic rhinitis', 'J30.9',   'Allergy and immunology');

INSERT INTO Medicine VALUES
  ('M01', 'Sumatriptan', 'Tablet', '50 mg'),
  ('M02', 'Cetirizine',  'Tablet', '10 mg');

INSERT INTO Appointment VALUES
  ('A501', 'P101', 'D07', '2026-09-03 09:00:00', 'DX01'),
  ('A548', 'P101', 'D12', '2026-09-21 14:00:00', 'DX02'),
  ('A566', 'P204', 'D07', '2026-09-24 11:00:00', 'DX01'),
  ('A590', 'P330', 'D12', '2026-10-02 13:30:00', NULL);   -- diagnosis pending

INSERT INTO Prescription VALUES
  ('RX1001', 'A501', 'M01', '2026-09-03'),
  ('RX1002', 'A548', 'M02', '2026-09-21'),
  ('RX1003', 'A566', 'M01', '2026-09-24');

-- ---------------------------------------------------------------------------
-- Section 2: illustrative sample records (fictional)
-- ---------------------------------------------------------------------------

INSERT INTO Doctor VALUES
  ('D15', 'Dr. Moreau', 'Sports Medicine', '2115'),
  ('D21', 'Dr. Okafor', 'Dermatology',     '2121');

INSERT INTO Patient VALUES
  ('P412', 'Daniel Reyes', '555-0182', '2003-04-17'),
  ('P415', 'Sofia Rossi',  '555-0127', '2002-11-02'),
  ('P431', 'Aiden Brooks', '555-0163', '2004-06-29'),
  ('P458', 'Priya Nair',   '555-0118', '2001-01-15'),
  ('P503', 'Lucas Martin', '555-0195', '2005-08-08'),
  ('P517', 'Hana Sato',    '555-0136', '2003-12-21'),
  -- Registered at orientation, no visit yet: possible only because Patient is its own table.
  ('P529', 'Noah Kim',     '555-0152', '2006-03-05');

INSERT INTO Diagnosis VALUES
  ('DX03', 'Ankle sprain',       'S93.409A', 'Musculoskeletal'),
  ('DX04', 'Acute bronchitis',   'J20.9',    'Respiratory'),
  ('DX05', 'Contact dermatitis', 'L25.9',    'Dermatological'),
  ('DX06', 'Tension headache',   'G44.209',  'Neurological');

INSERT INTO Medicine VALUES
  ('M03', 'Naproxen',       'Tablet',  '250 mg'),
  ('M04', 'Hydrocortisone', 'Cream',   '1%'),
  ('M05', 'Benzonatate',    'Capsule', '100 mg'),
  ('M06', 'Ibuprofen',      'Tablet',  '400 mg'),
  -- In the formulary, never prescribed yet: possible only because Medicine is its own table.
  ('M07', 'Loratadine',     'Tablet',  '10 mg');

INSERT INTO Appointment VALUES
  ('A602', 'P412', 'D15', '2026-10-05 10:00:00', 'DX03'),
  ('A605', 'P415', 'D21', '2026-10-05 15:30:00', 'DX05'),
  ('A611', 'P431', 'D07', '2026-10-06 09:30:00', 'DX06'),
  ('A614', 'P458', 'D12', '2026-10-07 11:00:00', 'DX04'),
  ('A618', 'P101', 'D07', '2026-10-08 16:00:00', 'DX01'),
  ('A623', 'P503', 'D15', '2026-10-09 08:30:00', 'DX03'),
  ('A627', 'P517', 'D12', '2026-10-12 13:00:00', 'DX02'),
  ('A630', 'P204', 'D07', '2026-10-13 10:30:00', 'DX06'),
  ('A634', 'P412', 'D15', '2026-10-19 10:00:00', NULL),    -- follow-up, pending
  ('A638', 'P415', 'D21', '2026-10-20 14:00:00', 'DX05'),
  ('A641', 'P458', 'D12', '2026-10-21 09:00:00', 'DX04'),
  ('A645', 'P431', 'D07', '2026-10-22 15:00:00', 'DX01'),
  ('A649', 'P503', 'D15', '2026-10-23 08:30:00', NULL),    -- pending
  ('A652', 'P517', 'D21', '2026-10-26 11:30:00', 'DX05');

INSERT INTO Prescription VALUES
  ('RX1004', 'A602', 'M03', '2026-10-05'),
  ('RX1005', 'A605', 'M04', '2026-10-05'),
  ('RX1006', 'A611', 'M06', '2026-10-06'),
  ('RX1007', 'A614', 'M05', '2026-10-07'),
  ('RX1008', 'A618', 'M01', '2026-10-08'),
  ('RX1009', 'A623', 'M03', '2026-10-09'),
  ('RX1010', 'A627', 'M02', '2026-10-12'),
  ('RX1011', 'A630', 'M06', '2026-10-13'),
  ('RX1012', 'A638', 'M04', '2026-10-20'),
  ('RX1013', 'A645', 'M01', '2026-10-22'),
  ('RX1014', 'A652', 'M04', '2026-10-26');
  -- A641 (bronchitis follow-up) ends with a diagnosis and no prescription.
