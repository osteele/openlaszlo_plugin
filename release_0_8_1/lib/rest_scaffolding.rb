# Author:: Oliver Steele, Max Carlson
# Copyright:: Copyright (c) 2006 Oliver Steele, Max Carlson.  All rights reserved.
# License:: MIT License.

require 'action_controller'

module ActionController # :nodoc:
  module RestScaffolding # :nodoc:
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end
    
    # REST Scaffolding provides OpenLaszlo REST actions for creating, reading,
    # updating, and destroying records.
    #
    # Example:
    #
    #  class ContactsController < ActionController::Base
    #    rest_scaffold :contacts
    #  end
    module ClassMethods
      # Adds OpenLaszlo REST actions to the controller.  The options
      # are the same as for ActionView::Scaffolding.scaffold, except
      # that the <tt>:suffix</tt> option is not currently supported.
      #
      # This method adds these actions:
      #  records
      #  page
      #  create
      #  update
      #  delete
      #
      # Additionally, +index+ is a synonyms for +records+.
      def rest_scaffold(model_id, options = {})
        options.assert_valid_keys(:class_name, :suffix)
        
        singular_name = model_id.to_s
        class_name    = options[:class_name] || singular_name.camelize
        plural_name   = singular_name.pluralize
        
        class_eval <<-"end_eval", __FILE__, __LINE__
          def records
            ranges = RangeList.parse(params[:id] || '', :domain_start => 1)
            options = {}
            options[:conditions] = ranges.to_sql_condition unless ranges.empty?
            records = #{class_name}.find :all, options
            count = #{class_name}.count
            response.headers["Content-Type"] = "text/xml"
            render :text => records_xml(records, count)
          end
          alias_method :index, :records
          
          def page
            ranges = RangeList.parse params[:id], :domain_start => 1
            records = #{class_name}.find_pages ranges
            count = #{class_name}.count
            response.headers["Content-Type"] = "text/xml"
            render :text => records_xml(records, count)
          end
          alias_method :pages, :page
          
          def schema
            response.headers["Content-Type"] = "text/xml"
            render :text => schema_xml(#{class_name})
          end
          
          def create
            values = params['id'].split('&').map {|s| s.split('=', 2)}
            record = #{class_name}.new(Hash[*values.flatten])
            response.headers["Content-Type"] = "text/xml"
            if record.save
              render :text => "<create>\#{record.id}</create>"
            else
              render :text => "<error>\#{record.full_messages.join("\n")}</error>"
            end
          end
          
          def update
            values = params['id'].split('&').map {|s| s.split('=', 2)}
            attributes = Hash[*values.flatten]
            id = attributes['id']
            attributes.delete 'id'
            record = #{class_name}.find id
            record.attributes = attributes
            response.headers["Content-Type"] = "text/xml"
            if record.save
              render :text => "<update>\#{record.id}</update>"
            else
              render :text => "<error>\#{record.full_messages.join("\n")}</error>"
            end
          end
          
          def delete
            id = params['id']
            conditions = compute_conditions id
            #{class_name}.delete_all conditions
            response.headers["Content-Type"] = "text/xml"
            render :text => "<deleted id='\#{id}'/>"
          end
          
          private
          def compute_conditions expr
            (expr||'').split(',').map do |subexpr|
              conjuncts = []
              conjuncts << "id=\#{subexpr}" if subexpr =~ /^[0-9]+$/
              if subexpr =~ /^([0-9]*)-([0-9]*)$/
                conjuncts << "\#{$1}<=id" if $1
                conjuncts << "id<\#{$2}" if $2
              end
              '(' + conjuncts.join(' AND ') + ')'
            end.join(' OR ')
          end
          
          def compute_options expr
            options = {}
            conditions = compute_conditions expr
            options[:conditions] = conditions unless conditions.empty?
            return options            
          end
        end_eval
      end
    end
  end
end

ActionController::Base.class_eval do
  include ActionController::RestScaffolding
end
