module coral.css.css;

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
        this.constraint=constraint;
    }
    void emit(OutBuffer buffer)
    {
        buffer.writefln("%s %s {", selector, constraint ? constraint : "");
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
    void addConstraint(string constraint)
    {
        this.constraint = constraint;
    }
    void eraseConstraints()
    {
        constraint = null;
    }
    private string selectorName;
    private string constraint;
    public @property const(string) selector() { return selectorName;}
    private string[string] properties;
}