/**
 * @summary
 * Updates an existing scan configuration
 *
 * @procedure spScanConfigurationUpdate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PUT /api/v1/internal/scan-configuration/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanConfiguration
 *   - Required: Yes
 *   - Description: Configuration identifier
 *
 * @param {NVARCHAR(100)} name
 *   - Required: Yes
 *   - Description: Configuration name
 *
 * @param {NVARCHAR(500)} description
 *   - Required: No
 *   - Description: Configuration description
 *
 * @param {NVARCHAR(MAX)} extensionsJson
 *   - Required: Yes
 *   - Description: JSON array of file extensions
 *
 * @param {NVARCHAR(MAX)} namePatternsJson
 *   - Required: Yes
 *   - Description: JSON array of name patterns
 *
 * @param {INT} minimumAgeDays
 *   - Required: Yes
 *   - Description: Minimum file age in days
 *
 * @param {INT} minimumSizeBytes
 *   - Required: Yes
 *   - Description: Minimum file size in bytes
 *
 * @param {BIT} includeSystemFiles
 *   - Required: Yes
 *   - Description: Include system files flag
 *
 * @testScenarios
 * - Valid update with all parameters
 * - Error when configuration doesn't exist
 * - Validation of business rules
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationUpdate]
  @idAccount INTEGER,
  @idScanConfiguration INTEGER,
  @name NVARCHAR(100),
  @description NVARCHAR(500) = '',
  @extensionsJson NVARCHAR(MAX),
  @namePatternsJson NVARCHAR(MAX),
  @minimumAgeDays INTEGER,
  @minimumSizeBytes INTEGER,
  @includeSystemFiles BIT
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
   * @throw {nameRequired}
   */
  IF @name IS NULL OR @name = ''
  BEGIN
    ;THROW 51000, 'nameRequired', 1;
  END;

  /**
   * @validation Business rule validation
   * @throw {minimumAgeMustBeEqualOrGreaterZero}
   */
  IF @minimumAgeDays < 0
  BEGIN
    ;THROW 51000, 'minimumAgeMustBeEqualOrGreaterZero', 1;
  END;

  /**
   * @validation Business rule validation
   * @throw {minimumSizeMustBeEqualOrGreaterZero}
   */
  IF @minimumSizeBytes < 0
  BEGIN
    ;THROW 51000, 'minimumSizeMustBeEqualOrGreaterZero', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      UPDATE [functional].[scanConfiguration]
      SET
        [name] = @name,
        [description] = @description,
        [extensionsJson] = @extensionsJson,
        [namePatternsJson] = @namePatternsJson,
        [minimumAgeDays] = @minimumAgeDays,
        [minimumSizeBytes] = @minimumSizeBytes,
        [includeSystemFiles] = @includeSystemFiles,
        [dateModified] = GETUTCDATE()
      WHERE [idScanConfiguration] = @idScanConfiguration
        AND [idAccount] = @idAccount;

      /**
       * @output {ScanConfiguration, 1, n}
       * @column {INT} idScanConfiguration - Configuration identifier
       */
      SELECT
        [scnCfg].[idScanConfiguration],
        [scnCfg].[name],
        [scnCfg].[description],
        [scnCfg].[extensionsJson],
        [scnCfg].[namePatternsJson],
        [scnCfg].[minimumAgeDays],
        [scnCfg].[minimumSizeBytes],
        [scnCfg].[includeSystemFiles],
        [scnCfg].[dateCreated],
        [scnCfg].[dateModified]
      FROM [functional].[scanConfiguration] [scnCfg]
      WHERE [scnCfg].[idScanConfiguration] = @idScanConfiguration
        AND [scnCfg].[idAccount] = @idAccount;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO