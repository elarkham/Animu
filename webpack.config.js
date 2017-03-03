const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: "./web/static/js/index.js",

  output: {
    path: "./priv/static",
    filename: "js/app.js"
  },

  resolve: {
    modules: [ "node_modules", __dirname + "/web/static/js" ],
    extensions: ['.js', '.elm', '.scss']
  },

  module: {
    noParse: /\.elm$/,
    rules: [
      { test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            cwd: __dirname,
            warn: true,
          },
        }
      },
      { test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: ['css-loader', 'sass-loader']
        })
      }]
  },

  plugins: [
    new ExtractTextPlugin('css/main.css')
  ]
};
