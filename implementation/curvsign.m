function signedv = curvsign (v)
    aux = v;
    signedv = blanks(length(v));
    % The following ranges are considered zero values
    % 1e-13 (or more?) for Topography
    % 1e-19 for Geoid Anomalies
    % 1e-?? for Crustal Thickness
    % At the moment they are heuristics.
    % There should be a criterion based on information extracted from data
    % that establishes the bounds of the range in each case.
    %aux( -1e-19 < v & v < 1e-19 ) = NaN;
    %aux( abs(v) < 1e-30 ) = NaN;
    %aux( abs(v) < abs(min(v))^2 ) = NaN;
    signedv( isnan(aux) ) = '-';
    signedv( aux < 0 ) = '0';
    signedv( aux > 0 ) = '1';
