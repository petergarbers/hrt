Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given an organization exists with name: "organization1"
    And a data_request exists with title: "data_request1"
    And an organization "my_organization" exists with name: "organization2"
    And a data_response should exist with data_request: the data_request, organization: organization "my_organization"
    And a reporter exists with email: "pink.panther@hrtapp.com", organization: organization "my_organization"
    And a project exists with name: "project1", budget: "20000", data_response: the data_response
    And a location exists with short_display: "Location1"
    And the location is one of the project's locations
    And a location exists with short_display: "Location2"
    And the location is one of the project's locations
    And I am signed in as "pink.panther@hrtapp.com"
    And I follow "Projects"

    @javascript 
    Scenario: Reporter can CRUD activities
      When I follow "Add activity"
        And I fill in "activity_name" with "activity1"
        And I fill in "activity_description" with "1ctivity1 description"
        And I press "activity_submit"
        Then wait a few moments
        And I fill in the activities budget field with "33" and spend field with "44" for that activity
        And I press "Save"
        Then I should see "Workplan was successfully saved"
      When I follow "1ctivity1 description"
        And I fill in "Name" with "activity2"
        And I fill in "Description" with "activity2 description"
        And I press "Save"
      Then I should see "Activity was successfully updated"
      When I follow "activity2"
        And I confirm the popup dialog
        And I follow "Delete this Activity"
      Then I should see "Activity was successfully destroyed"


    Scenario Outline: Reporter can CRUD activities and see errors
      Given I follow "Add activity"
        And I fill in "activity_name" with "activity1"
        And I fill in "activity_description" with "1ctivity1 description"
        And I press "activity_submit"
        Then wait a few moments
        And I fill in the activities budget field with "33" and spend field with "44" for that activity
        And I press "Save"
      When I follow "1ctivity1 description"
        And I fill in "Name" with "<name>"
        And I fill in "Description" with "activity description"
        And I fill in "Start date" with "<start_date>"
        And I fill in "End date" with "<end_date>"
        And I select "<project>" from "Project"
        And I press "Save"
      Then I should see "Oops, we couldn't save your changes."
        And I should see "<message>"

        Examples:
           | name | start_date | end_date   | project  | message                       |
           | a1   | 2011-01-01 | 2011-12-01 |          | Project can't be blank        |



    Scenario: A reporter can create comments for an activity
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
      When I follow "Projects"
       And I follow "Activity1 description"
       And I fill in "Title" with "Comment title"
       And I fill in "Comment" with "Comment body"
       And I press "Create Comment"
      Then I should see "Comment title"
       And I should see "Comment body"

    Scenario: A reporter can create comments for an activity and see comment errors
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
      When I follow "Projects"
        And I follow "Activity1 description"
        And I press "Create Comment"
        Then wait a few moments
        Then I should see "You cannot create blank comment"
        When I fill in "Title" with "Comment title"
      # TODO : restore this functionality
      #   And I press "Create Comment"
      # Then I should not see "You cannot create blank comment"
      #   And I should see "can't be blank" within "#comment_comment_input"
        
      When I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then I should see "Comment title"
        And I should see "Comment body"


    Scenario: Does not email users when a comment is made by a reporter
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
        And no emails have been sent
      When I follow "Projects"
        And I follow "Activity1 description"
        And I fill in "Comment" with "Comment body"
        And I fill in "Title" with "Comment title"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then "reporter_1@example.com" should not receive an email

    @javascript
    Scenario: A reporter can select implementer for an activity
      When I follow "Add activity"
        And I fill in "activity_name" with "activity1"
        And I fill in "activity_description" with "1ctivity1 description"
        And I press "activity_submit"
        Then wait a few moments
        And I fill in the activities budget field with "33" and spend field with "44" for that activity
        And I press "Save"
        And I follow "1ctivity1 description"
      # check if by default reporter organization is selected
      And I follow "Add Implementer"
      # Then I fill in "theCombobox" with "organization2"

      When I fill in "Name" with "Activity1"
        And I fill in "Description" with "Activity1 description"
        And I fill in "theCombobox" with "organization2"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-03-01"
        And I press "Save"
      Then I should see "Activity was successfully updated"

    @wip
    Scenario: A reporter can filter activities
      Given an activity exists with name: "activity2", description: "activity1 description", project: the project, data_response: the data_response
        And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response
      When I follow "Activities"
      Then I should see "activity1 description"
        And I should see "activity2 description"

      When I fill in "query" with "activity1"
        And I press "Search"
      Then I should see "activity1 description"
      And I should not see "activity2 description"

    @wip
    Scenario Outline: A reporter can sort activities
      Given an activity exists with name: "activity1", description: "activity1 description", project: the project, data_response: the data_response, spend: 1, budget: 1
        And a project exists with name: "project2", data_response: the data_response
        And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response, spend: 2, budget: 2
      When I follow "Activities"
        And I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text1>"
        And column "<column>" row "2" should have text "<text2>"

      When I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text2>"
        And column "<column>" row "2" should have text "<text1>"

        Examples:
            | column_name  | column | text1                 | text2                 |
            | Project      | 1      | project1              | project2              |
            | Description  | 2      | activity1 description | activity2 description |
            | Total Spent  | 3      | 1.0 RWF               | 2.0 RWF               |
            | Total Budget | 4      | 1.0 RWF               | 2.0 RWF               |

    @wip @javascript
    Scenario: A reporter can create funding sources (self funded) for an activity
      Given an organization "funding_organization1" exists with name: "funding_organization1"
        And a funding_flow exists with from: organization "funding_organization1", to: organization "my_organization", project: the project, data_response: the data_response
        And a funding_flow exists with from: organization "my_organization", to: organization "my_organization", project: the project, data_response: the data_response
        And an activity exists with name: "activity1", description: "activity1 description", budget: "33", spend: "44", project: the project, data_response: the data_response
        And I follow "Projects"
      # When I follow "Add activity"
      #   And I fill in "activity_name" with "activity1"
      #   And I fill in "activity_description" with "activity1 description"
      #   And I press "activity_submit"
      #   Then wait a few moments
      #   And I fill in the activities budget field with "33" and spend field with "44" for that activity
      #   And I press "Save"

      When I follow "activity1"
        And I follow "Add funding source"
        And I select "funding_organization1" from "Organization" within ".fields"
        And I fill in "Past Expenditure" with "111" within ".fields"
        And I fill in "Current Budget" with "222" within ".fields"

        And I press "Save"
      Then I should see "Activity was successfully updated"
            
            
      # TODO: combobox
      @javascript  @wip
      Scenario: A reporter can create funding sources for an activity
        Given an organization "funding_organization1" exists with name: "funding_organization1"
          And a funding_flow exists with from: organization "funding_organization1", to: organization "my_organization", project: the project, data_response: the data_response
          And an organization "funding_organization2" exists with name: "funding_organization2"
          And a funding_flow exists with from: organization "funding_organization2", to: organization "my_organization", project: the project, data_response: the data_response
        When I follow "Add activity"
          And I fill in "activity_name" with "Activity1"
          And I fill in "activity_description" with "Activity1 description"
          And I press "activity_submit"
          Then wait a few moments
          And I fill in the activities budget field with "33" and spend field with "44" for that activity
          And I press "Save"

        When I follow "Activity1 description"
          And I follow "Add funding source"
          And I select "funding_organization2" from "Organization" within ".fields"
          And I fill in "Expenditure" with "333" within ".fields"
          And I fill in "Budget" with "444" within ".fields"
          And I press "Save & Classify >"
        Then I should see "Activity was successfully updated"
    
    
    
    
    

    @wip
    Scenario: If the data_request has not got a budget or a past expenditure then only the save button should appear
      Given I follow "Sign Out"
      And a data_request "data_request10" exists with title: "THE DATA_REQUEST", spend: false, budget: false
      And a data_response "data_response10" exists with data_request: data_request "data_request10", organization: organization "my_organization"
      And a project exists with name: "project19", data_response: data_response "data_response10"
      And a activity exists with project: the project, name: "activity14", description: "act14desc"
      And I am signed in as "reporter"
      And I follow "THE DATA_REQUEST"
      And I follow "Projects"
      When I follow "Add" within ".sub-head:nth-child(2)"
        And I fill in "Name" with "activity1"
        And I fill in "Description" with "1ctivity1 description"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-12-01"
        And I select "project1" from "Project"
      Then I should see "Save" button
      And I should not see "Save & Classify >" button

		@wip
    Scenario: Reporter can download Implementers CSV template
      Given an activity exists with description: "activity1", project: the project, data_response: the data_response
      When I follow "Projects"
        And I follow "activity1"
        And I follow "Get Template" within "#sub_activities_upload_box"
      Then I should see "Implementer,Current Expenditure,Budget"


    Scenario: Reporter can see message when attached malformed CSV file for implementers
      Given an activity exists with description: "activity1", project: the project, data_response: the data_response
      When I follow "Projects"
        And I follow "activity1"
        And I attach the file "spec/fixtures/malformed.csv" to "File" within "#sub_activities_upload_box"
        And I press "Import" within "#sub_activities_upload_box"
      Then I should see "Your CSV file does not seem to be properly formatted."


    Scenario: Reporter can see message when no file attached for implementers
      Given an activity exists with description: "activity1", project: the project, data_response: the data_response
      When I follow "Projects"
        And I follow "activity1"
        And I press "Import" within "#sub_activities_upload_box"
        Then I should see "Please select a file to upload implementers."

		@wip
	  Scenario: Reporter can upload and change implementers
	    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
	    When I follow "Projects"
	      And I follow "activity1"
	      And I attach the file "spec/fixtures/implementers.csv" to "File" within "#sub_activities_upload_box"
	      And I press "Import" within "#sub_activities_upload_box"
	    Then I should see "Implementers were successfully uploaded."
	      And the "Sub-Activity Past Expenditure" field should contain "66"
	      And the "Sub-Activity Budget" field should contain "77"

	  @wip
	  Scenario: Reporter can upload and change implementers
	    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
	      And sub_activity exists with budget: 66, spend: 77, data_response: the data_response, activity: the activity, provider: the organization, id: 100
	    When I follow "Projects"
	      And I follow "activity1"
	      And I attach the file "spec/fixtures/implementers_update.csv" to "File" within "#sub_activities_upload_box"
	      And I press "Import" within "#sub_activities_upload_box"
	    Then I should see "Implementers were successfully uploaded."
	      And the "Sub-Activity Past Expenditure" field should contain "99"
	      And the "Sub-Activity Budget" field should contain "100"
