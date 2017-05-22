module coral.css.css;

import std.algorithm;
import std.stdio;
import std.outbuffer;

class StyleSheet
{
    static StyleSheet fromData(string data)
    {
        auto sheet = new StyleSheet;

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
    void opIndexAssign(string value, string name)
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
    auto selector = new Selector("textview text");
    selector["font-family"] = "DejaVu Sans Mono Book";
    selector["background"] = "red";

    auto buffer = new OutBuffer();
    selector.emit(buffer);
    assert(buffer.toString() == 
"textview text {
  background: red;
  font-family: DejaVu Sans Mono Book;
}", "selector unittest failed");
}
