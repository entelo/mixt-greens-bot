require "bundler"
Bundler.require
require "./init.rb"

puts "Loaded .env:"
puts File.read(".env")

store_url = ENV["STORE_URL"]
address1 = ENV["ADDRESS1"]
address2 = ENV["ADDRESS2"] || ""
city = ENV["CITY"]
zip = ENV["ZIP"]
address1 and city and zip or raise "Please specify STORE_URL, ADDRESS1, ADDRESS2, CITY and ZIP in a .env file."

USAGE_MSG = "Usage: ruby start.rb [CSV file with responses] [Delivery date in m/d/y] [Delivery time = \"11:45 AM\"]"
infile = ARGV[0]
delivery_date = ARGV[1]
delivery_time = ARGV[2] || "11:45 AM"
infile and delivery_date and delivery_time or raise USAGE_MSG

ITEM_TYPE_PATHS = {
  'Salad' => '/order/menu.aspx?cid=1',
  'Sandwich' => '/order/menu.aspx?cid=2',
  'Grain bowl' => '/order/menu.aspx?cid=9201',
}


$orders = Rcsv.parse(File.read(infile))
puts "Loaded #{$orders.size} responses."

Capybara.current_driver = :selenium_chrome
Capybara.app_host = "https://mixtgreens.brinkpos.net"


# Init order
# ===

Capybara.visit("/order/default.aspx")
Capybara.visit(store_url)

delivery_radio = Capybara.find(:xpath, "//input[following-sibling::label[1][contains(., 'DELIVERY')]]")
delivery_radio.click

Capybara.fill_in \
  "ctl00_cph1_NewAddressControl_txtAddress1",
  with: address1
Capybara.fill_in \
  "ctl00_cph1_NewAddressControl_txtAddress2",
  with: address2
Capybara.fill_in \
  "ctl00_cph1_NewAddressControl_txtCity",
  with: city
state = Capybara.find("#ctl00_cph1_NewAddressControl_states")
state.find(:xpath, "option[@value='CA']").select_option

Capybara.fill_in \
  "ctl00_cph1_txtDate_I",
  with: delivery_date
Capybara.find("#ctl00_cph1_txtDate_I").send_keys("\n")
time = Capybara.find("#ctl00_cph1_ddlTime")
time.find(:xpath, "option[@value='#{delivery_time}']").select_option
Capybara.fill_in \
  "ctl00_cph1_NewAddressControl_txtZip",
  with: zip

Capybara.click_on("Continue")


# Add $orders
# ===

# Sort orders without customization on top
$orders.sort_by! {|_,_,_,_,_,_,details| (details.nil? || details.empty?) ? 0 : 1}

last_item_type = nil
$orders.each_with_index do |response, i|
  puts "#{i}: #{response}"
  (_timestamp, email, name, salad, grain_bowl, sandwich, details) = response

  if salad && !salad.empty?
    item = salad
    item_type = 'Salad'
  elsif grain_bowl && !grain_bowl.empty?
    item = grain_bowl
    item_type = 'Grain bowl'
  elsif sandwich && !sandwich.empty?
    item = sandwich
    item_type = 'Sandwich'
  else
    raise
  end

  # Change category if needed
  if last_item_type != item_type
    item_type_path = ITEM_TYPE_PATHS[item_type]
    Capybara.visit(item_type_path)
    sleep(1)
  end
  last_item_type = item_type

  # Activate item
  order_item_div = Capybara.find(:xpath, "//div[@class='item-order'][following-sibling::div[@class='item-name'][1][contains(., '#{item}')]]")
  order_item_link = order_item_div.find("a")
  order_item_div.click
  item_id = order_item_link[:id].match(/item_(\d+)_/)[1]
  sleep(0.75)

  # No customization
  if details.nil? || details.empty?
    Capybara.fill_in \
      "ctl00_cph1_item_#{item_id}_ctl01_txtNote",
      with: name
    Capybara.find("#ctl00_cph1_item_#{item_id}_btnAdd").click
    sleep(1)

  # Customization
  else
    Capybara.find("#ctl00_cph1_item_#{item_id}_btnCustomize").click
    Capybara.fill_in \
      "ctl00_cph1_ei_orderItemControl_txtNote",
      with: name
    # HACK: Wait for manual intervention lol
    STDOUT << "Details: #{details}\nPress enter when done"
    gets
  end

end


binding.pry
puts 123
