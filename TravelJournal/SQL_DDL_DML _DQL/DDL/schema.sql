/* =====================================================================
   TravelJournalDB
   ===================================================================== */

/* ---------------- Database context ---------------- */
-- Set current database so subsequent objects target the right DB.

USE [TravelJournalDB]

GO

/****** Object:  Table [dbo].[EntryLocations]    Script Date: 2/11/2568 22:30:16 ******/
/* ---------------- Session options ---------------- */
-- Ensure deterministic behavior for object creation.

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

/* ---------------- Tables ---------------- */
-- Base entities and relationships.

-- Table: [dbo].[EntryLocations]
CREATE TABLE [dbo].[EntryLocations](

	[EntryLocationID] [int] IDENTITY(1,1) NOT NULL,
	[EntryID] [int] NULL,
	[LocationID] [int] NULL,
	[VisitOrder] [int] NULL,
	[Notes] [nvarchar](500) COLLATE Thai_CI_AS NULL,
	[PhotoURL] [nvarchar](255) COLLATE Thai_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[EntryLocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[Locations]    Script Date: 2/11/2568 22:30:16 ******/
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

-- Table: [dbo].[Locations]
CREATE TABLE [dbo].[Locations](

	[LocationID] [int] IDENTITY(1,1) NOT NULL,
	[LocationName] [nvarchar](200) COLLATE Thai_CI_AS NOT NULL,
	[Address] [nvarchar](500) COLLATE Thai_CI_AS NULL,
	[City] [nvarchar](100) COLLATE Thai_CI_AS NULL,
	[Country] [nvarchar](100) COLLATE Thai_CI_AS NULL,
	[Latitude] [decimal](10, 8) NOT NULL,
	[Longitude] [decimal](11, 8) NOT NULL,
	[Category] [nvarchar](50) COLLATE Thai_CI_AS NULL,
	[CreatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[LocationStatistics]    Script Date: 2/11/2568 22:30:16 ******/
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

-- Table: [dbo].[LocationStatistics]
CREATE TABLE [dbo].[LocationStatistics](

	[StatID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [int] NULL,
	[VisitCount] [int] NULL,
	[AverageRating] [decimal](3, 2) NULL,
	[PopularityScale] [int] NULL,
	[LastUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[StatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[TravelEntries]    Script Date: 2/11/2568 22:30:16 ******/
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

-- Table: [dbo].[TravelEntries]
CREATE TABLE [dbo].[TravelEntries](

	[EntryID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[Title] [nvarchar](200) COLLATE Thai_CI_AS NOT NULL,
	[Description] [nvarchar](max) COLLATE Thai_CI_AS NULL,
	[TravelDate] [date] NOT NULL,
	[Rating] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[EntryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

/****** Object:  Table [dbo].[UserActivityLogs]    Script Date: 2/11/2568 22:30:16 ******/
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

-- Table: [dbo].[UserActivityLogs]
CREATE TABLE [dbo].[UserActivityLogs](

	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[ActivityType] [nvarchar](50) COLLATE Thai_CI_AS NOT NULL,
	[ActivityDescription] [nvarchar](500) COLLATE Thai_CI_AS NULL,
	[IPAddress] [nvarchar](50) COLLATE Thai_CI_AS NULL,
	[UserAgent] [nvarchar](500) COLLATE Thai_CI_AS NULL,
	[CreatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[Users]    Script Date: 2/11/2568 22:30:16 ******/
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

-- Table: [dbo].[Users]
CREATE TABLE [dbo].[Users](

	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](50) COLLATE Thai_CI_AS NOT NULL,
	[Email] [nvarchar](100) COLLATE Thai_CI_AS NOT NULL,
	[PasswordHash] [nvarchar](255) COLLATE Thai_CI_AS NOT NULL,
	[FullName] [nvarchar](100) COLLATE Thai_CI_AS NULL,
	[DateOfBirth] [date] NULL,
	[ProfileImage] [nvarchar](255) COLLATE Thai_CI_AS NULL,
	[CreatedDate] [datetime] NULL,
	[LastLogin] [datetime] NULL,
	[IsActive] [bit] NULL,
	[Role] [nvarchar](20) COLLATE Thai_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_Locations_LatLong]    Script Date: 2/11/2568 22:30:16 ******/
/* ---------------- Indexes ---------------- */
-- Non-functional change: comments only; index definitions preserved.

-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_Locations_LatLong] ON [dbo].[Locations]

(
	[Latitude] ASC,
	[Longitude] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

/****** Object:  Index [IX_LocationStatistics_LocationID]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_LocationStatistics_LocationID] ON [dbo].[LocationStatistics]

(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

/****** Object:  Index [IX_TravelEntries_TravelDate]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_TravelEntries_TravelDate] ON [dbo].[TravelEntries]

(
	[TravelDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

/****** Object:  Index [IX_TravelEntries_UserID]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_TravelEntries_UserID] ON [dbo].[TravelEntries]

(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_UserActivityLogs_ActivityType]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_UserActivityLogs_ActivityType] ON [dbo].[UserActivityLogs]

(
	[ActivityType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

/****** Object:  Index [IX_UserActivityLogs_CreatedDate]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_UserActivityLogs_CreatedDate] ON [dbo].[UserActivityLogs]

(
	[CreatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

/****** Object:  Index [IX_UserActivityLogs_UserID]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_UserActivityLogs_UserID] ON [dbo].[UserActivityLogs]

(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_Users_Email]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_Users_Email] ON [dbo].[Users]

(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_Users_Username]    Script Date: 2/11/2568 22:30:16 ******/
-- Index to aid query performance
CREATE NONCLUSTERED INDEX [IX_Users_Username] ON [dbo].[Users]

(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Locations] ADD  DEFAULT (getdate()) FOR [CreatedDate]

GO

ALTER TABLE [dbo].[LocationStatistics] ADD  DEFAULT ((0)) FOR [VisitCount]

GO

ALTER TABLE [dbo].[LocationStatistics] ADD  DEFAULT (getdate()) FOR [LastUpdated]

GO

ALTER TABLE [dbo].[TravelEntries] ADD  DEFAULT (getdate()) FOR [CreatedDate]

GO

ALTER TABLE [dbo].[TravelEntries] ADD  DEFAULT (getdate()) FOR [UpdatedDate]

GO

ALTER TABLE [dbo].[UserActivityLogs] ADD  DEFAULT (getdate()) FOR [CreatedDate]

GO

ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [CreatedDate]

GO

ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[Users] ADD  DEFAULT ('User') FOR [Role]

GO

ALTER TABLE [dbo].[EntryLocations]  WITH CHECK ADD FOREIGN KEY([EntryID])
REFERENCES [dbo].[TravelEntries] ([EntryID])
ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EntryLocations]  WITH CHECK ADD FOREIGN KEY([LocationID])
REFERENCES [dbo].[Locations] ([LocationID])
ON DELETE CASCADE

GO

ALTER TABLE [dbo].[LocationStatistics]  WITH CHECK ADD FOREIGN KEY([LocationID])
REFERENCES [dbo].[Locations] ([LocationID])
ON DELETE CASCADE

GO

ALTER TABLE [dbo].[TravelEntries]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
ON DELETE CASCADE

GO

ALTER TABLE [dbo].[UserActivityLogs]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
ON DELETE CASCADE

GO

ALTER TABLE [dbo].[LocationStatistics]  WITH CHECK ADD CHECK  (([PopularityScale]>=(1) AND [PopularityScale]<=(5)))

GO

ALTER TABLE [dbo].[TravelEntries]  WITH CHECK ADD CHECK  (([Rating]>=(1) AND [Rating]<=(5)))

GO

/****** Object:  Trigger [dbo].[trg_UpdateStatsAfterEntry]    Script Date: 2/11/2568 22:30:16 ******/
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

/* ---------------- Triggers ---------------- */
-- Event-driven logic tied to table DML. Body preserved exactly.

-- Trigger: [dbo].[trg_UpdateStatsAfterEntry]
CREATE TRIGGER [dbo].[trg_UpdateStatsAfterEntry]

ON [dbo].[EntryLocations]
AFTER INSERT
AS
BEGIN
    DECLARE @LocationID INT;
    
    SELECT @LocationID = LocationID FROM inserted;
    
    EXEC sp_UpdateLocationStatistics @LocationID;
END;

GO

-- Trigger state management
ALTER TABLE [dbo].[EntryLocations] ENABLE TRIGGER [trg_UpdateStatsAfterEntry]

GO
