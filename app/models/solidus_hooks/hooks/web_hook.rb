module SolidusHooks
  module Hooks
    class WebHook < ApplicationRecord
      has_many :events, as: :eventable, dependent: :destroy

      accepts_nested_attributes_for :events, allow_destroy: true

      def notify(record, event_id = nil)
        event_id ||= events.first.try(:id)
        response = HTTParty.post url, body: {
          hook_id: id,
          event_id: event_id,
          token: listener_token,
          record_id: record.id,
          model: record.class.to_s
        }.to_json
        case response.code
        when 200
          logger.debug("Notification response: #{response.to_json}")
        else
          logger.warn("Notification response: #{response.to_json}")
        end
      rescue Exception => ex
        logger.error("Error on Hook #{id} when notifying: #{ex.message}")
      end
    end
  end
end
