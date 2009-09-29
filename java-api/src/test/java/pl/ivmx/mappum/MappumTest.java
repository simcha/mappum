/**
 * 
 */
package pl.ivmx.mappum;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import iv.Client;
import iv.Person;
import junit.framework.TestCase;

/**
 * @author Jan Topinski (jtopinski@ivmx.pl)
 *
 */
public class MappumTest extends TestCase {

  /* (non-Javadoc)
   * @see junit.framework.TestCase#setUp()
   */
  protected void setUp() throws Exception {
    super.setUp();
  }
  public void testGetDefinedElementTrees(){
    MappumApi mp = new MappumApi();
    WorkdirLoader wl = mp.getWorkdirLoader("../sample/server/schema","../sample/server/map",null);
    wl.generate_and_require();
    List<TreeElement> ls =  wl.definedElementTrees();
    TreeElement treeElement = ls.get(0);
    assertEquals(null,treeElement.getClazz());
    assertEquals("Client",treeElement.getName());
    assertEquals(false,treeElement.getIsArray());
    assertEquals(10,treeElement.getElements().size());
    wl.cleanup();
  }

  public void testTransform(){
    MappumApi mp = new MappumApi();
    mp.loadMaps();
    Person per = new Person();
    per.setTitle("sir");
    per.setType("NaN");
    per.setPersonId("asddsa");
    per.setSex("M");
    per.setName("Skory");
    per.setEmail1("j@j.com");
    per.setEmail2("k@k.com");
    per.setEmail3("l@l.com");
    per.setAddress(new Person.Address());
    per.getAddress().setStreet("Victoria");
    per.setPhones(new Person.Phone[]{new Person.Phone("21311231"), new Person.Phone("21311232")});
    per.setMainPhone(new Person.Phone());
    per.getMainPhone().setNumber("09876567");
    per.getMainPhone().setType("mobile");
    per.setCorporation("Corporation l.t.d.");
    per.setDateUpdated(Calendar.getInstance().getTime());
    per.setSpouse(new Person());
    per.getSpouse().setName("Linda");

    long time = System.currentTimeMillis();
    Client cli = null;
    Person person = null;
    JavaTransform jt = mp.getJavaTransform();
    for (int i = 0; i < 10; i++) {
      cli = (Client) jt.transform(per);     
      person = (Person) jt.transform(cli);
    }
    time = System.currentTimeMillis()-time;
    System.out.print(time);
    assertEquals("2",cli.getSexId());
    assertEquals("Skoryski",cli.getSurname());
    assertEquals("M",person.getSex());
    assertEquals("Skory",person.getName());
  }
}
