-- 1. Total providers received
SELECT COUNT(*) AS total_providers
FROM provider_credentialing_sample;

-- 2. Backlog by status
SELECT status, COUNT(*) AS provider_count
FROM provider_credentialing_sample
GROUP BY status
ORDER BY provider_count DESC;

-- 3. Average turnaround time by state
SELECT state,
       ROUND(AVG(turnaround_days), 2) AS avg_turnaround_days
FROM provider_credentialing_sample
GROUP BY state
ORDER BY avg_turnaround_days DESC;

-- 4. SLA breaches
SELECT COUNT(*) AS sla_breach_count
FROM provider_credentialing_sample
WHERE turnaround_days > sla_target_days;

-- 5. Analyst productivity
SELECT assigned_analyst,
       COUNT(*) AS total_cases,
       SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_cases,
       ROUND(AVG(turnaround_days), 2) AS avg_turnaround_days
FROM provider_credentialing_sample
GROUP BY assigned_analyst
ORDER BY completed_cases DESC;

-- 6. Monthly volume trend
SELECT SUBSTR(received_date, 1, 7) AS month,
       COUNT(*) AS intake_volume
FROM provider_credentialing_sample
GROUP BY SUBSTR(received_date, 1, 7)
ORDER BY month;

-- 7. Exception rates
SELECT
    SUM(documents_missing_flag) AS missing_documents_cases,
    SUM(verification_issue_flag) AS verification_issue_cases,
    SUM(committee_required_flag) AS committee_review_cases
FROM provider_credentialing_sample;

-- 8. Aging bucket logic for pending files
SELECT
    CASE
        WHEN turnaround_days BETWEEN 0 AND 7 THEN '0-7 Days'
        WHEN turnaround_days BETWEEN 8 AND 14 THEN '8-14 Days'
        WHEN turnaround_days BETWEEN 15 AND 30 THEN '15-30 Days'
        ELSE '31+ Days'
    END AS aging_bucket,
    COUNT(*) AS pending_count
FROM provider_credentialing_sample
WHERE status <> 'Completed'
GROUP BY
    CASE
        WHEN turnaround_days BETWEEN 0 AND 7 THEN '0-7 Days'
        WHEN turnaround_days BETWEEN 8 AND 14 THEN '8-14 Days'
        WHEN turnaround_days BETWEEN 15 AND 30 THEN '15-30 Days'
        ELSE '31+ Days'
    END
ORDER BY pending_count DESC;
