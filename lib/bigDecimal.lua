---@requirement: MetatableBuilder
---@author: Xpecya

local MetatableBuilder = require "aul.metatableBuilder.MetatableBuilder";

local function valueOfOct(input)
    local pointIndex = input:find("%.");
    local eIndex = input:find("[eE]");
    local div;
    if pointIndex ~= nil then
        local numberEnd;
        if eIndex == nil then
            numberEnd = input:len();
        elseif eIndex == 1 then
            error("e/E can't be the first letter in a number!");
        else
            numberEnd = eIndex - 1;
        end
        div = 10 ^ (input:sub(pointIndex, numberEnd):len() - 1);
    else
        div = 1;
    end
    
end

local function valueOfHex(input)

end

local function valueOfString(input)
    local first = input:char(1);
    if first == "0" then
        -- maybe hex
        local second = input:char(2);
        if second == 'x' or second == 'X' then
            -- must be hex
            return valueOfHex(input:sub(3));
        end
    end
    return valueOfOct(input);
end

return setmetatable({}, MetatableBuilder.new().immutable().index({
    valueOf = function(input)
        local inputType = type(input);
        if inputType ~= "number" and inputType ~= "string" then
            error("input type must be number or string!");
        end
        if inputType == "number" then
            input = tostring(input);
        end
        return valueOfString(input);
    end
}).build());
