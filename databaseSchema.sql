CREATE TABLE [dbo].[Lookup] (
    Id INT PRIMARY KEY,
    Category NVARCHAR(50) NOT NULL,
    Value NVARCHAR(50) NOT NULL
);

-- Populate Lookup Table and lock it
INSERT INTO [dbo].[Lookup] ([Id], [Category], [Value]) VALUES
    (1, N'RoomStatus', N'Available'),
    (2, N'RoomStatus', N'Occupied'),
    (3, N'RoomStatus', N'Dirty'),
    (4, N'PaymentStatus', N'Paid'),
    (5, N'PaymentStatus', N'Unpaid'),
    (6, N'PaymentMethod', N'Credit Card'),
    (7, N'PaymentMethod', N'Cash'),
    (8, N'PaymentMethod', N'Online Payment'),
    (9, N'IDType', N'Passport'),
    (10, N'IDType', N'Driver License'),
    (11, N'IDType', N'National ID'),
    (12, N'FeedBackType', N'Complaint'),
    (13, N'FeedBackType', N'Suggestion'),
    (14, N'FeedBackType', N'Compliment'),
    (15, N'Employees Position', N'Staff'),
    (16, N'Employees Position', N'Manager'),
    (17, N'Employees Position', N'Finance Manager'),
    (18, N'Employees Position', N'Chef'),
    (19, N'Employees Position', N'Janitor'),
    (20, N'Employees Shift', N'Morning'),
    (21, N'Employees Shift', N'Afternoon'),
    (22, N'Employees Shift', N'Night'),
    (23, N'Status', N'True'),
    (24, N'Status', N'False');

-- Disable further changes to Lookup table data
ALTER TABLE [dbo].[Lookup] 
ADD CONSTRAINT CK_Lookup_NoUpdates CHECK (1 = 1);  -- Placeholder for immutability constraints




-- Employee Table




CREATE TABLE [dbo].[Employee] (
    Id INT IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL 
        CHECK (FirstName NOT LIKE '%[^a-zA-Z]%'),  -- Alphabet only
    LastName NVARCHAR(50) NULL 
        CHECK (LastName NOT LIKE '%[^a-zA-Z]%'),  -- Alphabet only
    CNIC CHAR(13) NOT NULL UNIQUE 
        CHECK (CNIC NOT LIKE '%[^0-9]%' AND len(CNIC) = 13),  -- Digits only, length 13
    ContactNo CHAR(11) NOT NULL UNIQUE 
        CHECK (ContactNo NOT LIKE '%[^0-9]%' AND len(ContactNo) = 11),  -- Digits only, length 11
    Email NVARCHAR(100) NOT NULL UNIQUE 
        CHECK (Email LIKE '%_@__%.__%'),  -- Email format
    ProfilePhoto NVARCHAR(255) NULL,
    DOB DATE NOT NULL,
    [Shift] INT NOT NULL 
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    IsActive INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    
    SalaryAmount DECIMAL(12, 3) NOT NULL 
        CHECK (SalaryAmount BETWEEN 20000 AND 10000000),  -- Salary range
	Ispaid INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),

    AddedBy INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Employee](Id),
    UpdatedBy INT NULL
		FOREIGN KEY REFERENCES [dbo].[Employee](Id),
);

-- User Table
CREATE TABLE [dbo].[User] (
	EmployeeID INT NOT NULL 
         FOREIGN KEY REFERENCES [dbo].[Employee](Id),
    Username NVARCHAR(50) NOT NULL UNIQUE 
        CHECK (Username NOT LIKE '%[^a-zA-Z0-9]%'),  -- No special characters
    [Password] NVARCHAR(50) NOT NULL 
        CHECK (Password LIKE '%[A-Z]%' AND Password LIKE '%[0-9]%'),  -- Caps + Digit required
	UpdateDate datetime NULL,

	Primary Key (EmployeeID)
);

-- Attendance Table
CREATE TABLE [dbo].[Attendance] (
    EmployeeID INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Employee](Id),
    Date DATE NOT NULL,
    AttendanceStatus INT NOT NULL 
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    CheckInTime DATETIME NULL,
    CheckOutTime DATETIME NULL,
    CONSTRAINT PK_Attendance PRIMARY KEY (EmployeeID, Date)
);


-- Salary Table
CREATE TABLE [dbo].[Salary] (
    SalaryID INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,
    PayDate DATE NOT NULL,
    PaidBy INT NOT NULL,
    Incentive DECIMAL(18, 2) NULL CHECK (Incentive >= 0),  -- Non-negative
    IncentiveDescription TEXT NULL,
    IncrementDate DATE NULL,

    -- Foreign key constraints
    CONSTRAINT FK_Salary_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES [dbo].[Employee](Id),
    CONSTRAINT FK_Salary_PaidBy FOREIGN KEY (PaidBy) REFERENCES [dbo].[Employee](Id)
);


-- Customer Table
CREATE TABLE [dbo].[Customer] (
    CustomerID INT IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL 
        CHECK (FirstName NOT LIKE '%[^a-zA-Z]%'),  -- Alphabet only
    LastName NVARCHAR(50) NULL 
        CHECK (LastName NOT LIKE '%[^a-zA-Z]%'),  -- Alphabet only
    PhoneNumber CHAR(11) NOT NULL UNIQUE 
        CHECK (PhoneNumber NOT LIKE '%[^0-9]%' AND LEN(PhoneNumber) = 11),  -- Digits only, length 11
    Email NVARCHAR(100) NOT NULL UNIQUE
        CHECK (Email LIKE '%_@__%.__%'),  -- Email format
    IDType int NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    [Address] NVARCHAR(255) NULL, 
    DOB DATE NULL,  -- New column
    Nationality NVARCHAR(100) NULL,
    BookingHistory TEXT NULL,
    Preferences TEXT NULL,  -- New column
    LastStayDate DATE NULL  -- New column
);



-- Feedback Table
CREATE TABLE [dbo].[Feedback] (
    FeedbackID INT IDENTITY PRIMARY KEY,
    Type INT NOT NULL 
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    DateSubmitted DATE NOT NULL,
    Rating INT NOT NULL 
        CHECK (Rating BETWEEN 1 AND 5),  -- Rating 1-5
    CustomerID INT NOT NULL 
        FOREIGN KEY REFERENCES [dbo].[Customer](CustomerID),
    Feedback TEXT NULL  -- New column
);







-- Expense Table
CREATE TABLE [dbo].[Expense] (
    ExpenseID INT IDENTITY PRIMARY KEY,
    [Date] DATE NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Amount FLOAT NOT NULL 
        CHECK (Amount > 0),  -- Positive amount
    Notes TEXT NULL  
);



-- Rooms Table
CREATE TABLE [dbo].[Rooms] (
    RoomID INT IDENTITY PRIMARY KEY,
    RoomType NVARCHAR(50) NOT NULL,
    RoomStatus INT NOT NULL 
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    
	LastCleaned DateTime Null,

	PricePerDay FLOAT NOT NULL 
        CHECK (PricePerDay > 0),-- Positive price
    
	RoomArea FLOAT NULL 
        CHECK (RoomArea > 0),  -- Positive area if provided
    FloorNumber INT NOT NULL 
        CHECK (FloorNumber > 0),  -- Positive floor number
    MaxOccupancy INT NOT NULL 
        CHECK (MaxOccupancy > 0),  -- Positive occupancy
    BedType NVARCHAR(50) NOT NULL,
	LastMaintenanceDate Date Null,
    AddedBy INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Employee](Id),
	UpdatedBy INT NULL
		FOREIGN KEY REFERENCES [dbo].[Employee](Id),

);

-- Booking Table
CREATE TABLE [dbo].[Booking] (
    BookingId INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL 
        FOREIGN KEY REFERENCES [dbo].[Customer](CustomerID),
    RoomID INT NOT NULL 
        FOREIGN KEY REFERENCES [dbo].[Rooms](RoomID),
    CheckInTime DATETIME NOT NULL,
    CheckOutTime DATETIME NULL,
    PaymentStatus INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    PaymentMethod INT NOT NULL
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    NumberOfGuests INT NOT NULL 
        CHECK (NumberOfGuests > 0),
    TotalAmount FLOAT NOT NULL 
        CHECK (TotalAmount > 0),  -- Positive total amount
    SpecialRequest TEXT NULL,  -- New column
    CancellationDate DATE NULL,  -- New column
    AddedBy NVARCHAR(50) NOT NULL,
);

-- Earning Table
CREATE TABLE [dbo].[Earning] (
    EarningID INT IDENTITY PRIMARY KEY,
    [Date] DATE NOT NULL,
    Amount FLOAT NOT NULL 
        CHECK (Amount >= 0), 
    [Source] NVARCHAR(100) NOT NULL,
    BookingID INT NULL
		FOREIGN KEY REFERENCES [dbo].[Booking](BookingId)
);



CREATE TABLE [dbo].[Image](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Link] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
	[RoomID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


-- Amenities Table
CREATE TABLE [dbo].[Amenities] (
    AmenityID INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(50) NOT NULL,
    RoomID INT NOT NULL 
        FOREIGN KEY REFERENCES [dbo].[Rooms](RoomID)
);


-- EmployeeDesignation Table
CREATE TABLE [dbo].[EmployeeDesignation] (
    DesignationID INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL 
        FOREIGN KEY REFERENCES [dbo].[Employee](Id),
    Position INT NOT NULL 
		FOREIGN KEY REFERENCES [dbo].[Lookup](Id),
    PromotionDate DATE NULL
);

