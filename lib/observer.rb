
require 'observer/version'

module Observer
  extend ActiveSupport::Concern

  included do
    after_initialize :store_timestamps

    before_save :store_changes

    after_save :run_events_lookup

    after_touch :run_events_lookup
  end

  def timestamps_before
    @time_stamps_before ||= {}
  end

  def changes_before
    @changes_before ||= {}
  end

  def store_timestamps
    all_timestamp_attributes_in_model.each { |attr| timestamps_before[attr] = send(attr) }
  end

  def store_changes
    changes_before.clear
    changes_before.merge!(changes)
    true
  end

  def run_events_lookup
    all_timestamp_attributes_in_model.each do |field|
      if !changes_before.key?(field.to_s) && (before_value = timestamps_before[field]) != (current_value = send(field))
        changes_before[field.to_s] = [before_value, current_value]
      end
    end
    if changes_before.present?
      observer_events.each { |e| e.lookup_on(self, changes_before) }
    end
    changes_before.clear
    store_timestamps
  end

  def observer_events
    self.class.observer_events
  end

  module ClassMethods

    def observer_events
      Observer::Event.where(target_name: to_s)
    end
  end

  def self.table_name_prefix
    'observer_'
  end
end