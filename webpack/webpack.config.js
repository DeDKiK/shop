const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
  entry: "./src/index.tsx",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "..", "/build"),
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/index.html",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.(ts|js)x?$/,
        use: [
          {
            loader: "babel-loader",
          },
        ],
        exclude: /node_modules/,
      },
      {
        test: /\.css$/i,
        exclude: /\.module\.css$/,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.module\.css$/i,
        use: [
          "style-loader",
          {
            loader: "css-loader",
            options: { modules: true, esModule: false },
          },
        ],
      },
      {
        test: /\.(png|jpe?g|gif|svg|ico)$/i,
        type: "asset/resource",
      },
      {
        test: /\.json$/,
        type: "json",
      },
    ],
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js", ".css"],
    modules: [path.resolve(__dirname, "src"), "node_modules"],
  },
  devServer: {
    static: "./dist",
    historyApiFallback: true,
    port: 8080,
    hot: true,
  },
  mode: "development",
};
