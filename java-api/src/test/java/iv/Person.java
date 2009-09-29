package iv;

import java.util.Date;

public class Person {
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
  public static class Phone {
    private String number;
    private String extension;
    private String type;
    public Phone(){
    }
    public Phone(String number){
      this.number = number;
    }
    /**
     * @return the number
     */
    public String getNumber() {
      return number;
    }
    /**
     * @param number the number to set
     */
    public void setNumber(String number) {
      this.number = number;
    }
    /**
     * @return the extension
     */
    public String getExtension() {
      return extension;
    }
    /**
     * @param extension the extension to set
     */
    public void setExtension(String extension) {
      this.extension = extension;
    }
    /**
     * @return the type
     */
    public String getType() {
      return type;
    }
    /**
     * @param type the type to set
     */
    public void setType(String type) {
      this.type = type;
    }
  }
  private String title;
  private String type;
  private String personId;
  private String name;
  private String surname;
  private String sex;
  private String email1;
  private String email2;
  private String email3;
  private Phone mainPhone;
  private Phone[] phones;
  private Address address;
  private String corporation;
  private Person spouse;
  private Date dateUpdated;

  public String getCorporation() {
    return corporation;
  }
  public void setCorporation(String corporation) {
    this.corporation = corporation;
  }
  public Person getSpouse() {
    return spouse;
  }
  public void setSpouse(Person spouse) {
    this.spouse = spouse;
  }
  public Date getDateUpdated() {
    return dateUpdated;
  }
  public void setDateUpdated(Date dateUpdated) {
    this.dateUpdated = dateUpdated;
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
     * @return the type
     */
    public String getType() {
      return type;
    }
    /**
     * @param type the type to set
     */
    public void setType(String type) {
      this.type = type;
    }

  /**
   * @return the personId
   */
  public String getPersonId() {
    return personId;
  }
  /**
   * @param personId the personId to set
   */
  public void setPersonId(String personId) {
    this.personId = personId;
  }
  /**
   * @return the name
   */
  public String getName() {
    return name;
  }
  /**
   * @param name the name to set
   */
  public void setName(String name) {
    this.name = name;
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
   * @return the sex
   */
  public String getSex() {
    return sex;
  }
  /**
   * @param sex the sex to set
   */
  public void setSex(String sex) {
    this.sex = sex;
  }
  /**
   * @return the email1
   */
  public String getEmail1() {
    return email1;
  }
  /**
   * @param email1 the email1 to set
   */
  public void setEmail1(String email1) {
    this.email1 = email1;
  }
  /**
   * @return the email2
   */
  public String getEmail2() {
    return email2;
  }
  /**
   * @param email2 the email2 to set
   */
  public void setEmail2(String email2) {
    this.email2 = email2;
  }
  /**
   * @return the email3
   */
  public String getEmail3() {
    return email3;
  }
  /**
   * @param email3 the email3 to set
   */
  public void setEmail3(String email3) {
    this.email3 = email3;
  }
  /**
   * @return the mainPhone
   */
  public Phone getMainPhone() {
    return mainPhone;
  }
  /**
   * @param mainPhone the mainPhone to set
   */
  public void setMainPhone(Phone mainPhone) {
    this.mainPhone = mainPhone;
  }
  /**
   * @return the phones
   */
  public Phone[] getPhones() {
    return phones;
  }
  /**
   * @param phones the phones to set
   */
  public void setPhones(Phone[] phones) {
    this.phones = phones;
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

