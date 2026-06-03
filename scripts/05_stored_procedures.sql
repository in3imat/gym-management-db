-- ============================================================
-- SECTION 5 — STORED PROCEDURES
-- ============================================================


-- ── SP 1: Add New Member ──────────────────────────────────────
-- Purpose : Safely inserts a new member after validating email and phone uniqueness.
--           Returns the new MemberID on success.

CREATE OR ALTER PROCEDURE sp_AddMember
    @FirstName      NVARCHAR(50),
    @LastName       NVARCHAR(50),
    @Gender         CHAR(1),
    @DateOfBirth    DATE,
    @Phone          VARCHAR(20),
    @Email          VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate: email must be unique
    IF EXISTS (SELECT 1 FROM Members WHERE Email = @Email)
    BEGIN
        RAISERROR('A member with this email already exists.', 16, 1);
        RETURN;
    END

    -- Validate: phone must be unique
    IF EXISTS (SELECT 1 FROM Members WHERE Phone = @Phone)
    BEGIN
        RAISERROR('A member with this phone number already exists.', 16, 1);
        RETURN;
    END

    -- Validate: age must be at least 15
    IF DATEDIFF(YEAR, @DateOfBirth, GETDATE()) < 15
    BEGIN
        RAISERROR('Member must be at least 15 years old.', 16, 1);
        RETURN;
    END

    INSERT INTO Members (FirstName, LastName, Gender, DateOfBirth, Phone, Email)
    VALUES (@FirstName, @LastName, @Gender, @DateOfBirth, @Phone, @Email);

    DECLARE @NewID INT = SCOPE_IDENTITY();
    PRINT 'Member added successfully. MemberID = ' + CAST(@NewID AS VARCHAR);
    SELECT @NewID AS NewMemberID;
END;



-- ── SP 2: Register Membership ─────────────────────────────────
-- Purpose : Assigns a membership plan to a member.
--           Validates that no active membership already exists for that member.
--           Automatically calculates EndDate from plan duration.

CREATE OR ALTER PROCEDURE sp_RegisterMembership
    @MemberID   INT,
    @PlanID     INT,
    @StartDate  DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate: member must exist
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID = @MemberID)
    BEGIN
        RAISERROR('Member not found.', 16, 1);
        RETURN;
    END

    -- Validate: plan must exist
    IF NOT EXISTS (SELECT 1 FROM MembershipPlans WHERE PlanID = @PlanID)
    BEGIN
        RAISERROR('Membership plan not found.', 16, 1);
        RETURN;
    END

    -- Validate: member should not already have an active membership
    IF EXISTS (
        SELECT 1 FROM Memberships
        WHERE MemberID = @MemberID
          AND Status = 'Active'
          AND EndDate >= CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR('Member already has an active membership.', 16, 1);
        RETURN;
    END

    -- Calculate end date from plan duration
    DECLARE @DurationMonths INT;
    SELECT @DurationMonths = DurationMonths FROM MembershipPlans WHERE PlanID = @PlanID;

    DECLARE @EndDate DATE = DATEADD(MONTH, @DurationMonths, @StartDate);

    INSERT INTO Memberships (MemberID, PlanID, StartDate, EndDate, Status)
    VALUES (@MemberID, @PlanID, @StartDate, @EndDate, 'Active');

    DECLARE @NewMembershipID INT = SCOPE_IDENTITY();
    PRINT 'Membership registered. MembershipID = ' + CAST(@NewMembershipID AS VARCHAR)
        + ' | EndDate = ' + CAST(@EndDate AS VARCHAR);
    SELECT @NewMembershipID AS NewMembershipID, @EndDate AS EndDate;
END;



-- ── SP 3: Book a Session ──────────────────────────────────────
-- Purpose : Books a session for a member.
--           Validates: member existence, session availability, no duplicate booking,
--           and that the member holds an active membership.

CREATE OR ALTER PROCEDURE sp_BookSession
    @MemberID   INT,
    @SessionID  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate: member must exist and be active
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID = @MemberID AND IsActive = 1)
    BEGIN
        RAISERROR('Active member not found.', 16, 1);
        RETURN;
    END

    -- Validate: member must have an active membership
    IF NOT EXISTS (
        SELECT 1 FROM Memberships
        WHERE MemberID = @MemberID
          AND Status = 'Active'
          AND EndDate >= CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR('Member does not have an active membership. Please renew before booking.', 16, 1);
        RETURN;
    END

    -- Validate: session must exist
    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE SessionID = @SessionID)
    BEGIN
        RAISERROR('Session not found.', 16, 1);
        RETURN;
    END

    -- Validate: no duplicate booking
    IF EXISTS (SELECT 1 FROM Bookings WHERE MemberID = @MemberID AND SessionID = @SessionID)
    BEGIN
        RAISERROR('Member has already booked this session.', 16, 1);
        RETURN;
    END

    -- Validate: session must not be full (also enforced by trigger, double-checked here)
    DECLARE @Max INT, @Current INT;
    SELECT @Max = MaxCapacity, @Current = CurrentBookings
    FROM Sessions WHERE SessionID = @SessionID;

    IF @Current >= @Max
    BEGIN
        RAISERROR('Session is fully booked. No available spots.', 16, 1);
        RETURN;
    END

    -- Insert booking
    INSERT INTO Bookings (MemberID, SessionID, Status)
    VALUES (@MemberID, @SessionID, 'Confirmed');

    -- Update session booking count
    UPDATE Sessions
    SET CurrentBookings = CurrentBookings + 1
    WHERE SessionID = @SessionID;

    PRINT 'Booking confirmed for MemberID = ' + CAST(@MemberID AS VARCHAR)
        + ' | SessionID = ' + CAST(@SessionID AS VARCHAR);
END;



-- ── SP 4: Record Payment ──────────────────────────────────────
-- Purpose : Records a payment for a membership.
--           Validates that the membership belongs to the member and that the amount is positive.

CREATE OR ALTER PROCEDURE sp_RecordPayment
    @MemberID       INT,
    @MembershipID   INT,
    @Amount         DECIMAL(10,2),
    @PaymentMethod  NVARCHAR(50),
    @Notes          NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate: member must exist
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID = @MemberID)
    BEGIN
        RAISERROR('Member not found.', 16, 1);
        RETURN;
    END

    -- Validate: membership must belong to this member
    IF NOT EXISTS (
        SELECT 1 FROM Memberships
        WHERE MembershipID = @MembershipID AND MemberID = @MemberID
    )
    BEGIN
        RAISERROR('Membership does not belong to this member.', 16, 1);
        RETURN;
    END

    -- Validate: amount must be positive
    IF @Amount <= 0
    BEGIN
        RAISERROR('Payment amount must be greater than zero.', 16, 1);
        RETURN;
    END

    -- Validate: payment method
    IF @PaymentMethod NOT IN ('Cash', 'Credit Card', 'Bank Transfer', 'Online')
    BEGIN
        RAISERROR('Invalid payment method. Use: Cash, Credit Card, Bank Transfer, or Online.', 16, 1);
        RETURN;
    END

    INSERT INTO Payments (MemberID, MembershipID, Amount, PaymentMethod, Notes)
    VALUES (@MemberID, @MembershipID, @Amount, @PaymentMethod, @Notes);

    DECLARE @NewPaymentID INT = SCOPE_IDENTITY();
    PRINT 'Payment recorded. PaymentID = ' + CAST(@NewPaymentID AS VARCHAR);
    SELECT @NewPaymentID AS NewPaymentID;
END;



-- ── SP 5: Cancel Booking ──────────────────────────────────────
-- Purpose : Cancels an existing confirmed booking and frees up the spot in the session.

CREATE OR ALTER PROCEDURE sp_CancelBooking
    @BookingID  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate: booking must exist and be in Confirmed status
    DECLARE @SessionID INT, @CurrentStatus NVARCHAR(20);
    SELECT @SessionID = SessionID, @CurrentStatus = Status
    FROM Bookings WHERE BookingID = @BookingID;

    IF @SessionID IS NULL
    BEGIN
        RAISERROR('Booking not found.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus <> 'Confirmed'
    BEGIN
        RAISERROR('Only confirmed bookings can be cancelled.', 16, 1);
        RETURN;
    END

    -- Update booking status
    UPDATE Bookings SET Status = 'Cancelled' WHERE BookingID = @BookingID;

    -- Release the spot in the session
    UPDATE Sessions
    SET CurrentBookings = CurrentBookings - 1
    WHERE SessionID = @SessionID AND CurrentBookings > 0;

    PRINT 'Booking #' + CAST(@BookingID AS VARCHAR) + ' has been cancelled.';
END;