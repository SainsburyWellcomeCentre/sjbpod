function out = truncExp(offset, rate, trunc)

tmp = trunc;
while tmp >= trunc
    tmp = exprnd(rate);
end

out = tmp + offset;