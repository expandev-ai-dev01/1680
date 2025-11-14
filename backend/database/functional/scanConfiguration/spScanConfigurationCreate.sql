/**
 * @summary
 * Creates a new scan configuration with specified criteria for identifying temporary files
 *
 * @procedure spScanConfigurationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/scan-configuration
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
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
 * - Valid creation with all parameters
 * - Validation of required parameters
 * - Validation of minimum age >= 0
 * - Validation of minimum size >= 0
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationCreate]
  @idAccount INTEGER,
  @name NVARCHAR(100),
  @description NVARCHAR(500) = '',
  @extensionsJson NVARCHAR(MAX),
  @namePatternsJson NVARCHAR(MAX),
  @minimumAgeDays INTEGER = 7,
  @minimumSizeBytes INTEGER = 0,
  @includeSystemFiles BIT = 0
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
   * @throw {nameRequired}
   */
  IF @name IS NULL OR @name = ''
  BEGIN
    ;THROW 51000, 'nameRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {extensionsJsonRequired}
   */
  IF @extensionsJson IS NULL OR @extensionsJson = ''
  BEGIN
    ;THROW 51000, 'extensionsJsonRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {namePatternsJsonRequired}
   */
  IF @namePatternsJson IS NULL OR @namePatternsJson = ''
  BEGIN
    ;THROW 51000, 'namePatternsJsonRequired', 1;
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

      INSERT INTO [functional].[scanConfiguration]
      ([idAccount], [name], [description], [extensionsJson], [namePatternsJson], [minimumAgeDays], [minimumSizeBytes], [includeSystemFiles])
      VALUES
      (@idAccount, @name, @description, @extensionsJson, @namePatternsJson, @minimumAgeDays, @minimumSizeBytes, @includeSystemFiles);

      /**
       * @output {ScanConfiguration, 1, n}
       * @column {INT} idScanConfiguration - Configuration identifier
       * @column {NVARCHAR} name - Configuration name
       * @column {NVARCHAR} description - Configuration description
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
        [scnCfg].[dateCreated]
      FROM [functional].[scanConfiguration] [scnCfg]
      WHERE [scnCfg].[idScanConfiguration] = SCOPE_IDENTITY();

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO