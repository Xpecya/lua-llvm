---@author Xpecya

----------------------------------------syntax.h----------------------------------------

--- block ::= {statement} [returnStatement]
local function block(reader, tree)  end

--- statement ::=
--- ';' |
--- valueList '=' expressionList |
--- functionCall |
--- label |
--- 'break' |
--- 'goto' name |
--- 'do' block 'end' |
--- 'while' expression 'do' block 'end' |
--- 'repeat' block 'until' expression |
--- 'if' expression 'then' block {'elseif' expression 'then' block} ['else' block] 'end' |
--- 'for' name '=' expression ',' expression [',' expression] 'do' block 'end' |
--- 'function' functionName functionBody |
--- 'local' 'function' name functionBody |
--- 'local' nameList ['=' expressionList]
local function statement(reader)  end

--- returnStatement ::= 'return' [expressionList] [';']
local function returnStatement(reader)  end

--- expressionList ::= exp {',' exp}
local function expressionList(reader)  end

--- expression ::= 'nil' | 'false' | 'true' | numeral | literalString | '...' | functionDefine | prefixExpression | tableConstructor | expression binop expression | unop expression
local function expression(reader)  end

--- numeral ::= hex | oct
local function numeral(reader)  end

--- hex ::= hexPrefix hexNumber ['.' hexNumber] [pSuffix]
local function hex(reader)  end

--- hexPrefix ::= '0x' | '0X'
local function hexPrefix(reader)  end

--- hexNumber ::= {'0'-'9', 'a'-'f', 'A'-'F'}
local function hexNumber(reader)  end

--- e ::= 'e' | 'E'
local function e(reader)  end

--- pSuffix ::= p generalNumeralSuffix
local function pSuffix(reader)  end

--- p ::= 'p' | 'P'
local function p(reader)  end

--- plusOrMinus ::= '+' | '-'
local function plusOrMinus(reader)  end

--- octNumber ::= {'0'-'9'}
local function octNumber(reader)  end

--- oct ::= octNumber ['.' octNumber] [eSuffix]
local function oct(reader)  end

--- eSuffix ::= e generalNumeralSuffix
local function eSuffix(reader)  end

--- generalNumeralSuffix ::= [plusOrMinus] octNumber
local function generalNumeralSuffix(reader)  end

local function octFloat(reader)  end

local function skipComments(reader)  end

----------------------------------------syntax.h----------------------------------------

local function commentLine(reader, next)
    if next == nil then
        return nil;
    end
    if next ~= '\n' then
        repeat
            next = reader.next();
        until next == '\n'
    end
    return reader.next();
end

local function commentBlock(reader)
    local count = 0;
    while true do
        local next = reader.next();
        if next == '=' then
            count = count + 1;
        elseif next == '[' then
            -- a commentBlock start
            while true do
                next = reader.next();
                if next == nil then
                    reader.error("unclosed comment block");
                elseif next == ']' then
                    local check = true;
                    for _ = 1, count do
                        next = reader.next();
                        if next ~= '=' then
                            check = false;
                            break;
                        end
                    end
                    if check then
                        next = reader.next();
                        if next == ']' then
                            -- a comment block ends
                            return reader.next();
                        else
                            -- 回到外层循环，重新找]
                            break;
                        end
                    end
                end
            end
        else
            -- this is a comment line
            return commentLine(reader, next);
        end
    end
end

skipComments = function(reader)
    local next = reader.next();
    if next == '-' then
        -- a comment
        next = reader.next();
        if next == '[' then
            -- may be a comment block
            return commentBlock(reader);
        else
            -- must be a comment line
            return commentLine(reader, next);
        end
    else
        return next;
    end
end

local function skipSpaces(reader)
    local next = reader.next();
    while true do
        if next == nil or next > " " then
            if next == '-' then
                next = skipComments(reader);
            else
                return next;
            end
        else
            next = reader.next();
        end
    end
end

block = function(reader)
    local function concat(str1, str2)
        if str2 == nil then
            reader.error("syntax error near <eof>");
        end
        return str1 .. str2;
    end

    local next = skipSpaces(reader);
    local result = {
        type = "block",
        statements = {},
        returnStatement = nil
    }
    if next == nil then
        -- 一个字儿也不写同样是一个合法的block
        return result;
    elseif next == "r" then
        next = reader.next();
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
                            -- returnStatement
                            if next == nil or next <= " " then
                                returnStatement(reader, result);
                            else
                                return statement(reader, result, concat("return", next));
                            end
                        else
                            return statement(reader, result, concat("retur", next));
                        end
                    else
                        return statement(reader, result, concat("retu", next));
                    end
                else
                    return statement(reader, result, concat("ret", next));
                end
            else
                return statement(reader, result, concat("re", next));
            end
        else
            return statement(reader, result, concat("r", next));
        end
    else
        return statement(reader, result, concat("", next));
    end
    return result;
end

statement = function(reader, blockTable, previous)
    if previous == nil then
        previous = "";
    end

end

returnStatement = function(reader, blockTable)
    local next = skipSpaces(reader);
    local result = {
        value = nil;
    }
    if next ~= nil then
        local expressions, nextItem = expressionList(reader, next);
        result.value = expressions;
        if nextItem == ";" then
            -- 结尾可以有一个分号
            nextItem = skipSpaces(reader);
        end
        if nextItem ~= nil then
            -- 其他的报错
            error("syntax error at " .. nextItem);
        end
    end
    -- return后面什么也不写视为return nil
    blockTable.returnStatement = result;
end

expressionList = function(reader, next)
    local results = {};
    local singleExpression;
    while true do
        singleExpression, next = expression(reader, next);
        table.insert(results, singleExpression);
        if next == ',' then
            next = skipSpaces(reader);
        else
            return results, next;
        end
    end
end

expression = function(reader, next)
    if next >= '0' and next <= '9' then
        return numeral(reader, next);
    elseif next == '-' or next == '#' or next == '~' then
        -- unop exp
    end
end

numeral = function(reader, next)
    if next == '0' then
        next = reader.next();
        if next == 'x' or next == "X" then
            return hex(reader);
        end
    end
    return oct(reader, next);
end

oct = function(reader, next)
    local result = {
        type = "integer",
        oct = true
    }
    local number;
    number, next = octNumber(reader, next);
    result.integer = number;
    if next == '.' then
        result.type = "float";
        return octFloat(reader);
    elseif next == 'e' or next == 'E' then
        next = eSuffix(reader, result);
    else
        return result, next;
    end
end

octFloat = function(reader, result)
    local number, next = octNumber(reader, result);
    result.tail = number;
    if next == 'e' or next == 'E' then
        return eSuffix(reader);
    else
        return next;
    end
end

eSuffix = function(reader, result)
    local next = reader.next();
    local resultString = "";
    if next == '+' or next == '-' then
        resultString = next;
        next = reader.next();
    end
    while true do
        next = reader.next();
        if next >= '0' and next <= '9' then
            resultString = resultString .. next;
        else
            result.e = resultString;
            return next;
        end
    end
end

octNumber = function(reader, next)
    if next == nil then
        next = "";
    end
    local result = next;
    while true do
        next = reader.next();
        if next >= '0' and next <= '9' then
            result = result .. next;
        else
            return result, next;
        end
    end
    return result, next;
end

return block;
