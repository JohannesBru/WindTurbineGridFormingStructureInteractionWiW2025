function p = selectTestCasePaper(p,Nr)

    switch Nr
        case 1
            % Phase Jump 2 degree positive
            p.TestCase.Nr = 1; 
            p.TestCase.direction = "pos";
        case 2
            % Angle Oscillation 0.2 Hz 
            p.TestCase.Nr = 14; 
            p.TestCase.direction = "neg";
        case 3
            % Angle Oscillation 0.326 Hz
            p.TestCase.Nr = 15; 
            p.TestCase.direction = "neg";
        case 4
            % Angle Oscillation 0.4 Hz
            p.TestCase.Nr = 16; 
            p.TestCase.direction = "neg";    
        case 5
            % FNN
            p.TestCase.Nr = 8; 
            p.TestCase.direction = "neg";

    end

end

