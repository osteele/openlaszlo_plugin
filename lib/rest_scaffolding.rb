# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# 
# This program is free software.
# You can distribute/modify this program under the same terms as the {OpenLaszlo platform}[http://openlaszlo.org].

module ActionController
  module RestScaffolding # :nodoc:
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def rest_scaffold(model_id, options = {})
        options.assert_valid_keys(:class_name, :suffix)
        
        singular_name = model_id.to_s
        class_name    = options[:class_name] || singular_name.camelize
        plural_name   = singular_name.pluralize
        
        class_eval <<-"end_eval", __FILE__, __LINE__
          def records
            options = compute_options params[:id]
            records = #{class_name}.find :all, options
            response.headers["Content-Type"] = "text/xml"
            render :text => RestHelper::records_xml(records)
          end
          alias_method :index, :records
          
          def page
            expr = params[:id]
            records = []
            for subexpr in expr.split(',') do
              options = {}
              # start, start-, start-end, or -end
              if subexpr =~ /^([0-9]+)?(-([0-9]+)?)?$/
                first = ($1 && $1.to_i) || 1
                last = $2 ? ($3 && $3.to_i) : first
                options[:offset] = first
                options[:limit] = last+1-first if last
              end
              records += #{class_name}.find :all, options
            end
            response.headers["Content-Type"] = "text/xml"
            render :text => RestHelper::records_xml(records)
          end
          
          def schema
            response.headers["Content-Type"] = "text/xml"
            render :text => RestHelper::schema_xml(#{class_name})
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