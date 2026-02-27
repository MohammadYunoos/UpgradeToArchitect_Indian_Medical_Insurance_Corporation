-- =====================================================
-- IMIC - Core Workflow Queries
-- Production-Ready T-SQL Procedures & Queries
-- =====================================================

-- =====================================================
-- 1. SUBMIT POLICY APPLICATION (with documents)
-- =====================================================

CREATE OR ALTER PROCEDURE imic.sp_SubmitPolicyApplication
    @AgentID              BIGINT,
    @PolicyHolderID       BIGINT,
    @IntendedCoverAmount  DECIMAL(14,2),
    @IntendedPlan         NVARCHAR(100),
    @PremiumQuote         DECIMAL(14,2),
    @PaymentMode          NVARCHAR(50),
    @ChequeNo             NVARCHAR(50),
    @ChequeStatus         NVARCHAR(50),
    @AgeProofPath         NVARCHAR(500),
    @MedicalReportPath    NVARCHAR(500)
AS
BEGIN
    SET XACT_ABORT ON;
    
    INSERT INTO imic.PolicyApplication 
        (AgentID, PolicyHolderID, Status, IntendedCoverAmount, IntendedPlan, PremiumQuote, PaymentMode, ChequeNo, ChequeStatus)
    VALUES 
        (@AgentID, @PolicyHolderID, N'Submitted', @IntendedCoverAmount, @IntendedPlan, @PremiumQuote, @PaymentMode, @ChequeNo, @ChequeStatus);
    
    DECLARE @ApplicationID BIGINT = SCOPE_IDENTITY();
    
    INSERT INTO imic.ApplicationDocument (ApplicationID, DocType, FileRef)
    VALUES 
        (@ApplicationID, N'AgeProof', @AgeProofPath),
        (@ApplicationID, N'MedicalReport', @MedicalReportPath);
    
    SELECT @ApplicationID AS ApplicationID;
END;
GO

-- =====================================================
-- 2. APPROVE APPLICATION → ISSUE POLICY & MEMBERS (TXN)
-- =====================================================

CREATE OR ALTER PROCEDURE imic.sp_ApproveApplicationAndIssuePolicy
    @ApplicationID BIGINT
AS
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRAN;
    
    -- Update application status
    UPDATE imic.PolicyApplication 
    SET Status = N'Approved', RejectionReason = NULL 
    WHERE ApplicationID = @ApplicationID AND Status = N'Submitted';
    
    IF @@ROWCOUNT = 0 
    BEGIN
        ROLLBACK TRAN;
        THROW 50001, 'Application not approvable or already processed.', 1;
    END
    
    -- Create policy
    INSERT INTO imic.Policy (PolicyHolderID, AgentID, ApplicationID, CoverAmount, PremiumAmount, StartDate, EndDate, Status)
    SELECT 
        pa.PolicyHolderID, 
        pa.AgentID, 
        pa.ApplicationID,
        pa.IntendedCoverAmount, 
        pa.PremiumQuote,
        CAST(SYSUTCDATETIME() AS DATE), 
        NULL, 
        N'Active'
    FROM imic.PolicyApplication pa
    WHERE pa.ApplicationID = @ApplicationID;
    
    DECLARE @PolicyID BIGINT = SCOPE_IDENTITY();
    
    -- Create primary member (policy holder)
    INSERT INTO imic.Member (PolicyID, FullName, DOB, Gender, RelationToPrimary, IsPrimary)
    SELECT 
        @PolicyID, 
        ph.FullName, 
        ph.DOB, 
        NULL, 
        N'Self', 
        1
    FROM imic.PolicyHolder ph
    JOIN imic.PolicyApplication pa ON pa.PolicyHolderID = ph.PolicyHolderID
    WHERE pa.ApplicationID = @ApplicationID;
    
    COMMIT TRAN;
    
    SELECT @PolicyID AS PolicyID;
END;
GO

-- =====================================================
-- 3. SUBMIT CLAIM (with documents)
-- =====================================================

CREATE OR ALTER PROCEDURE imic.sp_SubmitClaim
    @PolicyID          BIGINT,
    @MemberID          BIGINT,
    @AgentID           BIGINT,
    @ClaimedAmount     DECIMAL(14,2),
    @HospitalBillPath  NVARCHAR(500),
    @ReportPath        NVARCHAR(500)
AS
BEGIN
    SET XACT_ABORT ON;
    
    INSERT INTO imic.Claim (PolicyID, MemberID, SubmittedByAgentID, Status, ClaimedAmount)
    VALUES (@PolicyID, @MemberID, @AgentID, N'SentForApproval', @ClaimedAmount);
    
    DECLARE @ClaimID BIGINT = SCOPE_IDENTITY();
    
    INSERT INTO imic.ClaimDocument (ClaimID, DocType, FileRef)
    VALUES 
        (@ClaimID, N'HospitalBill', @HospitalBillPath),
        (@ClaimID, N'DiagnosticReport', @ReportPath);
    
    SELECT @ClaimID AS ClaimID;
END;
GO

-- =====================================================
-- 4. ACCEPT CLAIM → RECORD CHEQUE (TXN)
-- =====================================================

CREATE OR ALTER PROCEDURE imic.sp_AcceptClaimAndIssueCheque
    @ClaimID       BIGINT,
    @ApprovedAmount DECIMAL(14,2),
    @ChequeNumber  NVARCHAR(50),
    @BankName      NVARCHAR(100)
AS
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRAN;
    
    -- Update claim status
    UPDATE imic.Claim 
    SET Status = N'Accepted', 
        ApprovedAmount = @ApprovedAmount, 
        RejectionReason = NULL, 
        DecisionAt = SYSUTCDATETIME()
    WHERE ClaimID = @ClaimID AND Status = N'SentForApproval';
    
    IF @@ROWCOUNT = 0 
    BEGIN
        ROLLBACK TRAN;
        THROW 50002, 'Claim not approvable or already processed.', 1;
    END
    
    -- Create cheque record
    INSERT INTO imic.Cheque (ClaimID, ChequeNumber, BankName, ChequeDate, Amount, DispatchedAt)
    VALUES (@ClaimID, @ChequeNumber, @BankName, CAST(SYSUTCDATETIME() AS DATE), @ApprovedAmount, NULL);
    
    COMMIT TRAN;
    
    SELECT 'Claim accepted and cheque issued.' AS Message;
END;
GO

-- =====================================================
-- 5. REJECT CLAIM
-- =====================================================

CREATE OR ALTER PROCEDURE imic.sp_RejectClaim
    @ClaimID BIGINT,
    @Reason  NVARCHAR(500)
AS
BEGIN
    SET XACT_ABORT ON;
    
    UPDATE imic.Claim 
    SET Status = N'Rejected', 
        RejectionReason = @Reason, 
        ApprovedAmount = NULL, 
        DecisionAt = SYSUTCDATETIME()
    WHERE ClaimID = @ClaimID AND Status = N'SentForApproval';
    
    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50003, 'Claim not found or already processed.', 1;
    END
    
    SELECT 'Claim rejected.' AS Message;
END;
GO

-- =====================================================
-- 6. LOGIN ATTEMPT HANDLING
-- =====================================================

CREATE OR ALTER PROCEDURE imic.sp_HandleFailedLogin
    @Username NVARCHAR(100)
AS
BEGIN
    SET XACT_ABORT ON;
    
    UPDATE imic.UserAccount 
    SET FailedAttemptCount = FailedAttemptCount + 1,
        Locked = CASE WHEN FailedAttemptCount + 1 >= 3 THEN 1 ELSE Locked END
    WHERE Username = @Username;
END;
GO

CREATE OR ALTER PROCEDURE imic.sp_HandleSuccessfulLogin
    @UserID BIGINT
AS
BEGIN
    SET XACT_ABORT ON;
    
    UPDATE imic.UserAccount 
    SET FailedAttemptCount = 0, LastLoginAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;
END;
GO

CREATE OR ALTER PROCEDURE imic.sp_UnlockUserAccount
    @UserID BIGINT
AS
BEGIN
    SET XACT_ABORT ON;
    
    UPDATE imic.UserAccount 
    SET Locked = 0, FailedAttemptCount = 0 
    WHERE UserID = @UserID;
    
    SELECT 'User account unlocked.' AS Message;
END;
GO

-- =====================================================
-- 7. UTILITY QUERIES
-- =====================================================

-- Policy holder dashboard
CREATE OR ALTER VIEW imic.vwPolicyHolderSummary AS
SELECT 
    ph.PolicyHolderID,
    ph.FullName,
    COUNT(DISTINCT p.PolicyID) AS ActivePolicies,
    COUNT(DISTINCT c.ClaimID) AS TotalClaims,
    SUM(CASE WHEN c.Status = N'Accepted' THEN c.ApprovedAmount ELSE 0 END) AS ApprovedClaimsAmount,
    SUM(CASE WHEN c.Status = N'SentForApproval' THEN c.ClaimedAmount ELSE 0 END) AS PendingClaimsAmount
FROM imic.PolicyHolder ph
LEFT JOIN imic.Policy p ON p.PolicyHolderID = ph.PolicyHolderID AND p.Status = N'Active'
LEFT JOIN imic.Claim c ON c.PolicyID = p.PolicyID
GROUP BY ph.PolicyHolderID, ph.FullName;
GO

-- Agent performance
CREATE OR ALTER VIEW imic.vwAgentPerformance AS
SELECT 
    a.AgentID,
    a.Name,
    COUNT(DISTINCT pa.ApplicationID) AS ApplicationsSubmitted,
    COUNT(DISTINCT p.PolicyID) AS PoliciesIssued,
    SUM(p.PremiumAmount) AS TotalPremium,
    COUNT(DISTINCT c.ClaimID) AS ClaimsProcessed,
    SUM(CASE WHEN c.Status = N'Accepted' THEN c.ApprovedAmount ELSE 0 END) AS ClaimsApproved
FROM imic.Agent a
LEFT JOIN imic.PolicyApplication pa ON pa.AgentID = a.AgentID
LEFT JOIN imic.Policy p ON p.AgentID = a.AgentID
LEFT JOIN imic.Claim c ON c.SubmittedByAgentID = a.AgentID
GROUP BY a.AgentID, a.Name;
GO

-- Claims awaiting approval
CREATE OR ALTER VIEW imic.vwPendingClaims AS
SELECT 
    c.ClaimID,
    c.SubmittedAt,
    p.PolicyID,
    ph.FullName AS PolicyHolderName,
    m.FullName AS MemberName,
    c.ClaimedAmount,
    a.Name AS AgentName,
    DATEDIFF(DAY, c.SubmittedAt, SYSUTCDATETIME()) AS DaysAwaitingApproval
FROM imic.Claim c
JOIN imic.Policy p ON p.PolicyID = c.PolicyID
JOIN imic.PolicyHolder ph ON ph.PolicyHolderID = p.PolicyHolderID
JOIN imic.Member m ON m.MemberID = c.MemberID
JOIN imic.Agent a ON a.AgentID = c.SubmittedByAgentID
WHERE c.Status = N'SentForApproval'
ORDER BY c.SubmittedAt ASC;
GO

-- =====================================================
-- END OF WORKFLOW QUERIES
-- =====================================================
