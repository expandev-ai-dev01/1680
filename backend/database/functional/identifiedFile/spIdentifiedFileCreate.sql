/**
 * @summary
 * Records a file identified as temporary during scan operation
 *
 * @procedure spIdentifiedFileCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/identified-file
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
 * @param {NVARCHAR(500)} filePath
 *   - Required: Yes
 *   - Description: Complete file path
 *
 * @param {NVARCHAR(255)} fileName
 *   - Required: Yes
 *   - Description: File name
 *
 * @param {NVARCHAR(50)} fileExtension
 *   - Required: Yes
 *   - Description: File extension
 *
 * @param {BIGINT} fileSizeBytes
 *   - Required: Yes
 *   - Description: File size in bytes
 *
 * @param {DATETIME2} fileModifiedDate
 *   - Required: Yes
 *   - Description: File last modified date
 *
 * @param {NVARCHAR(200)} identificationCriteria
 *   - Required: Yes
 *   - Description: Criteria that identified this file
 *
 * @testScenarios
 * - Valid file identification
 * - Validation of scan operation existence
 */
CREATE OR ALTER PROCEDURE [functional].[spIdentifiedFileCreate]
  @idAccount INTEGER,
  @idScanOperation INTEGER,
  @filePath NVARCHAR(500),
  @fileName NVARCHAR(255),
  @fileExtension NVARCHAR(50),
  @fileSizeBytes BIGINT,
  @fileModifiedDate DATETIME2,
  @identificationCriteria NVARCHAR(200)
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

      INSERT INTO [functional].[identifiedFile]
      ([idAccount], [idScanOperation], [filePath], [fileName], [fileExtension], [fileSizeBytes], [fileModifiedDate], [identificationCriteria])
      VALUES
      (@idAccount, @idScanOperation, @filePath, @fileName, @fileExtension, @fileSizeBytes, @fileModifiedDate, @identificationCriteria);

      /**
       * @output {IdentifiedFile, 1, n}
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
      WHERE [idnFil].[idIdentifiedFile] = SCOPE_IDENTITY();

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO