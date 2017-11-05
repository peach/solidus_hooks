module SolidusHooks
  module Observer
    class Event < ApplicationRecord
      serialize :triggers

      has_many :event_dependencies, class_name: SolidusHooks::Observer::EventDependency.to_s, inverse_of: :event

      before_save :check_triggers

      after_save :store_sub_events

      def check_triggers
        @sub_events = {}
        checked = {}
        if triggers.blank?
          errors.add(:triggers, "can't be blank")
        else
          triggers.each do |field, cond|
            if target_model.attribute_names.include?(field.to_s)
              checked[field] = cond
            else
              if (r = target_model.reflect_on_association(field))
                if cond.is_a?(Hash)
                  if (sub_event = self.class.new(triggers: cond.deep_dup, target_name: r.klass)).valid?
                    dependency = SolidusHooks::Observer::EventDependency.new(association_name: field)
                    dependency.dependent_event = self
                    @sub_events[sub_event] = dependency
                  else
                    errors.add(:triggers, "association #{field} is not valid: #{sub_event.errors.full_messages.to_sentence}")
                  end
                else
                  errors.add(:triggers, "conditions for association #{field} should be a Hash")
                end
              else
                errors.add(:triggers, "contains non attribute, nor association entry: #{field}")
              end
            end
          end
        end
        if errors.blank?
          self.triggers = checked
          true
        else
          false
        end
      end

      def store_sub_events
        (@sub_events || {}).each do |sub_event, dependency|
          sub_event.save && (sub_event.event_dependencies << dependency)
        end
      end

      def target_model
        @target_model ||= target_name.constantize
      end

      def applies_to?(changes, triggers = self.triggers)
        or_triggers = triggers['$or']
        and_result = triggers.present? && (or_triggers.nil? || triggers.size > 1)
        triggers.each do |field, cond|
          next if field == '$or'
          and_result &&= (values = changes[field]) && apply?(cond, *values)
          unless and_result
            if or_triggers
              break
            else
              return false
            end
          end
        end
        and_result || (or_triggers && or_triggers.any? { |t| applies_to?(changes, t) })
      end

      # Determines if a condition applies to a given pair of old-new values. If the condition
      # is a Hash then each entry must define an operator and a respective constraint.
      #
      # For example:
      #
      #   { "checked": true }
      #
      # applies when the <tt>checked</tt> attribute becomes true, while
      #
      #    { "price": { "$get": 100, "$lt": 250 } }
      #
      # applies when the <tt>price</tt> becomes greater or equals than 100.
      #
      def apply?(cond, old_value, new_value)
        if cond.is_a?(Hash)
          return false if apply_hash?(cond, old_value, new_value)
          return false unless apply_hash?(cond, new_value, old_value)
        else
          old_value != cond && cond == new_value
        end
        true
      end

      def apply_hash?(cond, value, other)
        cond.each do |op, constraint|
          if (match = op.to_s.match(/\A\$(.+)/))
            begin
              operator = "apply_#{match[1]}_operator?"
              if operator == 'apply_changes_operator?'
                return false unless apply_changes_operator?(value, other, constraint)
              else
                return false unless send(operator, value, constraint)
              end
            rescue Exception => ex
              fail "Error executing operator #{op}: #{ex.message}"
            end
          else
            fail "Invalid operator #{op}"
          end
        end
        true
      end


      # Evaluator for <tt>$present</tt> operator.
      #
      # Usage example:
      #
      #   { "created_at": { "$present": true }  }
      #
      def apply_present_operator?(value, constraint)
        if constraint
          value.present?
        else
          value.blank?
        end
      end

      # Evaluator for <tt>$changes</tt> operator. If the operator constraint
      # truthy value is not true then the operator does not applies.
      #
      # Usage example:
      #
      #   { "updated_at": { "$changes": true }  }
      #
      def apply_changes_operator?(value, other, constraint)
        constraint && (value != other)
      end

      # Evaluator for <tt>$ne</tt> operator.
      #
      # For example:
      #
      #    { "color": { "$ne": "yellow"" } }
      #
      # applies when a "yellow" <tt>color</tt> attribute takes another value.
      #
      def apply_ne_operator?(value, constraint)
        !value.eql?(constraint)
      end


      # Evaluator for <tt>$gt</tt> operator.
      #
      # For example:
      #
      #    { "price": { "$gt": 100 } }
      #
      # applies when the <tt>price</tt> becomes greater than 100.
      #
      def apply_gt_operator?(value, constraint)
        value > constraint
      end

      # Evaluator for <tt>$gte</tt> operator.
      #
      # For example:
      #
      #    { "price": { "$gte": 100 } }
      #
      # applies when the <tt>price</tt> becomes greater than or equals to 100.
      #
      def apply_gte_operator?(value, constraint)
        value >= constraint
      end

      # Evaluator for <tt>$lt</tt> operator.
      #
      # For example:
      #
      #    { "price": { "$lt": 100 } }
      #
      # applies when the <tt>price</tt> becomes less than 100.
      #
      def apply_lt_operator?(value, constraint)
        value < constraint
      end

      # Evaluator for <tt>$lte</tt> operator.
      #
      # For example:
      #
      #    { "price": { "$lte": 100 } }
      #
      # applies when the <tt>price</tt> becomes less than or equals to 100.
      #
      def apply_lte_operator?(value, constraint)
        value <= constraint
      end

      # Evaluator for <tt>$in</tt> operator.
      #
      # For example:
      #
      #    { "color": { "$in": ["red", "green", "blue"] } }
      #
      # applies when a non RGB <tt>color</tt> takes one of the RGB values.
      #
      def apply_in_operator?(value, constraint)
        constraint.include?(value)
      end

      # Evaluator for <tt>$nin</tt> operator.
      #
      # For example:
      #
      #    { "color": { "$nin": ["red", "green", "blue"] } }
      #
      # applies when an RGB <tt>color</tt> becomes a non RGB value.
      #
      def apply_nin_operator?(value, constraint)
        constraint.exclude?(value)
      end

      def lookup_on(record, changes = nil)
        changes ||= record.changes
        if applies_to?(changes)
          trigger_on(record)
        end
      end

      def trigger_on(record)
        logger.debug("Triggering #{self} on record #{target_model} ##{record.id}")
        self.class.trigger(self, record)
        event_dependencies.each { |dependency| dependency.trigger_on(record) }
      end

      def to_s
        str = "Event ##{id}"
        str = "#{str} '#{name}'" if name.present?
        str
      end

      class << self

        def triggered_callbacks
          @triggered_callbacks ||= []
        end

        def when_triggered(&block)
          triggered_callbacks << block if block
        end

        def trigger(event, source)
          if triggered_callbacks.present?
            triggered_callbacks.each do |callback|
              args =
                case callback.arity
                when 0
                  []
                when 1
                  [source]
                else
                  [source, event]
                end
              callback.call(*args)
            end
          else
            logger.warn 'No triggers callbacks defined'
          end
        end

        def define_attribute(name, cast_type, default: NO_DEFAULT_PROVIDED, user_provided_default: true)
          if name == 'triggers'
            default = {}
            cast_type = HashType.new
          end
          super
        end
      end

      class HashType < ActiveRecord::Type::Text

        def cast_value(value)
          if value.is_a?(Hash)
            value
          else
            JSON.parse(value).to_hash
          end.with_indifferent_access
        end

        def serialize(value)
          if value.is_a?(String)
            value
          else
            value.to_json
          end
        end
      end
    end
  end
end
