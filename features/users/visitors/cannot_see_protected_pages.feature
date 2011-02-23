Feature: Visitors cannot see protected pages
  In order to protect information
  As a visitor
  I should not be able to see certain pages

@visitors @protected_pages @allow-rescue
Scenario Outline: Visit protected page, get redirected to login screen
  When I go to the <page> page
  Then I should see "You must be logged in to access this page"
  And I should be on the login page
  Examples:
    | page            |
    | projects        |
    | funding sources |
    | implementers    |
    | activities      |
    | classifications |
    | other costs     |
