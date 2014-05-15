class WaiterController < ApplicationController

	skip_before_action :verify_authenticity_token 
  	before_action :set_customer, only: [:order]

	def order		
		if is_start_word? params[:text]
		end
		render json: { success: true }
	end

	def is_start_word? text
		text.downcase == ENV['START'].downcase
	end

	def set_customer
      @customer = Customer.find_by_phone_number(params[:phone_number])
      if @contact.nil?
        @customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
      end
      @customer
    end
end
