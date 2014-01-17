require 'purchase_import'
class UploadsController < ApplicationController
  def import
    @total_revenue = PurchaseImport.new(params[:file]).total_revenue
    Rails.logger.warn "$#{"%.2f" % @total_revenue}"
    redirect_to uploads_url, notice: "Purchases successfully imported. Total gross revenue for the uploaded file: $#{"%.2f" % @total_revenue}"
  end
  
  def index
  end
end
