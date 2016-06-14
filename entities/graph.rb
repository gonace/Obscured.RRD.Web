module Obscured
  module Entities
    class Graph
      attr_accessor :id
      attr_accessor :name
      attr_accessor :image
      attr_accessor :type

      def initialize(id, name, image, type = nil)
        @id = id
        @name = name
        @image = image
        @type = type
      end
    end
  end
end