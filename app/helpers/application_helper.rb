module ApplicationHelper
	def is_a_pizza_code? code
		(Pizza.pluck :code).map(&:downcase).include? code
	end
	def is_a_pizza_size? size
		['s','m','l'].include? size
	end
	def is_a_main_order? text
		is_a_pizza_code?(text[-2]) && is_a_pizza_size?(text[-1])
	end
	def get_pizza_name code
		pizza = Pizza.find_by_code code
		pizza.name
	end
	def get_pizza_size size
		sizes = {
			's' => 'Small',
			'm' => 'Medium',
			'l' => 'Large'
		}
		sizes size
	end
end
