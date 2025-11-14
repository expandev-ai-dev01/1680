/**
 * @schema functional
 * Business logic schema for AutoClean application
 */
CREATE SCHEMA [functional];
GO

/**
 * @table {scanConfiguration} Configuration for file scanning operations
 * @multitenancy true
 * @softDelete true
 * @alias scnCfg
 */
CREATE TABLE [functional].[scanConfiguration] (
  [idScanConfiguration] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [extensionsJson] NVARCHAR(MAX) NOT NULL,
  [namePatternsJson] NVARCHAR(MAX) NOT NULL,
  [minimumAgeDays] INTEGER NOT NULL DEFAULT (7),
  [minimumSizeBytes] INTEGER NOT NULL DEFAULT (0),
  [includeSystemFiles] BIT NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table {scanOperation} Records of file scanning operations
 * @multitenancy true
 * @softDelete false
 * @alias scnOpr
 */
CREATE TABLE [functional].[scanOperation] (
  [idScanOperation] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanConfiguration] INTEGER NOT NULL,
  [directoryPath] NVARCHAR(500) NOT NULL,
  [includeSubdirectories] BIT NOT NULL DEFAULT (1),
  [status] INTEGER NOT NULL DEFAULT (0),
  [progress] INTEGER NOT NULL DEFAULT (0),
  [totalFilesAnalyzed] INTEGER NOT NULL DEFAULT (0),
  [totalFilesIdentified] INTEGER NOT NULL DEFAULT (0),
  [potentialSpaceBytes] BIGINT NOT NULL DEFAULT (0),
  [dateStarted] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateCompleted] DATETIME2 NULL
);
GO

/**
 * @table {identifiedFile} Files identified as temporary during scan
 * @multitenancy true
 * @softDelete false
 * @alias idnFil
 */
CREATE TABLE [functional].[identifiedFile] (
  [idIdentifiedFile] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanOperation] INTEGER NOT NULL,
  [filePath] NVARCHAR(500) NOT NULL,
  [fileName] NVARCHAR(255) NOT NULL,
  [fileExtension] NVARCHAR(50) NOT NULL,
  [fileSizeBytes] BIGINT NOT NULL,
  [fileModifiedDate] DATETIME2 NOT NULL,
  [identificationCriteria] NVARCHAR(200) NOT NULL,
  [selected] BIT NOT NULL DEFAULT (1),
  [dateIdentified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table {removalOperation} Records of file removal operations
 * @multitenancy true
 * @softDelete false
 * @alias rmvOpr
 */
CREATE TABLE [functional].[removalOperation] (
  [idRemovalOperation] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanOperation] INTEGER NOT NULL,
  [removalMode] INTEGER NOT NULL DEFAULT (0),
  [status] INTEGER NOT NULL DEFAULT (0),
  [progress] INTEGER NOT NULL DEFAULT (0),
  [totalFilesRemoved] INTEGER NOT NULL DEFAULT (0),
  [totalFilesWithError] INTEGER NOT NULL DEFAULT (0),
  [spaceFreedBytes] BIGINT NOT NULL DEFAULT (0),
  [dateStarted] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateCompleted] DATETIME2 NULL
);
GO

/**
 * @table {removalResult} Individual file removal results
 * @multitenancy true
 * @softDelete false
 * @alias rmvRst
 */
CREATE TABLE [functional].[removalResult] (
  [idRemovalResult] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idRemovalOperation] INTEGER NOT NULL,
  [idIdentifiedFile] INTEGER NOT NULL,
  [success] BIT NOT NULL,
  [errorMessage] NVARCHAR(500) NULL,
  [dateProcessed] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table {scheduledCleanup} Scheduled automatic cleanup configurations
 * @multitenancy true
 * @softDelete true
 * @alias schCln
 */
CREATE TABLE [functional].[scheduledCleanup] (
  [idScheduledCleanup] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanConfiguration] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [active] BIT NOT NULL DEFAULT (0),
  [frequency] INTEGER NOT NULL DEFAULT (1),
  [scheduleTime] TIME NOT NULL DEFAULT ('03:00'),
  [dayOfWeek] INTEGER NULL,
  [dayOfMonth] INTEGER NULL,
  [cronExpression] NVARCHAR(100) NULL,
  [directoriesJson] NVARCHAR(MAX) NOT NULL,
  [nextExecution] DATETIME2 NULL,
  [lastExecution] DATETIME2 NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey {pkScanConfiguration}
 * @keyType Object
 */
ALTER TABLE [functional].[scanConfiguration]
ADD CONSTRAINT [pkScanConfiguration] PRIMARY KEY CLUSTERED ([idScanConfiguration]);
GO

/**
 * @primaryKey {pkScanOperation}
 * @keyType Object
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [pkScanOperation] PRIMARY KEY CLUSTERED ([idScanOperation]);
GO

/**
 * @primaryKey {pkIdentifiedFile}
 * @keyType Object
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [pkIdentifiedFile] PRIMARY KEY CLUSTERED ([idIdentifiedFile]);
GO

/**
 * @primaryKey {pkRemovalOperation}
 * @keyType Object
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [pkRemovalOperation] PRIMARY KEY CLUSTERED ([idRemovalOperation]);
GO

/**
 * @primaryKey {pkRemovalResult}
 * @keyType Object
 */
ALTER TABLE [functional].[removalResult]
ADD CONSTRAINT [pkRemovalResult] PRIMARY KEY CLUSTERED ([idRemovalResult]);
GO

/**
 * @primaryKey {pkScheduledCleanup}
 * @keyType Object
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [pkScheduledCleanup] PRIMARY KEY CLUSTERED ([idScheduledCleanup]);
GO

/**
 * @foreignKey {fkScanOperation_ScanConfiguration} Links scan operation to its configuration
 * @target {functional.scanConfiguration}
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [fkScanOperation_ScanConfiguration] FOREIGN KEY ([idScanConfiguration])
REFERENCES [functional].[scanConfiguration]([idScanConfiguration]);
GO

/**
 * @foreignKey {fkIdentifiedFile_ScanOperation} Links identified file to scan operation
 * @target {functional.scanOperation}
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [fkIdentifiedFile_ScanOperation] FOREIGN KEY ([idScanOperation])
REFERENCES [functional].[scanOperation]([idScanOperation]);
GO

/**
 * @foreignKey {fkRemovalOperation_ScanOperation} Links removal operation to scan operation
 * @target {functional.scanOperation}
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [fkRemovalOperation_ScanOperation] FOREIGN KEY ([idScanOperation])
REFERENCES [functional].[scanOperation]([idScanOperation]);
GO

/**
 * @foreignKey {fkRemovalResult_RemovalOperation} Links removal result to removal operation
 * @target {functional.removalOperation}
 */
ALTER TABLE [functional].[removalResult]
ADD CONSTRAINT [fkRemovalResult_RemovalOperation] FOREIGN KEY ([idRemovalOperation])
REFERENCES [functional].[removalOperation]([idRemovalOperation]);
GO

/**
 * @foreignKey {fkRemovalResult_IdentifiedFile} Links removal result to identified file
 * @target {functional.identifiedFile}
 */
ALTER TABLE [functional].[removalResult]
ADD CONSTRAINT [fkRemovalResult_IdentifiedFile] FOREIGN KEY ([idIdentifiedFile])
REFERENCES [functional].[identifiedFile]([idIdentifiedFile]);
GO

/**
 * @foreignKey {fkScheduledCleanup_ScanConfiguration} Links scheduled cleanup to configuration
 * @target {functional.scanConfiguration}
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [fkScheduledCleanup_ScanConfiguration] FOREIGN KEY ([idScanConfiguration])
REFERENCES [functional].[scanConfiguration]([idScanConfiguration]);
GO

/**
 * @check {chkScanOperation_Status} Validates scan operation status
 * @enum {0} Not Started
 * @enum {1} In Progress
 * @enum {2} Completed
 * @enum {3} Error
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [chkScanOperation_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @check {chkScanOperation_Progress} Validates progress percentage
 * @enum {0-100} Progress percentage
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [chkScanOperation_Progress] CHECK ([progress] BETWEEN 0 AND 100);
GO

/**
 * @check {chkRemovalOperation_RemovalMode} Validates removal mode
 * @enum {0} Recycle Bin
 * @enum {1} Permanent
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_RemovalMode] CHECK ([removalMode] BETWEEN 0 AND 1);
GO

/**
 * @check {chkRemovalOperation_Status} Validates removal operation status
 * @enum {0} Not Started
 * @enum {1} In Progress
 * @enum {2} Completed
 * @enum {3} Error
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @check {chkRemovalOperation_Progress} Validates progress percentage
 * @enum {0-100} Progress percentage
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_Progress] CHECK ([progress] BETWEEN 0 AND 100);
GO

/**
 * @check {chkScheduledCleanup_Frequency} Validates cleanup frequency
 * @enum {0} Daily
 * @enum {1} Weekly
 * @enum {2} Monthly
 * @enum {3} Custom
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_Frequency] CHECK ([frequency] BETWEEN 0 AND 3);
GO

/**
 * @check {chkScheduledCleanup_DayOfWeek} Validates day of week
 * @enum {1-7} Sunday to Saturday
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_DayOfWeek] CHECK ([dayOfWeek] IS NULL OR [dayOfWeek] BETWEEN 1 AND 7);
GO

/**
 * @check {chkScheduledCleanup_DayOfMonth} Validates day of month
 * @enum {1-31} Day of month
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_DayOfMonth] CHECK ([dayOfMonth] IS NULL OR [dayOfMonth] BETWEEN 1 AND 31);
GO

/**
 * @index {ixScanConfiguration_Account} Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanConfiguration_Account]
ON [functional].[scanConfiguration]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index {ixScanOperation_Account} Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Account]
ON [functional].[scanOperation]([idAccount]);
GO

/**
 * @index {ixScanOperation_Configuration} Lookup by configuration
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Configuration]
ON [functional].[scanOperation]([idAccount], [idScanConfiguration]);
GO

/**
 * @index {ixIdentifiedFile_Account} Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixIdentifiedFile_Account]
ON [functional].[identifiedFile]([idAccount]);
GO

/**
 * @index {ixIdentifiedFile_ScanOperation} Lookup by scan operation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixIdentifiedFile_ScanOperation]
ON [functional].[identifiedFile]([idAccount], [idScanOperation]);
GO

/**
 * @index {ixRemovalOperation_Account} Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalOperation_Account]
ON [functional].[removalOperation]([idAccount]);
GO

/**
 * @index {ixRemovalOperation_ScanOperation} Lookup by scan operation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalOperation_ScanOperation]
ON [functional].[removalOperation]([idAccount], [idScanOperation]);
GO

/**
 * @index {ixRemovalResult_Account} Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalResult_Account]
ON [functional].[removalResult]([idAccount]);
GO

/**
 * @index {ixRemovalResult_RemovalOperation} Lookup by removal operation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalResult_RemovalOperation]
ON [functional].[removalResult]([idAccount], [idRemovalOperation]);
GO

/**
 * @index {ixScheduledCleanup_Account} Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScheduledCleanup_Account]
ON [functional].[scheduledCleanup]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index {ixScheduledCleanup_Active} Lookup active schedules
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixScheduledCleanup_Active]
ON [functional].[scheduledCleanup]([idAccount], [active])
WHERE [deleted] = 0;
GO