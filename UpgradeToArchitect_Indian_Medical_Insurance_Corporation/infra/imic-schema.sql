-- =====================================================
-- IMIC - Insurance System (Azure SQL)
-- Production-Ready T-SQL DDL for Azure SQL Database
-- =====================================================

-- Create schema
CREATE SCHEMA imic AUTHORIZATION dbo;
GO

-- =====================================================
-- PARTIES & SECURITY TABLES
-- =====================================================

CREATE TABLE imic.PolicyHolder (
    PolicyHolderID   BIGINT IDENTITY(1,1) PRIMARY KEY,
    FullName         NVARCHAR(200) NOT NULL,
    DOB              DATE NULL,
    Email            NVARCHAR(200) NULL,
    Phone            NVARCHAR(50)  NULL,
    Address          NVARCHAR(500) NULL,
    CreatedAt        datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_PolicyHolder_Email ON imic.PolicyHolder(Email);
CREATE INDEX IX_PolicyHolder_Phone ON imic.PolicyHolder(Phone);
GO

CREATE TABLE imic.Agent (
    AgentID   BIGINT IDENTITY(1,1) PRIMARY KEY,
    Name      NVARCHAR(200) NOT NULL,
    LicenseNo NVARCHAR(100) NULL,
    Email     NVARCHAR(200) NULL,
    Phone     NVARCHAR(50)  NULL,
    Branch    NVARCHAR(100) NULL,
    CreatedAt datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_Agent_LicenseNo ON imic.Agent(LicenseNo);
CREATE INDEX IX_Agent_Email ON imic.Agent(Email);
GO

CREATE TABLE imic.CompanyStaff (
    StaffID   BIGINT IDENTITY(1,1) PRIMARY KEY,
    FullName  NVARCHAR(200) NOT NULL,
    Email     NVARCHAR(200) NULL,
    Role      NVARCHAR(100) NULL,
    Department NVARCHAR(100) NULL,
    CreatedAt datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_CompanyStaff_Email ON imic.CompanyStaff(Email);
GO

CREATE TABLE imic.UserAccount (
    UserID             BIGINT IDENTITY(1,1) PRIMARY KEY,
    Username           NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash       VARBINARY(256) NOT NULL,
    Role               NVARCHAR(30) NOT NULL CHECK (Role IN (N'POLICY_HOLDER', N'AGENT', N'STAFF')),
    Locked             BIT NOT NULL DEFAULT(0),
    FailedAttemptCount INT NOT NULL DEFAULT(0),
    LastLoginAt        datetime2(0) NULL,
    PolicyHolderID     BIGINT NULL,
    AgentID            BIGINT NULL,
    StaffID            BIGINT NULL,
    CONSTRAINT FK_UserAccount_PolicyHolder FOREIGN KEY (PolicyHolderID) REFERENCES imic.PolicyHolder(PolicyHolderID),
    CONSTRAINT FK_UserAccount_Agent        FOREIGN KEY (AgentID)        REFERENCES imic.Agent(AgentID),
    CONSTRAINT FK_UserAccount_Staff        FOREIGN KEY (StaffID)        REFERENCES imic.CompanyStaff(StaffID),
    CONSTRAINT CK_UserAccount_RoleBinding CHECK (
        (Role = N'POLICY_HOLDER' AND PolicyHolderID IS NOT NULL AND AgentID IS NULL AND StaffID IS NULL) OR
        (Role = N'AGENT'          AND AgentID        IS NOT NULL AND PolicyHolderID IS NULL AND StaffID IS NULL) OR
        (Role = N'STAFF'          AND StaffID        IS NOT NULL AND PolicyHolderID IS NULL AND AgentID IS NULL)
    )
);

CREATE INDEX IX_UserAccount_Username ON imic.UserAccount(Username);
CREATE INDEX IX_UserAccount_Role ON imic.UserAccount(Role);
GO

-- =====================================================
-- APPLICATION PHASE TABLES
-- =====================================================

CREATE TABLE imic.PolicyApplication (
    ApplicationID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    AgentID              BIGINT NOT NULL,
    PolicyHolderID       BIGINT NOT NULL,
    SubmittedAt          datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    Status               NVARCHAR(20) NOT NULL CHECK (Status IN (N'Submitted', N'Approved', N'Rejected')),
    RejectionReason      NVARCHAR(500) NULL,
    IntendedCoverAmount  DECIMAL(14,2) NULL,
    IntendedPlan         NVARCHAR(100) NULL,
    PremiumQuote         DECIMAL(14,2) NULL,
    PaymentMode          NVARCHAR(50)  NULL,
    ChequeNo             NVARCHAR(50)  NULL,
    ChequeStatus         NVARCHAR(50)  NULL,
    CONSTRAINT FK_PolicyApplication_Agent        FOREIGN KEY (AgentID)        REFERENCES imic.Agent(AgentID),
    CONSTRAINT FK_PolicyApplication_PolicyHolder FOREIGN KEY (PolicyHolderID) REFERENCES imic.PolicyHolder(PolicyHolderID)
);

CREATE INDEX IX_PolicyApplication_Status ON imic.PolicyApplication(Status);
CREATE INDEX IX_PolicyApplication_AgentID ON imic.PolicyApplication(AgentID);
CREATE INDEX IX_PolicyApplication_SubmittedAt ON imic.PolicyApplication(SubmittedAt);
GO

CREATE TABLE imic.ApplicationDocument (
    AppDocID      BIGINT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID BIGINT NOT NULL,
    DocType       NVARCHAR(50)  NOT NULL,
    FileRef       NVARCHAR(500) NOT NULL,
    UploadedAt    datetime2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ApplicationDocument_Application FOREIGN KEY (ApplicationID) REFERENCES imic.PolicyApplication(ApplicationID) ON DELETE CASCADE
);

CREATE INDEX IX_ApplicationDocument_ApplicationID ON imic.ApplicationDocument(ApplicationID);
GO

-- =====================================================
-- POLICIES & MEMBERS TABLES
-- =====================================================

CREATE TABLE imic.Policy (
    PolicyID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    PolicyHolderID  BIGINT NOT NULL,
    AgentID         BIGINT NOT NULL,
    ApplicationID   BIGINT NULL UNIQUE,
    CoverAmount     DECIMAL(14,2) NOT NULL,
    PremiumAmount   DECIMAL(14,2) NOT NULL,
    StartDate       DATE NOT NULL,
    EndDate         DATE NULL,
    Status          NVARCHAR(20) NOT NULL CHECK (Status IN (N'Active', N'Lapsed', N'Cancelled')),
    CreatedAt       datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Policy_PolicyHolder FOREIGN KEY (PolicyHolderID) REFERENCES imic.PolicyHolder(PolicyHolderID),
    CONSTRAINT FK_Policy_Agent        FOREIGN KEY (AgentID)        REFERENCES imic.Agent(AgentID),
    CONSTRAINT FK_Policy_Application  FOREIGN KEY (ApplicationID)  REFERENCES imic.PolicyApplication(ApplicationID)
);

CREATE INDEX IX_Policy_Status ON imic.Policy(Status);
CREATE INDEX IX_Policy_PolicyHolderID ON imic.Policy(PolicyHolderID);
CREATE INDEX IX_Policy_StartDate ON imic.Policy(StartDate);
GO

CREATE TABLE imic.Member (
    MemberID          BIGINT IDENTITY(1,1) PRIMARY KEY,
    PolicyID          BIGINT NOT NULL,
    FullName          NVARCHAR(200) NOT NULL,
    DOB               DATE NULL,
    Gender            NVARCHAR(20) NULL,
    RelationToPrimary NVARCHAR(30) NOT NULL,
    IsPrimary         BIT NOT NULL DEFAULT(0),
    CONSTRAINT FK_Member_Policy FOREIGN KEY (PolicyID) REFERENCES imic.Policy(PolicyID) ON DELETE CASCADE
);

CREATE UNIQUE INDEX UQ_Member_PrimaryPerPolicy ON imic.Member(PolicyID) WHERE IsPrimary = 1;
CREATE INDEX IX_Member_PolicyID ON imic.Member(PolicyID);
GO

CREATE TABLE imic.MemberDocument (
    MemberDocID BIGINT IDENTITY(1,1) PRIMARY KEY,
    MemberID    BIGINT NOT NULL,
    DocType     NVARCHAR(50)  NOT NULL,
    FileRef     NVARCHAR(500) NOT NULL,
    UploadedAt  datetime2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_MemberDocument_Member FOREIGN KEY (MemberID) REFERENCES imic.Member(MemberID) ON DELETE CASCADE
);

CREATE INDEX IX_MemberDocument_MemberID ON imic.MemberDocument(MemberID);
GO

-- =====================================================
-- CLAIMS TABLES
-- =====================================================

CREATE TABLE imic.Claim (
    ClaimID            BIGINT IDENTITY(1,1) PRIMARY KEY,
    PolicyID           BIGINT NOT NULL,
    MemberID           BIGINT NOT NULL,
    SubmittedByAgentID BIGINT NOT NULL,
    SubmittedAt        datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    Status             NVARCHAR(20) NOT NULL CHECK (Status IN (N'SentForApproval', N'Accepted', N'Rejected')),
    ClaimedAmount      DECIMAL(14,2) NOT NULL,
    ApprovedAmount     DECIMAL(14,2) NULL,
    RejectionReason    NVARCHAR(500) NULL,
    DecisionAt         datetime2(0) NULL,
    CONSTRAINT FK_Claim_Policy FOREIGN KEY (PolicyID) REFERENCES imic.Policy(PolicyID),
    CONSTRAINT FK_Claim_Member FOREIGN KEY (MemberID) REFERENCES imic.Member(MemberID),
    CONSTRAINT FK_Claim_Agent  FOREIGN KEY (SubmittedByAgentID) REFERENCES imic.Agent(AgentID)
);

CREATE INDEX IX_Claim_Status ON imic.Claim(Status);
CREATE INDEX IX_Claim_PolicyID ON imic.Claim(PolicyID);
CREATE INDEX IX_Claim_SubmittedAt ON imic.Claim(SubmittedAt);
GO

CREATE TABLE imic.ClaimDocument (
    ClaimDocID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ClaimID    BIGINT NOT NULL,
    DocType    NVARCHAR(50)  NOT NULL,
    FileRef    NVARCHAR(500) NOT NULL,
    UploadedAt datetime2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ClaimDocument_Claim FOREIGN KEY (ClaimID) REFERENCES imic.Claim(ClaimID) ON DELETE CASCADE
);

CREATE INDEX IX_ClaimDocument_ClaimID ON imic.ClaimDocument(ClaimID);
GO

CREATE TABLE imic.Cheque (
    ChequeID     BIGINT IDENTITY(1,1) PRIMARY KEY,
    ClaimID      BIGINT NOT NULL UNIQUE,
    ChequeNumber NVARCHAR(50)  NOT NULL,
    BankName     NVARCHAR(100) NULL,
    ChequeDate   DATE NOT NULL,
    Amount       DECIMAL(14,2) NOT NULL,
    DispatchedAt datetime2(0) NULL,
    CONSTRAINT FK_Cheque_Claim FOREIGN KEY (ClaimID) REFERENCES imic.Claim(ClaimID) ON DELETE CASCADE
);

CREATE INDEX IX_Cheque_ChequeNumber ON imic.Cheque(ChequeNumber);
GO

-- =====================================================
-- VIEWS
-- =====================================================

CREATE OR ALTER VIEW imic.vwPolicyHolderDashboard AS
SELECT 
    ph.PolicyHolderID,
    ph.FullName     AS PolicyHolderName,
    p.PolicyID,
    p.Status        AS PolicyStatus,
    p.CoverAmount,
    p.PremiumAmount,
    p.StartDate,
    p.EndDate,
    m.MemberID,
    m.FullName      AS MemberName,
    m.RelationToPrimary,
    m.IsPrimary,
    c.ClaimID,
    c.Status        AS ClaimStatus,
    c.ClaimedAmount,
    c.ApprovedAmount,
    c.SubmittedAt,
    c.DecisionAt
FROM imic.PolicyHolder ph
JOIN imic.Policy p     ON p.PolicyHolderID = ph.PolicyHolderID
JOIN imic.Member m     ON m.PolicyID      = p.PolicyID
LEFT JOIN imic.Claim c ON c.PolicyID      = p.PolicyID AND c.MemberID = m.MemberID;
GO

-- =====================================================
-- SAMPLE INDEXES FOR REPORTING
-- =====================================================

CREATE INDEX IX_Policy_CreatedAt ON imic.Policy(CreatedAt);
CREATE INDEX IX_Claim_DecisionAt ON imic.Claim(DecisionAt);
CREATE INDEX IX_UserAccount_LastLoginAt ON imic.UserAccount(LastLoginAt);

-- =====================================================
-- DDL COMPLETE
-- =====================================================
