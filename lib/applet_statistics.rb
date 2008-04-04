require 'code_statistics'

class CodeStatistics #:nodoc:
  def calculate_directory_statistics_with_lzx(directory, pattern = /.*\.rb$/)
    pattern = /.*\.(lzx|js)$|(#{pattern})/ if File.expand_path(directory).index(File.expand_path("#{RAILS_ROOT}/app/applets")) == 0
    calculate_directory_statistics_without_lzx(directory, pattern)
  end
  alias_method_chain :calculate_directory_statistics, :lzx
end
