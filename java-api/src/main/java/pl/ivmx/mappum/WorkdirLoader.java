package pl.ivmx.mappum;

import java.util.List;

public interface WorkdirLoader {
  public void generate_and_require();
  public List<TreeElement> definedElementTrees();
  /**
   * Clean tmpdir
   */
  public void cleanup();
}