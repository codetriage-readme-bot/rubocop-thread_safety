# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid mutating class and module attributes.
      #
      # They are implemented by class variables, which are not thread-safe.
      #
      # @example
      #   # bad
      #   class User
      #     cattr_accessor :current_user
      #   end
      class ClassAndModuleAttributes < Cop
        MSG = 'Avoid mutating class and module attributes.'.freeze

        def_node_matcher :mattr?, <<-MATCHER
          (send nil?
            {:mattr_writer :mattr_accessor :cattr_writer :cattr_accessor}
            ...)
        MATCHER

        def_node_matcher :attr?, <<-MATCHER
          (send nil?
            {:attr :attr_accessor :attr_writer}
            ...)
        MATCHER

        def on_send(node)
          return unless mattr?(node) || singleton_attr?(node)
          add_offense(node, message: MSG)
        end

        private

        def singleton_attr?(node)
          attr?(node) && node.ancestors.map(&:type).include?(:sclass)
        end
      end
    end
  end
end
