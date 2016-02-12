require "pandoc-ruby"
require "nokogiri"

class WpHTMLValidator

  class Error < StandardError
  end

  attr_reader :id, :original_html

  def initialize(id, original_html)
    @id = id
    @original_html = original_html
    @markdown_text = nil
  end

  def validate(display_error: false)
    # NOTE `autolink_bare_uris` option is only used to compare HTML structure. It should be removed later.

    original_doc = Nokogiri::HTML(normalize_html(original_html))
    current_doc = Nokogiri::HTML(normalize_html(current_html))

    convert_u_to_strong(original_doc)
    strip_unnecessary_tag(original_doc)

    normalize_wrapped_paragraph(original_doc)
    normalize_wrapped_paragraph(current_doc)

    notmalize_text_content(original_doc)
    notmalize_text_content(current_doc)

    diff = []

    original_doc.diff(current_doc) do |change, node|
      next if change == ' '
      next if node.text.blank?
      next if node.is_a?(Nokogiri::XML::Attr)

      diff << "#{change} #{node.to_html}"
    end

    unless diff.empty?
      if display_error
        $stderr.puts "Post#id: #{id}"
        $stderr.puts diff.join("\n")
        $stderr.puts
      end
    end

    diff.empty?
  end

  def validate!
    unless validate(display_error: true)
      raise Error, "#{id} has some difference."
    end
  end

  def markdown_text
    return @markdown_text if @markdown_text

    html = Nokogiri::HTML(original_html).tap {|doc|
      convert_u_to_strong(doc)
      strip_img_attribtues(doc)
    }.search('body')[0].inner_html

    html.split(Page::SEPARATOR).map {|page|
      PandocRuby.convert(page,
                         {
                           from: :html,
                           to: 'markdown_github'
                         },
                         "atx-header")
    }.join(Page::SEPARATOR + "\n")
      .gsub('****', '<br>') # XXX Workaround for compatibility
  end

  def current_html
    markdown_text.split(Page::SEPARATOR).map {|page|
      # PandocRuby.convert(page, from: 'markdown_github-autolink_bare_uris', to: 'html')

      renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true), tables: true)
      renderer.render(page)
    }.join(Page::SEPARATOR + "\n")
  end

  private

  def normalize_html(html)
    # XXX Workaround to suppress unexpected diff
    html
      .gsub(/ +/, ' ')
      .gsub(/\r\n/, "\n")
      .gsub(/\n+/, "")
  end

  def strip_unnecessary_tag(doc)
    doc.search('div[dir="ltr"]').each do |node|
      node.replace(node.text)
    end
  end

  def convert_u_to_strong(doc)
    doc.search('u').each do |node|
      node.name = 'strong'
    end
  end

  def strip_img_attribtues(doc)
    doc.search('img').each do |node|
      white_list_attributes = %w(src title)
      (node.attributes.keys - white_list_attributes).each do |attr|
        node.remove_attribute(attr)
      end
    end
  end

  def normalize_wrapped_paragraph(doc)
    doc.search('p').each do |node|
      node.replace(node.inner_html) # Strip `<p>`
    end
  end

  def notmalize_text_content(doc)
    # XXX Workaround to suppress unexpected diff
    doc.search('text()').each do |node|
      node.replace(node.text.strip.gsub(' ', ''))
    end
  end
end