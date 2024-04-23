classdef tScienceCDFOut < MAGIOTestCase
% TSCIENCECDFOUT Unit tests for "mag.io.out.ScienceCDF" class.

    methods (TestClassSetup)

        % Check that SPDF CDF Toolbox is installed.
        function checkSPDFCDFToolbox(testCase)
            testCase.assumeTrue(exist("spdfcdfinfo", "file") == 2, "SPDF CDF Toolbox not installed. Test skipped.");
        end
    end

    methods (Test)

        % Test that export file name is generated correctly.
        function getExportFileName(testCase)

            % Set up.
            metaData = mag.meta.Science(Mode = "Burst", Sensor = "FIB", Timestamp = datetime("now"));
            data = mag.Science(timetable.empty(), metaData);

            expectedFileName = compose("imap_mag_l2b_burst-magi_%s_v2.cdf", datetime("today", Format = "yyyyMMdd"));

            % Exercise.
            format = mag.io.out.ScienceCDF(Level = "L2b", Version = "V2");
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that conversion to export format returns expected data.
        function convertToExportFormat(testCase)

            % Set up.
            data = mag.Science(timetable.empty(), mag.meta.Science());

            % Exercise.
            format = mag.io.out.ScienceCDF();
            exportData = format.convertToExportFormat(data);

            % Verify.
            testCase.verifySameHandle(exportData, data, "Export data should be identical to input.");
        end

        % Test that "write" method calls SPDF CDF APIs.
        function write(testCase)

            % Set up.
            referenceFile = fullfile(testCase.TestDataLocation, "imap_mag_l1a_burst-magi_20240314_v001.cdf");
            expectedExportData = mag.io.import(FileNames = referenceFile, Format = mag.io.in.ScienceCDF(Timestamp = "epoch", Field = "vectors", Range = "vectors"));

            % Exercise.
            format = mag.io.out.ScienceCDF(Level = "L1b", SkeletonLocation = testCase.TestDataLocation, Version = "V001");

            fileName = fullfile(testCase.WorkingDirectory.Folder, format.getExportFileName(expectedExportData));
            format.write(fileName, expectedExportData);

            % Verify.
            testCase.assertThat(@() isfile(fileName), matlab.unittest.constraints.Eventually(matlab.unittest.constraints.IsTrue()));

            actualExportData = mag.io.import(FileNames = fileName, Format = mag.io.in.ScienceCDF());
            testCase.assertSize(actualExportData.Data, size(expectedExportData.Data), "Exported data size should match expectation.");

            testCase.verifyLessThanOrEqual(actualExportData.Time - expectedExportData.Time, milliseconds(1), "Timestamps should match expectation.");
            testCase.verifyEqual(actualExportData.XYZ, expectedExportData.XYZ, "Field should match expectation.");
            testCase.verifyEqual(actualExportData.Range, expectedExportData.Range, "Range should match expectation.");

            testCase.verifyEqual(actualExportData.MetaData, expectedExportData.MetaData, "Meta data should match expectation.");
        end
    end
end
