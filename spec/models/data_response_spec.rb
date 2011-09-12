require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do

  describe "associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:data_request) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:other_costs).dependent(:destroy) }
    it { should have_many(:implementer_splits).dependent(:destroy) }
    it { should have_many(:sub_activities).dependent(:destroy) } #TODO: deprecate
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:users_currently_completing) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "validations" do
    subject { basic_setup_response; @response }
    it { should validate_presence_of(:data_request_id) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_uniqueness_of(:data_request_id).scoped_to(:organization_id) }
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        basic_setup_response
        @commentable = @response
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches projects count" do
      basic_setup_response
      @response.projects_count.should == 0
      Factory.create(:project, :data_response => @response)
      @response.reload.projects_count.should == 1
    end

    it "caches activities count" do
      basic_setup_project
      @response.activities_count.should == 0
      Factory.create(:activity, :data_response => @response, :project => @project)
      @response.reload.activities_count.should == 1
    end

    it "caches sub activities count" do
      basic_setup_activity
      @response.sub_activities_count.should == 0
      @sub_activity = Factory(:sub_activity, :data_response => @response,
                              :activity => @activity, :provider => @organization)
      @response.reload.sub_activities_count.should == 1
    end
  end

  describe "searching for in-progress data responses" do
    it "should not be in progress on creation" do
      basic_setup_response
      DataResponse.in_progress.should_not include(@response)
    end

    it "should be in progress if it has a project" do
      basic_setup_project
      DataResponse.in_progress.should include(@response)
    end
  end

  describe 'Currency cache update' do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.5)
      Money.default_bank.add_rate(:EUR, :USD, 1.5)
      @organization = Factory(:organization, :currency => 'RWF')
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response,
                              :currency => nil)
      @activity     = Factory(:activity, :data_response => @response,
                              :project => @project)
      @sa           = Factory(:sub_activity, :activity => @activity, :data_response => @response,
                              :budget => 1000, :spend => 2000)
      @activity.reload
      @activity.save
    end

    it "should update cached USD amounts on Activity and Code Assignment" do
      @activity.budget_in_usd.should == 500
      @activity.spend_in_usd.should == 1000
      @organization.reload # dr.activities wont be updated otherwise
      @organization.currency = 'EUR'
      @organization.save
      @activity.reload
      @activity.budget_in_usd.should == 1500
      @activity.spend_in_usd.should == 3000
    end
  end

  describe "#name" do
    it "returns data_response name" do
      organization = Factory(:organization)
      request      = Factory(:data_request, :organization => organization,
                             :title => 'Data Request 1')
      response     = organization.latest_response

      response.name.should == 'Data Request 1'
    end
  end

  describe "#budget & #spend" do
    before :each do
      organization = Factory(:organization, :currency => 'USD')
      request      = Factory(:data_request, :organization => organization)
      @response    = organization.latest_response
    end

    context "same currency" do
      it "returns total" do
        project      = Factory(:project, :data_response => @response)
        @activity    = Factory(:activity, :data_response => @response, :project => project)
        @sa          = Factory(:sub_activity, :activity => @activity, :data_response => @response,
                               :budget => 200, :spend => 100)
        @oc1         = Factory(:other_cost, :data_response => @response, :project => project)
        @sa2         = Factory(:sub_activity, :activity => @oc1, :data_response => @response,
                               :budget => 200, :spend => 100)
        @oc2         = Factory(:other_cost, :data_response => @response)
        @sa          = Factory(:sub_activity, :activity => @oc2, :data_response => @response,
                               :budget => 200, :spend => 100)
        @activity.reload; @activity.save;
        @oc1.reload; @oc1.save;
        @oc2.reload; @oc2.save;
        @response.budget.to_f.should == 600
        @response.spend.to_f.should == 300
      end
    end

    context "different currency" do
      it "returns total" do
        Money.default_bank.add_rate(:RWF, :USD, 0.5)
        Money.default_bank.add_rate(:USD, :RWF,  2)
        project      = Factory(:project, :data_response => @response, :currency => 'RWF')
        @activity1 = Factory(:activity, :data_response => @response, :project => project)
        @sa1       = Factory(:sub_activity, :data_response => @response, :activity => @activity1,
                             :spend => 100, :budget => 200)
        @other_cost1 = Factory(:other_cost, :data_response => @response, :project => project)
        @sa2         = Factory(:sub_activity, :data_response => @response, :activity => @other_cost1,
                               :spend => 100, :budget => 200)
        @other_cost2 = Factory(:other_cost, :data_response => @response)
        @sa3         = Factory(:sub_activity, :data_response => @response, :activity => @other_cost2,
                               :spend => 100, :budget => 200)
        @activity1.reload; @activity1.save;
        @other_cost1.reload; @other_cost1.save;
        @other_cost2.reload; @other_cost2.save;
        @response.budget.to_f.should == 400 # 100 + 100 + 200
        @response.spend.to_f.should == 200 # 50 + 50 + 100
      end
    end
  end
end

        #Factory(:activity, :data_response => @response, :project => project,
                #:spend => 100, :budget => 200)
        #Factory(:other_cost, :data_response => @response, :project => project,
                #:spend => 100, :budget => 200)
        #Factory(:other_cost, :data_response => @response,
                #:spend => 100, :budget => 200)
        #@response.budget.to_f.should == 400 # 100 + 100 + 200
        #@response.spend.to_f.should == 200 # 50 + 50 + 100

# == Schema Information
#
# Table name: data_responses
#
#  id                                :integer         primary key
#  data_request_id                   :integer
#  complete                          :boolean         default(FALSE)
#  created_at                        :timestamp
#  updated_at                        :timestamp
#  organization_id                   :integer
#  currency                          :string(255)
#  fiscal_year_start_date            :date
#  fiscal_year_end_date              :date
#  contact_name                      :string(255)
#  contact_position                  :string(255)
#  contact_phone_number              :string(255)
#  contact_main_office_phone_number  :string(255)
#  contact_office_location           :string(255)
#  submitted                         :boolean
#  submitted_at                      :timestamp
#  projects_count                    :integer         default(0)
#  comments_count                    :integer         default(0)
#  activities_count                  :integer         default(0)
#  sub_activities_count              :integer         default(0)
#  activities_without_projects_count :integer         default(0)
#
