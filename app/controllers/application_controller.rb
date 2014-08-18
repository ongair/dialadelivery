class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_order_question order_type, place="", outlet=""
    order_question = OrderQuestion.where(OrderQuestion.arel_table[:order_type].matches(order_type)).take.text
    case order_type
    when "welcome"
      message = order_question.gsub(/(?=\bThank\b)/, @customer.name+'. ')
    when "location_and_outlet"
      message = order_question.gsub(/(?=\bis\b)/, place+' ')
      message = message.gsub(/(?=\bWe\b)/, outlet.name.gsub(',','')+'. ')
    when 'location_no_outlet'
      message = order_question.gsub(/(?=\bwe\b)/, @customer.name+' ')+' '+place+'.'
    when 'no_surburb'
      message = order_question.gsub(/(?=\bas\b)/, place+' ')
    end
  end

  def get_outlet_text_for_order_location place, name
  	"Your order for #{place} will be sent to #{name}"
  end

  def get_outlet_text_for_no_order_location place, name
  	"Sorry #{name} we do not yet have an outlet near #{place}"
  end
end
