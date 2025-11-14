/**
 * @summary
 * Retrieves a specific scan configuration by ID
 *
 * @procedure spScanConfigurationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-configuration/:id
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
 * @testScenarios
 * - Retrieve existing configuration
 * - Error when configuration doesn't exist
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationGet]
  @idAccount INTEGER,
  @idScanConfiguration INTEGER
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
   * @output {ScanConfiguration, 1, n}
   * @column {INT} idScanConfiguration - Configuration identifier
   * @column {NVARCHAR} name - Configuration name
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
    AND [scnCfg].[idAccount] = @idAccount
    AND [scnCfg].[deleted] = 0;
END;
GO