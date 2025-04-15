module.exports = {
  configureWebpack: {
    module: {
      rules: [
        {
          test: /\.csv$/,
          loader: 'csv-loader',
          options: {
            dynamicTyping: true,
            header: true,
            skipEmptyLines: true
          }
        }
      ]
    }
  },
  devServer: {
    client: {
      webSocketTransport: 'sockjs'  // Use sockjs instead of ws
    },
    webSocketServer: 'sockjs'  // Force sockjs
  },
  lintOnSave: false,
  pluginOptions: {
    lintOnBuild: false,
    stylelint: {}
  },
  publicPath:
    process.env.NODE_ENV === 'production' && process.env.REPO_NAME
      ? '/' +
        process.env.REPO_NAME +
        __dirname.substring(process.env.GITHUB_WORKSPACE.length)
      : '/'
};