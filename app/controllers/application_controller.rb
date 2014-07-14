class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
  	pizza = Pizza.where(Pizza.arel_table[:code].matches(code)).take
  	# pizza = Pizza.find_by_code code.upcase
  	pizza.name
  end

  def get_pizza_size size
  	sizes = {
  		's' => 'Small',
  		'm' => 'Medium',
  		'l' => 'Large'
  	}
  	sizes[size]
  end
end
