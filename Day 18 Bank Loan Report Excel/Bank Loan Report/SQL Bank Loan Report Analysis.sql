select * from project..financialloandata

-- Total Application
Select count(*) as total_application
from project..financialloandata;


 -- MTD Loan Applications
select count(*) as mtd_loan_application
from project..financialloandata
where month(issue_date) = 12;

-- PMTD Loan Applications
select count(*) as mtd_loan_application
from project..financialloandata
where month(issue_date) = 11;

-- Total Funded Amount

Select sum(loan_amount) as total_loan_amount
From project..financialloandata;

-- MTD Total Funded Amount

Select sum(loan_amount) as MTD_total_loan_amount
From project..financialloandata
Where month(issue_date) = 12;

-- PMTD Total Funded Amount
select sum(loan_amount) as PMTD_total_loan_amount
from project..financialloandata
where month(issue_date) = 11;

-- Total Amount Received
Select sum(total_payment) as total_amount_received
From project..financialloandata;


-- MTD Total Amount Received
Select sum(total_payment) as total_amount_received
From project..financialloandata
Where Month(issue_date) = 12;

-- PMTD Total Amount Received
Select sum(total_payment) as total_amount_received
From project..financialloandata
Where Month(issue_date) = 11;

-- Amount Received By each month
Select Month(issue_date) as [Month],
	sum(total_payment) as Loan_payment_received
From project..financialloandata
Group by Month(issue_date)
Order by Month(issue_date);


-- Average Interest Rate

Select Round(Avg(int_rate)*100,3) as Avg_Interest_Rate
From project..financialloandata;

-- MTD Average Interest
Select Round(Avg(int_rate)*100,3) as Avg_Interest_Rate
From project..financialloandata
Where Month(issue_date)  = 12;

-- Avg DTI
SELECT Round(AVG(dti)*100,3) AS Avg_DTI 
FROM project..financialloandata;
 
-- MTD Avg DTI
SELECT Round(AVG(dti)*100,3) AS MTD_Avg_DTI 
FROM project..financialloandata
WHERE MONTH(issue_date) = 12;
 
-- PMTD Avg DTI
SELECT Round(AVG(dti)*100,3) AS PMTD_Avg_DTI 
FROM project..financialloandata
WHERE MONTH(issue_date) = 11;
 

-- GOOD LOAN ISSUED
-- Good Loan Percentage
SELECT 
    ROUND(
        (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) 
        * 100.0) / COUNT(id),3) AS good_loan_percentage
FROM project..financialloandata;


-- Good Loan Applications
Select count(*) as good_loan_application
From project..financialloandata
Where loan_status = 'Fully Paid' or loan_status = 'Current';

-- Good Loan Fund Amount
Select sum(loan_amount) as good_loan_amount
From project..financialloandata
Where loan_status = 'Fully Paid' or loan_status = 'Current';

-- Good Loan Amount Received

Select sum(total_payment)  as good_loan_amount_received
From project..financialloandata
Where loan_status = 'Fully Paid' or loan_status = 'Current';

-- BAD LOAN ISSUED

-- Bad Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) / 
	COUNT(id) AS Bad_Loan_Percentage
From project..financialloandata
 
-- Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications 
From project..financialloandata
WHERE loan_status = 'Charged Off'
 
-- Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount 
From project..financialloandata
WHERE loan_status = 'Charged Off'
 
-- Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_amount_received 
From project..financialloandata
WHERE loan_status = 'Charged Off'



-- Loan Status

Select loan_status,
	count(loan_status) as total_loan_status,
	sum(loan_amount) as total_loan_amount,
	sum(total_payment) as total_amount_received,
	Round(AVG(int_rate)*100,3) as AVG_interest_rate,
	Round(AVG(dti)*100,3) as AVG_dti
From project..financialloandata
Group by loan_status;


-- MTD Loan Status
Select loan_status,
	count(loan_status) as total_loan_status,
	sum(loan_amount) as total_loan_amount,
	sum(total_payment) as total_amount_received,
	Round(AVG(int_rate)*100,3) as AVG_interest_rate,
	Round(AVG(dti)*100,3) as AVG_dti
From project..financialloandata
Where Month(issue_date) = 12
Group by loan_status;

-- BANK LOAN REPORT | OVERVIEW

Select
Month(issue_date) as Month_Number,
	DATENAME(Month,issue_date) as [Month],
	count(id) as total_application,
	sum(loan_amount) as Total_Loan_amount,
	sum(total_payment) as Total_Amount_Received
From project..financialloandata
Group by Month(issue_date),DATENAME(Month,issue_date)
Order by Month(issue_date);

-- State

Select address_state,
	count(id) as total_application,
	sum(loan_amount) as Total_Loan_amount,
	sum(total_payment) as Total_Amount_Received
From project..financialloandata
Group by address_state
Order by address_state;

-- Employee-lenght
Select emp_length,
	count(id) as total_application,
	sum(loan_amount) as Total_Loan_amount,
	sum(total_payment) as Total_Amount_Received
From project..financialloandata
Group by emp_length
Order by emp_length;

-- Purpose
Select purpose,
	count(id) as total_application,
	sum(loan_amount) as Total_Loan_amount,
	sum(total_payment) as Total_Amount_Received
From project..financialloandata
Group by purpose
Order by purpose;

-- HomeOwenership

Select home_ownership,
	count(id) as total_application,
	sum(loan_amount) as Total_Loan_amount,
	sum(total_payment) as Total_Amount_Received
From project..financialloandata
Group by home_ownership
Order by home_ownership;