require 'spec_helper'
require 'purchase_import'

describe PurchaseImport do
  let (:test_file) { Struct.new(:path).new(File.join(Rails.root.join('example_input.tab'))) }
  
  subject { PurchaseImport.new(test_file) }
  describe '#initialize' do
    it "inserts four purchases from a test file" do
      expect{ subject }.to change(Purchase, :count).by(4)
    end
  end
  describe '@total_revenue' do
    it 'should return total_revenue' do
      expect(subject.total_revenue).to eq(95)
    end
  end
end

describe ImportHashBuilder do
  let(:row_hash) { {:purchaser_name=>"Amy Pond", :item_description=>"$30 of awesome for $10", :item_price=>10.0, :purchase_count=>5, :merchant_address=>"456 Unreal Rd", :merchant_name=>"Tom's Awesome Shop" } }
  let(:customer_amy) { FactoryGirl.create(:customer, name: "Amy Pond") }
  let(:item_awesome) { FactoryGirl.create(:item, description: "$30 of awesome for $10") }
  let(:merchant_tom) { FactoryGirl.create(:merchant, name: "Tom's Awesome Shop") }

  subject { ImportHashBuilder.new(row_hash) }
  describe '#customer' do
    it "returns a new customer record for a new customer" do
      customer = subject.send(:customer)
      expect(customer.new_record?).to be_true
      expect(customer.name).to eq('Amy Pond')
    end
    it "returns an existing customer record for an existing customer" do
      customer_amy
      customer = subject.send(:customer)
      expect(customer.new_record?).to be_false
      expect(customer.name).to eq('Amy Pond')
    end
  end
  
  describe '#item' do
    it "returns a new item record for a new item" do
      item = subject.send(:item)
      expect(item.new_record?).to be_true
      expect(item.description).to eq('$30 of awesome for $10')
    end
    it "returns an existing item record for an existing item" do
      item_awesome
      item = subject.send(:item)
      expect(item.new_record?).to be_false
      expect(item.description).to eq('$30 of awesome for $10')
    end
  end
  
  describe '#merchant' do
    it "returns a new merchant record for a new merchant" do
      merchant = subject.send(:merchant)
      expect(merchant.new_record?).to be_true
      expect(merchant.name).to eq("Tom's Awesome Shop")
    end
    it "returns an existing merchant record for an existing merchant" do
      merchant_tom
      merchant = subject.send(:merchant)
      expect(merchant.new_record?).to be_false
      expect(merchant.name).to eq("Tom's Awesome Shop")
    end
  end
  
  describe '#item_with_merchant' do
    it "returns a Hash with both item and merchant_attributes" do
      item_with_merchant = subject.send(:item_with_merchant)
      expect(item_with_merchant.class).to eq(Hash)
      expect(item_with_merchant.has_key?(:merchant_attributes)).to be_true
    end
  end
  
  describe '#save' do
    it "saves to database" do
      expect{ subject.save }.to change(Purchase, :count).by(1)
      expect{ subject.save }.to change(Customer, :count).by(1)
      expect{ subject.save }.to change(Item, :count).by(1)
      expect{ subject.save }.to change(Merchant, :count).by(1)
    end
  end
  
  describe '#purchase' do
    context "no existing customer, item, or merchant" do
      it "returns a Hash with purchase, item, merchant, and customer attributes" do
        purchase = subject.send(:purchase)
        expect(purchase.class).to eq(Hash)
        expect(purchase[:price]).to eq(10.0)
        expect(purchase[:item_count]).to eq(5)
        expect(purchase.has_key?(:customer_attributes)).to be_true
        expect(purchase.has_key?(:item_attributes)).to be_true
        expect(purchase[:item_attributes].has_key?(:merchant_attributes)).to be_true
      end
    end
    context "existing customer" do
      it "excludes customer_attributes" do
        customer_amy
        purchase = subject.send(:purchase)
        expect(purchase.has_key?(:customer_attributes)).to be_false
        expect(purchase.has_key?(:item_attributes)).to be_true
        expect(purchase[:item_attributes].has_key?(:merchant_attributes)).to be_true
      end      
    end
    context "existing item" do
      it "excludes item_attributes" do
        item_awesome
        purchase = subject.send(:purchase)
        expect(purchase.has_key?(:customer_attributes)).to be_true
        expect(purchase.has_key?(:item_attributes)).to be_false
      end
    end
    context "existing merchant" do
      it "includes the merchant_id so we don't get a new merchant" do
        merchant_tom
        purchase = subject.send(:purchase)
        expect(purchase.has_key?(:customer_attributes)).to be_true
        expect(purchase.has_key?(:item_attributes)).to be_true
        expect(purchase[:item_attributes].has_key?(:merchant_attributes)).to be_true
        expect(purchase[:item_attributes][:merchant_attributes]["id"].present?).to be_true
      end
    end
  end
  
  describe '@revenue' do
    it 'should return the calculated revenue for the row' do
      expect(subject.revenue).to eq(50.0)
    end
  end  
end
