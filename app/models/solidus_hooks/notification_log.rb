module SolidusHooks
  class NotificationLog < ActiveRecord::Base
    belongs_to :event, class_name: SolidusHooks::Observer::Event.name
    belongs_to :notification_hook, class_name: SolidusHooks::Hooks::NotificationHook.name
  end
end
