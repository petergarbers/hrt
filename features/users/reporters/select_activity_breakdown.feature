Feature: NGO/donor can enter a code breakdown for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down activities into individual codes

Background:
  Given a project with name "TB Treatment Project"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" 
  Given I am signed in as a reporter 

Scenario: See a breakdown for an activity
  When I go to the activities page
  And I follow "Classify"
  And I should see "TB Drugs procurement"
  #Then I should see "DEVELOPMENT OF SECTOR INSTITUTIONAL CAPACITY"

# http://www.pivotaltracker.com/story/show/4355865

Scenario: See both budget for an activity coding
  When I go to the activities page
  And I follow "Classify"
  Then I should be on the coding budget page for "TB Drugs procurement"
  And I should see "Budget"
  And I should see the "Budget" tab is active

Scenario: enter budget for an activity
  Given I am on the coding budget page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity budget was successfully updated."
  And I should be on the coding budget page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

Scenario: See both budget and expenditure for an activity coding
  When I go to the activities page
  And I follow "Classify"
  Then I should be on the coding budget page for "TB Drugs procurement"
  And I should see "Budget"
  And I should see "Expenditure"
  When I follow "Expenditure"
  Then I should be on the coding expenditure page for "TB Drugs procurement"
  And I should see the "Expenditure" tab is active

Scenario: enter expenditure for an activity
  Given I am on the coding expenditure page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity expenditure was successfully updated."
  And I should be on the coding expenditure page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

Scenario: Bug: enter budget for an activity, save, shown with xx,xxx.yy number formatting, save again, ensure number is not nerfed. 
  Given I am on the coding budget page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity budget was successfully updated."
  And I should be on the coding budget page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"
  And I press "Save"
  Then the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

@wip
Scenario: enter percentage for an activity budget coding
  Given I am on the coding budget page for "TB Drugs procurement"
  When I fill in "% for Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "100"
  And I press "Save"
  Then I should see "Activity budget was successfully updated."
  And I should be on the coding budget page for "TB Drugs procurement"
  And the "% for Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "100"
