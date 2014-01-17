require 'smarter_csv'
class PurchaseImport
  attr_reader :total_revenue
  def initialize(file)
    @total_revenue = 0
    SmarterCSV.process(file.path, { col_sep: "\t", chunk_size: 3 }) do |chunk|
      chunk.each do |row|
        Rails.logger.warn row.inspect
        hasher = ImportHashBuilder.new(row)
        hasher.save
        @total_revenue += hasher.revenue
      end
    end
  end
end

class ImportHashBuilder
  attr_reader :revenue
  def initialize(row_hash)
    @revenue = 0
    @row_hash = row_hash
    @customer = customer
    @merchant = merchant
    @item = item
    @purchase = purchase
  end
  
  def save
    Purchase.create(@purchase)
  end

private
  def customer
    Customer.where(name: @row_hash[:purchaser_name]).first_or_initialize
  end
  
  def merchant
    Merchant.where(name: @row_hash[:merchant_name], address: @row_hash[:merchant_address]).first_or_initialize
  end
  
  def item
    Item.where(description: @row_hash[:item_description], merchant_id: @merchant.id).first_or_initialize
  end
  
  def item_with_merchant
    @item.attributes.merge({ merchant_attributes: @merchant.attributes })
  end
  
  def purchase
    price = @row_hash[:item_price]
    item_count = @row_hash[:purchase_count]
    @revenue = price * item_count
    customer_opts = (@customer.new_record? ? { customer_attributes: @customer.attributes } : { customer_id: @customer.id })
    item_opts = (@item.new_record? ? { item_attributes: item_with_merchant } : { item_id: @item.id })
    purchase_opts = { price: price, item_count: item_count }
    return purchase_opts.merge(item_opts).merge(customer_opts)
  end
  
end
