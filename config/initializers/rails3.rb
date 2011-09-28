# RAILS_ROOT = Rails.root

class ActiveModel::Errors
  alias :length :size
end

class ActiveRecord::Base
  alias :callback :run_callbacks
  
  def self.merge_conditions(*conditions)
    segments = []

    conditions.each do |condition|
      unless condition.blank?
        sql = sanitize_sql(condition)
        segments << sql unless sql.blank?
      end
    end

    "(#{segments.join(') AND (')})" unless segments.empty?
  end
end
