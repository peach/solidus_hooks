class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  alias_method :backup_assign_nested_attributes_for_collection_association, :assign_nested_attributes_for_collection_association

  def assign_nested_attributes_for_collection_association(association_name, attributes_collection)
    options = self.nested_attributes_options[association_name]
    if attributes_collection.respond_to?(:permitted?)
      attributes_collection = attributes_collection.to_h
    end

    unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
      raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
    end

    check_record_limit!(options[:limit], attributes_collection)

    if attributes_collection.is_a? Hash
      keys = attributes_collection.keys
      attributes_collection = if keys.include?('id') || keys.include?(:id)
                                [attributes_collection]
                              else
                                attributes_collection.values
                              end
    end

    association = association(association_name)

    attributes_collection.each do |attributes|
      if (id = attributes['id']) && ActiveRecord::Type::Boolean.new.cast(attributes.delete('_add'))
        if (record = association.klass.find(id))
          send(association_name) << record
        else
          raise_nested_attributes_record_not_found!(association_name, id)
        end
      end
    end

    backup_assign_nested_attributes_for_collection_association(association_name, attributes_collection)
  end
end
