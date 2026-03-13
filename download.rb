require "net/http"
require "fileutils"

companies = %w[
  google.com openai.com anthropic.com apple.com github.com
  facebook.com twitter.com linkedin.com slack.com zoom.us shopify.com dropbox.com
  telegram.org stripe.com postmarkapp.com mailpace.com gitlab.com userlist.com resend.com
  loops.so mailgun.com basecamp.com fizzy.do chirpform.com gumroad.com moneybird.com mollie.com adyen.com
]

output_dir = File.expand_path("app/assets/images/fuik/icons", __dir__)
FileUtils.mkdir_p(output_dir)

def fetch(url, limit = 5)
  return nil if limit == 0

  uri = URI(url)
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.get(uri) }

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    fetch(response["location"], limit - 1)
  end
end

companies.each do |domain|
  name = domain.split(".").first
  png_path = File.join(output_dir, "#{name}.png")
  jpg_path = File.join(output_dir, "#{name}.jpg")

  body = fetch("https://www.google.com/s2/favicons?domain=#{domain}&sz=128")

  if body && body.length > 100
    File.binwrite(png_path, body)
    system("sips", "-s", "format", "jpeg", png_path, "--out", jpg_path)
    File.delete(png_path)
    puts "✓ #{name}"
  else
    puts "✗ #{name}"
  end
end
