class WaiterController < ApplicationController

	skip_before_action :verify_authenticity_token 
  	before_action :set_customer, only: [:order]

	def order		
		if is_start_word? params[:text]
			if !has_pending_orders?
				start_order
			end
		end
		render json: { success: true }
	end

	private		

		def start_order
			order = Order.create! customer_id: @customer.id
			reply order
		end

		def reply order
			
		end

		def is_start_word? text
			text.downcase == ENV['START'].downcase
		end

		def has_pending_orders?
			!@customer.orders.pending.empty?
		end

		def set_customer
	      @customer = Customer.find_by_phone_number(params[:phone_number])
	      if @contact.nil?
	        @customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
	      end
	      @customer
	    end
end
