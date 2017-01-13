Animu
=====

Video streaming webapp for watching, sharing and managing
media in a local network. This app serves as a “Hello World” for
introducing myself to new technologies and as such is never made with
the intention of use in a production system. This is the third iteration
using the phoenix frameowrk as the backend and elm-lang for the frontend.

Setup
=====

 * Install dependencies with `mix deps.get`
 * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
 * Populate the database with `mix run priv/repo/seeds.exs`
 * Install NPM and run `npm install`, this is for brunch+elm
 * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

###### Version 3.0.2
