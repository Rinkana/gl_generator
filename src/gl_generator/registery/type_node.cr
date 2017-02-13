module Registery
  class TypeNode < BaseNode
    TYPEMAP = {
      "char": "UInt8",
      "signed char": "Int8",
      "unsigned char": "UInt8",
      "short": "Int16",
      "signed short": "Int16",
      "unsigned short": "UInt16",
      "int": "Int32",
      "signed int": "Int32",
      "unsigned int": "UInt32",
      "int64_t": "Int64",
      "uint64_t": "UInt64",
      "float": "Float32",
      "double": "Float64",
      "ptrdiff_t": "Int32",#"Void*",#"PtrDiffT",
      "void": "Void",
      "void *": "Void*",
      "void *const*": "Void*"
    }

    # For when the typemap does not hold up
    NAMEMAP = {
      "GLhandleARB": "Void*",
      "GLsync": "Void*",
      "GLDEBUGPROC": "Void*",
      "GLDEBUGPROCARB": "Void*",
      "GLDEBUGPROCKHR": "Void*",
      "GLDEBUGPROCAMD": "Void*",
      "struct _cl_context": "Void*",
      "struct _cl_event": "Void*"
    }

    IGNORED_NAMES = %w(stddef khrplatform inttypes)
    IGNORED_APIS = %w(gles1 gles2 glsc2)

    property internal_name = ""
    property c_typedef = ""

    def parse # Called when added as a child
      parse_name
      parse_c_typedef
      parse_internal_name
    end

    # Get the definition name from the name attr or name node
    def parse_name
      return unless @xml_node.is_a?(XML::Node)

      name_attr = @xml_node.as(XML::Node)["name"]?
      @name = name_attr if name_attr

      name_node = @xml_node.as(XML::Node).xpath_node("name")
      @name = (name_node.try &.content).to_s.strip if name_node.is_a?(XML::Node)

      @name
    end

    def parse_c_typedef
      return unless @xml_node.is_a?(XML::Node)

      content = (@xml_node.try &.content).to_s
      @c_typedef = @name ? content.chomp(@name + ";").sub("typedef ","").strip : "TODO"

      @c_typedef
    end

    def parse_internal_name
      @internal_name = TYPEMAP[@c_typedef] if TYPEMAP[@c_typedef]?
      @internal_name = NAMEMAP[@name] if NAMEMAP[@name]?

      api_type = root.as(RootNode).find_child_by_name(@c_typedef, TypeNode).try &.as(TypeNode).internal_name
      @internal_name = api_type if api_type

      if @internal_name.empty?
        p "UNABLE TO MATCH TYPE #{@name} (#{@c_typedef})"
        @internal_name = "Void"
      end

      @internal_name
    end

    def ignore?
      return true if IGNORED_NAMES.includes?(parse_name)
      return true if IGNORED_APIS.includes?(@xml_node.try &.["api"]?)
      false
    end

    def build; end

  end
end
