/**
 * 
 */
package pl.ivmx.mappum;

import java.util.List;

import org.jruby.RubyException;
import org.jruby.exceptions.RaiseException;

/**
 * @author Jan Topinski (jtopinski@ivmx.pl)
 *
 */
public class JavaMappumException extends RuntimeException {

  /**
   * 
   */
  public JavaMappumException() {
    super();
  }
  /**
   * @param arg0
   * @param arg1
   */
  public JavaMappumException(String arg0, RubyException arg1) {
    super(arg0, new RaiseException(arg1));
  }
  /**
   * @param arg0
   * @param arg1
   */
  public JavaMappumException(String arg0, Throwable arg1) {
    super(arg0, arg1);
  }
  /**
   * @param arg0
   */
  public JavaMappumException(String arg0) {
    super(arg0);
  }
  /**
   * @param arg0
   */
  public JavaMappumException(Throwable arg0) {
    super(arg0);
  }
  /**
   * @param arg0
   */
  public JavaMappumException(RubyException arg0) {
    super(new RaiseException(arg0));
  }
  private static final long serialVersionUID = 1L;

  private String fromName;
  private String toName;
  private Object from;
  private Object to;
  private Object fromRoot;
  private Object toRoot;
  private List<String> mappumBacktrace;
  /**
   * 
   * 
   * @return the fromName
   */
  public String getFromName() {
    return fromName;
  }
  /**
   * @param fromName the fromName to set
   */
  public void setFromName(String fromName) {
    this.fromName = fromName;
  }
  /**
   * @return the toName
   */
  public String getToName() {
    return toName;
  }
  /**
   * @param toName the toName to set
   */
  public void setToName(String toName) {
    this.toName = toName;
  }
  /**
   * @return the from
   */
  public Object getFrom() {
    return from;
  }
  /**
   * @param from the from to set
   */
  public void setFrom(Object from) {
    this.from = from;
  }
  /**
   * @return the to
   */
  public Object getTo() {
    return to;
  }
  /**
   * @param to the to to set
   */
  public void setTo(Object to) {
    this.to = to;
  }
  /**
   * @return the fromRoot
   */
  public Object getFromRoot() {
    return fromRoot;
  }
  /**
   * @param fromRoot the fromRoot to set
   */
  public void setFromRoot(Object fromRoot) {
    this.fromRoot = fromRoot;
  }
  /**
   * @return the toRoot
   */
  public Object getToRoot() {
    return toRoot;
  }
  /**
   * @param toRoot the toRoot to set
   */
  public void setToRoot(Object toRoot) {
    this.toRoot = toRoot;
  }
  /**
   * @return the mappumBacktrace
   */
  public List<String> getMappumBacktrace() {
    return mappumBacktrace;
  }
  /**
   * @param mappumBacktrace the mappumBacktrace to set
   */
  public void setMappumBacktrace(List<String> mappumBacktrace) {
    this.mappumBacktrace = mappumBacktrace;
  }

}
