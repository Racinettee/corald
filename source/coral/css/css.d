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
    this(string name)
    {
        selectorName = name;
    }
    void emit(OutBuffer buffer)
    {
        buffer.writefln("%s {", selector);
        foreach(e; properties.byKeyValue)
        {
            buffer.writefln("  %s: %s;", e.key, e.value);
        }
        buffer.writef("}");
    }
    void addProperty(string key, string value)
    {
        properties[key] = value;
    }
    void removeProperty(string key)
    {
        properties.remove(key);
    }
    string opIndex(string name)
    {
        return properties[name];
    }
    void opIndexAssign(string name, string value)
    {
        properties[name] = value;
    }
    Selector opAssign(string name)
    {
        selectorName = name;
        return this;
    }
    private string selectorName;
    public @property const(string) selector()
    {
        return selectorName;
    }
    private string[string] properties;
}
unittest
{
    auto selector = new Selector("textview");
    selector["font-family"] = "monospace";
    auto buffer = new OutBuffer();
    selector.emit(buffer);
    writeln(buffer.toString());
    assert(buffer.toString() == 
"textview {
  monospace: font-family;
}");
}
