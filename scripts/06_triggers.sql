-- ============================================================
-- SECTION 6 — TRIGGERS
-- ============================================================


-- ── Trigger 1: Prevent Overbooking ────────────────────────────
-- Purpose : Fires INSTEAD OF INSERT on Bookings.
--           Blocks the insert entirely if the session has reached max capacity.
--           This is a safety net in addition to the stored procedure check.

CREATE OR ALTER TRIGGER trg_PreventOverbooking
ON Bookings
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SessionID  INT,
            @MemberID   INT,
            @MaxCap     INT,
            @CurrBook   INT;

    SELECT @SessionID = SessionID, @MemberID = MemberID FROM inserted;

    SELECT @MaxCap = MaxCapacity, @CurrBook = CurrentBookings
    FROM Sessions WHERE SessionID = @SessionID;

    IF @CurrBook >= @MaxCap
    BEGIN
        RAISERROR('TRIGGER: Booking rejected — session "%d" is at full capacity (%d/%d spots).',
                  16, 1, @SessionID, @CurrBook, @MaxCap);
        RETURN;
    END

    -- If space is available, allow the insert
    INSERT INTO Bookings (MemberID, SessionID, BookingDate, Status)
    SELECT MemberID, SessionID, BookingDate, Status FROM inserted;
END;



-- ── Trigger 2: Auto-Expire Memberships on Payment ─────────────
-- Purpose : After any payment is recorded, checks if any memberships
--           have passed their EndDate and marks them as 'Expired' automatically.
--           Ensures membership status stays accurate without manual updates.

CREATE OR ALTER TRIGGER trg_AutoExpireMemberships
ON Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Memberships
    SET Status = 'Expired'
    WHERE Status = 'Active'
      AND EndDate < CAST(GETDATE() AS DATE);

    -- Log how many were updated
    IF @@ROWCOUNT > 0
        INSERT INTO AuditLog (EventType, TableName, RecordID, Description)
        VALUES ('AUTO-EXPIRE', 'Memberships', NULL,
                'Membership auto-expiry check ran. Expired memberships updated to Expired status.');
END;



-- ── Trigger 3: Log Every Payment ──────────────────────────────
-- Purpose : After each payment insert, writes a record to AuditLog.
--           Provides a complete financial audit trail.

CREATE OR ALTER TRIGGER trg_LogPayment
ON Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLog (EventType, TableName, RecordID, Description)
    SELECT
        'PAYMENT',
        'Payments',
        i.PaymentID,
        'Payment of ' + CAST(i.Amount AS VARCHAR) + ' JD received from MemberID '
            + CAST(i.MemberID AS VARCHAR) + ' via ' + i.PaymentMethod
    FROM inserted i;
END;



-- ── Trigger 4: Log Member Registration ────────────────────────
-- Purpose : Fires after a new member is inserted.
--           Records the event in AuditLog for tracking purposes.

CREATE OR ALTER TRIGGER trg_LogNewMember
ON Members
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLog (EventType, TableName, RecordID, Description)
    SELECT
        'NEW MEMBER',
        'Members',
        i.MemberID,
        'New member registered: ' + i.FirstName + ' ' + i.LastName
            + ' | Email: ' + i.Email
    FROM inserted i;
END;