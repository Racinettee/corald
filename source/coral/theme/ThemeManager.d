import std.c.stdlib : getenv;
import std.string;

class ThemeManager
{
    // userhome/.coral/theme.css
    this()
    {
        string prefsPath = null;
        version(Windows)
        {
            //APPDATA
            prefsPath = fromStringz(getenv(toStringz("APPDATA")));
        }
        else
        {
            prefsPath = cast(string)fromStringz(getenv(toStringz("HOME")));
        }
        this(prefsPath);
    }
    this(string file_path)
    {
        
    }
    void save()
    {

    }
    void load()
    {

    }
}