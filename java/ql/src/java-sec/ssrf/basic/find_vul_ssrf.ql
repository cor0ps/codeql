import java


//https://pplsec.github.io/2018/09/19/JAVA%E4%BB%A3%E7%A0%81%E5%AE%A1%E8%AE%A1%E4%B9%8BXXE%E4%B8%8ESSRF/
class HTTPString extends StringLiteral {
  HTTPString() {
    // Avoid matching "https" here.
    exists(string s | this.getRepresentedString() = s |
      (
        // Either the literal "http", ...
        s = "http"
        or
        // ... or the beginning of a http URL.
        s.matches("http://%")
      ) and
      not s.matches("%/localhost%")
    )
  }
}


class URLOpenMethod extends Method{
URLOpenMethod(){
  this.getDeclaringType().getQualifiedName()="java.net.URL" and
  (
    this.getName()="openConnection" or 
    this.getName()="openStream"
  )
}
}


class InternalHttpClientMethod extends Method{
InternalHttpClientMethod(){
  this.getDeclaringType().getQualifiedName()="org,apache.http.impl.client.InternalHttpClient" 
}
}

class FileURLConnectionMethod extends Method{
FileURLConnectionMethod(){
  this.getDeclaringType().getQualifiedName()="sun.net.www.protocol.file.FileURLConnection" 
}
}

class URLConnectionMethod extends Method{
URLConnectionMethod(){
  this.getDeclaringType().getQualifiedName()="java.net.URLConnection"  and
  this.getName()="getInputStream" 
}
}

class HttpURLConnectionMethod extends Method{
HttpURLConnectionMethod(){
  this.getDeclaringType().getQualifiedName()="java.net.HttpURLConnection" and
  this.getName()="getInputStream"
}
}

class ImageIOMethod extends Method{
ImageIOMethod(){
  this.getDeclaringType().getQualifiedName()="javax.imageio.ImageIO" and
  this.getName()="read"
}
}

class HttpClientMethod extends Method{
HttpClientMethod(){
  this.getDeclaringType().getQualifiedName()="org.apache.http.impl.client.CloseableHttpClient" and
  this.getName()="execute"
}
}


from MethodAccess methodaccess
where 
methodaccess.getMethod() instanceof URLOpenMethod  or
methodaccess.getMethod() instanceof InternalHttpClientMethod  or
methodaccess.getMethod() instanceof FileURLConnectionMethod   or
methodaccess.getMethod() instanceof URLConnectionMethod   or
methodaccess.getMethod() instanceof HttpURLConnectionMethod  or
methodaccess.getMethod() instanceof ImageIOMethod   or
methodaccess.getMethod() instanceof HttpClientMethod
  
 //漏洞名称，漏洞类名，漏洞方法
select "SSRF",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()




