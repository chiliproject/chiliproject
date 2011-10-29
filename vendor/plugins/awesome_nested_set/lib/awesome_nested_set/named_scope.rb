#-- encoding: UTF-8
# Taken from Rails 2.1
module CollectiveIdea #:nodoc:
  module NamedScope #:nodoc:
    # All subclasses of ActiveRecord::Base have two named_scopes:
    # * <tt>all</tt>, which is similar to a <tt>find(:all)</tt> query, and
    # * <tt>scoped</tt>, which allows for the creation of anonymous scopes, on the fly:
    #
    #   Shirt.scoped(:conditions => {:color => 'red'}).scoped(:include => :washing_instructions)
    #
    # These anonymous scopes tend to be useful when procedurally generating complex queries, where passing
    # intermediate values (scopes) around as first-class objects is convenient.
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        named_scope :scoped, lambda { |scope| scope }
      end
    end

    module ClassMethods #:nodoc:
      def scopes
        read_inheritable_attribute(:scopes) || write_inheritable_attribute(:scopes, {})
      end

      # Adds a class method for retrieving and querying objects. A scope represents a narrowing of a database query,
      # such as <tt>:conditions => {:color => :red}, :select => 'shirts.*', :include => :washing_instructions</tt>.
      #
      #   class Shirt < ActiveRecord::Base
      #     named_scope :red, :conditions => {:color => 'red'}
      #     named_scope :dry_clean_only, :joins => :washing_instructions, :conditions => ['washing_instructions.dry_clean_only = ?', true]
      #   end
      # 
      # The above calls to <tt>named_scope</tt> define class methods <tt>Shirt.red</tt> and <tt>Shirt.dry_clean_only</tt>. <tt>Shirt.red</tt>, 
      # in effect, represents the query <tt>Shirt.find(:all, :conditions => {:color => 'red'})</tt>.
      #
      # Unlike Shirt.find(...), however, the object returned by <tt>Shirt.red</tt> is not an Array; it resembles the association object
      # constructed by a <tt>has_many</tt> declaration. For instance, you can invoke <tt>Shirt.red.find(:first)</tt>, <tt>Shirt.red.count</tt>,
      # <tt>Shirt.red.find(:all, :conditions => {:size => 'small'})</tt>. Also, just
      # as with the association objects, name scopes acts like an Array, implementing Enumerable; <tt>Shirt.red.each(&block)</tt>,
      # <tt>Shirt.red.first</tt>, and <tt>Shirt.red.inject(memo, &block)</tt> all behave as if Shirt.red really were an Array.
      #
      # These named scopes are composable. For instance, <tt>Shirt.red.dry_clean_only</tt> will produce all shirts that are both red and dry clean only.
      # Nested finds and calculations also work with these compositions: <tt>Shirt.red.dry_clean_only.count</tt> returns the number of garments
      # for which these criteria obtain. Similarly with <tt>Shirt.red.dry_clean_only.average(:thread_count)</tt>.
      #
      # All scopes are available as class methods on the ActiveRecord descendent upon which the scopes were defined. But they are also available to
      # <tt>has_many</tt> associations. If,
      #
      #   class Person < ActiveRecord::Base
      #     has_many :shirts
      #   end
      #
      # then <tt>elton.shirts.red.dry_clean_only</tt> will return all of Elton's red, dry clean
      # only shirts.
      #
      # Named scopes can also be procedural.
      #
      #   class Shirt < ActiveRecord::Base
      #     named_scope :colored, lambda { |color|
      #       { :conditions => { :color => color } }
      #     }
      #   end
      #
      # In this example, <tt>Shirt.colored('puce')</tt> finds all puce shirts.
      #
      # Named scopes can also have extensions, just as with <tt>has_many</tt> declarations:
      #
      #   class Shirt < ActiveRecord::Base
      #     named_scope :red, :conditions => {:color => 'red'} do
      #       def dom_id
      #         'red_shirts'
      #       end
      #     end
      #   end
      #
      #
      # For testing complex named scopes, you can examine the scoping options using the
      # <tt>proxy_options</tt> method on the proxy itself.
      #
      #   class Shirt < ActiveRecord::Base
      #     named_scope :colored, lambda { |color|
      #       { :conditions => { :color => color } }
      #     }
      #   end
      #
      #   expected_options = { :conditions => { :colored => 'red' } }
      #   assert_equal expected_options, Shirt.colored('red').proxy_options
      def named_scope(name, options = {}, &block)
        scopes[name] = lambda do |parent_scope, *args|
          Scope.new(parent_scope, case options
            when Hash
              options
            when Proc
              options.call(*args)
          end, &block)
        end
        (class << self; self end).instance_eval do
          define_method name do |*args|
            scopes[name].call(self, *args)
          end
        end
      end
    end

    class Scope #:nodoc:
      attr_reader :proxy_scope, :proxy_options
      [].methods.each { |m| delegate m, :to => :proxy_found unless m =~ /(^__|^nil\?|^send|class|extend|find|count|sum|average|maximum|minimum|paginate)/ }
      delegate :scopes, :with_scope, :to => :proxy_scope

      def initialize(proxy_scope, options, &block)
        [options[:extend]].flatten.each { |extension| extend extension } if options[:extend]
        extend Module.new(&block) if block_given?
        @proxy_scope, @proxy_options = proxy_scope, options.except(:extend)
      end

      def reload
        load_found; self
      end

      protected
      def proxy_found
        @found || load_found
      end

      private
      def method_missing(method, *args, &block)
        if scopes.include?(method)
          scopes[method].call(self, *args)
        else
          with_scope :find => proxy_options do
            proxy_scope.send(method, *args, &block)
          end
        end
      end

      def load_found
        @found = find(:all)
      end
    end
  end
end