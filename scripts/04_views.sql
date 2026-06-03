-- ============================================================
-- SECTION 4 — VIEWS
-- ============================================================


-- ── View 1: Active Members ────────────────────────────────────
-- Purpose : Shows all members who currently have an active membership.
--           Useful for front-desk staff to quickly verify member access rights.

CREATE OR ALTER VIEW vw_ActiveMembers AS
SELECT
    m.MemberID,
    m.FirstName + ' ' + m.LastName        AS FullName,
    m.Phone,
    m.Email,
    mp.PlanName,
    ms.StartDate,
    ms.EndDate,
    DATEDIFF(DAY, GETDATE(), ms.EndDate)   AS DaysRemaining
FROM Members m
JOIN Memberships ms ON m.MemberID = ms.MemberID
JOIN MembershipPlans mp ON ms.PlanID = mp.PlanID
WHERE ms.Status = 'Active'
  AND ms.EndDate >= CAST(GETDATE() AS DATE);



-- ── View 2: Revenue Summary by Plan ──────────────────────────
-- Purpose : Shows total revenue collected per membership plan.
--           Useful for monthly financial reporting and plan performance analysis.

CREATE OR ALTER VIEW vw_RevenueSummary AS
SELECT
    mp.PlanName,
    mp.Price                               AS PlanPrice,
    COUNT(p.PaymentID)                     AS TotalTransactions,
    SUM(p.Amount)                          AS TotalRevenue,
    AVG(p.Amount)                          AS AvgPayment
FROM Payments p
JOIN Memberships ms ON p.MembershipID = ms.MembershipID
JOIN MembershipPlans mp ON ms.PlanID = mp.PlanID
GROUP BY mp.PlanName, mp.Price;



-- ── View 3: Trainer Schedule ──────────────────────────────────
-- Purpose : Displays each trainer's upcoming sessions with booking stats.
--           Useful for trainer management and identifying underbooked sessions.

CREATE OR ALTER VIEW vw_TrainerSchedule AS
SELECT
    t.TrainerID,
    t.FirstName + ' ' + t.LastName         AS TrainerName,
    t.Specialization,
    s.SessionName,
    s.SessionDate,
    s.StartTime,
    s.EndTime,
    s.Room,
    s.MaxCapacity,
    s.CurrentBookings,
    s.MaxCapacity - s.CurrentBookings       AS AvailableSpots
FROM Trainers t
JOIN Sessions s ON t.TrainerID = s.TrainerID
WHERE s.SessionDate >= CAST(GETDATE() AS DATE);



-- ── View 4: Session Booking Overview ─────────────────────────
-- Purpose : Full overview of all bookings, linking member and session details.
--           Useful for attendance tracking and session popularity reports.

CREATE OR ALTER VIEW vw_BookingOverview AS
SELECT
    b.BookingID,
    m.FirstName + ' ' + m.LastName          AS MemberName,
    m.Phone                                  AS MemberPhone,
    s.SessionName,
    t.FirstName + ' ' + t.LastName          AS TrainerName,
    s.SessionDate,
    s.StartTime,
    s.Room,
    b.Status                                 AS BookingStatus,
    b.BookingDate
FROM Bookings b
JOIN Members m   ON b.MemberID  = m.MemberID
JOIN Sessions s  ON b.SessionID = s.SessionID
JOIN Trainers t  ON s.TrainerID = t.TrainerID;