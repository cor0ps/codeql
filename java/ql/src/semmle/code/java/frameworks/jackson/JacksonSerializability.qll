/**
 * Provides classes and predicates for working with Java Serialization in the context of
 * the `com.fasterxml.jackson` JSON processing framework.
 */

import java
import semmle.code.java.Serializability
import semmle.code.java.Reflection
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.DataFlow5

class JacksonJSONIgnoreAnnotation extends NonReflectiveAnnotation {
  JacksonJSONIgnoreAnnotation() {
    exists(AnnotationType anntp | anntp = this.getType() |
      anntp.hasQualifiedName("com.fasterxml.jackson.annotation", "JsonIgnore")
    )
  }
}

abstract class JacksonSerializableType extends Type { }

/**
 * A method used for serializing objects using Jackson. The final parameter is the object to be
 * serialized.
 */
library class JacksonWriteValueMethod extends Method {
  JacksonWriteValueMethod() {
    (
      getDeclaringType().hasQualifiedName("com.fasterxml.jackson.databind", "ObjectWriter") or
      getDeclaringType().hasQualifiedName("com.fasterxml.jackson.databind", "ObjectMapper")
    ) and
    getName().matches("writeValue%") and
    getParameter(getNumberOfParameters() - 1).getType() instanceof TypeObject
  }
}

library class ExplicitlyWrittenJacksonSerializableType extends JacksonSerializableType {
  ExplicitlyWrittenJacksonSerializableType() {
    exists(MethodAccess ma |
      // A call to a Jackson write method...
      ma.getMethod() instanceof JacksonWriteValueMethod and
      // ...where `this` is used in the final argument, indicating that this type will be serialized.
      usesType(ma.getArgument(ma.getNumArgument() - 1).getType(), this)
    )
  }
}

library class FieldReferencedJacksonSerializableType extends JacksonSerializableType {
  FieldReferencedJacksonSerializableType() {
    exists(JacksonSerializableField f | usesType(f.getType(), this))
  }
}

abstract class JacksonDeserializableType extends Type { }

private class TypeLiteralToJacksonDatabindFlowConfiguration extends DataFlow5::Configuration {
  TypeLiteralToJacksonDatabindFlowConfiguration() {
    this = "TypeLiteralToJacksonDatabindFlowConfiguration"
  }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof TypeLiteral }

  override predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess ma, Method m, int i |
      ma.getArgument(i) = sink.asExpr() and
      m = ma.getMethod() and
      m.getParameterType(i) instanceof TypeClass and
      exists(RefType decl | decl = m.getDeclaringType() |
        decl.hasQualifiedName("com.fasterxml.jackson.databind", "ObjectReader") or
        decl.hasQualifiedName("com.fasterxml.jackson.databind", "ObjectMapper") or
        decl.hasQualifiedName("com.fasterxml.jackson.databind.type", "TypeFactory")
      )
    )
  }

  TypeLiteral getSourceWithFlowToJacksonDatabind() { hasFlow(DataFlow::exprNode(result), _) }
}

library class ExplicitlyReadJacksonDeserializableType extends JacksonDeserializableType {
  ExplicitlyReadJacksonDeserializableType() {
    exists(TypeLiteralToJacksonDatabindFlowConfiguration conf |
      usesType(conf.getSourceWithFlowToJacksonDatabind().getTypeName().getType(), this)
    )
  }
}

library class FieldReferencedJacksonDeSerializableType extends JacksonDeserializableType {
  FieldReferencedJacksonDeSerializableType() {
    exists(JacksonDeserializableField f | usesType(f.getType(), this))
  }
}

class JacksonSerializableField extends SerializableField {
  JacksonSerializableField() {
    exists(JacksonSerializableType superType |
      superType = getDeclaringType().getASupertype*() and
      not superType instanceof TypeObject and
      superType.fromSource()
    ) and
    not this.getAnAnnotation() instanceof JacksonJSONIgnoreAnnotation
  }
}

class JacksonDeserializableField extends DeserializableField {
  JacksonDeserializableField() {
    exists(JacksonDeserializableType superType |
      superType = getDeclaringType().getASupertype*() and
      not superType instanceof TypeObject and
      superType.fromSource()
    ) and
    not this.getAnAnnotation() instanceof JacksonJSONIgnoreAnnotation
  }
}

/**
 * A call to the `addMixInAnnotations` or `addMixIn` Jackson method.
 *
 * This informs Jackson to treat the annotations on the second class argument as if they were on
 * the first class argument. This allows adding annotations to library classes, for example.
 */
class JacksonAddMixinCall extends MethodAccess {
  JacksonAddMixinCall() {
    exists(Method m |
      m = this.getMethod() and
      m.getDeclaringType().hasQualifiedName("com.fasterxml.jackson.databind", "ObjectMapper")
    |
      m.hasName("addMixIn") or
      m.hasName("addMixInAnnotations")
    )
  }

  /**
   * Gets a possible type for the target of the mixing, if any can be deduced.
   */
  RefType getATarget() { result = inferClassParameterType(getArgument(0)) }

  /**
   * Gets a possible type that will be mixed in, if any can be deduced.
   */
  RefType getAMixedInType() { result = inferClassParameterType(getArgument(1)) }
}

/**
 * A Jackson annotation.
 */
class JacksonAnnotation extends Annotation {
  JacksonAnnotation() { getType().getPackage().hasName("com.fasterxml.jackson.annotation") }
}

/**
 * A type used as a Jackson mixin type.
 */
class JacksonMixinType extends ClassOrInterface {
  JacksonMixinType() { exists(JacksonAddMixinCall mixinCall | this = mixinCall.getAMixedInType()) }

  /**
   * Gets a type that this type is mixed into.
   */
  RefType getATargetType() {
    exists(JacksonAddMixinCall mixinCall | this = mixinCall.getAMixedInType() |
      result = mixinCall.getATarget()
    )
  }

  /**
   * Gets a callable from this type that is mixed in by Jackson.
   */
  Callable getAMixedInCallable() {
    result = getACallable() and
    (
      result.(Constructor).isDefaultConstructor() or
      result.getAnAnnotation() instanceof JacksonAnnotation or
      result.getAParameter().getAnAnnotation() instanceof JacksonAnnotation
    )
  }

  /**
   * Gets a field that is mixed in by Jackson.
   */
  Field getAMixedInField() {
    result = getAField() and
    result.getAnAnnotation() instanceof JacksonAnnotation
  }
}

class JacksonMixedInCallable extends Callable {
  JacksonMixedInCallable() {
    exists(JacksonMixinType mixinType | this = mixinType.getAMixedInCallable())
  }

  /**
   * Gets a candidate target type that this callable can be mixed into.
   */
  RefType getATargetType() {
    exists(JacksonMixinType mixinType | this = mixinType.getAMixedInCallable() |
      result = mixinType.getATargetType()
    )
  }

  /**
   * Gets a callable on a possible target that this is mixed into.
   */
  Callable getATargetCallable() {
    exists(RefType targetType | targetType = getATargetType() |
      result = getATargetType().getACallable() and
      if this instanceof Constructor
      then
        // The mixed in type will have a different name to the target type, so just compare the
        // parameters.
        result.getSignature().suffix(targetType.getName().length()) =
          getSignature().suffix(getDeclaringType().getName().length())
      else
        // Signatures should match
        result.getSignature() = getSignature()
    )
  }
}
