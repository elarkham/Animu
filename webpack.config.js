module.exports = {
  entry: "./web/static/js/index.js",

  output: {
    path: "./priv/static/js",
    filename: "app.js"
  },

  resolve: {
    modules: [ "node_modules", __dirname + "/web/static/js" ],
    extensions: ['.js', '.elm']
  },

  module: {
    noParse: /\.elm$/,
    rules: [{
      test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            cwd: __dirname,
            warn: true,
          },
        }
      }],
  },

};
