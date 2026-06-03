-- ============================================================
-- SECTION 3 — SAMPLE DATA
-- ============================================================


-- ── 3.1 Trainers ─────────────────────────────────────────────
INSERT INTO Trainers (FirstName, LastName, Specialization, Phone, Email, HireDate)
VALUES
    ('Khalid',  'Al-Rashid',  'Bodybuilding & Strength',  '0791100001', 'khalid.rashid@gym.com',   '2021-03-15'),
    ('Sara',    'Haddad',     'Yoga & Flexibility',        '0791100002', 'sara.haddad@gym.com',     '2020-07-01'),
    ('Omar',    'Mansour',    'Cardio & HIIT',             '0791100003', 'omar.mansour@gym.com',    '2022-01-10'),
    ('Lina',    'Barakat',    'Pilates & Core Training',   '0791100004', 'lina.barakat@gym.com',    '2019-11-20'),
    ('Faris',   'Zreiqat',    'Boxing & MMA',              '0791100005', 'faris.zreiqat@gym.com',   '2023-04-05'),
    ('Nadia',   'Samara',     'Zumba & Dance Fitness',     '0791100006', 'nadia.samara@gym.com',    '2021-09-18');



-- ── 3.2 MembershipPlans ──────────────────────────────────────
INSERT INTO MembershipPlans (PlanName, DurationMonths, Price, Description)
VALUES
    ('Monthly Basic',       1,   30.00, 'Access to gym floor and basic equipment'),
    ('Monthly Premium',     1,   55.00, 'Full access including classes and sauna'),
    ('Quarterly Basic',     3,   80.00, '3-month basic access — save 11%'),
    ('Quarterly Premium',   3,  145.00, '3-month premium access — save 12%'),
    ('Annual Basic',       12,  280.00, 'Annual basic access — best value'),
    ('Annual Premium',     12,  500.00, 'Annual unlimited access — all features');



-- ── 3.3 Members ──────────────────────────────────────────────
INSERT INTO Members (FirstName, LastName, Gender, DateOfBirth, Phone, Email, JoinDate)
VALUES
    ('Ahmad',   'Alnaimat',   'M', '2002-12-03', '0790000001', 'ahmad@email.com',   '2024-01-10'),
    ('Rana',    'Khalil',     'F', '1995-08-23', '0790000002', 'rana@email.com',    '2024-02-01'),
    ('Tariq',   'Obeidat',    'M', '2000-03-17', '0790000003', 'tariq@email.com',   '2024-02-15'),
    ('Hana',    'Nasser',     'F', '1993-11-30', '0790000004', 'hana@email.com',    '2024-01-20'),
    ('Yousef',  'Smadi',      'M', '1990-07-04', '0790000005', 'yousef@email.com',  '2023-12-01'),
    ('Dima',    'Houri',      'F', '1997-01-15', '0790000006', 'dima@email.com',    '2024-03-05'),
    ('Samir',   'Qasim',      'M', '1985-09-09', '0790000007', 'samir@email.com',   '2023-10-10'),
    ('Nour',    'Faouri',     'F', '2001-04-22', '0790000008', 'nour@email.com',    '2024-03-20'),
    ('Bilal',   'Araydah',    'M', '1996-12-08', '0790000009', 'bilal@email.com',   '2024-04-01'),
    ('Maya',    'Hamdan',     'F', '1999-06-18', '0790000010', 'maya@email.com',    '2024-04-10');



-- ── 3.4 Memberships ──────────────────────────────────────────
INSERT INTO Memberships (MemberID, PlanID, StartDate, EndDate, Status)
VALUES
    (1,  6, '2024-01-10', '2025-01-10', 'Active'),
    (2,  2, '2024-02-01', '2024-03-01', 'Expired'),
    (3,  3, '2024-02-15', '2024-05-15', 'Active'),
    (4,  5, '2024-01-20', '2025-01-20', 'Active'),
    (5,  1, '2023-12-01', '2023-12-31', 'Expired'),
    (6,  4, '2024-03-05', '2024-06-05', 'Active'),
    (7,  6, '2023-10-10', '2024-10-10', 'Active'),
    (8,  2, '2024-03-20', '2024-04-20', 'Active'),
    (9,  3, '2024-04-01', '2024-07-01', 'Active'),
    (10, 1, '2024-04-10', '2024-05-10', 'Active');



-- ── 3.5 Sessions ─────────────────────────────────────────────
INSERT INTO Sessions (SessionName, TrainerID, SessionDate, StartTime, EndTime, Room, MaxCapacity, CurrentBookings)
VALUES
    ('Morning Strength',      1, '2024-05-01', '07:00', '08:00', 'Weights Room',    15, 3),
    ('Yoga Flow',             2, '2024-05-01', '09:00', '10:00', 'Studio A',        12, 5),
    ('HIIT Blast',            3, '2024-05-02', '18:00', '19:00', 'Cardio Zone',     20, 8),
    ('Core & Pilates',        4, '2024-05-02', '10:00', '11:00', 'Studio B',        10, 2),
    ('Boxing Fundamentals',   5, '2024-05-03', '17:00', '18:30', 'Boxing Room',     8,  4),
    ('Zumba Night',           6, '2024-05-03', '19:00', '20:00', 'Studio A',        25, 12),
    ('Advanced Bodybuilding', 1, '2024-05-04', '08:00', '09:30', 'Weights Room',    10, 1),
    ('Stretch & Recover',     2, '2024-05-04', '11:00', '12:00', 'Studio B',        15, 0),
    ('Fat Burn Cardio',       3, '2024-05-05', '07:30', '08:30', 'Cardio Zone',     20, 6),
    ('MMA Basics',            5, '2024-05-05', '16:00', '17:30', 'Boxing Room',     8,  7);



-- ── 3.6 Bookings ─────────────────────────────────────────────
INSERT INTO Bookings (MemberID, SessionID, Status)
VALUES
    (1, 1,  'Confirmed'),
    (1, 3,  'Confirmed'),
    (2, 2,  'Attended'),
    (3, 3,  'Confirmed'),
    (4, 6,  'Confirmed'),
    (5, 9,  'Attended'),
    (6, 4,  'Confirmed'),
    (7, 5,  'Confirmed'),
    (8, 6,  'Confirmed'),
    (9, 7,  'Confirmed'),
    (10,2,  'Confirmed'),
    (3, 9,  'Confirmed'),
    (4, 1,  'Confirmed'),
    (6, 10, 'Confirmed');



-- ── 3.7 Payments ─────────────────────────────────────────────
INSERT INTO Payments (MemberID, MembershipID, Amount, PaymentDate, PaymentMethod, Notes)
VALUES
    (1,  1,  500.00, '2024-01-10', 'Credit Card',   'Annual Premium — full payment'),
    (2,  2,   55.00, '2024-02-01', 'Cash',          'Monthly Premium'),
    (3,  3,   80.00, '2024-02-15', 'Online',        'Quarterly Basic'),
    (4,  4,  280.00, '2024-01-20', 'Bank Transfer', 'Annual Basic'),
    (5,  5,   30.00, '2023-12-01', 'Cash',          'Monthly Basic'),
    (6,  6,  145.00, '2024-03-05', 'Credit Card',   'Quarterly Premium'),
    (7,  7,  500.00, '2023-10-10', 'Bank Transfer', 'Annual Premium'),
    (8,  8,   55.00, '2024-03-20', 'Cash',          'Monthly Premium'),
    (9,  9,   80.00, '2024-04-01', 'Online',        'Quarterly Basic'),
    (10,10,   30.00, '2024-04-10', 'Cash',          'Monthly Basic');
