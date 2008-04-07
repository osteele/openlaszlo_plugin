require 'source_annotation_extractor'

# Monkey-patch to look in OpenLaszlo source files
class SourceAnnotationExtractor
  def find_in_with_lzx(dir)
    results = find_in_without_lzx(dir)

    Dir.glob("#{dir}/*") do |item|
      case
      when File.basename(item)[0] == ?.
      when File.directory?(item)
      when item =~ /\.js$/
        results.update(extract_annotations_from(item, /(?:\/\/|\/\*)\s*(#{tag})(?:.*:|:)?\s*(.*?)(?:\*\/)?$/))
      when item =~ /\.lzx$/
        results.update(extract_annotations_from(item, /(?:<!--|\/\/|\/\*)\s*(@#{tag})(?:.*:|:)?\s*(.*)/))
      end
    end

    results
  end
  alias_method_chain :find_in, :lzx
end
