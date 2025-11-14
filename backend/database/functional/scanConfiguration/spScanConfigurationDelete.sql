/**
 * @summary
 * Soft deletes a scan configuration
 *
 * @procedure spScanConfigurationDelete
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - DELETE /api/v1/internal/scan-configuration/:id
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
 * - Valid deletion of existing configuration
 * - Error when configuration doesn't exist
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationDelete]
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

  BEGIN TRY
    BEGIN TRAN;

      UPDATE [functional].[scanConfiguration]
      SET
        [deleted] = 1,
        [dateModified] = GETUTCDATE()
      WHERE [idScanConfiguration] = @idScanConfiguration
        AND [idAccount] = @idAccount;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO