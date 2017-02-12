module coral.lua.classes;

import std.stdio;
import std.traits;

import coral.lua.c.all;
import coral.lua.state;
import coral.lua.attrib;

void registerClass(T)(State state)
{
    static assert(hasUDA!(T, LuaExport));

    lua_State* L = state.state;

    luaL_newmetatable(L, "luaL_"~T.stringof);

    iterateUDAMembers!(T, 0);
}

void iterateUDAMembers(T, uint index)()
{
    static if(__traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public" && hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport))
    {
        pragma(msg, "Found a member with uda "~__traits(derivedMembers, T)[index]);

    }
    
    static if(index + 1 < __traits(derivedMembers, T).length)
        iterateUDAMembers!(T, index+1);
}