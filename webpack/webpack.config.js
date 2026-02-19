const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = (env, argv) => {
  const isProduction = argv.mode === "production";

  return {
    entry: "./src/index.tsx",
    output: {
      filename: "bundle.js",
      path: path.resolve(__dirname, "../dist"),
      publicPath: isProduction ? "./" : "/",
      clean: true,
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
      static: false,
      historyApiFallback: {
        index: "/index.html",
        disableDotRule: true,
      },
      port: 8080,
      hot: true,
      client: {
        overlay: true,
      },
      open: true,
      allowedHosts: "all",
    },
    mode: isProduction ? "production" : "development",
    devtool: isProduction ? false : "cheap-module-source-map",
  };
};
