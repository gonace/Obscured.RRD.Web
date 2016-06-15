module Obscured
  module Entities
    class Node
      attr_accessor :name
      attr_accessor :path
      attr_accessor :group
      attr_accessor :type

      def initialize(name, path, group, type)
        @name = name
        @path = path
        @group = group
        @type = type
      end
    end
  end
end