require 'solidus_hooks/hooks/version'
require 'solidus_hooks/observer/event'
module SolidusHooks
  module Hooks
    def self.table_name_prefix
      'hooks_'
    end
  end

  class Observer::Event
    has_and_belongs_to_many :hooks,
                            join_table: 'events_hooks',
                            foreign_key: 'hook_id',
                            association_foreign_key: 'event_id',
                            class_name: SolidusHooks::Hooks::NotificationHook.to_s

    accepts_nested_attributes_for :hooks, allow_destroy: true
  end
end

SolidusHooks::Observer::Event.when_triggered do |record, event|
  event.hooks.each { |hook| hook.notify(record, event.id) }
end
