module coral.debugger.IDebugger;

interface IDebugger
{
  void start();
  void stop();
  // -----------
  void stepInto();
  void stepOver();
  void stepOut();
  // ------------
  void setBreakpoint(const string filename, int line);
}