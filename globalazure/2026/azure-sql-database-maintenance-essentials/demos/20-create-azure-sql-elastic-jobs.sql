------------------------------------------------------------------------
-- Event:        Global Azure 2026 - Pordenone, April 18              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Azure SQL Database Maintenance Essentials            --
--                                                                    --
-- Demo:         Create Azure SQL Elastic Jobs                        --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- 1. Create Azure Resource Group: rg-sqlops-dev-itn-02

-- 2. Create Azure User Assigned Managed Identity: umi-sqlops-maint-dev-itn-02

-- 3. Create Azure SQL logical instance for job management: azure-sql-sqlops-dev-itn-02

-- 4. Create Azure SQL Database for job management: jobdb-dev-itn-02 (S1 service tier)

-- 5. Create Azure SQL Elastic Job Agent: eja-dev-itn-02

-- 6. Create target group and add targets for the jobs: tg-devtest-itn-02

-- 7. Create a job with T-SQL steps to run against the target group: JobMaintenanceIndex

-- 8. Configure authentication for the job agent

-- 9. Execute the job and monitor the execution

-- 10. Schedule the job to run periodically



-- Automate management tasks in Azure SQL
-- https://learn.microsoft.com/azure/azure-sql/database/job-automation-overview?view=azuresql#elastic-database-jobs-preview


-- Elastic jobs in Azure SQL Database
-- https://learn.microsoft.com/azure/azure-sql/database/elastic-jobs-overview?view=azuresql


-- Tutorial: Create, configure, and manage elastic jobs
-- https://learn.microsoft.com/azure/azure-sql/database/elastic-jobs-tutorial?view=azuresql


-- Troubleshooting Common issues with Elastic Jobs in Azure SQL Database
-- https://techcommunity.microsoft.com/t5/azure-sql-blog/troubleshooting-common-issues-with-elastic-jobs-in-azure-sql/ba-p/1180766


-- Elastic Jobs in Azure SQL Database – What and Why
-- https://techcommunity.microsoft.com/t5/azure-sql-blog/elastic-jobs-in-azure-sql-database-what-and-why/ba-p/1177902


-- Azure SQL Database Elastic Jobs preview refresh
-- https://techcommunity.microsoft.com/t5/azure-sql-blog/azure-sql-database-elastic-jobs-preview-refresh/ba-p/3965759


-- General availability: Elastic Jobs in Azure SQL Database
-- https://techcommunity.microsoft.com/t5/azure-sql-blog/general-availability-elastic-jobs-in-azure-sql-database/ba-p/4087140 
