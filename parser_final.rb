require 'rubygems'
require 'pry'
require 'open-uri'
require 'nokogiri'
require 'csv'

class Parser
  def initialize(uri, file_name)
    @uri = URI(uri)
    @host = @uri.host
    @http_scheme = @uri.scheme
    @file_name = file_name
  end

  def parse
    doc = fetch_document(@uri)
    links_to_multiproducts = get_hrefs_for_multiproducts(doc)
    result = []

    while(links_to_multiproducts.length > 0) do
      @path = links_to_multiproducts.pop.attribute('href').value
      multiproduct_page = go_to_multiproduct_page(@path)

      products = get_products(multiproduct_page)
      products.each do |product|

        name = find_name(product).gsub(/[\t\n]/, "").squeeze(" ")
        weight_tags = find_weights(product)
        weights = weight_tags.map { |tag| find_weight(tag) }

        price_tags = find_prices(product)
        prices = price_tags.map { |tag| find_price(tag).gsub(/[\t\n]/, "").squeeze(" ") }
        img = find_img(product)
        for i in 0..weights.length
          if prices[i]
            result << [name_with_weight(name, weights[i]), prices[i], img]
          end
        end
      end
    end

    write_to_csv(result)
  end

  private

  def name_with_weight(name, weight)
    if weight.empty?
      name
    else
      "#{name}(#{weight})"
    end
  end

  def get_hrefs_for_multiproducts(doc)
    doc.xpath('//*[@id="center_column"]/div[3]/div/div[*]/div/div[1]/div/a')
  end

  def find_name(product)
    product.xpath('//*[@id="right"]/div/div[1]/div/h1').text.strip
  end

  def find_prices(product)
    product.xpath('//*[@id="attributes"]/fieldset/div//span[@class="attribute_price"]')
  end

  def find_price(price_tag)
    price_tag.text
  end

  def find_weights(product)
    product.xpath('//div[@class="attribute_list"]//span[@class="attribute_name"]')
  end

  def find_weight(weight_tag)
    weight_tag.text
  end

  def find_img(product)
    image_with_id = product.xpath("//*[@id='bigpic']")
    image_with_id.attribute('src').value
  end

  def go_to_multiproduct_page(path)
    product_url = URI(path)
    fetch_document(product_url)
  end

  def get_products(doc)
    doc.xpath('//*[@id="center_column"]//div[3]/div/div[1]/div')
  end

  def fetch_document(uri)
    Nokogiri::HTML(open(uri))
  end

  def write_to_csv(results)
    CSV.open(@file_name, "wb") do |csv|
      csv << ["name", "price", "img url"]
      results.each do |found_item|
        csv << found_item
      end
    end
  end
end

puts "Input URL:"
#uri = gets
uri = "https://www.petsonic.com/snacks-huesos-para-perros/"
puts "Input output file's path and name (example: ~/user/Desktop/test_file.csv):"
file_name = gets

#file_name = "test.csv"
parser = Parser.new(uri, file_name)
parser.parse
puts uri

