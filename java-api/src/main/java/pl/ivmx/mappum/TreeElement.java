/**
 * 
 */
package pl.ivmx.mappum;

import java.util.List;

/**
 * @author Jan Topinski (jtopinski@ivmx.pl)
 *
 */
public interface TreeElement {
  public String getName();
  public void setName(String name);
  public List<TreeElement> getElements();
  public void setElements(List<TreeElement> elems);
  public boolean getIsArray();
  public void setIsArray(boolean isArray);
  public String getClazz();
  public void setClazz(String clazz);

  
}
