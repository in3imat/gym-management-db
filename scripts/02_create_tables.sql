-- ============================================================
-- SECTION 2 — TABLE DEFINITIONS
-- ============================================================
-- ERD OVERVIEW (Text Form)
--
--  Trainers        ──< Sessions        (one trainer delivers many sessions)
--  Members         ──< Bookings        (one member makes many bookings)
--  Sessions        ──< Bookings        (one session has many bookings)
--  MembershipPlans ──< Memberships     (one plan is used by many memberships)
--  Members         ──< Memberships     (one member can have many memberships over time)
--  Members         ──< Payments        (one member makes many payments)
--  Memberships     ──< Payments        (one membership can have many payments)
-- ============================================================


-- ── 2.1 Trainers ─────────────────────────────────────────────
-- Stores trainer profiles and their area of specialization.

CREATE TABLE Trainers (
    TrainerID       INT             IDENTITY(1,1)   PRIMARY KEY,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Specialization  NVARCHAR(100)   NOT NULL,
    Phone           VARCHAR(20)     NOT NULL UNIQUE,
    Email           VARCHAR(100)    NOT NULL UNIQUE,
    HireDate        DATE            NOT NULL DEFAULT GETDATE(),
    IsActive        BIT             NOT NULL DEFAULT 1   -- 1 = Active, 0 = Inactive
);



-- ── 2.2 MembershipPlans ──────────────────────────────────────
-- Defines the plans the gym offers (e.g. Monthly, Quarterly, Annual).

CREATE TABLE MembershipPlans (
    PlanID          INT             IDENTITY(1,1)   PRIMARY KEY,
    PlanName        NVARCHAR(100)   NOT NULL UNIQUE,
    DurationMonths  INT             NOT NULL CHECK (DurationMonths > 0),
    Price           DECIMAL(10,2)   NOT NULL CHECK (Price > 0),
    Description     NVARCHAR(255)   NULL
);



-- ── 2.3 Members ──────────────────────────────────────────────
-- Core member information.

CREATE TABLE Members (
    MemberID        INT             IDENTITY(1,1)   PRIMARY KEY,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Gender          CHAR(1)         NOT NULL CHECK (Gender IN ('M', 'F')),
    DateOfBirth     DATE            NOT NULL,
    Phone           VARCHAR(20)     NOT NULL UNIQUE,
    Email           VARCHAR(100)    NOT NULL UNIQUE,
    JoinDate        DATE            NOT NULL DEFAULT GETDATE(),
    IsActive        BIT             NOT NULL DEFAULT 1
);



-- ── 2.4 Memberships ──────────────────────────────────────────
-- Links a member to a plan and records the active period.

CREATE TABLE Memberships (
    MembershipID    INT             IDENTITY(1,1)   PRIMARY KEY,
    MemberID        INT             NOT NULL,
    PlanID          INT             NOT NULL,
    StartDate       DATE            NOT NULL,
    EndDate         DATE            NOT NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Active'
                        CHECK (Status IN ('Active', 'Expired', 'Suspended')),
    CONSTRAINT FK_Memberships_Member    FOREIGN KEY (MemberID)  REFERENCES Members(MemberID),
    CONSTRAINT FK_Memberships_Plan      FOREIGN KEY (PlanID)    REFERENCES MembershipPlans(PlanID),
    CONSTRAINT CK_Memberships_Dates     CHECK (EndDate > StartDate)
);



-- ── 2.5 Sessions ─────────────────────────────────────────────
-- Classes/training sessions that members can book.

CREATE TABLE Sessions (
    SessionID       INT             IDENTITY(1,1)   PRIMARY KEY,
    SessionName     NVARCHAR(100)   NOT NULL,
    TrainerID       INT             NOT NULL,
    SessionDate     DATE            NOT NULL,
    StartTime       TIME            NOT NULL,
    EndTime         TIME            NOT NULL,
    Room            NVARCHAR(50)    NOT NULL,
    MaxCapacity     INT             NOT NULL CHECK (MaxCapacity > 0),
    CurrentBookings INT             NOT NULL DEFAULT 0,
    CONSTRAINT FK_Sessions_Trainer      FOREIGN KEY (TrainerID) REFERENCES Trainers(TrainerID),
    CONSTRAINT CK_Sessions_Time         CHECK (EndTime > StartTime),
    CONSTRAINT CK_Sessions_Bookings     CHECK (CurrentBookings >= 0)
);



-- ── 2.6 Bookings ─────────────────────────────────────────────
-- Records which member booked which session.

CREATE TABLE Bookings (
    BookingID       INT             IDENTITY(1,1)   PRIMARY KEY,
    MemberID        INT             NOT NULL,
    SessionID       INT             NOT NULL,
    BookingDate     DATETIME        NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Confirmed'
                        CHECK (Status IN ('Confirmed', 'Cancelled', 'Attended')),
    CONSTRAINT FK_Bookings_Member       FOREIGN KEY (MemberID)  REFERENCES Members(MemberID),
    CONSTRAINT FK_Bookings_Session      FOREIGN KEY (SessionID) REFERENCES Sessions(SessionID),
    CONSTRAINT UQ_Bookings_MemberSession UNIQUE (MemberID, SessionID)  -- no duplicate bookings
);



-- ── 2.7 Payments ─────────────────────────────────────────────
-- Tracks all financial transactions from members.

CREATE TABLE Payments (
    PaymentID       INT             IDENTITY(1,1)   PRIMARY KEY,
    MemberID        INT             NOT NULL,
    MembershipID    INT             NOT NULL,
    Amount          DECIMAL(10,2)   NOT NULL CHECK (Amount > 0),
    PaymentDate     DATETIME        NOT NULL DEFAULT GETDATE(),
    PaymentMethod   NVARCHAR(50)    NOT NULL
                        CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Bank Transfer', 'Online')),
    Notes           NVARCHAR(255)   NULL,
    CONSTRAINT FK_Payments_Member       FOREIGN KEY (MemberID)      REFERENCES Members(MemberID),
    CONSTRAINT FK_Payments_Membership   FOREIGN KEY (MembershipID)  REFERENCES Memberships(MembershipID)
);



-- ── 2.8 AuditLog ─────────────────────────────────────────────
-- Automatically logs important system events (used by triggers).

CREATE TABLE AuditLog (
    LogID           INT             IDENTITY(1,1)   PRIMARY KEY,
    EventType       NVARCHAR(100)   NOT NULL,
    TableName       NVARCHAR(100)   NOT NULL,
    RecordID        INT             NULL,
    Description     NVARCHAR(500)   NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
