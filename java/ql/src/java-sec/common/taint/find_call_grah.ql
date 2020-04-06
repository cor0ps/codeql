import java

//寻找问题类
class ContentTypeHandlerClass extends RefType{
ContentTypeHandlerClass(){
this.getQualifiedName()="org.apache.struts2.rest.handler.ContentTypeHandler"
}
}

//寻找问题方法
class ToObjectMethod extends Method{
    ToObjectMethod(){
        this.getDeclaringType().getASupertype() instanceof ContentTypeHandlerClass
        and this.hasName("toOject")
    }
}


