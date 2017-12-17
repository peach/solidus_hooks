module SolidusHooks
  module Hooks
    class NotificationHook < ApplicationRecord
      has_many :events, as: :eventable, dependent: :destroy

      accepts_nested_attributes_for :events, allow_destroy: true
      has_many :notification_logs, class_name: SolidusHooks::NotificationLog.name

      def notify(record, event_id = self.event_id)
        self.notification_logs.create!(event_id: event_id, record_id: record.id, target_model: record.class.to_s)
      end
    end
  end
end
