'use strict';

// SCSS Loader
require('../scss/main.scss')

// Elm Loader
let Elm = require('../elm/Main');

let token = localStorage.getItem('token');
let window = document.defaultView;

let flags =
  { token: token
  , window: { height: window.innerHeight
            , width: window.innerWidth
            }
  }

let app = Elm.Main.fullscreen(flags);

app.ports.store.subscribe(function(data){
  let [key, value] = data
  localStorage.setItem(key, value)
});

app.ports.removeFromStorage.subscribe(function(key){
  localStorage.removeItem(key)
});

