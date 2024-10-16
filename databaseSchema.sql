USE [master]
GO
/****** Object:  Database [Nextay]    Script Date: 11/10/2024 12:19:50 pm ******/
CREATE DATABASE [Nextay]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'testing', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\testing.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'testing_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\testing_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Nextay] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Nextay].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Nextay] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Nextay] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Nextay] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Nextay] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Nextay] SET ARITHABORT OFF 
GO
ALTER DATABASE [Nextay] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Nextay] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Nextay] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Nextay] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Nextay] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Nextay] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Nextay] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Nextay] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Nextay] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Nextay] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Nextay] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Nextay] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Nextay] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Nextay] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Nextay] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Nextay] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Nextay] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Nextay] SET RECOVERY FULL 
GO
ALTER DATABASE [Nextay] SET  MULTI_USER 
GO
ALTER DATABASE [Nextay] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Nextay] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Nextay] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Nextay] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Nextay] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Nextay] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Nextay', N'ON'
GO
ALTER DATABASE [Nextay] SET QUERY_STORE = ON
GO
ALTER DATABASE [Nextay] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Nextay]
GO
/****** Object:  Table [dbo].[Amenities]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Amenities](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[RoomID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attendance]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attendance](
	[EmployeeId] [int] NULL,
	[Date] [date] NOT NULL,
	[AttendanceStatus] [int] NULL,
	[CheckInTime] [datetime] NULL,
	[CheckOutTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Booking]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Booking](
	[BookingId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[RoomId] [int] NULL,
	[CheckInTime] [datetime] NOT NULL,
	[CheckOutTime] [datetime] NULL,
	[PaymentStatus] [int] NULL,
	[PaymentMethod] [int] NULL,
	[NumberOfGuests] [int] NOT NULL,
	[TotalAmount] [float] NOT NULL,
	[SpecialRequest] [text] NULL,
	[CancellationDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerTable]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerTable](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](100) NOT NULL,
	[LastName] [varchar](100) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[PhoneNumber] [bigint] NOT NULL,
	[Address] [varchar](255) NULL,
	[DOB] [date] NULL,
	[Nationality] [varchar](100) NULL,
	[IDType] [int] NULL,
	[BookingHistory] [text] NULL,
	[Preferences] [text] NULL,
	[LastStayDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Earning]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Earning](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NOT NULL,
	[Amount] [float] NOT NULL,
	[Source] [int] NULL,
	[BookingId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](100) NOT NULL,
	[LastName] [varchar](100) NOT NULL,
	[CNIC] [varchar](15) NOT NULL,
	[ContactNo] [varchar](15) NULL,
	[Email] [varchar](100) NULL,
	[ProfilePhoto] [varchar](255) NULL,
	[SalaryId] [int] NULL,
	[DOB] [date] NULL,
	[Shift] [int] NULL,
	[IsActive] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeDesignation]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeDesignation](
	[EmployeeId] [int] NULL,
	[PromotionId] [int] IDENTITY(1,1) NOT NULL,
	[Position] [int] NULL,
	[PromotionDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[PromotionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Expense]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Expense](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NOT NULL,
	[Amount] [float] NOT NULL,
	[Category] [int] NULL,
	[Notes] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Feedback]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feedback](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NULL,
	[DateSubmitted] [datetime] NULL,
	[Status] [int] NULL,
	[Rating] [int] NULL,
	[CustomerId] [int] NULL,
	[Feedback] [text] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Image]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  Table [dbo].[Lookup]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lookup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Category] [varchar](100) NULL,
	[Value] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rooms]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rooms](
	[RoomID] [int] IDENTITY(1,1) NOT NULL,
	[RoomType] [varchar](100) NOT NULL,
	[RoomStatus] [int] NULL,
	[LastCleaned] [datetime] NULL,
	[ImageId] [int] NULL,
	[PricePerDay] [float] NOT NULL,
	[RoomArea] [float] NULL,
	[FloorNumber] [int] NOT NULL,
	[MaxOccupancy] [int] NOT NULL,
	[BedType] [varchar](100) NOT NULL,
	[LastMaintenanceDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[RoomID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Salary]    Script Date: 11/10/2024 12:19:50 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Salary](
	[EmployeeId] [int] NULL,
	[SalaryId] [int] IDENTITY(1,1) NOT NULL,
	[PayDate] [date] NULL,
	[Incentive] [float] NULL,
	[IncentiveDescription] [text] NULL,
	[IncrementDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Feedback] ADD  DEFAULT (getdate()) FOR [DateSubmitted]
GO
ALTER TABLE [dbo].[Rooms] ADD  DEFAULT (getdate()) FOR [LastCleaned]
GO
ALTER TABLE [dbo].[Amenities]  WITH CHECK ADD FOREIGN KEY([RoomID])
REFERENCES [dbo].[Rooms] ([RoomID])
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD FOREIGN KEY([AttendanceStatus])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([Id])
GO
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD FOREIGN KEY([CustomerId])
REFERENCES [dbo].[CustomerTable] ([Id])
GO
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD FOREIGN KEY([PaymentStatus])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD FOREIGN KEY([PaymentMethod])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD FOREIGN KEY([RoomId])
REFERENCES [dbo].[Rooms] ([RoomID])
GO
ALTER TABLE [dbo].[CustomerTable]  WITH CHECK ADD FOREIGN KEY([IDType])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Earning]  WITH CHECK ADD FOREIGN KEY([BookingId])
REFERENCES [dbo].[Booking] ([BookingId])
GO
ALTER TABLE [dbo].[Earning]  WITH CHECK ADD FOREIGN KEY([Source])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD FOREIGN KEY([IsActive])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD FOREIGN KEY([Shift])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[EmployeeDesignation]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([Id])
GO
ALTER TABLE [dbo].[EmployeeDesignation]  WITH CHECK ADD FOREIGN KEY([Position])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Expense]  WITH CHECK ADD FOREIGN KEY([Category])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD FOREIGN KEY([CustomerId])
REFERENCES [dbo].[CustomerTable] ([Id])
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD FOREIGN KEY([Status])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD FOREIGN KEY([Type])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Image]  WITH CHECK ADD FOREIGN KEY([RoomID])
REFERENCES [dbo].[Rooms] ([RoomID])
GO
ALTER TABLE [dbo].[Rooms]  WITH CHECK ADD FOREIGN KEY([RoomStatus])
REFERENCES [dbo].[Lookup] ([Id])
GO
ALTER TABLE [dbo].[Salary]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([Id])
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD CHECK  (([Rating]>=(0) AND [Rating]<=(5)))
GO
USE [master]
GO
ALTER DATABASE [Nextay] SET  READ_WRITE 
GO
