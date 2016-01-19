exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        'js/util.js': /^(web\/static\/js\/util)|(node_modules\/phoenix(_html)?)/,
        'js/gald.js': /^(web\/static\/js\/gald)/,
        'js/lobby.js': /^(web\/static\/js\/lobby)/,
        'js/react.js': /^(node_modules\/react)/
      }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      // order: {
      //   before: [
      //     'web/static/vendor/js/jquery-2.1.1.js',
      //     'web/static/vendor/js/bootstrap.min.js'
      //   ]
      // }
    },
    stylesheets: {
      joinTo: 'css/app.css'
    },
    // templates: {
    //   joinTo: 'js/app.js'
    // }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to '/web/static/assets'. Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["web/static", "test/static"],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      presets: ["es2015", "react"],
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/gald.js": ["web/static/js/gald/main"],
      "js/lobby.js": ["web/static/js/lobby/main"]
    }
  },

  npm: {
    enabled: true,
    whitelist: ["phoenix", "phoenix_html", "react", "react-dom"]
  }
};
