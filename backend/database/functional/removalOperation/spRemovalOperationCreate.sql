/**
 * @summary
 * Creates a new removal operation for selected files
 *
 * @procedure spRemovalOperationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/removal-operation
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanOperation
 *   - Required: Yes
 *   - Description: Scan operation identifier
 *
 * @param {INT} removalMode
 *   - Required: Yes
 *   - Description: Removal mode (0=Recycle Bin, 1=Permanent)
 *
 * @testScenarios
 * - Valid creation with recycle bin mode
 * - Valid creation with permanent mode
 * - Validation of scan operation existence
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationCreate]
  @idAccount INTEGER,
  @idScanOperation INTEGER,
  @removalMode INTEGER = 0
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
   * @throw {idScanOperationRequired}
   */
  IF @idScanOperation IS NULL
  BEGIN
    ;THROW 51000, 'idScanOperationRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   * @throw {scanOperationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[scanOperation] [scnOpr]
    WHERE [scnOpr].[idScanOperation] = @idScanOperation
      AND [scnOpr].[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'scanOperationDoesntExist', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      INSERT INTO [functional].[removalOperation]
      ([idAccount], [idScanOperation], [removalMode], [status])
      VALUES
      (@idAccount, @idScanOperation, @removalMode, 0);

      /**
       * @output {RemovalOperation, 1, n}
       * @column {INT} idRemovalOperation - Operation identifier
       */
      SELECT
        [rmvOpr].[idRemovalOperation],
        [rmvOpr].[idScanOperation],
        [rmvOpr].[removalMode],
        [rmvOpr].[status],
        [rmvOpr].[progress],
        [rmvOpr].[totalFilesRemoved],
        [rmvOpr].[totalFilesWithError],
        [rmvOpr].[spaceFreedBytes],
        [rmvOpr].[dateStarted]
      FROM [functional].[removalOperation] [rmvOpr]
      WHERE [rmvOpr].[idRemovalOperation] = SCOPE_IDENTITY();

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO