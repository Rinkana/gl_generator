module Registery
  class EnumNode < BaseNode
    PREFIX = "E_" # enum prefix

    TYPES = {
      "ul": "_u32",
      "ull": "_u64"
    }

    property value = ""
    #property type = ""

    def initialize(@xml_node)
      super

      if @xml_node.is_a?(XML::Node)
        @name = @xml_node.as(XML::Node)["name"].to_s
        @name = (name.match(/^(GL_)?(.+)$/).try &.[2]).to_s
      end
    end

    def value
      if @xml_node.is_a?(XML::Node)
        @value = @xml_node.as(XML::Node)["value"].to_s
      end

      @value = @value + parse_type.to_s

      @value
    end

    def parse_type
      return unless @xml_node.is_a?(XML::Node)
      type_attr = @xml_node.as(XML::Node)["type"]?.to_s

      return TYPES[type_attr] if type_attr && TYPES.has_key?(type_attr)

      return TYPES["ul"].to_s if @value.starts_with?("0x")

      ""
    end

    def ignore?
      return true if TypeNode::IGNORED_APIS.includes?(@xml_node.try &.["api"]?)
      false
    end

    def build
      "#{PREFIX}#{name} = #{value}"
    end

  end
end
