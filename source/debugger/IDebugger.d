module coral.debugger.IDebugger;

interface IDebugger
{
  void start();
  void stop();
  void close();
  void stepInto();
  void stepOver();
  void stepOut();
}