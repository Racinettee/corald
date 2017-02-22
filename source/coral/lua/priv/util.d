module coral.lua.priv.util;
enum isUserStruct(T) = is(T == struct) && !is(Unqual!T == LuaObject) && !is(Unqual!T == LuaTable) && !is(Unqual!T == LuaDynamic) && !is(Unqual!T == LuaFunction) && !is(T == Ref!S, S);
