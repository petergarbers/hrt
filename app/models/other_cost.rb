# == Schema Information
#
# Table name: activities
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  beneficiary        :string(255)
#  target             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  comments           :string(255)
#  expected_total     :decimal(, )
#  provider_id        :integer
#  other_cost_type_id :integer
#  description        :text
#  type               :string(255)
#  start_month        :string(255)
#  end_month          :string(255)
#  budget             :decimal(, )
#  spend_q1           :decimal(, )
#  spend_q2           :decimal(, )
#  spend_q3           :decimal(, )
#  spend_q4           :decimal(, )
#

class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  belongs_to :other_cost_type

  @@valid_root_types = [ Nha] #TODO change to right types
  def valid_roots_for_code_assignment
    @@valid_root_types = [ Nha] #TODO change to right types
    Code.roots.reject { |r| ! @@valid_root_types.include? r.class }
    #TODO add code so that non-root notes can start the top of the tree
  end
end
