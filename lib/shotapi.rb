# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# ShotAPI Ruby SDK
# Official Ruby client for ShotAPI - Screenshot & Rendering API
#
# @example
#   client = ShotAPI::Client.new('sk_your_api_key')
#   image = client.screenshot('https://example.com')
#   File.binwrite('screenshot.png', image)
#
module ShotAPI
  VERSION = '1.0.0'
  DEFAULT_BASE_URL = 'https://shotapi.net'
  DEFAULT_TIMEOUT = 60

  class Error < StandardError
    attr_reader :status_code

    def initialize(message, status_code = nil)
      @status_code = status_code
      super(message)
    end
  end

  class AuthenticationError < Error; end
  class RateLimitError < Error; end
  class FeatureNotAvailableError < Error; end

  class Client
    attr_accessor :api_key, :base_url, :timeout

    def initialize(api_key, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT)
      @api_key = api_key
      @base_url = base_url.chomp('/')
      @timeout = timeout
    end

    # Take a screenshot of a URL
    #
    # @param url [String] The URL to capture
    # @param options [Hash] Screenshot options
    # @return [String] Binary image data
    def screenshot(url, **options)
      payload = { url: url }.merge(convert_options(options))
      request('/v1/screenshot', payload)
    end

    # Render HTML/CSS to an image
    #
    # @param html [String] HTML content to render
    # @param options [Hash] Render options
    # @return [String] Binary image data
    def render(html, **options)
      payload = { html: html }.merge(convert_options(options))
      request('/v1/render', payload)
    end

    # Extract metadata from a URL
    #
    # @param url [String] The URL to analyze
    # @param options [Hash] Metadata options
    # @return [Hash] Metadata result
    def metadata(url, **options)
      payload = { url: url }.merge(convert_options(options))
      response = request('/v1/metadata', payload, json: true)
      JSON.parse(response)
    end

    # Take screenshots of multiple URLs
    #
    # @param urls [Array<String>] List of URLs to capture
    # @param options [Hash] Screenshot options
    # @return [Hash] Batch result
    def batch(urls, **options)
      payload = {
        urls: urls,
        options: convert_options(options)
      }
      response = request('/v1/batch', payload, json: true)
      JSON.parse(response)
    end

    # Compare two URLs visually
    #
    # @param url_a [String] First URL
    # @param url_b [String] Second URL
    # @param options [Hash] Diff options
    # @return [Hash] { image: binary, percentage: float }
    def diff(url_a, url_b, **options)
      payload = {
        url_a: url_a,
        url_b: url_b,
        width: options[:width] || 1280,
        height: options[:height] || 720
      }

      uri = URI("#{@base_url}/v1/diff")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = @timeout

      req = Net::HTTP::Post.new(uri.path)
      req['Content-Type'] = 'application/json'
      req['X-API-Key'] = @api_key
      req.body = payload.to_json

      response = http.request(req)
      handle_error(response)

      percentage = response['X-Diff-Percentage']&.to_f || 0.0
      { image: response.body, percentage: percentage }
    end

    private

    def convert_options(options)
      mapping = {
        full_page: :full_page,
        fullPage: :full_page,
        device_scale_factor: :device_scale_factor,
        deviceScaleFactor: :device_scale_factor,
        dark_mode: :dark_mode,
        darkMode: :dark_mode,
        custom_css: :custom_css,
        customCss: :custom_css,
        custom_js: :custom_js,
        customJs: :custom_js,
        user_agent: :user_agent,
        userAgent: :user_agent,
        wait_for_selector: :wait_for_selector,
        waitForSelector: :wait_for_selector,
        click_selector: :click_selector,
        clickSelector: :click_selector,
        hide_selectors: :hide_selectors,
        hideSelectors: :hide_selectors,
        block_ads: :block_ads,
        blockAds: :block_ads,
        extract_markdown: :extract_markdown,
        extractMarkdown: :extract_markdown
      }

      options.transform_keys { |k| mapping[k] || k }
    end

    def request(endpoint, payload, json: false)
      uri = URI("#{@base_url}#{endpoint}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = @timeout

      req = Net::HTTP::Post.new(uri.path)
      req['Content-Type'] = 'application/json'
      req['X-API-Key'] = @api_key
      req.body = payload.to_json

      response = http.request(req)
      handle_error(response)
      response.body
    end

    def handle_error(response)
      case response.code.to_i
      when 200..299
        # Success
      when 401
        raise AuthenticationError.new('Invalid API key', 401)
      when 403
        raise FeatureNotAvailableError.new(response.body, 403)
      when 429
        raise RateLimitError.new('Rate limit exceeded', 429)
      else
        raise Error.new(response.body, response.code.to_i)
      end
    end
  end
end
