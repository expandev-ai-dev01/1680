/**
 * @summary
 * Lists all scan configurations for an account
 *
 * @procedure spScanConfigurationList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-configuration
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @testScenarios
 * - List all configurations for valid account
 * - Empty result for account with no configurations
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationList]
  @idAccount INTEGER
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
   * @output {ScanConfigurationList, n, n}
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
    [scnCfg].[dateCreated],
    [scnCfg].[dateModified]
  FROM [functional].[scanConfiguration] [scnCfg]
  WHERE [scnCfg].[idAccount] = @idAccount
    AND [scnCfg].[deleted] = 0
  ORDER BY [scnCfg].[dateCreated] DESC;
END;
GO