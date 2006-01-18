class <%= class_name %>Controller < ApplicationController
  # The following line can be used instead of the generated definitions
  # of records, page, schema, create, etc.  The generated definitions
  # are provided as a starting point in case you need to modify them.
  #
  #rest_scaffold :<%= singular_name %>
  
  def records
    # The default route places the range list in the id parameter.
    # Retrieve it from there so that this action works with the default
    # route.
    ranges = RangeList.parse(params[:id] || '', :domain_start => 1)
    options = {}
    options[:conditions] = ranges.to_sql_condition unless ranges.empty?
    records = <%= class_name %>.find :all, options
    response.headers["Content-Type"] = "text/xml"
    render :text => RestHelper::records_xml(records)
  end
  alias_method :index, :records
  
  def page
    ranges = RangeList.parse params[:id], :domain_start => 1
    records = ranges.pages_for <%= class_name %>
    response.headers["Content-Type"] = "text/xml"
    render :text => RestHelper::records_xml(records)
  end
  alias_method :pages, :page
  
  def schema
    response.headers["Content-Type"] = "text/xml"
    render :text => RestHelper::schema_xml(<%= class_name %>)
  end
  
  def create
    values = params['id'].split('&').map {|s| s.split('=', 2)}
    record = <%= class_name %>.new(Hash[*values.flatten])
    response.headers["Content-Type"] = "text/xml"
    if record.save
      render :text => "<create>#{record.id}</create>"
    else
      render :text => "<error>#{record.full_messages.join("\n")}</error>"
    end
  end
  
  def update
    values = params['id'].split('&').map {|s| s.split('=', 2)}
    attributes = Hash[*values.flatten]
    id = attributes['id']
    attributes.delete 'id'
    record = <%= class_name %>.find id
    record.attributes = attributes
    response.headers["Content-Type"] = "text/xml"
    if record.save
      render :text => "<update>#{record.id}</update>"
    else
      render :text => "<error>#{record.full_messages.join("\n")}</error>"
    end
  end
  
  def delete
    ranges = RangeList.parse params['id'], :domain_start => 1
    conditions = ranges.to_array :first_index => 1
    <%= class_name %>.delete_all conditions
    response.headers["Content-Type"] = "text/xml"
    render :text => "<deleted id='#{id}'/>"
  end
end
