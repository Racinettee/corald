module coral.util.editor;

import std.string : lastIndexOf;

import gtk.Builder;

import gsv.SourceBuffer;
import gsv.SourceFile;
import gsv.SourceFileLoader;
import gsv.SourceFileSaver;
import gsv.SourceLanguageManager;

import gio.File;
import gio.Cancellable;
import gio.SimpleAsyncResult;

import coral.component.notebook;
import coral.component.tablabel;
import coral.component.sourceeditor;

private immutable string defaultTitle = "New File";

public:

pure @safe string shortName(in string fullpath)
in
{
  assert(fullpath.length != 0);
}
body
{
  long index = lastIndexOf(fullpath, '/');
  // If theres no forward slash in fullpath then just return the path
  if(index == -1)
    return fullpath;
  
  return fullpath[index+1..$];
}

T getItem(T)(Builder b, string n)
{
    T item = cast(T)b.getObject(n);
    if(item is null)
        throw new Exception("Failed to get object: "~n~" from builder");
    return item;
}

alias FileOpenSaveCallback = void delegate (bool result, string filepath, TabLabel);
private void onOpenFailed(bool result, string fp, TabLabel)
{
    import std.stdio : writeln;
    if(!result)
        writeln("Failed to open: "~fp);
}

private alias GAsyncReadyCallback = extern (C) void function(GObject* source_object, GAsyncResult* res, void* user_data);
private alias GProgressCallback = extern (C) void function(long, long, void*);
private alias GProgressCallbackNotify = extern (C) void function(void*);
void openFile(Notebook notebook, const string filepath, FileOpenSaveCallback callback = (r, f, tl) => onOpenFailed(r, f, tl))
{
    int fileNo = notebook.isFileOpen(filepath);
    if(fileNo != -1)
    {
        notebook.setCurrentPage(fileNo);
        return;
    }

    auto sourceFile = new SourceFile();
    sourceFile.setLocation(File.parseName(filepath));
    auto sourceLanguage = SourceLanguageManager.getDefault().guessLanguage(filepath, null);
    if(!sourceLanguage)
        sourceLanguage = SourceLanguageManager.getDefault().guessLanguage("default.c", null);
    auto sourceBuffer = new SourceBuffer(sourceLanguage);
    auto fileLoader = new SourceFileLoader(sourceBuffer, sourceFile);
    auto cancellation = new Cancellable();

    class UserData
    {
        string filepath;
        FileOpenSaveCallback callback;
        SourceFileLoader loader;
        Notebook notebook;
        SourceBuffer sourceBuf;
    }

    GAsyncReadyCallback finalize = function(GObject* sourceObj, GAsyncResult* result, void* userdat) @trusted
    {
        import coral.util.memory : dealloc;
        import std.stdio : writeln;
	
        auto userDat = cast(UserData)userdat;
        try
        {
            GSimpleAsyncResult* simpleResult = cast(GSimpleAsyncResult*)result;
            if(userDat.loader.loadFinish(new SimpleAsyncResult(simpleResult)))
            {
                auto tabLabel = userDat.notebook.addPage(new SourceEditor(userDat.sourceBuf), shortName(userDat.filepath), userDat.filepath);
                userDat.notebook.setCurrentPage(-1);
                if(userDat.callback)
                    userDat.callback(true, userDat.filepath, tabLabel);
            }
            else
            {
                throw new Exception("Error occured loading file");
            }
        }
        catch(Exception e)
        {
            writeln(e.msg);
            if(userDat.callback)
                userDat.callback(false, userDat.filepath, null);
        }
        finally
        {
            // there is need for an else case that notifies the user that their file cannot be opened
            dealloc(userDat);
        }
    };

    import coral.util.memory : alloc;

    auto userDat = alloc!UserData;
    userDat.filepath = filepath;
    userDat.callback = callback;
    userDat.loader = fileLoader;
    userDat.notebook = notebook;
    userDat.sourceBuf = sourceBuffer;

    fileLoader.loadAsync(cast(int)GPriority.DEFAULT, cancellation,
        cast(GProgressCallback)0, cast(void*)0,
        cast(GProgressCallbackNotify)0, finalize, cast(void*)userDat);
}

/// Save the current page of the notebook
void saveFile(Notebook notebook, string filepath, FileOpenSaveCallback callback = null)
{
    SourceFile sourceFile = new SourceFile();
    sourceFile.setLocation(File.parseName(filepath));
    SourceEditor sourceEditor = cast(SourceEditor)notebook.getNthPage(notebook.getCurrentPage);
    SourceBuffer sourceBuffer = sourceEditor.editor.getBuffer;
    SourceFileSaver sourceSaver = new SourceFileSaver(sourceBuffer, sourceFile);

    class SaveUserData
    {
        string filepath;
        FileOpenSaveCallback callback;
        SourceFileSaver saver;
        TabLabel tablabel;
    }

    GAsyncReadyCallback finalize = function(GObject* sourceObj, GAsyncResult* result, void* userdat) @trusted
    {
        import coral.util.memory : dealloc;
        import std.stdio : writeln;
        import std.path : baseName;

        SaveUserData userData = cast(SaveUserData)userdat;
        try
        {
            GSimpleAsyncResult* simpleResult = cast(GSimpleAsyncResult*)result;
            if(userData.saver.saveFinish(new SimpleAsyncResult(simpleResult)))
            {
                writeln("File saved");
                userData.tablabel.setTitleAndPath(userData.filepath);
                if(userData.callback)
                    userData.callback(true, userData.filepath, userData.tablabel);
            }
            else
            {
                throw new Exception("Failed to save file.");
            }
        }
        catch(Exception e)
        {
            writeln(e.msg);
            if(userData.callback)
                userData.callback(false, userData.filepath, null);
        }
        finally
        {
            dealloc(userData);
        }
    };

    import coral.util.memory : alloc;

    auto userDat = alloc!SaveUserData;
    userDat.filepath = filepath;
    userDat.callback = callback;
    userDat.saver = sourceSaver;
    userDat.tablabel = cast(TabLabel)notebook.getTabLabel(notebook.getNthPage(notebook.getCurrentPage));
    auto cancellation = new Cancellable();

    sourceSaver.saveAsync(cast(int)GPriority.DEFAULT, cancellation,
        cast(GProgressCallback)0, cast(void*)0,
        cast(GProgressCallbackNotify)0, finalize, cast(void*)userDat);
}
