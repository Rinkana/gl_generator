module Registery
  class RootNode < BaseNode

    def map(xpath : String, node_class : BaseNode.class)
      return raise "No XML node set!" unless @xml_node

      @xml_node.as(XML::Node).xpath_nodes(xpath).each do |xml_node|
        child_node = node_class.new(xml_node)
        push child_node unless child_node.ignore?
      end
    end

    def build
      children.map{ |c| c.build.to_s }.reject(&.empty?)
    end

  end
end
