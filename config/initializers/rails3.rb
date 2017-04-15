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

# https://gist.github.com/akaspick/rails/commit/60d358b23348a14447d176fa51624ad5434eb575
class HTML::Document  
  alias :old_initialize :initialize
  def initialize(doc, *args)
    old_initialize(doc.to_s, *args)
  end
end
