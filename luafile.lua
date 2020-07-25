-- local a=1-2


-- public class MyClass

--     local _xx = 2;
--     local _yy<int>= 3;

--     function ctor(){

--     }

--     function destroy(){

--     }

--     function aaa(){

--         _xx = 2;
--     }

--     function _test(){

--     }

-- end


-- define("MyClass",{
--     _xx = 2,
--     _yy = 3,

-- },{
--     function ctor()
--         this._tt = 5
--     end,
--     function destroy(){

--     }
-- })

-- local myCls = new MyClass();

-- local 

-- MyClass = class.def(MyBass);
-- function MyClass.test()

-- end


-- local s = MyClass.new();
-- MyClass.test(s);
-- MyClass.close(s);

-- MyClass.ctor(s)
-- MyClass.destroy(s);

local source = [[
    class MyClass : MyBass{

        local aa = 2222
        local bb = "中\"午"
    
        function ctor(aa,...){
            this.ctor(aa)
            this.super.ctor(aa,...)
        }

        function test(){

        }

        static function dd(){

        }

        function destroy(){

        }
    }
]]


local source = [[
    var xx = 22323;
    var xx = aaaaa;
    var xx = {
        ee = "中\"午";
       bb = 00;
   }
   function test(aaa,ee,ddd){
       var tt=44;
       var uu=99;
   }
   class MyClass{

        var xx = 23
        var yy = 45

        function ctor(rr,cc){
            this.xx = ((rr + 22) + 4) & 44 !=5;
            this.yy = cc;
        }


        function test(){
           
        }

   }
]]


local NUM_BEGIN,NUM_END = string.byte('0',1),string.byte('9',1);
local SPECIAL_CHAR_EMPTY = string.byte(' ',1)
local SPECIAL_CHAR_LF = string.byte("\n",1)

-- local CHAR_BEGIN,CHAR_END = string.byte('a',1),string.byte('z',1);
-- local BIG_CHAR_BEGIN,BIG_CHAR_END = string.byte('A',1),string.byte('Z',1);
-- local SPECIAL_CHAR_LOWER = string.byte('_',1)
-- local SPECIAL_CHAR_AND = string.byte('@',1)


local charstats = {"\\","\"",":",";","{","}","(",")","=",".",",","+","-","*","/","%","&","|",">","<","!"}
local tokenstats = {"class","var","function","self","super"}

function isnumber(charcode)
    return charcode >= NUM_BEGIN and charcode <= NUM_END
end

function ischar(charcode)
    return charcode ~= SPECIAL_CHAR_EMPTY and charcode ~= SPECIAL_CHAR_LF --charcode == SPECIAL_CHAR_LOWER or charcode == SPECIAL_CHAR_AND or (charcode >= CHAR_BEGIN and charcode <= CHAR_END) or (charcode >= BIG_CHAR_BEGIN and charcode <= BIG_CHAR_END)
end

function strjoin(list,g)
    local t = ""
    for _,v in ipairs(list) do
        if #t > 0 then
            t = t .. g
        end
        t = t .. v 
    end
    return t
end

function split(source,start)

    local chartype = nil;
    for i = start, #source do
        local c = string.sub(source,i,i)
        for _,char in ipairs(charstats) do
            if char == c then
                if start < i then
                    return chartype,string.sub(source,start,i - 1),start,i - 1
                else
                    return c,c,start,i
                end
            end
        end

        local name = string.sub(source,start,i)
        for _,char in ipairs(tokenstats) do
            if char == name then
                return name,name,start,i
            end
        end

        local charcode = string.byte(source,i)
        if i == start then
            if isnumber(charcode) then
                chartype = "number"
            elseif ischar(charcode) then
                chartype = "name"
            else
                chartype = "empty"
            end
        else
            if "number" == chartype and not isnumber(charcode) then
                return chartype,string.sub(source,start,i - 1),start,i - 1
            end
            if "name" == chartype and not (ischar(charcode) or isnumber(charcode)) then
                return chartype,string.sub(source,start,i - 1),start,i - 1
            end
            if "empty" == chartype and (ischar(charcode) or isnumber(charcode)) then
                return chartype,string.sub(source,start,i - 1),start,i - 1
            end
        end
    end
    return null,null,start,start+ 30
end

local token = {}

function token:next()
    
    self.type,self.name,self.start,self.finish = split(self.source,self.finish + 1)
    if "empty" == self.type then
        self:next()
    end
end

function token:test(type)
    
    return self.type == type
end

function token:get()
    
    return {
        type = self.type,
        name = self.name,
        start = self.start,
        finish = self.finish
    }
end

function token:nextvalue()
    
    local go = self:get()
    self:next()
    return go
end

function token:loop()
    
    local tokens = {}
    while #self.source > self.finish do
        self:next()
        if self.type then
            tokens[#tokens + 1] = self:get()
        end
    end
    return tokens
end

function token:dump(tokens)

    for i,t in ipairs(tokens) do
        print("aaaaaa "..string.sub(self.source,t.start,t.finish))
   end
end

function token:data(source)
    self.source = source
    self.start = 1
    self.finish = 1
end

function token:lex(source)
    self:data(source)
    --self:dump(self:loop())
end

--token:lex(source)


local lexer = {
    go = {},
    token = token
}

function lexer:push(lauguage)

    self.go[#self.go + 1] = lauguage
end


function lexer:skip(type,warning)

    if self.token:test(type) then
        self.token:next()
    else
        if warning then
            print("WARRING: "..type)
        end
    end
end

function lexer:operatesegment()

    if self.token:test("+") 
        or self.token:test("-") 
        or self.token:test("*") 
        or self.token:test("/") 
        or self.token:test("%")
        or self.token:test("!")
        or self.token:test("&")
        or self.token:test("|")
        or self.token:test(">")
        or self.token:test("<")
    then
        local v = self.token:nextvalue().name
        print("zzzzz >>>>>>> "..v)
        if self.token:test("&") 
            or self.token:test("|") 
            or self.token:test(">") 
            or self.token:test("<") 
            or self.token:test("=") 
        then
            return v.. self.token:nextvalue().name
        end
        return v
    end
end

function lexer:stringsegment()

    if self.token:test("\"") then
        local v = "\""
        self.token:next()
        while not self.token:test("\"") do
            if self.token:test("\\") then
                self.token:next()
                v = v .. "\\"
            end
            v = v .. self.token:nextvalue().name
        end
        self.token:next()
        return v .. "\""
    end
end

function lexer:namesegment()

    if self.token:test("name") then
        local v = self.token:nextvalue().name
        while self.token:test(".") do
            self.token:next()
            if self.token:test("name") then
                v = v ..".".. self.token:nextvalue().name
            end
        end
        print("ggggggggg >>>>>>>>>>>>>>>> "..v)
        return v
    end
end

function lexer:expressionsegment()

    local v = self:valuesegment()
    if v then
        local o = self:operatesegment()
        while o do
            print("zzzzzzeeeee "..v.."   " ..o)
            v = v .. o .. self:valuesegment()
            o = self:operatesegment()
        end
        print("zzzzzzeeeeettt "..v)
        return v
    end 
end


function lexer:funcsegment(isclass)

    if self.token:test("function") then
        local funcname = ""
        local args = {}
        local body = {}

        if isclass then
            args[#args + 1] =  "this"
        end
        self.token:next()
        print("?>>>>>>>funcsegment ")
        if self.token:test("name") then
            funcname = self.token:nextvalue().name
        end
        print("?>>>>>>>funcsegment "..funcname)
        self.token:next()
        while not self.token:test(")") do
            if self.token:test(",") then
                self.token:next()
            end
            args[#args + 1] =  self.token:nextvalue().name
            print("?>>>>>>>name "..args[#args])
        end
        self.token:next()
        self.token:next()
        while not self.token:test("}") do
            body[#body + 1] = self:assignsegment()
            --print(">>>>>>>body "..body[#body])
        end
        self.token:next()
        return "function(".. strjoin(args,",")..")"..strjoin(body,"").."end",funcname
    end
end


function lexer:classsegment()

    if self.token:test("class") then
        self.token:next()
        local classvalue = {}
        local classfuncs = {}
        local classname = self.token:nextvalue().name
        print("?>>>>>>>classsegment "..classname)
        self.token:next()
        while not self.token:test("}") do
            if self.token:test("var") then
                self.token:next();
                classvalue[#classvalue + 1] = self.token:nextvalue().name..self.token:nextvalue().name..self:valuesegment()
            elseif self.token:test("function") then
                local funcbody,funcname = self:valuesegment(classname)
                classfuncs[#classfuncs + 1]  = classname .."." .. funcname .."="..funcbody
            end
            self:skip(";")
        end
        print("?>>>>>>>classsegment "..strjoin(classvalue,""))
        print("?>>>>>>>classsegment "..strjoin(classfuncs,","))
        return classname .. "={};"..classname .. ".__class__="..classname..";"..classname..".new=function (...) local tt = setmetatable({"..strjoin(classvalue,";").."},{__index = "..classname.."});if tt.ctor then tt.ctor(tt,...) end; return tt; end "..strjoin(classfuncs,";")
    end

    self:skip(";")
end

function lexer:valuesegment(isclass)

    if self.token:test("name") then
        return self:namesegment()
    elseif self.token:test("number") then
        return self.token:nextvalue().name
    elseif self.token:test("\"") then
        local vv =  self:stringsegment()
        if self.token:test(".") then
            self.token:next()
            if self.token:test(".") then
                vv = vv .. ".." .. self:valuesegment()
            end
        end
        return vv
    elseif self.token:test("(") then
        self.token:next()
        local vv = self:expressionsegment()
        self.token:next()
        print("?>>>>>>>vvvvvvvvvvvvvvvvvv "..vv.."   " ..self.token:get().name)
        return "(" .. vv .. ")"
    elseif self.token:test("{") then
        local vv = "{"
        self.token:next() 
        while self.token:test("name") do
            vv = vv .. self:assignsegment()
        end  
        self.token:next()   
        vv = vv .. "}"
        return vv
    elseif self.token:test("function") then
        return self:funcsegment(isclass)
    elseif self.token:test("class") then
        return self:classsegment()
    end
end

function lexer:assignsegment()

    local assign = null;
    if self.token:test("var") then
        self.token:next();
        assign =  "local " .. self.token:nextvalue().name..self.token:nextvalue().name..self:expressionsegment()..";"
    elseif self.token:test("function") then
        local funcbody,funcname = self:valuesegment(false)
        assign = "local " ..funcname .. "="..funcbody
    elseif self.token:test("class") then
        assign = self:valuesegment()
        print("zzzzz >>"..assign)
    elseif self.token:test("name") then
        local name = self:namesegment()
        print("tttuuuuuuuu >>>  "..name)
        assign =  name..self.token:nextvalue().name..self:expressionsegment()..";"
    end

    self:skip(";")
    return assign
end

function lexer:nextsegment(classname)

    local s = self:assignsegment(classname)
    if self.token:test(";") then
        self.token:next()
    end
    return s
end

function lexer:test(source)

    self.token:lex(source)
    self.token:dump(self.token:loop())
    self.token:lex(source)
    self.token:next()

    local xxx = ""
    local aa = self:nextsegment()
    while aa do
        xxx = xxx .. aa .. "\n"
        aa = self:nextsegment("class")
    end
    print(xxx)
end

lexer:test(source)