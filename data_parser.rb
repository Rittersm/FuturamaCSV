require 'erb'
require 'csv'

# Class objects are rows of the csv file brought in.
class Delivery
  @@total_revenue = 0
  @@all_pilots = []
  @@planets = []
  @@pilot_money = {}
  @@planet_money = {}
  attr_accessor :destination, :shipment, :crates, :money, :pilot, :bonus

  def self.total_revenue
    @@total_revenue
  end

  def self.all_pilots
    @@all_pilots
  end

  def self.planets
    @@planets
  end

  def self.pilot_money
    @@pilot_money
  end

  def self.planet_money
    @@planet_money
  end

  def pilot_money_writer
    @@pilot_money[pilot] = @@pilot_money[pilot].to_i + money
  end

  def planet_money_writer
    @@planet_money[destination] = @@planet_money[destination].to_i + money
  end

  def initialize(destination, shipment, crates, money)
    @destination = destination
    @shipment = shipment
    @crates = crates
    @money = money
    @pilot = determine_pilot[destination.to_sym]
    @bonus = money / 10.0
    @@total_revenue += money
    @@all_pilots << pilot unless @@all_pilots.include?(pilot)
    @@planets << destination unless @@planets.include?(destination)
    pilot_money_writer
    planet_money_writer
  end

  def determine_pilot
    pilots = { Earth: 'Fry', Uranus: 'Bender', Mars: 'Amy' }
    pilots.default = 'Leela'
    pilots
  end

  def self.pilot_deliveries(pilot)
    delivery_objects.select { |delivery| delivery.pilot == pilot }
  end
end

delivery_objects = []

CSV.foreach('planet_express_logs.csv', headers: true) do |row|
  delivery_objects << Delivery.new(
    row['Destination'],
    row['Shipment'],
    row['Crates'].to_s.to_i,
    row['Money'].to_s.to_i
  )
end

pilots = delivery_objects.collect(&:pilot).uniq

pilot_data = []

pilot_data << pilots.map do |pilot|
  {
    pilot: pilot,
    deliveries: delivery_objects.each do |delivery|
      delivery.pilot == pilot
    end.length.to_i,
    bonus: delivery_objects.select { |delivery| delivery.pilot == pilot }.collect(&:bonus).inject(:+).to_i
  }
end

new_file = File.open('./report.html', 'w+')
new_file << ERB.new(File.read('./report.html.erb')).result(binding)
new_file.close
