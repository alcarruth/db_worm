# `db_worm`

Package `db_worm`, short for *database websocket object relational
mapping*, is a tool which maps PostgreSQL databases to server-side
objects and then on to browser side object stubs using pure
Coffeescript, JSON data and my companion project `ws_rmi` which
provides remote method invocation over websockets.

I'm using my
[Tickets-R-Us](https://github.com/alcarruth/fullstack-p3-item-catalog)
database to exercise this code.  I developed the tickets project using
a stack consisting of `python`, `sql_alchemy`, `psycopg2` and `flask`.
It worked well but I felt that I could do better using just
coffeescript, JSON and `ws_rmi`.  (I still do :-)

The implementation of `db_worm` is divided into two parts: `db_orm`
and `db_rmi` which handle, obviously enough, the object relational
mapping and the remote method invocation aspects, respectively.

## `db_orm`

The general idea is that the database table definitions are
represented by subclasses of `Table` and `Table_Row` classes.  These
subclassess are generated automatically by the `db_orm` portion of the
project.  My goal is to abstract away the complexity of the process
allowing the table definitions to resemble SQL definitions as much as
possible.

The code below is pure coffeescript but reads much like an SQL table
definition.  It's easy for the user to write and it's easy
(effortless, actually) for the db_orm code to parse.


```
table_defs  =
  
  conference:
    abbrev_name: string: { primary_key: true }
    name: string: {}
    logo: string: {}
    teams: back_reference: { table_name: 'team', col_name: 'conference_name' }

  team:
    id: integer: { primary_key: true }
    name: string: {} 
    nickname: string: {}
    logo: string: {}
    espn_id: integer: {}
    city: string: {}
    state: string: {}
    conference_name: string: {}
    conference: reference: { table_name: 'conference', col_name: 'conference_name' }
    home_games: back_reference: { table_name: 'game', col_name: 'home_team_id' }
    away_games: back_reference: { table_name: 'game', col_name: 'visiting_team_id' }
    full_name: local_method: { method: -> "#{@name()} #{@nickname()}" }
    games: local_method:
      method: ->
        away_games = (await @away_games())
        home_games = (await @home_games())
        games = away_games.concat(home_games)
        return games.sort(_by_('date'))

  game:
    id: integer: { primary_key: true }
    home_team_id: integer: {}
    visiting_team_id: integer: {}
    date: date: {}
    home_team: reference: {table_name: 'team', col_name: 'home_team_id'}
    visiting_team: reference: {table_name: 'team', col_name: 'visiting_team_id'}
    tickets: back_reference: {table_name: 'ticket_lot', col_name: 'game_id'}

  ticket_user:
    id: integer: { primary_key: true }
    name: string: {}
    email: string: {}
    picture: string: {}
    ticket_lots: back_reference: {table_name: 'ticket_lot', col_name: 'user_id'}
    
  ticket_lot:
    id: integer: { primary_key: true }
    user_id: integer: {}
    game_id: integer: {}
    section: string: {}
    row: string: {}
    price: string: {}
    img_path: string: {}
    seller: reference: {table_name: 'ticket_user', col_name: 'seller_id'}
    buyer: reference: {table_name: 'ticket_user', col_name: 'buyer_id'}
    game: reference: {table_name: 'game', col_name: 'game_id'}
    tickets: back_reference: {table_name: 'ticket', col_name: 'lot_id'}
    num_seats: local_method:
      method: ->
        (await @tickets()).length
    seats: local_method:
      method: ->
        ticket.seat() for ticket in (await tickets()).sort()

  ticket:
    id: string: { primary_key: true }
    lot_id: string: {}
    seat: string: {}
    lot: reference: { name_name: 'ticket_lot', col_name: 'lot_id' }

```

## `db_rmi`

The second half of the project is `db_rmi` which extends the `ws_rmi`
classes with db specific sub-classes so that the `Table` and
`Table_Row` classes created by `db_orm` are mapped to stub classes on
the client/browser side.  Calling a method in the browser invokes the
method in the server on the corresponding remote object on the server
side which is directly mapped to the database.

## Status

At this point this basically sorta works !-) I've expanded the
`ws_rmi` code so that when a client first connects the only object
stub it has available is an `admin` object stub.  The `admin` object
then provides specifications for the available `Table` objects so that
the appropriate `Table_Stubs` can be generated.  So far so good, but
there are decisions to be made about caching, asynchrony (callback,
promises, async/await) and where table methods for reference and
back-reference columns are executed.  Many of these decisions are
application specific and `db_worm` should provide a means for
specifying a particular choice.

### Table Row Caching

With the tickets app, for example, the `conference` and `team` tables,
(and perhaps also the `game` table), are essentially static and are
required by the browser to render the main pages, so they should be loaded
in their entirety when the document is loaded.  On the other hand, the
`ticket_user`, `ticket_lot` and `ticket` tables are subject to change
and if cached should be understood by the programmer to be possibly
dirty and in need of refreshing or verification from the database.

### Column Classes

The SQL_Columns are immediately available in the `Table_Row` object
and can be produced immediately by the stub, but handling reference,
back-reference and local_method columns requires a call to foreign
table object and/or a call to the object's methods and this raises
some questions:

 - Should these calls be handled at the level of the object stub
   *i.e.* calling a Table_Stub method?
 - or should they invoke a remote method which then provides the
   reference or local method functionality?
 - and can this question be resolved generally as one or the other
   possibilities?
 - or are there perhaps situations which variably require one or the
   other?

(Perhaps a diagram might make this clearer.  I don't have one yet :-)


The SQL_Column class currently includes subclasses for SQL types:

 - `Integer`
 - `String`
 - `Date`
 
Adding others should be pretty easy by just a simple subclass for each type.
Barring any difficulty I could perhaps just go down the list of SQL column
types and add classes like the ones I have already:

```
class SQL_Column extends Column

  constructor: (options) ->
    super(options)
    @sql_column = true
        
  __column_method: =>
    name = @col_name
    return () ->
      @__obj[name]

class SQL_String extends SQL_Column
class SQL_Integer extends SQL_Column
class SQL_Date extends SQL_Column

```
    
I refer to columns which are not simple SQL datatypes as *pseudo-columns*.
So far I have three pseudo-columns: 
    
#### Reference

A `Reference Column` contains a key value which refers to a foreign
table. Producing the data entails a call to the `find_by_id()` method
of the foreign table object.

#### Back_Reference

A `Back_Reference Column` contains a (table\_name, key\_name)
pair. Producing the data entails a call to the `find_where()` method
of the foreign table object.

#### Local_Method

The `Local_Method Column` allows for the inclusion of arbitrary
coffeescript/javascript code.  As an example the `team` definition has
two reference columns, `home_games()` and `away_games()`, and one
local method column which includes code to retrieve the home and away
games, concatenate the results and sort the array by the game dates.
So far I think this local method approach is suitable for short snippets
but to much code in the table distrubs the aesthetics of the otherwise clean
SQL style table definitions.  Arbitray methods can of course be added directly
to the code produced by `db_orm`

### Asynchrony Model

My ws_rmi code was originally developed using a callback model and the
remote object was assumed to require a callback argument which means
that the stub did as well.  For a simple example, the stack class
definition (in coffeescript) looks like this:

```
class Stack

  # note that the object must have an id in order to
  # register and operate with the rmi server
  #
  constructor: (@id) ->
    @stack = []

  push: (x, cb) =>
    @stack.push(x)
    console.log @stack
    cb(true)

  pop: (cb) =>
    cb( @stack.pop())
    console.log @stack


class Stack_Stub extends WS_RMI_Stub
  @add_stub('push')
  @add_stub('pop')
```

Ideally the `ws_rmi` implementation should be flexible with respect to
the async style of the remote object making it as easy as possible for
the programmer.  Unlike the stack example the `db_orm` uses promises,
so now would be a good time for me to have a look at re-implementing
`ws_rmi` using promises as well.


## To Do

The code is still very much in flux. The design is still unsettled and
evolving as I learn more about problems inherent in the goals of the
project.  It's even fairly likely that when I'm done I'll start over
with a more informed design and re-develop the whole thing.
That said, I think the db_orm part is fairly settled.
## Finally

The code is woefully short on comments and error handling.  Now that the 
design is beginning to settle I'll have a better idea of what to say
in my comments and error messages so I've got no excuse except to get
it done.
