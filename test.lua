local function valueOfOct(input)
    local pointIndex = input:find("%.");
    local eIndex = input:find("[eE]");
    if pointIndex ~= nil then
        local numberEnd;
        if eIndex == nil then
            numberEnd = input:len();
        elseif eIndex == 1 then
            error("e/E can't be the first letter in a number!");
        else
            numberEnd = eIndex - 1;
        end
        local div = 10 ^ (input:sub(pointIndex, numberEnd):len() - 1);
        print(div);
    end
end

local test = "1234.5e6";
valueOfOct(test);
