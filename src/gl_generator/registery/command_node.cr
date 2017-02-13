module Registery
  class CommandNode < BaseNode
    def initialize(@xml_node)
      super

      if @xml_node.is_a?(XML::Node)
        name_node = @xml_node.as(XML::Node).xpath_node("proto/name")

        @name = (name_node.try &.content).to_s.strip if name_node.is_a?(XML::Node)
      end
    end

    def internal_name
      (name.underscore.match(/^(gl_)?(.+)$/).try &.[2]).to_s
    end

    def parameters
      params = [] of String

      @xml_node.as(XML::Node).xpath_nodes("param").each do |parameter_node|
        param_name = (parameter_node.xpath_node("name").try &.text).to_s.strip

        parameter_content = parameter_node.children.select(&.text?).join("", &.to_s).squeeze

        # Check if the parameter contains other things then jus type & name
        parameter_residue = parameter_content
        parameter_residue = parameter_residue.sub(/const/, "").strip if parameter_residue =~ /const/

        # Add a * when the parameter is requested
        parameter_ptype = parameter_node.xpath_node("ptype")
        api_type_name = (parameter_ptype ? parameter_ptype.text.to_s.strip : parameter_content.strip)

        # Get the type from the registery or default to oid with an log message
        type_name = parent.as(RootNode).find_child_by_name(api_type_name, TypeNode).try &.as(TypeNode).internal_name

        if type_name
            type_name += "*" if parameter_residue =~ /\*/ || parameter_residue =~/\[.+\]/
        elsif TypeNode::TYPEMAP[parameter_residue]?
          type_name = TypeNode::TYPEMAP[parameter_residue]
        else
          p "UNMAPPED OR MISSING PARAM TYPE: '#{api_type_name}/#{parameter_residue}' (#{name})"
          type_name = "Void"
        end

        params << "#{param_name}: #{type_name}"
      end

      params
    end

    def return_type
      proto_node = @xml_node.as(XML::Node).xpath_node("proto")
      return "Void" unless proto_node

      proto_content = proto_node.children.select(&.text?).map(&.to_s).join("").squeeze

      proto_residue = proto_content
      proto_residue = proto_residue.sub(/const/, "") if proto_residue =~ /const/
      proto_residue = proto_residue.strip

      proto_ptype = proto_node.xpath_node("ptype")
      api_return_type = (proto_ptype ? proto_ptype.text.to_s.strip : proto_content.strip )
      api_return_type = api_return_type.sub(@name, "").strip

      # Get the type from the registery or default to void with an log message
      return_type = parent.as(RootNode).find_child_by_name(api_return_type, TypeNode).try &.as(TypeNode).internal_name

      if return_type
        return_type += "*" if proto_residue =~ /\*/
      elsif TypeNode::TYPEMAP[proto_residue]?
        return_type = TypeNode::TYPEMAP[proto_residue]
      else
        p("UNMAPPED OR MISSING RETURN TYPE: '#{api_return_type}/#{proto_residue}' (#{name})")
        return_type = "Void"
      end

      return_type
    end

    def build
      "fun #{internal_name} = \"#{name}\"(#{parameters.join(", ")}) : #{return_type}"
    end
  end
end
