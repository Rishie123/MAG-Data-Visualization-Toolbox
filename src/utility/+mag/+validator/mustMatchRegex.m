function mustMatchRegex(value, pattern)
% MUSTMATCHREGEX Validator to check value matches regex pattern.

    if ~isempty(value) && ~matches(value, regexpPattern(pattern))
        error("Value ""%s"" does not match patter ""%s"".", value, pattern);
    end
end
