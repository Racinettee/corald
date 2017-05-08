import std.stdio;

class Selector
{
    this(string name, string constraint=null)
    {
        selectorName = name;
        this.constraint=constraint;
    }
    void emit(File file)
    {
        file.writeln(selector, constraint ? constraint : "", " {");
        foreach(e; properties.byKeyValue)
        {
            file.writeln(e.key, ": ", e.value, ";");
        }
        file.writeln("}");
    }
    void addProperty(string key, string value)
    {
        properties[key] = value;
    }
    void addConstraint(string constraint)
    {
        this.constraint = constraint;
    }
    private string selectorName;
    private string constraint;
    public @property const(string) selector() { return selectorName;}
    private string[string] properties;
}