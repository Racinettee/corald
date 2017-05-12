module coral.css.css;

import std.algorithm;
import std.stdio;
import std.outbuffer;

class StyleSheet
{
    static StyleSheet fromFile(string filepath)
    {
        auto sheet = new StyleSheet;
        auto file = File(filepath);

        // parse through the file - creating new selectors and stuff

        return sheet; 
    }
    void addSelector(Selector sel)
    {
        selectors ~= sel;
    }
    void emit(OutBuffer buffer)
    {
        foreach(sel; selectors)
        {
            sel.emit(buffer);
        }
    }
    private Selector[] selectors;
}
class Selector
{
    this(string name, string constraint=null)
    {
        selectorName = name;
        constraints = [];
    }
    void emit(OutBuffer buffer)
    {
        buffer.writefln("%s {", selector);
        foreach(e; properties.byKeyValue)
        {
            buffer.writefln("  %s: %s;", e.key, e.value);
        }
        buffer.writefln("}");
    }
    void addProperty(string key, string value)
    {
        properties[key] = value;
    }
    void removeProperty(string key)
    {
        properties.remove(key);
    }
    void setProperty(string key, string value)
    {
        properties[key] = value;
    }
    void appendConstraint(string constraint)
    {
        if(findContraint(constraint) == -1)
            constraints ~= constraint;
    }
    void eraseConstraint(string cnst)
    {
        remove!(SwapStrategy.unstable)(constraints, cnst);
    }
    void eraseConstraints()
    {
        constraints = [];
    }
    private string selectorName;
    private string[] constraints;
    public @property const(string) selector()
    {
        string result = selectorName;
        foreach(cnst; constraints)
            result ~= " " ~ cnst;
        return result;
    }
    private string[string] properties;
    private int findContraint(string name)
    {
        for(int i = 0; i < constraints.length; i++)
            if(constraints[i] == name)
                return i;
        return -1;
    }
}