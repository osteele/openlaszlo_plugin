class String
  def xmlize
    return self.underscore.gsub(/_/, '-')
  end
end
