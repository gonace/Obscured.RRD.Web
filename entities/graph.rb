module Obscured
  module Entities
    class Graph
      attr_accessor :id
      attr_accessor :name
      attr_accessor :image
      attr_accessor :type
      attr_accessor :node

      def initialize(id, name, image, type = nil, node = nil)
        @id = id
        @name = name
        @image = image
        @type = type
        @node = node
      end
    end
  end
end