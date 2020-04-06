import java

class DocumentBuilderFactoryMethod extends Method{
DocumentBuilderFactoryMethod(){
  this.getDeclaringType().getQualifiedName()="javax.xml.parsers.DocumentBuilderFactory" and
  (
    //this.getName()="getRuntime" or 
    this.getName()="newInstance"
  )
}
}

class SAXReaderMethod extends Method{
SAXReaderMethod(){
  this.getDeclaringType().getQualifiedName()="org.dom4j.io.SAXReader" and
  this.getName()="read"
}
}

class XMLReaderMethod  extends Method{
XMLReaderMethod(){
  this.getDeclaringType().getQualifiedName()="org.xml.sax.XMLReader" and
  this.getName()="parse"
}
}

class SAXParserFactoryMethod  extends Method{
SAXParserFactoryMethod(){
  this.getDeclaringType().getQualifiedName()="javax.xml.parsers.SAXParserFactory" and
  this.getName()="newInstance"
}
}

class SAXBuilderMethod  extends Method{
SAXBuilderMethod(){
  this.getDeclaringType().getQualifiedName()="org.jdom2.input.SAXBuilder" 
}
}

class SchemaFactoryMethod  extends Method{
SchemaFactoryMethod(){
  this.getDeclaringType().getQualifiedName()="javax.xml.validation.SchemaFactory" and
  this.getName()="newSchema"
}
}

class SAXTransformerFactoryMethod  extends Method{
SAXTransformerFactoryMethod(){
  this.getDeclaringType().getQualifiedName()="javax.xml.transform.sax.SAXTransformerFactory" and
  this.getName()="newInstance"
}
}

class TransformerFactoryMethod  extends Method{
TransformerFactoryMethod(){
  this.getDeclaringType().getQualifiedName()="javax.xml.transform.TransformerFactory" and
  this.getName()="newInstance"
}
}
class DigesterMethod  extends Method{
DigesterMethod(){
  this.getDeclaringType().getQualifiedName()="org.apache.commons.digester.Digester" and
  this.getName()="parse"
}
}

class ValidatorMethod  extends Method{
ValidatorMethod(){
  this.getDeclaringType().getQualifiedName()="javax.xml.validation.Validator" and
  this.getName()="validate"
}
}


from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof DocumentBuilderFactoryMethod  or
 methodaccess.getMethod() instanceof SAXReaderMethod or
 methodaccess.getMethod() instanceof XMLReaderMethod  or
 methodaccess.getMethod() instanceof SAXParserFactoryMethod  or
 methodaccess.getMethod() instanceof SAXBuilderMethod  or
 methodaccess.getMethod() instanceof SchemaFactoryMethod  or
 methodaccess.getMethod() instanceof SAXTransformerFactoryMethod  or
 methodaccess.getMethod() instanceof TransformerFactoryMethod  or
 methodaccess.getMethod() instanceof DigesterMethod or 
 methodaccess.getMethod() instanceof ValidatorMethod

 //漏洞名称，漏洞类名，漏洞方法
select "XXE",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


