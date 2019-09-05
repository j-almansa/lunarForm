function r = paramn(distance)
    r = ones(size(distance));
    switch r
        case distance < 1
            r = 2*r;
        case (1     <= distance) & (distance < 10)
            r = 3*r;
        case (10    <= distance) & (distance < 100)
            r = 4*r;
        case (100   <= distance) & (distance < 1000)
            r = 5*r;
        case (1000  <= distance) & (distance < 5000)
            r = 6*r;
        case (5000  <= distance) & (distance < 10000)
            r = 7*r;
        case (10000 <= distance) & (distance < 75000)
            r = 8*r;
        otherwise
            r = 9*r;
    end
