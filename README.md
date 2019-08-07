# DB WORM

DB WORM, short for database websocket object relational mapping, is an
attempt to map a PostgreSQL database straight through to the browser
by using pure Coffeescript, JSON data and remote method invocation
over websockets.  This is a companion project to my ws_rmi (websocket
remote method invocation) project.

## db_orm

The general idea is that the database table definitions are
represented by subclasses of Table and Table_Row classes.  These
subclassess are generated automatically by the db_orm portion of the
project.  My goal is to abstract away the complexity of the process as
possible allowing the table definitions to resemble SQL definitions as
much as possible.

I'm using my
[Tickets-R-Us](https://github.com/alcarruth/fullstack-p3-item-catalog)
database to exercise this code.  I developed the tickets project using
a stack consisting of python, sql_alchemy, psycopg2 and flask.  It
worked well but I felt that a pure coffeescript approach might allow
for cleaner code.  I still do.  The code below is pure coffeescript
but reads much like an SQL table definition.  It's easy for the user
to write and it's easy (effortless, actually) for the db_orm code to
parse.


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

## db_rmi

The second half of the project is db_rmi which extends my ws_rmi
classes with db specific subclasses so that the table and table_row
classes created by db_orm are mapped to stub classes on the
client/browser side.  Calling a method in the browser invokes the
method in the server on corresponding remote object which is directly
mapped to the database.

At this point this basically sorta works !-) I've expanded the ws_rmi
code so that when a client first connects it has only an admin object
stub.  This admin object can then provide specifications for the
available table objects so that table stubs can be generated.  So far
so good, but there are some issues.

There are decisions to be made about caching, asynchrony (callback,
promises, async/await) and where table methods for reference and
back-reference columns are executed.  Many of these decisions are
application specific.

With the tickets app, for example, the conference and team tables, and
perhaps also the game table, will be loaded in the browser in their
entirety.  They are essentially static and are needed to render basic
pages in the browser.  The ticket_user, ticket_lot and ticket tables
are subject to change and, if cached should be understood by the
programmer to be possibly dirty and in need of refreshing or
verification from the database.

My ws_rmi code was originally developed using a callback model.  The
remote object was assumed to require a callback and so the stub
should as well.  For a simple example, the stack class definition
(in coffeescript) looks like this:

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

Ideally the ws_rmi implementation should be flexible with respect to the async style of the
remote object to make using it as easy as possible.

## Status

The code is still very much in flux since since the design is
unsettled and evolving as I learn more about problems inherent in the
achieving the goals of the project.  It's even fairly likely that when I'm
done I'll start over with a more informed design and redevelop the whole thing.

That said, I think the db_orm part is fairly settled but it has a number of
issues:

  - It is woefully short on comments
  - ditto for error handling
  - the SQL_Column class currently includes subclasses for SQL types
    - Integer
    - String
    - Date
    Adding others should be pretty easy, just a simple subclass for each type
  - Three pseudo columns work well:
    - Reference
    - Back Reference
    - Local Method which can handle arbitrary coffeescript definitions.
    I don't know much about ORM generally so development has been driven
    by the requirements of my tickets app, and these have been met.