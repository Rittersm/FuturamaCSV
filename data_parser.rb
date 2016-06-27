require 'erb'
require 'csv'

class Delivery
  @@total_revenue = 0

  attr_accessor :destination, :shipment, :crates, :money, :pilot, :bonus

  def self.total_revenue
    @@total_revenue
  end

  def initialize(destination, shipment, crates, money)
    @destination = destination
    @shipment = shipment
    @crates = crates
    @money = money
    @pilot = determine_pilot[destination.to_sym]
    @bonus = money / 10.0
    @@total_revenue += money
  end

  def determine_pilot
    pilots = { Earth: "Fry", Uranus: "Bender", Mars: "Amy"}
    pilots.default = "Leela"
    pilots
  end

  def Delivery.pilot_deliveries(pilot)
    delivery_objects.select{|delivery| delivery.pilot == pilot}
  end
end

delivery_objects = []

CSV.foreach("planet_express_logs.csv", headers: true) do |row|
  delivery_objects << Delivery.new(row["Destination"], row["Shipment"], row["Crates"].to_s.to_i, row["Money"].to_s.to_i)
end

pilots = delivery_objects.collect{|delivery| delivery.pilot}.uniq

planets = delivery_objects.collect{|planet| planet.destination}.uniq

pilot_data = []

pilot_data << pilots.map do |pilot|
  {
    pilot: pilot,
    deliveries: delivery_objects.select{|delivery| delivery.pilot == pilot}.length.to_i,
    bonus: delivery_objects.select{|delivery| delivery.pilot == pilot}.collect{|delivery| delivery.bonus}.inject(:+).to_i
  }
end

revenue = []

revenue << pilots.map do |pilot|
  {
    pilot: pilot,
    revenue: delivery_objects.select{|delivery| delivery.pilot == pilot}.collect{|delivery| delivery.money}.inject(:+)
  }
end

revenue_by_planet = []

revenue_by_planet << planets.map do |planet|
  {
    planet: planet,
    revenue: delivery_objects.select{|delivery| delivery.destination == planet}.collect{|delivery| delivery.money}.inject(:+)
  }
end

new_file = File.open("./report.html", "w+")
new_file << ERB.new(File.read("./report.html.erb")).result(binding)
new_file.close

puts delivery_objects.inspect
puts Delivery.total_revenue
