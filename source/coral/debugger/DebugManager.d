module coral.debugger.manager;

import coral.debugger.idebugger;

DebugManager debugManager;

void initDebugManager()
{
  debugManager = new DebugManager();
}

void deinitDebugManager()
{
  debugManager.clearAll();
}

/// This class exists to ensure that all debuggers
/// are shut down at the programs end
class DebugManager
{
  ~this()
  {
    stopAll();
  }
  T newSession(T : IDebugger, Args...)(Args a)
  {
    T session = new T(a);
    registerSession(session);
    return session;
  }
  void registerSession(IDebugger instance)
  {
    synchronized(this) debugInstances ~= instance;
  }
  void stopAll()
  {
    synchronized(this)
    { 
      foreach(instance; debugInstances)
        instance.stop();
    }
  }
  void clearAll()
  {
    synchronized(this)
    {
      stopAll();
      debugInstances = [];
    }
  }
  private IDebugger[] debugInstances;
}
