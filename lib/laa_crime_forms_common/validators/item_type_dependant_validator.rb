module LaaCrimeFormsCommon
  module Validators
    class ItemTypeDependantValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        item_type = item_type_for(record)

        record.errors.add(attribute, :blank, item_type:) if value.blank?
        record.errors.add(attribute, :not_a_number, item_type:) if value.is_a?(String)
        record.errors.add(attribute, :greater_than, item_type:) if value.to_i.negative?
      end

      def item_type_for(record)
        basic = record.respond_to?(:item_type) ? record.item_type || 'item' : 'item'
        basic.pluralize
      end
    end
  end
end
