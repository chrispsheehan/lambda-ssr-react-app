const path = require('path');
const webpack = require('webpack');
const dotenv = require('dotenv');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

dotenv.config();

const watchOptions = {
  aggregateTimeout: 300, // Delay before rebuilding (in ms)
  poll: 1000, // Check for changes every second
  ignored: /node_modules/, // Ignore changes in node_modules
};

/**
 * Load JS, JSX, TS, and TSX files through Babel and TS Loader
 */
const babelLoader = {
  rules: [
    {
      test: /\.(js|jsx|ts|tsx)$/,
      exclude: /node_modules/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: [
            '@babel/preset-env',
            ['@babel/preset-react', { runtime: 'automatic' }],
            '@babel/preset-typescript'
          ]
        }
      }
    },
    {
      test: /\.scss$/,
      include: path.join(__dirname, 'assets/styles'),
      use: [
          MiniCssExtractPlugin.loader,
          {
              loader: 'css-loader',
              options: {
                  importLoaders: 2,
                  sourceMap: true
              }
          },
          'sass-loader',
          'postcss-loader'
      ],
    },
  ]
};

const resolve = {
  extensions: ['.js', '.jsx', '.ts', '.tsx']
};

const serverConfig = {
  target: 'node',
  mode: 'development', // change to production for production build
  entry: './src/server/server.tsx',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'server.cjs',
  },
  module: babelLoader,
  plugins: [
    // Remove the CopyWebpackPlugin that copies index.html here
  ],
  ignoreWarnings: [/Critical dependency: the request of a dependency is an expression/],
  resolve,
  watchOptions,
};

const clientConfig = {
  target: 'web',
  mode: 'development', // change to production for production build
  entry: './src/client/index.tsx',
  output: {
    path: path.join(__dirname, 'public/static'),
    publicPath: `/public/static`, // leading slash for resolves to the correct location regardless of the route
    filename: 'client.js',
  },
  module: babelLoader,
  plugins: [
    new HtmlWebpackPlugin({
      template: `${__dirname}/src/client/index.html`, // use the source HTML file
      filename: path.join(__dirname, 'dist', 'index.html'), // output to dist folder
      inject: 'body', // inject the client.js script at the end of the body tag
    }),
    new webpack.DefinePlugin({
      'process.env.STAGE': JSON.stringify(process.env.STAGE),
    }),
    new MiniCssExtractPlugin({
      filename: 'styles.css' // ensure this is a .css file
    }),
    new CopyWebpackPlugin({
      patterns: [
        { from: path.resolve(__dirname, 'assets'), to: path.join(__dirname, 'public/assets') }
      ]
    }),
  ],
  resolve,
  watchOptions,
};

module.exports = [serverConfig, clientConfig];
