---@author: Xpecya

local syntax = require "syntax";
local __GENERATOR__ = require "generator";

local function getReader(fileName)
    local file = io.open(fileName);
    local line = 1;
    local position = 1;
    local newLine;

    if file == nil then
        error("source file doesn't exist!");
    end

    return {
        next = function()
            local result = file:read(1);
            if newLine then
                line = line + 1;
                position = 1;
                newLine = nil;
            end
            if result == "\n" then
                newLine = true;
            else
                position = position + 1;
            end
            return result;
        end,
        error = function(message)
            error(string.format("error at line %d, position %d: %s!\r\n", line, position, message));
        end
    };
end

local function toString(table, number)
    local result = "{"
    local addComma = false;
    local spaces = "\r\n";
    if number == nil then
        number = 1;
    end
    for i = 1, number - 1 do
        spaces = spaces .. "\t";
    end
    local startSpaces = spaces .. "\t";
    for k, v in pairs(table) do
        if addComma then
            result = result .. ',';
        else
            addComma = true;
        end
        result = result .. startSpaces .. '"' .. k .. '" = ';
        if v == true or v == false then
           result = result .. tostring(v)
        elseif v == nil then
            result = result .. "nil"
        else
            local vType = type(v);
            if vType == "number" then
                result = result .. v;
            elseif vType == "string" then
                result = result .. '"' .. v .. '"';
            elseif vType == "table" then
                result = result .. toString(v, number + 1);
            end
        end
    end
    result = result .. spaces .. "}"
    return result;
end

local fileName = arg[1];
local reader = getReader(fileName);
local tree = syntax(reader);
print(toString(tree));
local start = fileName:find("%.lua");
local resultFileName = fileName:sub(1, start - 1) .. ".ll";
__GENERATOR__(tree, resultFileName);
