module coral.util.EditorUtil;

import std.string : lastIndexOf;

import gtk.Notebook;
import gtk.Builder;

import gsv.SourceBuffer;
import gsv.SourceFile;
import gsv.SourceFileLoader;
import gsv.SourceLanguageManager;

import gio.File;
import gio.Cancellable;
import gio.SimpleAsyncResult;

import coral.component.TabLabel;
import coral.component.SourceEditor;

private const string defaultTitle = "New File";

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

void addNewSourceEditor(Notebook nb, string fullpath = "")
{
  auto sourceEditor = new SourceEditor();
  nb.appendPage(sourceEditor, new TabLabel(fullpath == "" ? defaultTitle : shortName(fullpath), sourceEditor, fullpath));
}

void addNewSourceEditor(Notebook nb, SourceBuffer sb, string fullpath = "")
{
  auto sourceEditor = new SourceEditor(sb);
  nb.appendPage(sourceEditor, new TabLabel(fullpath == "" ? defaultTitle : shortName(fullpath), sourceEditor, fullpath));
}

T getItem(T)(Builder b, string n)
{
  T item = cast(T)b.getObject(n);
  if(item is null)
    throw new Exception("Failed to get object: "~n~" from builder");
  return item;
}

int isFileOpen(Notebook nb, const string fullpath)
{
  for(int i = 0; i < nb.getNPages(); i++)
  {
    const TabLabel tab = cast(TabLabel)nb.getTabLabel(nb.getNthPage(i));
    if(tab.fullPath == fullpath)
      return i;
  }
  return -1;
}

private alias GAsyncReadyCallback = extern (C) void function(GObject* source_object, GAsyncResult* res, void* user_data);
private alias GProgressCallback = extern (C) void function(long, long, void*);
private alias GProgressCallbackNotify = extern (C) void function(void*);
void openFile(Notebook notebook, const string filepath)
{
		int fileNo = isFileOpen(notebook, filepath);
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
			SourceFileLoader loader;
			Notebook notebook;
			SourceBuffer sourceBuf;
		}

		GAsyncReadyCallback finalize = function(GObject* sourceObj, GAsyncResult* result, void* userdat) @trusted
		{
			import coral.util.MemUtil : dealloc;

			auto userDat = cast(UserData)userdat;
			GSimpleAsyncResult* simpleResult = cast(GSimpleAsyncResult*)result;
			if(userDat.loader.loadFinish(new SimpleAsyncResult(simpleResult)))
      {
        addNewSourceEditor(userDat.notebook, userDat.sourceBuf, userDat.filepath);

        userDat.notebook.setCurrentPage(-1);
      }
      // there is need for an else case that notifies the user that their file cannot be opened
			dealloc(userDat);
		};

		import coral.util.MemUtil : alloc;

		auto userDat = alloc!UserData;
		userDat.filepath = filepath;
		userDat.loader = fileLoader;
		userDat.notebook = notebook;
		userDat.sourceBuf = sourceBuffer;

		fileLoader.loadAsync(cast(int)GPriority.DEFAULT, cancellation,
			cast(GProgressCallback)0, cast(void*)0,
			cast(GProgressCallbackNotify)0, finalize, cast(void*)userDat);
}