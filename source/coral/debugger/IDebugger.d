module coral.debugger.idebugger;

/// A basic interface by which debugger instances
/// should conform. Most debuggers support these interactions
interface IDebugger
{
  void start();
  void stop();
  // -----------
  void stepInto();
  void stepOver();
  void stepOut();
  // ------------
  void cont();
  void pause();
  // ------------
  void setBreakpoint(const string filename, int line);
}