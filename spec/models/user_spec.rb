require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:organization) }
    it { should allow_mass_assignment_of(:roles) }
  end

  describe "Associations" do
    it { should have_many :comments }
    it { should have_many :data_responses }
    it { should belong_to :organization }
    it { should belong_to :current_response }
  end

  describe "Validations" do
    subject { Factory(:reporter, :organization => Factory(:organization) ) }
    it { should be_valid }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:roles) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe "Callbacks" do
    before :each do
      @dr1 = Factory(:data_response)
      @dr2 = Factory(:data_response)
      @organization = Factory(:organization, :data_responses => [@dr1, @dr2])
    end

    it "assigns current_response to last data_response from the organization" do
      user = Factory.build(:user, :organization => @organization, :current_response => nil)
      user.save
      user.current_response.should == @dr2
    end

    it "does not assign current_response if it already exists" do
      dr   = Factory(:data_response)
      user = Factory.build(:user, :organization => @organization, :current_response => dr)
      user.save
      user.current_response.should_not == @dr2
    end
  end

  describe "roles= can be assigned" do
    it "can assign 1 role" do
      user = Factory.create(:reporter)
      user.roles = ['admin']
      user.save
      user.reload.roles.should == ['admin']
    end

    it "can assign 3 roles" do
      user = Factory.create(:reporter)
      user.roles = ['admin', 'reporter', 'activity_manager']
      user.save
      user.reload.roles.should == ['admin', 'reporter', 'activity_manager']
    end

    it "cannot assign unexisting role" do
      user = Factory.create(:reporter)
      user.roles.should == ['reporter']
      user.roles = ['admin123']
      user.save
      user.valid?.should be_false
    end
  end

  describe "roles" do
    it "is admin when roles_mask is 1" do
      user = Factory.create(:sysadmin)
      user.admin?.should be_true
      user.roles_mask.should == 1
    end

    it "is reporter when roles_mask is 2" do
      user = Factory.create(:reporter)
      user.reporter?.should be_true
      user.roles_mask.should == 2
    end

    it "is activity_manager when roles_mask is 4" do
      user = Factory.create(:activity_manager)
      user.activity_manager?.should be_true
      user.roles_mask.should == 4
    end

    it "is admin and reporter when roles_mask = 3" do
      user = Factory.create(:user, :roles => ['admin', 'reporter'])
      user.roles.should == ['admin', 'reporter']
      user.roles_mask.should == 3
    end

    it "is admin and activity_manager when roles_mask = 5" do
      user = Factory.create(:user, :roles => ['admin', 'activity_manager'])
      user.roles.should == ['admin', 'activity_manager']
      user.roles_mask.should == 5
    end

    it "is reporter and activity_manager when roles_mask = 6" do
      user = Factory.create(:user, :roles => ['reporter', 'activity_manager'])
      user.roles.should == ['reporter', 'activity_manager']
      user.roles_mask.should == 6
    end

    it "is admin, reporter and activity_manager when roles_mask = 7" do
      user = Factory.create(:user, :roles => ['admin', 'reporter', 'activity_manager'])
      user.roles.should == ['admin', 'reporter', 'activity_manager']
      user.roles_mask.should == 7
    end
  end

  describe "name" do
    it "returns full_name if full name is present" do
      user = Factory.create(:reporter, :full_name => "Pink Panter")
      user.name.should == "Pink Panter"
    end

    it "returns email if full name is nil" do
      user = Factory.create(:reporter, :full_name => nil, :email => 'pink.panter@hrtapp.com')
      user.name.should == "pink.panter@hrtapp.com"
    end

    it "returns email if full name is blank string" do
      user = Factory.create(:reporter, :full_name => '', :email => 'pink.panter@hrtapp.com')
      user.name.should == "pink.panter@hrtapp.com"
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                       :integer         primary key
#  username                 :string(255)
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  created_at               :timestamp
#  updated_at               :timestamp
#  roles_mask               :integer
#  organization_id          :integer
#  data_response_id_current :integer
#  text_for_organization    :text
#  full_name                :string(255)
#  perishable_token         :string(255)     default(""), not null
#

