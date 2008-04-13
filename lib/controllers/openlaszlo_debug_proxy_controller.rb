class OpenlaszloDebugProxyController < ActionController::Base
  def index
    render :nothing => true, :status => 404 and return # unless ENV['OPENLASZLO_URLx']
    url = request.env['REQUEST_URI'].sub(/^\/applets(?=\/)/, ENV['OPENLASZLO_URL'])
    logger.info "Request #{url}"
    res = Net::HTTP.get_response(URI::parse(url))
    unless res.kind_of? Net::HTTPSuccess
      return render(:text => res.body, :code => res.code)
    end
    headers['Content-type'] = res.content_type
    #res.each_key do |k| headers[k] = res.get_fields(k).first end
    render :text => res.body
  end
end
