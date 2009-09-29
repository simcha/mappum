package pl.ivmx.mappum;

public interface JavaTransform {
  /**
   * Transforms Pojo (plain old java bean)
   * @param from
   * @return
   */
  public Object transform(Object from, String map, Object to);
  public Object transform(Object from, String map);
  public Object transform(Object from);
}