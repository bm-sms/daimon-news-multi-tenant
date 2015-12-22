module ApplicationHelper
  def render_markdown(markdown_text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(markdown_text)
  end

  def google_tag_manager(gtm_id)
    if gtm_id
      render partial: 'google_tag_manager', locals: { gtm_id: gtm_id }
    end
  end
end
