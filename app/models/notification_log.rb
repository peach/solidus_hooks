class NotificationLog < ActiveRecord::Base
  belongs_to :event, class_name: Observer::Event.name
  belongs_to :notification_hook, class_name: Hooks::NotificationHook.name
end
