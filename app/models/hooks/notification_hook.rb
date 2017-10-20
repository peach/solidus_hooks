module Hooks
  class NotificationHook < ApplicationRecord
    has_and_belongs_to_many :events,
                            join_table: 'events_hooks',
                            foreign_key: 'event_id',
                            association_foreign_key: 'hook_id',
                            class_name: Observer::Event.to_s

    accepts_nested_attributes_for :events, allow_destroy: true
    has_many :notification_logs, class_name: NotificationLog.name

    def notify(record, event_id = self.event_id)
      self.notification_logs.create!(event_id: event_id, record_id: record.id, target_model: record.class.to_s)
    end
  end
end
