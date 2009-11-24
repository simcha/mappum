package iv;

import java.util.Date;
import java.util.Set;

public class Client {
  
  /**
   * @author Jan Topinski (jtopinski@ivmx.pl)
   *
   */
  public static class Address {
    private String street;
    private String city;
    /**
     * @return the street
     */
    public String getStreet() {
      return street;
    }
    /**
     * @param street the street to set
     */
    public void setStreet(String street) {
      this.street = street;
    }
    /**
     * @return the city
     */
    public String getCity() {
      return city;
    }
    /**
     * @param city the city to set
     */
    public void setCity(String city) {
      this.city = city;
    }
  }
  public static class NameType {
    private String name;
    private String type;
    /**
     * @return the street
     */
    public String getName() {
      return name;
    }
    /**
     * @param street the street to set
     */
    public void setName(String name) {
      this.name = name;
    }
    /**
     * @return the city
     */
    public String getType() {
      return type;
    }
    /**
     * @param city the city to set
     */
    public void setType(String type) {
      this.type = type;
    }
  }
  private String test;
  private String title;
  private String cid;
  private String first_name;
  private String surname;
  private String sexId;
  private String[] phones;
  private String[] emails;
  private String mainPhone;
  private String mainPhoneType;
  private Address address;
  private String orderBy;
  private Set<NameType> partners;
  private Date updated;

  public Date getUpdated() {
    return updated;
  }
  public void setUpdated(Date updated) {
    this.updated = updated;
  }
  public String getOrderBy() {
    return orderBy;
  }

  public void setOrderBy(String orderBy) {
    this.orderBy = orderBy;
  }
  public Set<NameType> getPartners() {
    return partners;
  }

  public void setPartners(Set<NameType> partners) {
    this.partners = partners;
  }
  /**
   * @return the test
   */
  public String getTest() {
    return test;
  }
  /**
   * @param test the test to set
   */
  public void setTest(String test) {
    this.test = test;
  }
  /**
   * @return the title
   */
  public String getTitle() {
    return title;
  }
  /**
   * @param title the title to set
   */
  public void setTitle(String title) {
    this.title = title;
  }
  /**
   * @return the id
   */
  public String getCid() {
    return cid;
  }
  /**
   * @param id the id to set
   */
  public void setCid(String id) {
    this.cid = id;
  }
  /**
   * @return the first_name
   */
  public String getFirst_name() {
    return first_name;
  }
  /**
   * @param first_name the first_name to set
   */
  public void setFirst_name(String first_name) {
    this.first_name = first_name;
  }
  /**
   * @return the surname
   */
  public String getSurname() {
    return surname;
  }
  /**
   * @param surname the surname to set
   */
  public void setSurname(String surname) {
    this.surname = surname;
  }
  /**
   * @return the sexId
   */
  public String getSexId() {
    return sexId;
  }
  /**
   * @param sexId the sexId to set
   */
  public void setSexId(String sexId) {
    this.sexId = sexId;
  }
  /**
   * @return the phones
   */
  public String[] getPhones() {
    return phones;
  }
  /**
   * @param phones the phones to set
   */
  public void setPhones(String[] phones) {
    this.phones = phones;
  }
  /**
   * @return the emails
   */
  public String[] getEmails() {
    return emails;
  }
  /**
   * @param emails the emails to set
   */
  public void setEmails(String[] emails) {
    this.emails = emails;
  }
  /**
   * @return the mainPhone
   */
  public String getMainPhone() {
    return mainPhone;
  }
  /**
   * @param mainPhone the mainPhone to set
   */
  public void setMainPhone(String mainPhone) {
    this.mainPhone = mainPhone;
  }
  /**
   * @return the mainPhoneType
   */
  public String getMainPhoneType() {
    return mainPhoneType;
  }
  /**
   * @param mainPhoneType the mainPhoneType to set
   */
  public void setMainPhoneType(String mainPhoneType) {
    this.mainPhoneType = mainPhoneType;
  }
  /**
   * @return the address
   */
  public Address getAddress() {
    return address;
  }
  /**
   * @param address the address to set
   */
  public void setAddress(Address address) {
    this.address = address;
  }
  

}

