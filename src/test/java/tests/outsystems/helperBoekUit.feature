Feature: Helper_class_boek_uit

  Background:
    *  url 'https://jsonplaceholder.typicode.com'


  Scenario: get todo List
    Given path 'todos/' + __arg.userId
    When method get
    Then status 200
    And print 'Helper Klasse response: Het boek is gelezen ' + response.completed
