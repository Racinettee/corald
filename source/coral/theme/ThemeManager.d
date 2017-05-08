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
            prefsPath = cast(string)fromStringz(getenv(toStringz("APPDATA")));
        }
        else
        {
            prefsPath = cast(string)fromStringz(getenv(toStringz("HOME")));
        }
        // build the path to .coral/theme.css
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