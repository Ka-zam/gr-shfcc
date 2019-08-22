function span = rrcspan( beta )
if beta < 0.2
    span = 30;
elseif beta < 0.65
    span = -floor( beta*44 ) + 33;
    if mod(span,2) == 1
        span = span + 1;
    end
else
    span =  4;   
end