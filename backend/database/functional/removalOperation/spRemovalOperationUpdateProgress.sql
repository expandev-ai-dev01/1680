/**
 * @summary
 * Updates removal operation progress and statistics
 *
 * @procedure spRemovalOperationUpdateProgress
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PATCH /api/v1/internal/removal-operation/:id/progress
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idRemovalOperation
 *   - Required: Yes
 *   - Description: Operation identifier
 *
 * @param {INT} status
 *   - Required: Yes
 *   - Description: Operation status
 *
 * @param {INT} progress
 *   - Required: Yes
 *   - Description: Progress percentage
 *
 * @param {INT} totalFilesRemoved
 *   - Required: Yes
 *   - Description: Total files removed
 *
 * @param {INT} totalFilesWithError
 *   - Required: Yes
 *   - Description: Total files with errors
 *
 * @param {BIGINT} spaceFreedBytes
 *   - Required: Yes
 *   - Description: Space freed in bytes
 *
 * @testScenarios
 * - Valid progress update
 * - Completion status update
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationUpdateProgress]
  @idAccount INTEGER,
  @idRemovalOperation INTEGER,
  @status INTEGER,
  @progress INTEGER,
  @totalFilesRemoved INTEGER,
  @totalFilesWithError INTEGER,
  @spaceFreedBytes BIGINT
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
   * @throw {idRemovalOperationRequired}
   */
  IF @idRemovalOperation IS NULL
  BEGIN
    ;THROW 51000, 'idRemovalOperationRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   * @throw {removalOperationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[removalOperation] [rmvOpr]
    WHERE [rmvOpr].[idRemovalOperation] = @idRemovalOperation
      AND [rmvOpr].[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'removalOperationDoesntExist', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      UPDATE [functional].[removalOperation]
      SET
        [status] = @status,
        [progress] = @progress,
        [totalFilesRemoved] = @totalFilesRemoved,
        [totalFilesWithError] = @totalFilesWithError,
        [spaceFreedBytes] = @spaceFreedBytes,
        [dateCompleted] = CASE WHEN @status IN (2, 3) THEN GETUTCDATE() ELSE [dateCompleted] END
      WHERE [idRemovalOperation] = @idRemovalOperation
        AND [idAccount] = @idAccount;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO