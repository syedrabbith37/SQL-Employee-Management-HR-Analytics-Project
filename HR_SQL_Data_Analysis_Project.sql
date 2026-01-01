/* ==========================================================================
   HR DATA ANALYTICS: END-TO-END SQL PROJECT
   Skills: DDL, DML, Joins, Self-Joins, Subqueries, & Window Functions
   Database: PostgreSQL / MySQL / SQL Server
========================================================================== */

-- 1. DATABASE SETUP (DDL)
-- Creating the relational structure

CREATE TABLE dept (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE Jobs (
    job_id INT PRIMARY KEY,
    job_title VARCHAR(50),
    min_salary NUMERIC(10,2),
    max_salary NUMERIC(10,2)
);

CREATE TABLE emp (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    job_id INT,
    manager_id INT,
    hire_date DATE,
    salary NUMERIC(10,2),
    dept_id INT,
    FOREIGN KEY (job_id) REFERENCES Jobs(job_id),
    FOREIGN KEY (dept_id) REFERENCES dept(dept_id),
    FOREIGN KEY (manager_id) REFERENCES emp(emp_id)
);

-- 2. DATA INGESTION (DML)
INSERT INTO dept VALUES 
(10, 'IT', 'Mumbai'), (20, 'Finance', 'Delhi'), 
(30, 'HR', 'Bangalore'), (40, 'Marketing', 'Hyderabad');

INSERT INTO Jobs VALUES
(1, 'Developer', 30000, 80000), (2, 'Manager', 60000, 120000),
(3, 'Analyst', 35000, 75000), (4, 'HR Executive', 25000, 60000);

INSERT INTO emp VALUES
(202, 'Karan', 2, NULL, '2015-09-09', 90000, 10),
(204, 'Meera', 2, NULL, '2016-04-14', 85000, 30),
(101, 'Amit', 1, 202, '2020-01-10', 50000, 10),
(102, 'Rahul', 1, 202, '2021-03-15', 45000, 10),
(103, 'Sneha', 3, 202, '2019-05-20', 40000, 20),
(104, 'Priya', 4, 204, '2021-07-11', 30000, 30);

-- 3. CORE REPORTING (JOINS & AGGREGATIONS)

-- Get employee details with Department and Job Title
SELECT e.emp_name, d.dept_name, j.job_title, e.salary
FROM emp e
JOIN dept d ON e.dept_id = d.dept_id
JOIN Jobs j ON e.job_id = j.job_id;

-- Self-Join: Identifying reporting lines (Employee to Manager)
SELECT m.emp_name AS Employee, n.emp_name AS Manager
FROM emp m
LEFT JOIN emp n ON m.manager_id = n.emp_id;

-- Group By: Total salary spend per department
SELECT dept_id, SUM(salary) as total_dept_spend
FROM emp
GROUP BY dept_id
HAVING SUM(salary) > 50000;

-- 4. INTERMEDIATE ANALYSIS (SUBQUERIES)

-- Employees earning more than the company-wide average
SELECT emp_name, salary 
FROM emp 
WHERE salary > (SELECT AVG(salary) FROM emp);

-- 5. ADVANCED ANALYSIS (WINDOW FUNCTIONS)

-- A. Ranking: Highest paid employee per department
-- This identifies the #1 earner in every team
SELECT * FROM (
    SELECT 
        emp_name, 
        dept_id, 
        salary,
        DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) as rnk
    FROM emp
) AS SalaryRanking WHERE rnk = 1;

-- B. Comparative Analysis: Individual Salary vs Dept Average
-- Shows if an employee is paid above or below their team mean
SELECT 
    emp_name, 
    salary,
    dept_id,
    AVG(salary) OVER(PARTITION BY dept_id) as dept_avg,
    (salary - AVG(salary) OVER(PARTITION BY dept_id)) as salary_difference
FROM emp;

-- C. Budget Utilization: Running Total of Salaries by Hire Date
SELECT 
    hire_date, 
    emp_name, 
    salary,
    SUM(salary) OVER(ORDER BY hire_date) as cumulative_payroll_spend
FROM emp;
