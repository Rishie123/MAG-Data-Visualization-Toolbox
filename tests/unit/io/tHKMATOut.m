classdef tHKMATOut < MAGIOTestCase
% THKMATOUT Unit tests for "mag.io.out.HKMAT" class.

    methods (Test)

        % Test that export file name is generated correctly.
        function getExportFileName(testCase)

            % Set up.
            metaData = mag.meta.HK(Type = "SID15", Timestamp = datetime("now"));
            data = mag.hk.SID15(timetable.empty(), metaData);

            expectedFileName = compose("%s HK.mat", datetime("now", Format = "ddMMyy-HHmm"));

            % Exercise.
            format = mag.io.out.HKMAT();
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that conversion to export format returns expected data.
        function convertToExportFormat(testCase)

            % Set up.
            metaData = mag.meta.HK(Type = "SID15", Timestamp = datetime("now"));

            rawData = timetable([datetime("yesterday"); datetime("today")], [1; 2], [3; 4], VariableNames = ["A", "B"]);
            data = mag.hk.SID15(rawData, metaData);

            % Exercise.
            format = mag.io.out.HKMAT();
            exportData = format.convertToExportFormat(data);

            % Verify.
            testCase.assertClass(exportData, "struct", "Export data should be a ""struct"".");
            testCase.assertThat(exportData, mag.test.IsField("HK"), """HK"" field should exist.");

            hk = exportData.HK;
            testCase.assertThat(hk, mag.test.IsField("SID15"), """SID15"" field should exist.");

            sid15 = hk.SID15;
            testCase.assertThat(sid15, mag.test.IsField("Time"), """Time"" field should exist.");
            testCase.assertThat(sid15, mag.test.IsField("A"), """A"" field should exist.");
            testCase.assertThat(sid15, mag.test.IsField("B"), """B"" field should exist.");

            testCase.verifyEqual(sid15.Time, [datetime("yesterday"); datetime("today")], """Time"" value should match expectation.");
            testCase.verifyEqual(sid15.A, [1; 2], """A"" value should match expectation.");
            testCase.verifyEqual(sid15.B, [3; 4], """B"" value should match expectation.");
        end
    end
end
