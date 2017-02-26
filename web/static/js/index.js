'use strict';

// Elm Loader
let Elm = require('../elm/Main');

let token = localStorage.getItem('token');
let app = Elm.Main.fullscreen({token: token});

app.ports.store.subscribe(function(data){
  let [key, value] = data
  localStorage.setItem(key, value)
});

