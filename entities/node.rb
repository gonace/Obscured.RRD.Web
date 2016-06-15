module Obscured
  module Entities
    class Node
      attr_accessor :name
      attr_accessor :type
      attr_accessor :group

      def initialize(name, type, group)
        @name = name
        @type = type
        @group = group
      end
    end
  end
end