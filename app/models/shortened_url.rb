class ShortenedUrl < ApplicationRecord
  UNIQUE_ID_LENGTH = 6
  validates :original_url, presence: true, on: :create
  
  # Validation for URL format
  validates_format_of :original_url,
                      # with: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  # Alternatively, you can use the following custom regex for more control:
                      # with: /\A(?:(?:http|https):\/\/)?([-a-zA-Z0-9.]{2,256}\.[a-z]{2,4})\b(?:\/[-a-zA-Z0-9@,!:%_\+.-#?&\/\/=]*)?\Z/
                    with:  /\A(?:(?:http|https):\/\/)?([a-zA-Z0-9.-]{2,256}\.[a-z]{2,4})\b(?:\/[a-zA-Z0-9@,!:%_\+.\-#?&\/\/=]*)?\Z/

  
  before_create do
    generate_short_url
    sanitize
  end

  def generate_short_url
    url = ([*('a'..'z'), *('0'..'9')]).sample(UNIQUE_ID_LENGTH).join
    old_url = ShortenedUrl.where(short_url: url).last
    if old_url.present?
      self.generate_short_url
    else
      self.short_url = url
    end
  end

  def find_duplicate
    ShortenedUrl.find_by_sanitize_url(sanitize_url)
  end

  def new_url
    find_duplicate.nil?
  end

  def sanitize
    self.original_url.strip!
    self.sanitize_url = self.original_url.downcase.gsub(/(https?:\/\/)|(www\.)/, "")
    self.sanitize_url = "http://#{self.sanitize_url}"
  end
end
