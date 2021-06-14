@smoke
Feature: Demo voor oefenen

  Background:
    *  url 'https://jsonplaceholder.typicode.com'

  Scenario: Met users
    Given url 'https://jsonplaceholder.typicode.com/users/1'
    When method get
    Then status 200
    And print response
    And match response.name == 'Leanne Graham'

  Scenario: simple test
    Given path 'todos/1'
    When method get
    Then status 200
    # Match 1 per keer
    And match response.userId == 1
    And match response.id == 1
    And match response.title == 'delectus aut autem'
    # match alles ineens
    And match response == { "userId": 1,  "id": 1,  "title": "delectus aut autem",  "completed": false  }
    # Of met een variablele
    * def antwoord =
        """
     {
      "userId": 1,
      "id": 1,
      "title": "delectus aut autem",
      "completed": false
     }
        """
    And match response == antwoord

# Gebruik de eerste call om een variable op te halen en gebruik deze in een volgende call
  Scenario: simple test and a following extra call
    Given path 'todos'
    When method get
    Then status 200
    And print response
    * def id = response[0].userId

    #tweede call met de eerder gedeclareede variabele
    Given path 'todos/' + id
    When method get
    Then status 200
    And match response.title == "delectus aut autem"


  Scenario Outline: Making Loads of calls
    Given path 'users/' + <id>
    When method get
    Then status 200
    And match response.name == <name>
    And match response.company.name == <companyName>

    Examples:
      | id | name               | companyName          |
      | 1  | 'Leanne Graham'    | 'Romaguera-Crona'    |
      | 2  | 'Ervin Howell'     | 'Deckow-Crist'       |
      | 3  | 'Clementine Bauch' | 'Romaguera-Jacobson' |


#  Helper Features
  Scenario: helper_klasse
    Given path 'todos/1'
    When method get
    Then status 200
    * def json = response
#    And print response
    And call read('classpath:tests/outsystems/helperBoekUit.feature') json


#   Fuzzy assertions
  Scenario: Fuzzy matching
    Given path 'todos/1'
    When method get
    Then status 200
    And match response.userId == '#number'
    And match response.title == '#string'
    And match response.completed == '#boolean'

    # externe source gebruiken
  Scenario: test sources

    * def json =  read('classpath:tests/outsystems/users.json')
    And match json[0].id == 1

    Given path 'users/' + json[0].id
    When method get
    Then status 200
    And print response


#   commandline aftrappen



#   Laten zien van de report die wordt gemaakt na




  Scenario: Jsonpath
    Given def json =
"""
{
    "store": {
        "book": [
            {
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            },
            {
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            },
            {
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            },
            {
                "category": "fiction",
                "author": "J. R. R. Tolkien",
                "title": "The Lord of the Rings",
                "isbn": "0-395-19395-8",
                "price": 22.99
            }
        ],
        "bicycle": {
            "color": "red",
            "price": 19.95
        }
    },
    "expensive": 10
}

"""

    Then match json.store.book[2].title == "Moby Dick"

    Then match json.store.book[*] contains {"category":"reference","author":"Nigel Rees","title":"Sayings of the Century","price":8.95}

    Then match json.store.book[*].author contains "Nigel Rees"

    Then match json.store.book[*].author != 'Henk'

#   Itereer over een array and check global contents
    Then match each json.store.book  == { category: '#present', author: '#string', title: '#string', isbn: '#ignore', price: '#number' }

#   geef aan hoeveel entries in the array hebt
    Then match json.store.book == '#[4]'

#  Check dat een boek met een ISBN nummer een auteur J. R. R. Tolkien heeft
    Then match json.store.book[?(@.isbn)].author contains "J. R. R. Tolkien"

#   Select the prices of the book under 10 and check the values
    Then match json.store.book[?(@.price < 10)].price == [8.95 , 8.99]

  Scenario: XML kan ook
    Given def cat = <cat><name>Billie</name></cat>
    * set cat /cat/name = 'Jean'
    * match cat / == <cat><name>Jean</name></cat>


# you can even set whole fragments of xml
    * def xml = <foo><bar>baz</bar></foo>
    * set xml/foo/bar = <hello>world</hello>
    * match xml == <foo><bar><hello>world</hello></bar></foo>

  Scenario: XML Werkt net zo makkelijk
    Given def foo =
  """
  <records>
    <record index="1">a</record>
    <record index="2">b</record>
    <record index="3" foo="bar">c</record>
  </records>
  """

    * match foo count(/records//record) == 3
    * match foo //record[@index=2] == 'b'
    * match foo //record[@foo='bar'] == 'c'