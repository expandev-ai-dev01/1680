/**
 * @load {scanConfiguration}
 */
INSERT INTO [functional].[scanConfiguration]
([idAccount], [name], [description], [extensionsJson], [namePatternsJson], [minimumAgeDays], [minimumSizeBytes], [includeSystemFiles])
VALUES
(1, 'Default Configuration', 'Default temporary file identification configuration', '["tmp","temp","cache","bak","log","~","swp"]', '["temp*","*_temp","*_old","*_bak","~*"]', 7, 0, 0);
GO