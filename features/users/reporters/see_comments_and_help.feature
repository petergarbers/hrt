Feature: Reporter can see comments & help for a data response 
  In order to help reporters
  As a reporter
  I want to be able to see Comments/Questions and Help on the relevant pages

@green
Scenario Outline: See comments/help
  Given a basic org + reporter profile, with data response, signed in
  Given model help for "<page>" page
  When I go to the <page> page
  Then I should see "General Questions / Comments"
  And I should see "Help"
  And I should see "Field Definitions"
  Examples:
    | page             | 
    | projects         |
    | funding sources  |
    | implementers     |
    | activities       |
    | classifications  |
    | other costs      |
