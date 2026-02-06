# ShotAPI Ruby SDK

Official Ruby SDK for [ShotAPI](https://shotapi.net) - The Screenshot & Rendering API.

## Installation

Add to your Gemfile:

```ruby
gem 'shotapi'
```

Or install directly:

```bash
gem install shotapi
```

## Quick Start

```ruby
require 'shotapi'

client = ShotAPI::Client.new('sk_your_api_key')

# Take a screenshot
image = client.screenshot('https://example.com')
File.binwrite('screenshot.png', image)
```

## Usage Examples

### Basic Screenshot

```ruby
client = ShotAPI::Client.new('sk_your_api_key')

# Simple screenshot
image = client.screenshot('https://stripe.com')

# Full-page screenshot with options
image = client.screenshot('https://github.com',
  full_page: true,
  format: 'png',
  width: 1920,
  height: 1080
)

# Dark mode with retina
image = client.screenshot('https://example.com',
  dark_mode: true,
  device_scale_factor: 2,
  block_ads: true
)
```

### Device Mockups

```ruby
# iPhone mockup
image = client.screenshot('https://example.com', mockup: 'iphone')

# MacBook mockup
image = client.screenshot('https://example.com', mockup: 'macbook')
```

### HTML to Image

```ruby
html = <<~HTML
  <div style="padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
    <h1 style="color: white; font-family: sans-serif;">Hello World!</h1>
  </div>
HTML

image = client.render(html, width: 800, height: 400)
```

### Metadata Extraction

```ruby
# Get page metadata
meta = client.metadata('https://github.com')
puts meta['title']
puts meta['description']
puts meta['og_image']

# With markdown content
meta = client.metadata('https://example.com', extract_markdown: true)
puts meta['markdown']
```

### Batch Screenshots

```ruby
urls = [
  'https://google.com',
  'https://github.com',
  'https://stripe.com'
]

result = client.batch(urls, format: 'png', full_page: true)
result['results'].each do |item|
  puts "#{item['url']} -> #{item['filename']}"
end
```

### Visual Diff

```ruby
result = client.diff(
  'https://example.com',
  'https://example.org',
  width: 1280,
  height: 720
)

puts "Pages differ by #{result[:percentage]}%"
File.binwrite('diff.png', result[:image])
```

## Error Handling

```ruby
begin
  image = client.screenshot('https://example.com')
rescue ShotAPI::AuthenticationError
  puts 'Invalid API key'
rescue ShotAPI::RateLimitError
  puts 'Rate limit exceeded'
rescue ShotAPI::FeatureNotAvailableError
  puts 'Feature not available on your plan'
rescue ShotAPI::Error => e
  puts "API error: #{e.message}"
end
```

## Rails Integration

```ruby
# config/initializers/shotapi.rb
SHOTAPI = ShotAPI::Client.new(Rails.application.credentials.shotapi_key)

# In a controller
class ScreenshotsController < ApplicationController
  def create
    image = SHOTAPI.screenshot(params[:url])
    send_data image, type: 'image/png', disposition: 'inline'
  end
end
```

## Links

- [Documentation](https://shotapi.net/docs-page)
- [Pricing](https://shotapi.net/pricing)
- [Dashboard](https://shotapi.net/dashboard)

## License

MIT License
