require "wp_html_validator"

parser = OptionParser.new

parser.banner = <<BANNER
Usage
  $ bin/rails r scripts/convert_html2md.rb [options] <fqdn> [public_id]
BANNER

dry_run = false
stop_on_error = false
validate_body = false
verbose = false

parser.on("--dry-run", "Dry run") do
  dry_run = true
end

parser.on("--stop-on-error", "Stop on error") do
  stop_on_error = true
end

parser.on("--validate-body", "Validate Post#body") do
  validate_body = true
end

parser.on("--verbose", "Verbose output") do
  verbose = true
end

parser.on("-e", "--environment=NAME", "Rails environment. This option is handled by `bin/rails r`") do |name|
  # NOP
end

argv = ARGV.dup
argv.delete("--")

begin
  parser.parse!(argv)
rescue OptionParser::ParseError => ex
  $stderr.puts ex.message
  $stderr.puts parser.help
  exit(false)
end

Post.class_eval do
  include WpHTMLUtil

  def markdown_body(&block)
    super(original_html, &block)
  end

  def validate!(stop_on_error, validate_body)
    validator = if validate_body
                  WpHTMLValidator.new(public_id, original_html, body)
                else
                  WpHTMLValidator.new(public_id, original_html)
                end
    if stop_on_error
      validator.validate!
    else
      validator.validate(display_error: true)
    end
  end
end

fqdn, public_id = argv

if validate_body
  puts "Validate Post#body"
else
  puts "Validate Post#original_html"
end

site = Site.find_by!(fqdn: fqdn)

site.transaction do
  if public_id
    post = site.posts.find_by(public_id: public_id)
    if post.validate!(stop_on_error, validate_body)
      unless dry_run
        post.body = post.markdown_body do |url|
          image = site.images.create!(remote_image_url: url)
          image.image_url
        end
        post.save!
      end
    else
      if verbose
        puts "--- original_html ---"
        puts post.original_html
        puts "--- target_html ---"
        puts post.target_html
        puts "--- markdown_body ---"
        puts post.markdown_body
      end
    end
  else
    puts "Target records: #{site.posts.count}"
    n_errors = 0
    site.posts.each do |_post|
      if _post.validate!(stop_on_error, validate_body)
        if !validate_body && !dry_run
          _post.body = _post.markdown_body do |url|
            image = site.images.create!(remote_image_url: url)
            image.image_url
          end
          _post.save!
        end
      else
        n_errors += 1
      end
    end
    puts "Errors: #{n_errors}"
  end
end
