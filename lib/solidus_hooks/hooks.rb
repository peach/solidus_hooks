require 'solidus_hooks/hooks/version'
require 'solidus_hooks/observer/event'
module SolidusHooks
  module Hooks
    def self.table_name_prefix
      'hooks_'
    end
  end
end

SolidusHooks::Observer::Event.when_triggered do |record, event|
  event.eventable.notify(record, event.id) if event.eventable.present?
end
