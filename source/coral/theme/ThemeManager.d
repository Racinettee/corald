module coral.theme.thememanager;

import coral.css.css;

import std.c.stdlib : getenv;
import std.stdio;
import std.string;

class ThemeManager
{
    // userhome/.coral/theme.css
    this()
    {
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
    this(string filePath)
    {
        prefsPath = filePath;
        stylesheet = StyleSheet.fromFile(filePath);
    }
    void save()
    {
        import std.outbuffer : OutBuffer;
        auto outbuff = new OutBuffer;
        stylesheet.emit(outbuff);
        auto outputFile = File(prefsPath);
        outputFile.write(outbuff.toBytes);
    }
    void load()
    {

    }
    void appendStyle(string selector, string property, string value)
    {
    	
    }
    string prefsPath;
    StyleSheet stylesheet;
}