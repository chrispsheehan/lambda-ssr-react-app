const path = require('path');
const webpack = require('webpack');
const dotenv = require('dotenv');
const htmlWebpackPlugin = require('html-webpack-plugin');
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
            ['@babel/preset-react', { 'runtime': 'automatic' }],
            '@babel/preset-typescript'
          ]
        }
      }
    }
  ]
};

const resolve = {
  extensions: ['.js', '.jsx', '.ts', '.tsx']
};

const serverConfig = {
  target: 'node',
  mode: 'development',
  entry: './src/server/server.tsx',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'server.cjs',
  },
  module: babelLoader,
  plugins: [
    new CopyWebpackPlugin({
      patterns: [
        { from: 'src/client/index.html', to: 'index.html' }
      ]
    }),
  ],
  ignoreWarnings: [/Critical dependency: the request of a dependency is an expression/],
  resolve,
  watchOptions,
};

const publicPath = process.env.CLIENT_PUBLIC_PATH;

const clientConfig = {
  target: 'web',
  mode: 'development',
  entry: './src/client/index.tsx',
  output: {
    path: path.join(__dirname, 'public/static'),
    publicPath: publicPath,
    filename: 'client.js',
  },
  module: babelLoader,
  plugins: [
    new htmlWebpackPlugin({
      template: `${__dirname}/src/client/index.html`
    }),
    new webpack.DefinePlugin({
      'process.env.STAGE': JSON.stringify(process.env.STAGE),
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
