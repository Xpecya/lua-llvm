---@author Xpecya

----------------------------------------ast.h----------------------------------------

--- get ast
---@param reader table file reader
---@param tree table unfinished tree
---@return table the hole tree
local function ast(reader, tree)
end;

--- call at default zone
--- when next item is '-'
--- it could be a comment line or a comment block
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the hole ast
local function comment(reader, tree)
end;

--- call at comment zone
--- when the starting items are --[
--- skip the comment block
---@param reader table the file reader
local function commentBlock(reader)
end;

--- call at comment zone
--- when the starting items are '-- '
--- skip the comment line
---@param reader table the file reader
local function commentLine(reader)
end;

--- call at the default zone
--- when the starting items is ':'
--- it could be a label definition
---@param reader table the file reader
local function label(reader)
end;

--- call at the default zone
--- when starting item is "f"
--- it may be "function", "for" or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function functionOrForOrDefine(reader, tree)
end

--- call at the default zone
--- when starting item is "g"
--- it may be "goto", or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function gotoOrDefine(reader, tree)
end

--- call at the default zone
--- when starting item is "i"
--- it may be "if", "io" or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function ifOrDefine(reader, tree)
end

--- call at the default zone
--- when starting item is "l"
--- it may be "local", or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function localOrDefine(reader, tree)
end

--- call at the default zone
--- when starting item is "r"
--- it may be "return" or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function returnOrDefine(reader, tree)
end

--- call at the default zone
--- when starting item is "w"
--- it may be "while" or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function whileOrDefine(reader, tree)
end

--- call at the default zone
--- when starting item is not above
--- it should be a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function define(reader, tree)
end

--- call at the default zone
--- when starting item is "_"
--- it may be "_G", "_VERSION" or a variable definition
---@param reader table the file reader
---@param tree table unfinished tree
---@return table the host ast
local function gOrVersionOrDefine(reader, tree)
end

local function name(reader)  end

local function expressionList(reader)  end

local reservedWords = {
    "and", "break", "do", "else", "elseif", "end",
    "false", "for", "function", "goto", "if", "in",
    "local", "nil", "not", "or", "repeat", "return",
    "then", "true", "until", "while"
}

----------------------------------------ast.h----------------------------------------

ast = function(reader, tree)
    if tree == nil then
        tree = {};
    end
    local next = reader.next();
    if next == nil then
        return tree;
    end

    ----------------- symbols -----------------

    if next <= " " or next == ";" then
        -- simply ignore it
        return ast(reader, tree);
    end
    if next < "-" then
        reader.error(string.format("unexpected '%s'", next));
    end
    if next == "-" then
        return comment(reader, tree);
    end
    if next > "-" and next < ":" then
        reader.error(string.format("unexpected '%s'", next));
    end
    if next == ":" then
        label(reader, tree);
        return ast(reader, tree);
    end
    if next > ";" and next < "A" then
        reader.error(string.format("unexpected '%s'", next));
    end
    if next > "Z" and next < "_" then
        reader.error(string.format("unexpected '%s'", next));
    end
    if next == "_" then
        return gOrVersionOrDefine(reader, tree);
    end
    if next == '`' then
        reader.error("unexpected '`'");
    end
    if next > "z" then
        reader.error(string.format("unexpected '%s'", next));
    end

    ----------------- characters -----------------

    if next == "f" then
        return functionOrForOrDefine(reader, tree);
    end
    if next == "g" then
        return gotoOrDefine(reader, tree);
    end
    if next == "i" then
        return ifOrDefine(reader, tree);
    end
    if next == "l" then
        return localOrDefine(reader, tree);
    end
    if next == "r" then
        return returnOrDefine(reader, tree);
    end
    if next == "w" then
        return whileOrDefine(reader, tree);
    end
    return define(reader, tree);
end

comment = function(reader, tree)
    local next = reader.next();
    if next == "-" then
        -- comment
        next = reader.next();
        if next == "[" then
            commentBlock(reader);
        else
            commentLine(reader);
        end
        return ast(reader, tree);
    end
    reader.error("unexpected '-'");
end

commentBlock = function(reader, count)
    if count == nil then
        local next = reader.next();
        if next ~= "[" or next ~= "=" then
            commentLine(reader);
        else
            count = 0;
            if next == "=" then
                while next == "=" do
                    count = count + 1;
                    next = reader.next();
                end
                if next == "[" then
                    -- --[=====[
                    commentBlock(reader, count);
                else
                    -- --[===asdfsadf
                    commentLine(reader);
                end
            else
                -- --[[
                commentBlock(reader, 0);
            end
        end
    else
        repeat
            local next = reader.next();
        until next == "]" or next == nil;
        if next == nil then
            reader.error("unclosed comment block");
        end
        local equals = 0;
        while true do
            local next = reader.next();
            if next == "=" then
                equals = equals + 1;
                if equals > count then
                    commentBlock(reader, count);
                    break ;
                end
            else
                if next == "]" then
                    if equals ~= count then
                        commentBlock(reader, count);
                    end
                elseif next == nil then
                    reader.error("unclosed comment block");
                else
                    commentBlock(reader, count);
                end
                break ;
            end
        end
    end
end

commentLine = function(reader)
    local next;
    repeat
        next = reader.next();
    until next == "\n" or next == nil;
end

label = function(reader, tree)
    local next = reader.next();
    if next ~= ":" then
        reader.error("unexpected ':'");
    end
    local labelName = name(reader);
    next = reader.next();
    if next == ":" then
        next = reader.next();
        if next == ":" then
            table.insert(tree, {
                __type__ = "label",
                name = labelName
            });
        else
            reader.error("unfinished label definition");
        end
    else
        reader.error("unfinished label definition");
    end
end

name = function(reader, result)
    if result == nil then
        result = "";
    end
    while true do
        local next = reader.next();
        if result >= '0' and result <= '9' then
            if result == "" then
                reader.error(string.format("unexpected number '%s'", next));
            end
            result = result .. next;
        elseif (result >= "A" and result <= "Z") or (result >= "a" or result <= "z") then
            result = result .. next;
        else
            for _, v in ipairs(reservedWords) do
                if result == v then
                    reader.error(string.format("reserved word '%s' is not allowed to be a name", v));
                end
            end
            return result;
        end
    end
end

returnOrDefine = function(reader, tree)
    local next = reader.next();
    if next == "e" then
        next = reader.next();
        if next == "t" then
            next = reader.next();
            if next == "u" then
                next = reader.next();
                if next == "r" then
                    next = reader.next();
                    if next == "n" then
                        next = reader.next();
                        if next <= " " then
                            -- return
                            table.insert(tree, {
                                type = "return",
                                value = expressionList(reader);
                            });
                        else
                            return define(reader, tree, "return" .. next);
                        end
                    else
                        return define(reader, tree, "retur" .. next);
                    end
                else
                    return define(reader, tree, "retu" .. next);
                end
            else
                return define(reader, tree, "ret" .. next);
            end
        else
            return define(reader, tree, "re" .. next);
            end
    else
        return define(reader, tree, "r" .. next);
    end
end

return ast;
