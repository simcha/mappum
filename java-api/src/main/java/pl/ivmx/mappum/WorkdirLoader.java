package pl.ivmx.mappum;

import java.util.List;

public interface WorkdirLoader {
  public void generateAndRequire();
  public List<TreeElement> definedElementTrees();
  /**
   * Clean tmpdir
   */
  public void cleanup();
}