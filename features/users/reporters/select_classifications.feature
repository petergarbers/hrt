Feature: NGO/donor can enter a classifications for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to see classifications for activities

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  Given a project with name "TB Treatment Project" and an existing response
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" and an existing response
  Given a refactor_me_please current_data_response for user "who_user"
  Given I am signed in as "who_user"

@green
Scenario: See a classification page for activities
  When I go to the classifications page
  Then I should see "WHO"
  And I should see "Budget by Coding"
  And I should see "Budget by District"
  And I should see "Budget by Cost Category"
  And I should see "Expenditure by Coding"
  And I should see "Expenditure by District"
  And I should see "Expenditure by Cost Category"
  And I should see "Classify"

@pending
Scenario: Classified budget by coding
Scenario: Classified budget by district
Scenario: Classified budget by cost category
Scenario: Classified expenditure by coding
Scenario: Classified expenditure by district
Scenario: Classified expenditure by cost category
