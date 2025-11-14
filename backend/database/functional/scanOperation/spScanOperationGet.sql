/**
 * @summary
 * Retrieves a specific scan operation with its identified files
 *
 * @procedure spScanOperationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-operation/:id
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
 * @testScenarios
 * - Retrieve existing operation with files
 * - Error when operation doesn't exist
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationGet]
  @idAccount INTEGER,
  @idScanOperation INTEGER
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
    [scnOpr].[dateStarted],
    [scnOpr].[dateCompleted]
  FROM [functional].[scanOperation] [scnOpr]
  WHERE [scnOpr].[idScanOperation] = @idScanOperation
    AND [scnOpr].[idAccount] = @idAccount;

  /**
   * @output {IdentifiedFiles, n, n}
   * @column {INT} idIdentifiedFile - File identifier
   */
  SELECT
    [idnFil].[idIdentifiedFile],
    [idnFil].[filePath],
    [idnFil].[fileName],
    [idnFil].[fileExtension],
    [idnFil].[fileSizeBytes],
    [idnFil].[fileModifiedDate],
    [idnFil].[identificationCriteria],
    [idnFil].[selected],
    [idnFil].[dateIdentified]
  FROM [functional].[identifiedFile] [idnFil]
  WHERE [idnFil].[idScanOperation] = @idScanOperation
    AND [idnFil].[idAccount] = @idAccount
  ORDER BY [idnFil].[fileSizeBytes] DESC;
END;
GO