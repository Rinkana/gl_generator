module Registery
  abstract class BaseNode
    property parent : BaseNode|Nil
    property children = [] of BaseNode
    property xml_node : XML::Node|Nil
    property name : String

    def initialize(@xml_node = nil)
      @name = self.class.to_s + Random.new.rand(1000..9999).to_s
    end

    def parse
    end

    def <<(child_node)
      push(child_node)
    end

    def push(*children : BaseNode)
      children.each do |child_node|
        child_node.parent = self
        child_node.parse
        self.children.push(child_node)
      end
    end

    def ignore?
      return false
    end

    def find_child_by_name(name : String, class_filter : BaseNode.class|Nil = nil)
      if !class_filter.nil?
        children.find{|record| record.name == name && record.class == class_filter}
      else
        children.find{|record| record.name == name}
      end
    end

    def root?
      parent.nil?
    end

    def root
      root? ? self : parent.try &.root
    end

    abstract def build

    def to_s
      @name
    end
  end
end
