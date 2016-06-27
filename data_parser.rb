require 'erb'
require 'csv'

class Delivery

  attr_accessor :destination, :shipment, :crates, :money, :pilot, :bonus

  def initialize(destination, shipment, crates, money)
    @destination = destination
    @shipment = shipment
    @crates = crates
    @money = money
    @pilot = determine_pilot[destination.to_sym]
    @bonus = money / 10.0
  end

  def determine_pilot
    pilots = { Earth: "Fry", Uranus: "Bender", Mars: "Amy"}
    pilots.default = "Leela"
    pilots
  end

end

deliveries = []

CSV.foreach("planet_express_logs.csv", headers: true) do |row|
  deliveries << row.to_hash
end

delivery_objects = deliveries.collect{|x| Delivery.new(x["Destination"], x["Shipment"], x["Crates"].to_i, x["Money"].to_i)}

total_revenue = delivery_objects.inject(0){|sum, x| sum += x.money}

class Pilot

  attr_accessor :pilot, :deliveries, :revenue, :bonus

  def initialize(pilot, deliveries, revenue, bonus)
    @pilot = pilot
    @deliveries = deliveries
    @revenue = revenue
    @bonus = bonus
  end

end

pilots = delivery_objects.collect{|delivery| delivery.pilot}.uniq

planets = delivery_objects.collect{|planet| planet.destination}.uniq

total_deliveries = []

total_deliveries << pilots.map do |pilot|
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
