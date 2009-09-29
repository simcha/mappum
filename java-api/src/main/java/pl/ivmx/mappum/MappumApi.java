package pl.ivmx.mappum;

import javax.script.ScriptContext;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

public class MappumApi {
  private MappumApi rubyMappum;

  public MappumApi() {
    this(true);
  }
  public MappumApi(boolean initialize){
    if(initialize){
      ScriptEngineManager m = new ScriptEngineManager();
      ScriptEngine rubyEngine = m.getEngineByName("jruby");
      ScriptContext context = rubyEngine.getContext();
      //context.setAttribute("this_mappum",this, ScriptContext.ENGINE_SCOPE);
      try {
        String script = "require 'mappum/java_transform'\n" +
            "return Mappum::JavaApi.new\n";
        Object o = rubyEngine.eval(script, context);
        rubyMappum = (MappumApi) o;
      } catch (ScriptException e) {
        throw new RuntimeException(e);
      }
    }
  }
  @SuppressWarnings("unused")
  private void setRubyImpl(MappumApi mappum) {
    rubyMappum = mappum;
  }


  public WorkdirLoader getWorkdirLoader() {
    return getWorkdirLoader(null,null,null);
  }
  public WorkdirLoader getWorkdirLoader(String schemaPath, String mapDir,String basedir) {
    return rubyMappum.getWorkdirLoader(schemaPath, mapDir, basedir);
  }

  /**
   * Load maps from class patch. Old definitions are removed first.
   * 
   */ 
  public void loadMaps() {
    loadMaps(null);
  }
  /**
   * Load maps from class patch. Old definitions are removed first.
   * 
   * @param dir - directory to load maps from (all jars and folders are scanned)
   */ 
  public void loadMaps(String dir) {
    loadMaps(dir, true);
  }
  /**
   * Load maps from class patch.
   * 
   * @param dir - directory to load maps from (all jars and folders are scanned)
   * @param reload - when true (default) old definitions are removed first
   */ 
  public void loadMaps(String dir, boolean reload) {
    rubyMappum.loadMaps(dir, reload);
  }
  public JavaTransform getJavaTransform(){
    return getJavaTransform(null);    
  }
  public JavaTransform getJavaTransform(String catalogue){
    return rubyMappum.getJavaTransform(catalogue);    
  }
}
