/**
 * @summary
 * Updates scan operation progress and statistics
 *
 * @procedure spScanOperationUpdateProgress
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PATCH /api/v1/internal/scan-operation/:id/progress
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanOperation
 *   - Required: Yes
 *   - Description: Operation identifier
 *
 * @param {INT} status
 *   - Required: Yes
 *   - Description: Operation status (0=Not Started, 1=In Progress, 2=Completed, 3=Error)
 *
 * @param {INT} progress
 *   - Required: Yes
 *   - Description: Progress percentage (0-100)
 *
 * @param {INT} totalFilesAnalyzed
 *   - Required: Yes
 *   - Description: Total files analyzed
 *
 * @param {INT} totalFilesIdentified
 *   - Required: Yes
 *   - Description: Total files identified as temporary
 *
 * @param {BIGINT} potentialSpaceBytes
 *   - Required: Yes
 *   - Description: Potential space that can be freed
 *
 * @testScenarios
 * - Valid progress update
 * - Completion status update
 * - Error status update
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationUpdateProgress]
  @idAccount INTEGER,
  @idScanOperation INTEGER,
  @status INTEGER,
  @progress INTEGER,
  @totalFilesAnalyzed INTEGER,
  @totalFilesIdentified INTEGER,
  @potentialSpaceBytes BIGINT
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

      UPDATE [functional].[scanOperation]
      SET
        [status] = @status,
        [progress] = @progress,
        [totalFilesAnalyzed] = @totalFilesAnalyzed,
        [totalFilesIdentified] = @totalFilesIdentified,
        [potentialSpaceBytes] = @potentialSpaceBytes,
        [dateCompleted] = CASE WHEN @status IN (2, 3) THEN GETUTCDATE() ELSE [dateCompleted] END
      WHERE [idScanOperation] = @idScanOperation
        AND [idAccount] = @idAccount;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO