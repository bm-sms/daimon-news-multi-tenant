class RedirectRule < ActiveRecord::Base
  before_validation :decode_request_path
  before_validation :decode_destination
  belongs_to :site

  validates :request_path, presence: true
  validates :request_path, uniqueness: {scope: :site_id}
  validates :destination, presence: true
  validates :site, presence: true
  validate :request_path_is_relative_path?
  validate :request_path_has_fragment_string?
  validate :request_path_has_query_string?
  validate :request_equal_destination?
  validate :redirect_loop?

  private

  def decode_request_path
    self.request_path = URI.decode_www_form_component(request_path)
  end

  def decode_destination
    destination_uri = Addressable::URI.parse(URI.decode_www_form_component(destination))
    if destination_uri.host
      destination_uri.host = SimpleIDN.to_unicode(destination_uri.host)
      self.destination = destination_uri.to_s
    else
      true
    end
  end

  def request_path_is_relative_path?
    errors.add(:request_path, :not_relative_path) unless request_path.start_with?("/")
  end

  def request_path_has_fragment_string?
    errors.add(:request_path, :has_fragment_string) if Addressable::URI.parse(request_path).fragment.present?
  end

  def request_path_has_query_string?
    errors.add(:request_path, :has_query_string) if Addressable::URI.parse(request_path).query.present?
  end

  def request_equal_destination?
    destination_uri = Addressable::URI.parse(destination).freeze
    if request_path == destination_uri.path && (destination_uri.hostname == site.fqdn || destination_uri.relative?)
      errors.add(:request_path, :not_equal_destination)
    end
  end

  def redirect_loop?
    redirect_loop_rule = site.redirect_rules.find do |redirect_rule|
      redirect_rule.request_path == destination && redirect_rule.destination == request_path
    end
    errors.add(:destination, :redirect_loop) if redirect_loop_rule.present?
  end
end