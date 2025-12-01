# Database-Course-Project
Pavlenko Course Project
Project overview

The project models a small Gym and Membership Management System.
The database includes the following main tables:

- Members
- Trainers
- MembershipTypes
- MemberMemberships
- TrainingSessions
- MemberSessions (junction table for a many-to-many relationship between Members and TrainingSessions)
- MemberLog

Requirments:

Primary and foreign keys, including a many-to-many relationship via MemberSessions
Several indexes, including unique and non-unique indexes
Data manipulation examples such as INSERT, UPDATE, DELETE and TRUNCATE
SELECT queries using COUNT, SUM, AVG, GROUP BY, ORDER BY and pagination with OFFSET and FETCH
JOIN examples including INNER JOIN, LEFT JOIN and multi-table joins
One view joining three tables: View_MemberSessions
One stored procedure: AddMember
One scalar function: CountSessions
One trigger: trg_MemberAdded, which logs added members
One transaction example using BEGIN TRANSACTION and COMMIT

How to run

Open the SQL script in SQL Server Management Studio.
Execute the script from the beginning.
The script creates the database, tables, inserts sample data and demonstrates the required queries, view, stored procedure, function, trigger and transaction.

