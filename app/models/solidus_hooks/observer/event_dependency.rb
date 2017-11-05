module SolidusHooks
  module Observer
    class EventDependency < ApplicationRecord

      belongs_to :event, class_name: SolidusHooks::Observer::Event.to_s, inverse_of: :event_dependencies

      belongs_to :dependent_event, class_name: SolidusHooks::Observer::Event.to_s, inverse_of: nil

      def trigger_on(event_source)
        if dependent_event
          if (r = dependent_event.target_model.reflect_on_association(association_name))
            dependent_record = dependent_event.target_model.where(id: event_source.send(r.foreign_key)).first
            if dependent_record
              dependent_event.trigger_on(dependent_record)
            end
          else
            logger.warn("Association name #{association_name} could not be found on #{dependent_event.target_model} model via event dependency #:#{id}")
          end
        else
          logger.warn("Broken dependent event reference on dependency #:#{id}")
        end
      end
    end
  end
end
