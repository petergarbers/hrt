require File.dirname(__FILE__) + '/../../spec_helper'

describe OtherCost do

  describe "classified?" do
    before :each do
      @request  = Factory.create(:data_request, :title => 'Data Request 1')
      @response = Factory.create(:data_response, :data_request => @request)
      @project = Factory(:project, :data_response => @response)
      @activity = Factory(:other_cost)
    end

    it "is classified? when both budget and spend are classified with factories" do
      classify_the_other_cost # has side effects- overrides @activity in before :each
      @activity.coding_budget_classified?.should == true
      @activity.coding_budget_cc_classified?.should == true
      @activity.coding_budget_district_classified?.should == true
      @activity.service_level_budget_classified?.should == true
      @activity.budget_classified?.should == true
      @activity.coding_spend_classified?.should == true
      @activity.coding_spend_cc_classified?.should == true
      @activity.coding_spend_district_classified?.should == true
      @activity.service_level_spend_classified?.should == true
      @activity.spend_classified?.should == true
      @activity.classified?.should be_true
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    def currency
      project ? project.currency : data_response.currency
    end

    describe "currency" do
      it "returns data response currency if other cost without a project" do
        dr = Factory.create(:data_response, :currency => 'EUR')
        oc = Factory.create(:other_cost, :project => nil, :data_response => dr)
        oc.currency.should == 'EUR'
      end

      it "returns project currency if other cost has a project" do
        pr = Factory.create(:project, :currency => 'USD')
        oc = Factory.create(:other_cost, :project => pr)
        oc.currency.should == 'USD'
      end
    end
  end
end
