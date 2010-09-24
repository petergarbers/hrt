class CodingBudgetCostCategorization < CodeAssignment

  def self.classified(activity)
    activity.budget == activity.send ("#{self}_amount")
  end

  def self.available_codes(activity = nil)
    CostCategory.roots
  end
end
