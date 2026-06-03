# 🏋️ Gym Management System — SQL Server Database Project

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-blue)
![Status](https://img.shields.io/badge/Status-Complete-success)
![License](https://img.shields.io/badge/License-MIT-green)

A fully implemented relational database system for managing a gym's
operations — built entirely with SQL Server and T-SQL.

---

## 📌 About the Project

This project simulates a real-world gym management system covering
member registration, membership plans, trainer scheduling, session
bookings, and payment tracking. It is designed to demonstrate
database design, normalization, and advanced SQL development skills.

---

## 🛠️ Technologies Used

- Microsoft SQL Server (SSMS)
- T-SQL (Transact-SQL)
- ERD Design (draw.io)

---

## ✅ Features

| Feature | Details |
|---|---|
| Tables | 8 tables with PK, FK, constraints |
| Views | 4 analytical views |
| Stored Procedures | 5 procedures with validation logic |
| Triggers | 4 triggers (overbooking, auto-expire, audit) |
| Sample Data | 10 realistic records per table |

---

## 🗂️ Database Structure

**Tables:** `Trainers` · `Members` · `MembershipPlans` ·
`Memberships` · `Sessions` · `Bookings` · `Payments` · `AuditLog`

**ERD Diagram:**



---

## 🚀 How to Run

1. Open **SQL Server Management Studio (SSMS)**
2. Run scripts in this order:

```sql
-- Run each file in the scripts/ folder in order:
01_create_database.sql
02_create_tables.sql
03_sample_data.sql
04_views.sql
05_stored_procedures.sql
06_triggers.sql
```

3. Test with the quick-test queries at the bottom of each file.

-- -- View all active members
SELECT * FROM vw_ActiveMembers;

-- View revenue summary
SELECT * FROM vw_RevenueSummary;

-- View trainer schedule
SELECT * FROM vw_TrainerSchedule;

-- View all bookings
SELECT * FROM vw_BookingOverview;

-- View audit log
SELECT * FROM AuditLog ORDER BY CreatedAt DESC;

-- Test: Add a new member
EXEC sp_AddMember
    @FirstName   = 'Layla',
    @LastName    = 'Khalidi',
    @Gender      = 'F',
    @DateOfBirth = '2000-09-14',
    @Phone       = '0790000099',
    @Email       = 'layla.k@email.com';

-- Test: Register a membership for the new member (MemberID = 11)
EXEC sp_RegisterMembership
    @MemberID  = 11,
    @PlanID    = 2,
    @StartDate = '2024-05-01';

-- Test: Book a session for the new member
EXEC sp_BookSession
    @MemberID  = 11,
    @SessionID = 8;

-- Test: Record a payment
EXEC sp_RecordPayment
    @MemberID      = 11,
    @MembershipID  = 11,
    @Amount        = 55.00,
    @PaymentMethod = 'Cash',
    @Notes         = 'Monthly Premium — May 2024';


## 📁 Project Structure

```
gym-management-db/
├── scripts/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_sample_data.sql
│   ├── 04_views.sql
│   ├── 05_stored_procedures.sql
│   └── 06_triggers.sql
├── docs/
│   └── ERD.png
└── README.md
```

---

## 👤 Author

**Ahmad Alnaimat** — Database Developer
[LinkedIn](https://linkedin.com/in/in3imat) ·


---

## 📄 License

This project is licensed under the MIT License.# gym-management-db
