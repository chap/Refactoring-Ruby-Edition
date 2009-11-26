class Movie
	REGULAR = 0
	NEW_RELEASE = 1
	CHILDRENS = 2
	
	attr_reader :title
	attr_reader :price_code
	
	def initialize(title, the_price_code)
		@title, self.price_code = title, the_price_code
	end
	
	def price_code=(value)
		@price_code = value
	end
	
	def charge(days_rented)
		result = 0
		case price_code
		when Movie::REGULAR
			result += 2
			result += (days_rented - 2) * 1.5 if days_rented > 2
		when Movie::NEW_RELEASE
			result += days_rented * 3
		when Movie::CHILDRENS
			result += 1.5
			result += (days_rented - 3) * 1.5 if days_rented > 3
		end
		result
	end
	
	def frequent_renter_points(days_rented)
		(price_code == Movie::NEW_RELEASE && days_rented > 1) ? 2 : 1
	end
end

class RegularPrice
end

class NewReleasePrice
end

class ChildrensPrice
end

class Rental
	attr_reader :movie, :days_rented
	
	def initialize(movie, days_rented)
		@movie, @days_rented = movie, days_rented
	end
	
	def charge
		movie.charge(days_rented)
	end
	
	def frequent_renter_points
		movie.frequent_renter_points(days_rented)
	end
end


class Customer
	attr_reader :name
	
	def initialize(name)
		@name = name
		@rentals = []
	end
	
	def add_rental(arg)
		@rentals << arg
	end
	
	def statement
		frequent_renter_points = 0
		result = "Rental Record for #{@name}\n"
		@rentals.each do |element|
			# show figures for this rental
			result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
		end
		#add footer lines
		result += "Amount owed is #{total_charge}\n"
		result += "You earned #{total_frequent_renter_points} frequent renter points"
		result
	end
	
	def html_statement
		result = "<h1>Rentals for <em>#{@name}</em></h1><p>\n"
		@rentals.each do |element|
			# show figures for this rental					
			result += "\t" + element.movie.title + ": " + element.charge.to_s + "<br>\n"
		end
		# add footer lines
		result += "<p>You owe <em>#{total_charge}</em></p>\n"
		result += "<p>On this rental you earned " +
							"<em>#{total_frequent_renter_points}</em> " +
							"frequent renter points</p>"
		result
	end
	
	private
	
	def total_charge
		@rentals.inject(0) {|sum, element| sum + element.charge}
	end
	
	def total_frequent_renter_points
		@rentals.inject(0) {|sum, element| sum + element.frequent_renter_points}
	end
end

require "test/unit"
class VideoRentalTest < Test::Unit::TestCase
	
	def test_statement
		customer = Customer.new('Chap')
		movie1 = Movie.new('Joe Versus the Volcano', Movie::REGULAR)
		rental1 = Rental.new(movie1, 5)
		customer.add_rental(rental1)
				
		assert_equal "Rental Record for Chap\n"          +
								 "\tJoe Versus the Volcano\t6.5\n"   +
								 "Amount owed is 6.5\n"              +
								 "You earned 1 frequent renter points", customer.statement
		
		
		movie2 = Movie.new('Sleepless in Seattle', Movie::CHILDRENS)
		rental2 = Rental.new(movie2, 1)
		customer.add_rental(rental2)
				
		assert_equal "Rental Record for Chap\n"          +
								 "\tJoe Versus the Volcano\t6.5\n"   +
								 "\tSleepless in Seattle\t1.5\n"     +
								 "Amount owed is 8.0\n"              +
								 "You earned 2 frequent renter points", customer.statement
		
		
		movie3 = Movie.new('You\'ve Got Mail', Movie::NEW_RELEASE)
		rental3 = Rental.new(movie3, 15)
		customer.add_rental(rental3)

		assert_equal "Rental Record for Chap\n"          +
								 "\tJoe Versus the Volcano\t6.5\n"   +
								 "\tSleepless in Seattle\t1.5\n"     +
								 "\tYou've Got Mail\t45\n"           +
								 "Amount owed is 53.0\n"             +
								 "You earned 4 frequent renter points", customer.statement
		
		assert_equal "<h1>Rentals for <em>Chap</em></h1><p>\n" + 
								 "\tJoe Versus the Volcano: 6.5<br>\n"     +
								 "\tSleepless in Seattle: 1.5<br>\n"       +
								 "\tYou've Got Mail: 45<br>\n"             +
								 "<p>You owe <em>53.0</em></p>\n"          +
								"<p>On this rental you earned "            +
								"<em>4</em> frequent renter points</p>", customer.html_statement
	end
end