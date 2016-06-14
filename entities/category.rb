module Obscured
  module Entities
    class Category
      attr_accessor :name
      attr_accessor :graphs

      def initialize(name, graphs = [])
        @name = name
        @graphs = graphs
      end
    end
  end
end