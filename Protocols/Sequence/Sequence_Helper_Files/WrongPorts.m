function wrong = WrongPorts(Port,PrevPort,Port1)
%returns all the port numbers that are inncorrect except for port 1 as
%poking here doesnt lead to punish, just resets to 'waitforsecondpoke' state  

if Port1 == 1
    if Port == 1
        wrong = 2345678;
    elseif Port == 2
        wrong = 345678;
    elseif Port == 3
        wrong = 245678;
    elseif Port == 4
        wrong = 235678;
    elseif Port == 5
        wrong = 234678;
    elseif Port == 6
        wrong = 234578;
    elseif Port == 7
        wrong = 234568;
    elseif Port == 8
        wrong = 234567;
    end
    
elseif Port1 == 2
    if Port == 1
        wrong = 345678;
    elseif Port == 2
        wrong = 1345678;
    elseif Port == 3
        wrong = 145678;
    elseif Port == 4
        wrong = 135678;
    elseif Port == 5
        wrong = 134678;
    elseif Port == 6
        wrong = 134578;
    elseif Port == 7
        wrong = 134568;
    elseif Port == 8
        wrong = 134567;
    end
    
elseif Port1 == 3
    if Port == 1
        wrong = 245678;
    elseif Port == 2
        wrong = 145678;
    elseif Port == 3
        wrong = 1245678;
    elseif Port == 4
        wrong = 125678;
    elseif Port == 5
        wrong = 124678;
    elseif Port == 6
        wrong = 124578;
    elseif Port == 7
        wrong = 124568;
    elseif Port == 8
        wrong = 124567;
    end
    
elseif Port1 == 4
    if Port == 1
        wrong = 235678;
    elseif Port == 2
        wrong = 135678;
    elseif Port == 3
        wrong = 125678;
    elseif Port == 4
        wrong = 1235678;
    elseif Port == 5
        wrong = 123678;
    elseif Port == 6
        wrong = 123578;
    elseif Port == 7
        wrong = 123568;
    elseif Port == 8
        wrong = 123567;
    end
elseif Port1 == 5
    if Port == 1
        wrong = 234678;
    elseif Port == 2
        wrong = 134678;
    elseif Port == 3
        wrong = 124678;
    elseif Port == 4
        wrong = 123678;
    elseif Port == 5
        wrong = 1234678;
    elseif Port == 6
        wrong = 123478;
    elseif Port == 7
        wrong = 123468;
    elseif Port == 8
        wrong = 123467;
    end
    
elseif Port1 == 6
    if Port == 1
        wrong = 234578;
    elseif Port == 2
        wrong = 134578;
    elseif Port == 3
        wrong = 124578;
    elseif Port == 4
        wrong = 123578;
    elseif Port == 5
        wrong = 123478;
    elseif Port == 6
        wrong = 1234578;
    elseif Port == 7
        wrong = 123458;
    elseif Port == 8
        wrong = 123457;
    end
    
elseif Port1 == 7
    if Port == 1
        wrong = 234568;
    elseif Port == 2
        wrong = 134568;
    elseif Port == 3
        wrong = 124568;
    elseif Port == 4
        wrong = 123568;
    elseif Port == 5
        wrong = 123468;
    elseif Port == 6
        wrong = 123458;
    elseif Port == 7
        wrong = 1234568;
    elseif Port == 8
        wrong = 123456;
    end
    
elseif Port1 == 8
    if Port == 1
        wrong = 234567;
    elseif Port == 2
        wrong = 134567;
    elseif Port == 3
        wrong = 124567;
    elseif Port == 4
        wrong = 123567;
    elseif Port == 5
        wrong = 123467;
    elseif Port == 6
        wrong = 123457;
    elseif Port == 7
        wrong = 123456;
    elseif Port == 8
        wrong = 1234567;
    end
end

if PrevPort > 0
    wrongtemp = num2str(wrong);
    indx = find(wrongtemp == num2str(PrevPort));
    wrongtemp(indx) =  [];
    wrong = str2num(wrongtemp); 
end

end



