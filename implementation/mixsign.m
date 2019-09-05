function classes = mixsign (sgnv1,sgnv2)
    aux = arrayfun(@(x) [sgnv1(x) sgnv2(x)],1:length(sgnv1),'un',0);
    classes = NaN(size(aux));
    for i=1:length(aux)
        if ~isequal(regexp(aux(i),'\-+'),{[]})
            classes(i) = NaN;
        else
            classes(i) = bin2dec(aux(i));
        end
    end
    classes = classes + 1;
    % Uncomment to replace NaNs with zeros
    %classes(isnan(classes)) = 0;