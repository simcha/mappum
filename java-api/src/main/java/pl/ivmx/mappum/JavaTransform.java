package pl.ivmx.mappum;

import java.util.Map;

public interface JavaTransform {
  /**
   * Transforms Pojo (plain old java bean)
   * @param from
   * @return transformed object
   */
  public Object transform(Object from);
  /**
   * Transforms Pojo (plain old java bean)
   * @param from
   * @param map name of map to use
   * @return transformed object
   */
  public Object transform(Object from, String map);
    /**
   * Transforms Pojo (plain old java bean)
   * @param from
   * @param map name of map to use
   * @param to object to change
   * @return transformed object
   */
  public Object transform(Object from, String map, Object to);
  /**
   * Transforms Pojo (plain old java bean)
   * @param from
   * @param map name of map to use
   * @param to object to change
   * @param map of options for now use "context" to store context
   * @return transformed object
   */
  public Object transform(Object from, String map, Object to, Map options);
  
  /**
   * Transforms Pojo (plain old java bean)
   * @param from
   * @param map of options for now use "context" to store context
   * @return transformed object
   */
  public Object transform(Object from, Map options);
}
