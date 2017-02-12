module coral.lua.classes;

import std.stdio;
import std.traits;

import coral.lua.state;
import coral.lua.attrib;

void registerClass(T)(State state)
{
    pragma(msg, __traits(getAttributes, T));
    static assert(hasUDA!(T.openFile, LuaExport));
    static assert(hasUDA!(T, LuaExport));
    static assert(getUDAs!(T, LuaExport)[0].name == "AppWindow");
    writeln("There are: ", getUDAs!(T, LuaExport).length, " udas for this class");
       // foreach(member; getUDAs!(T, LuaExport))
   //     writeln(member.name);
   iterateUDAMembers!(T, 0);

    /*foreach(member; __traits(derivedMembers, T))
    {
        pragma(msg, __traits(getAttributes, member));
        //static if(__traits(getProtection, mixin("T."~member)) == "public")
          //  write(mixin("T."~member).mangleof, " member: ", getUDAs!(mixin("T."~member), LuaExport));
        static if(__traits(getProtection, mixin("T."~member)) == "public" && hasUDA!(mixin("T."~member), LuaExport))
        {
            foreach(memberUDA; getUDAs!(mixin("T."~member), LuaExport))
                writeln(member~": ", memberUDA.name);
        }
    }*/
}

void iterateUDAMembers(T, uint index)()
{
    static if(__traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public")
        pragma(msg, __traits(derivedMembers, T)[index]);
    static if(__traits(getProtection, mixin("T."~__traits(derivedMembers, T)[index])) == "public" && hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), LuaExport))
        pragma(msg, "Found a member with uda");
    
    static if(index + 1 < __traits(derivedMembers, T).length)
        iterateUDAMembers!(T, index+1);
}