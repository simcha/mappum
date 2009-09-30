/**
 * 
 */
package pl.ivmx.mappum;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;
import java.util.concurrent.ThreadPoolExecutor;

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
    wl.generateAndRequire();
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
    Person per = newPerson();

    Client cli = null;
    Person person = null;
    JavaTransform jt = mp.getJavaTransform();
    long time = System.currentTimeMillis();
    for (int i = 0; i < 200; i++) {
      cli = (Client) jt.transform(per);     
      person = (Person) jt.transform(cli);
    }
    time = System.currentTimeMillis()-time;
    System.out.println(time);
    assertEquals("2",cli.getSexId());
    assertEquals("Skoryski",cli.getSurname());
    assertEquals("M",person.getSex());
    assertEquals("Skory",person.getName());
  }
  /**
   * @return
   */
  private Person newPerson() {
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
    return per;
  }
  public void testParalel() throws InterruptedException{
    int threads = 2;
    final int loops = 100;
    
    final MappumApi mp = new MappumApi();
    mp.loadMaps();
    final JavaTransform  jt = mp.getJavaTransform();
    
    Runnable  task = new Runnable(){
      
      public void run() {
        
        Person per = newPerson();
        for (int j = 0; j < loops; j++) {
          Client cli = (Client) jt.transform(per); 
          Person person = (Person) jt.transform(cli);
        }
      }
      
    };
    
    List<Thread> tl = new ArrayList<Thread>();
    for (int i = 0; i < threads; i++) {
      Thread th = new Thread(task);
      tl.add(th);
    }
    long time = System.currentTimeMillis();
    for (Thread thread : tl) {
      thread.start();
    }
    for (Thread thread : tl) {
      thread.join();
    }
    time = System.currentTimeMillis()-time;
    System.out.println(time);
  }
  public void testSeparation(){
    MappumApi mp = new MappumApi();
    mp.loadMaps();
    
    MappumApi mp2 = new MappumApi();
    try{
      JavaTransform  jt = mp2.getJavaTransform();
      fail("No maps error should be thrown");
    }catch (Exception e) {
      //ok
    }
  }
}
