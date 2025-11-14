/**
 * @summary
 * Creates a new scan operation to analyze files in a directory
 *
 * @procedure spScanOperationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/scan-operation
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanConfiguration
 *   - Required: Yes
 *   - Description: Configuration to use for scanning
 *
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Directory path to scan
 *
 * @param {BIT} includeSubdirectories
 *   - Required: Yes
 *   - Description: Include subdirectories flag
 *
 * @testScenarios
 * - Valid creation with all parameters
 * - Validation of configuration existence
 * - Validation of directory path
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationCreate]
  @idAccount INTEGER,
  @idScanConfiguration INTEGER,
  @directoryPath NVARCHAR(500),
  @includeSubdirectories BIT = 1
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Required parameter validation
   * @throw {idAccountRequired}
   */
  IF @idAccount IS NULL
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {idScanConfigurationRequired}
   */
  IF @idScanConfiguration IS NULL
  BEGIN
    ;THROW 51000, 'idScanConfigurationRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   * @throw {scanConfigurationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[scanConfiguration] [scnCfg]
    WHERE [scnCfg].[idScanConfiguration] = @idScanConfiguration
      AND [scnCfg].[idAccount] = @idAccount
      AND [scnCfg].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'scanConfigurationDoesntExist', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {directoryPathRequired}
   */
  IF @directoryPath IS NULL OR @directoryPath = ''
  BEGIN
    ;THROW 51000, 'directoryPathRequired', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      INSERT INTO [functional].[scanOperation]
      ([idAccount], [idScanConfiguration], [directoryPath], [includeSubdirectories], [status])
      VALUES
      (@idAccount, @idScanConfiguration, @directoryPath, @includeSubdirectories, 0);

      /**
       * @output {ScanOperation, 1, n}
       * @column {INT} idScanOperation - Operation identifier
       */
      SELECT
        [scnOpr].[idScanOperation],
        [scnOpr].[idScanConfiguration],
        [scnOpr].[directoryPath],
        [scnOpr].[includeSubdirectories],
        [scnOpr].[status],
        [scnOpr].[progress],
        [scnOpr].[totalFilesAnalyzed],
        [scnOpr].[totalFilesIdentified],
        [scnOpr].[potentialSpaceBytes],
        [scnOpr].[dateStarted]
      FROM [functional].[scanOperation] [scnOpr]
      WHERE [scnOpr].[idScanOperation] = SCOPE_IDENTITY();

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO