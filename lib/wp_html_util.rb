module WpHTMLUtil
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
