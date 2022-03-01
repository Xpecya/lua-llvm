---@author Xpecya

----------------------------------------generator.h----------------------------------------

--- generate the llvm-ir code from the tree
---@param tree table ast
---@param name string result file name
local function generate(tree, name)
end

----------------------------------------generator.h----------------------------------------

local function getInteger(input)
    local length = #input;
    local index = 1;
    local result = 0;
    for i = length, 1, -1 do
        local char = string.byte(input, index);
        local number = char - string.byte('0');
        result = result + number * 10 ^ (i - 1);
        index = index + 1;
    end
    return result;
end

local function createFunction(name, tree, context)
    local functionDefine = string.format("define dso_local i32 @%s() {\r\n\t", name);
    local statements = tree.statements;
    --- todo add statements
    local returnStatement = tree.returnStatement;
    local resultValues = returnStatement.value;
    --- todo multiple return
    local first = resultValues[1];
    if first.type == "integer" then
        functionDefine = functionDefine .. string.format("ret i32 %d", getInteger(first.integer));
    end
    return functionDefine .. "\r\n}\r\n";
end

generate = function(tree, name, context)
    if name ~= nil then
        local resultFile = io.open(name, "w");
        local resultString = generate(tree);
        resultFile:write(resultString);
    elseif context == nil then
        return generate(tree, nil, {
            functionName = "main"
        });
    else
        return createFunction(context.functionName, tree, context);
    end
end

return generate;
